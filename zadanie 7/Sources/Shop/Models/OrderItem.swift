import Fluent
import Vapor

final class OrderItem: Model, @unchecked Sendable {
    static let schema = "order_items"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "quantity")
    var quantity: Int

    @Parent(key: "order_id")
    var order: Order

    @Parent(key: "product_id")
    var product: Product

    init() {}

    init(id: UUID? = nil, quantity: Int, orderID: UUID, productID: UUID) {
        self.id = id
        self.quantity = quantity
        self.$order.id = orderID
        self.$product.id = productID
    }
}
