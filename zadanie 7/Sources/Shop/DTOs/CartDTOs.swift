import Vapor

struct CartListDTO: Codable, Content {
    var productID: UUID
    var quantity: Int
}

struct CartListItem: Encodable {
    let productID: UUID
    let name: String
    let price: Double
    let priceFormatted: String
    let quantity: Int
    let subtotalFormatted: String
    var subtotal: Double { price * Double(quantity) }
}

struct CartIndexContext: Encodable {
    let cartItems: [CartListItem]
    let total: Double
    let totalFormatted: String
}

struct OrderItemsListItem: Codable {
    let productName: String
    let quantity: Int
    let price: Double
    let priceFormatted: String
    let subtotalFormatted: String
    var subtotal: Double { price * Double(quantity) }
}

struct CartForm: Content {
    var productID: UUID
    var quantity: Int
}
