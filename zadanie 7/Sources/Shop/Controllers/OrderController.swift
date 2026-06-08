import Fluent
import Vapor

struct OrderController: RouteCollection {
    private let cache = RedisCache()

    func boot(routes: any RoutesBuilder) throws {
        let orders = routes.grouped("orders")
        orders.get(use: index)
        orders.group(":orderID") { order in
            order.get(use: show)
            order.get("edit", use: editForm)
            order.post(use: update)
            order.post("delete", use: delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> View {
        let items: [OrderListItem]
        if let cached = try await cache.getOrders(req) {
            items = cached
        } else {
            let orders = try await Order.query(on: req.db)
                .with(\.$orderItems) { items in
                    items.with(\.$product)
                }
                .sort(\.$createdAt, .descending)
                .all()

            items = orders.compactMap { order in
                ShopMappers.orderListItem(order, total: ShopMappers.orderTotal(order.orderItems))
            }
            try await cache.setOrders(req, orders: items)
        }

        return try await req.view.render("orders/index", OrderIndexContext(orders: items))
    }

    @Sendable
    func show(req: Request) async throws -> View {
        guard let orderID = req.parameters.get("orderID", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        if let cached = try await cache.getOrderDetail(req, id: orderID) {
            return try await req.view.render(
                "orders/show",
                OrderShowContext(
                    order: cached.order,
                    cartItems: cached.cartItems,
                    total: cached.total,
                    totalFormatted: ShopFormatters.formatPrice(cached.total)
                ))
        }

        let order = try await Order.query(on: req.db)
            .filter(\.$id == orderID)
            .with(\.$orderItems) { items in
                items.with(\.$product)
            }
            .first()

        guard let order else {
            throw Abort(.notFound)
        }
        guard let detail = ShopMappers.orderDetail(order) else {
            throw Abort(.internalServerError)
        }
        try await cache.setOrderDetail(req, detail: detail)

        return try await req.view.render(
            "orders/show",
            OrderShowContext(
                order: detail.order,
                cartItems: detail.cartItems,
                total: detail.total,
                totalFormatted: ShopFormatters.formatPrice(detail.total)
            ))
    }

    @Sendable
    func editForm(req: Request) async throws -> View {
        guard let orderID = req.parameters.get("orderID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let order = try await Order.find(orderID, on: req.db) else {
            throw Abort(.notFound)
        }

        return try await req.view.render(
            "orders/edit",
            OrderEditContext(
                id: orderID,
                customerName: order.customerName
            ))
    }

    @Sendable
    func update(req: Request) async throws -> Response {
        guard let orderID = req.parameters.get("orderID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let order = try await Order.find(orderID, on: req.db) else {
            throw Abort(.notFound)
        }

        let form = try req.content.decode(OrderForm.self)
        let trimmedName = form.customerName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw Abort(.badRequest, reason: "Customer name is required")
        }

        order.customerName = trimmedName
        try await order.save(on: req.db)
        try await cache.invalidateOrder(req, id: orderID)

        return req.redirect(to: "/orders/\(orderID)")
    }

    @Sendable
    func delete(req: Request) async throws -> Response {
        guard let orderID = req.parameters.get("orderID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let order = try await Order.find(orderID, on: req.db) else {
            throw Abort(.notFound)
        }

        try await order.delete(on: req.db)
        try await cache.invalidateOrder(req, id: orderID)

        return req.redirect(to: "/orders")
    }
}
