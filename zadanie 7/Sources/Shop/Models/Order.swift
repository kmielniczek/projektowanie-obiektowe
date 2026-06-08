import Fluent
import Vapor

final class Order: Model, @unchecked Sendable {
    static let schema = "orders"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "customer_name")
    var customerName: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Children(for: \.$order)
    var orderItems: [OrderItem]

    init() {}

    init(id: UUID? = nil, customerName: String) {
        self.id = id
        self.customerName = customerName
    }
}
