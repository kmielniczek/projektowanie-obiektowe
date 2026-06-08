import Vapor

struct OrderListItem: Codable {
    let id: UUID
    let customerName: String
    let createdAt: String
    let total: Double
    let totalFormatted: String
}

struct OrderListDTO: Codable {
    let orders: [OrderListItem]
}

struct OrderDetailDTO: Codable {
    let order: OrderListItem
    let cartItems: [OrderItemsListItem]
    let total: Double
}

struct OrderIndexContext: Encodable {
    let orders: [OrderListItem]
}

struct OrderShowContext: Encodable {
    let order: OrderListItem
    let cartItems: [OrderItemsListItem]
    let total: Double
    let totalFormatted: String
}

struct OrderEditContext: Encodable {
    let id: UUID
    let customerName: String
}

struct OrderForm: Content {
    var customerName: String
}
