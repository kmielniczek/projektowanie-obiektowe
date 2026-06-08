import Vapor

struct CartService {
    private let cartKey = "cart"

    func getItems(_ req: Request) throws -> [CartListDTO] {
        guard let json = req.session.data[cartKey],
            let data = json.data(using: .utf8)
        else {
            return []
        }
        return try JSONDecoder().decode([CartListDTO].self, from: data)
    }

    func saveItems(_ req: Request, items: [CartListDTO]) throws {
        if items.isEmpty {
            req.session.data[cartKey] = nil
        } else {
            let data = try JSONEncoder().encode(items)
            req.session.data[cartKey] = String(decoding: data, as: UTF8.self)
        }
    }

    func addProduct(_ req: Request, productID: UUID) async throws {
        var items = try getItems(req)
        if let index = items.firstIndex(where: { $0.productID == productID }) {
            items[index].quantity += 1
        } else {
            items.append(CartListDTO(productID: productID, quantity: 1))
        }
        try saveItems(req, items: items)
    }

    func updateQuantity(_ req: Request, productID: UUID, quantity: Int) throws {
        var items = try getItems(req)
        guard let index = items.firstIndex(where: { $0.productID == productID }) else {
            throw Abort(.notFound, reason: "Product not in cart")
        }
        if quantity <= 0 {
            items.remove(at: index)
        } else {
            items[index].quantity = quantity
        }
        try saveItems(req, items: items)
    }

    func removeProduct(_ req: Request, productID: UUID) throws {
        var items = try getItems(req)
        items.removeAll { $0.productID == productID }
        try saveItems(req, items: items)
    }

    func clear(_ req: Request) throws {
        try saveItems(req, items: [])
    }

    func buildCartViews(_ req: Request) async throws -> [CartListItem] {
        let items = try getItems(req)
        var views: [CartListItem] = []
        for item in items {
            guard let product = try await Product.find(item.productID, on: req.db) else {
                continue
            }
            views.append(
                CartListItem(
                    productID: item.productID,
                    name: product.name,
                    price: product.price,
                    priceFormatted: ShopFormatters.formatPrice(product.price),
                    quantity: item.quantity,
                    subtotalFormatted: ShopFormatters.formatPrice(
                        product.price * Double(item.quantity))
                ))
        }
        return views
    }
}
