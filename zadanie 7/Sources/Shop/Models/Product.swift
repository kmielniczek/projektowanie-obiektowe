import Fluent
import Vapor

final class Product: Model, @unchecked Sendable {
    static let schema = "products"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "price")
    var price: Double

    @Parent(key: "category_id")
    var category: Category

    @Children(for: \.$product)
    var orderItems: [OrderItem]

    init() {}

    init(id: UUID? = nil, name: String, price: Double, categoryID: UUID) {
        self.id = id
        self.name = name
        self.price = price
        self.$category.id = categoryID
    }
}
