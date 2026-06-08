import Fluent
import Vapor

struct CartController: RouteCollection {
    private let cart = CartService()
    private let cache = RedisCache()

    func boot(routes: any RoutesBuilder) throws {
        let cartRoutes = routes.grouped("cart")
        cartRoutes.get(use: index)
        cartRoutes.post("add", ":productID", use: add)
        cartRoutes.post("update", use: update)
        cartRoutes.post("remove", ":productID", use: remove)
        cartRoutes.post("place", use: place)
    }

    @Sendable
    func index(req: Request) async throws -> View {
        let cartItems = try await cart.buildCartViews(req)
        let total = cartItems.reduce(0) { $0 + $1.subtotal }
        return try await req.view.render(
            "cart/index",
            CartIndexContext(
                cartItems: cartItems,
                total: total,
                totalFormatted: ShopFormatters.formatPrice(total)
            ))
    }

    @Sendable
    func add(req: Request) async throws -> Response {
        guard
            let productID = req.parameters.get("productID", as: UUID.self)
        else { throw Abort(.badRequest) }

        guard
            try await Product.find(productID, on: req.db) != nil
        else { throw Abort(.notFound) }

        try await cart.addProduct(req, productID: productID)
        return req.redirect(to: "/cart")
    }

    @Sendable
    func update(req: Request) async throws -> Response {
        let form = try req.content.decode(CartForm.self)
        try cart.updateQuantity(req, productID: form.productID, quantity: form.quantity)
        return req.redirect(to: "/cart")
    }

    @Sendable
    func remove(req: Request) async throws -> Response {
        guard
            let productID = req.parameters.get("productID", as: UUID.self)
        else { throw Abort(.badRequest) }

        try cart.removeProduct(req, productID: productID)
        return req.redirect(to: "/cart")
    }

    @Sendable
    func place(req: Request) async throws -> Response {
        let form = try req.content.decode(OrderForm.self)
        let trimmedName = form.customerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw Abort(.badRequest, reason: "Customer name is required")
        }

        let items = try cart.getItems(req)
        guard !items.isEmpty else {
            throw Abort(.badRequest, reason: "Cart is empty")
        }

        let order = Order(customerName: trimmedName)
        try await order.save(on: req.db)

        guard let orderID = order.id else { throw Abort(.internalServerError) }

        for item in items {
            guard
                try await Product.find(item.productID, on: req.db) != nil
            else { continue }

            let orderItem = OrderItem(
                quantity: item.quantity,
                orderID: orderID,
                productID: item.productID
            )

            try await orderItem.save(on: req.db)
        }

        try cart.clear(req)
        try await cache.invalidateOrders(req)

        return req.redirect(to: "/orders/\(orderID)")
    }
}
