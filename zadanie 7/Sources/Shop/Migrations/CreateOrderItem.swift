import Fluent

struct CreateOrderItem: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(OrderItem.schema)
            .id()
            .field("quantity", .int, .required)
            .field(
                "order_id", .uuid, .required,
                .references(Order.schema, "id", onDelete: .cascade)
            )
            .field(
                "product_id", .uuid, .required,
                .references(Product.schema, "id", onDelete: .cascade)
            )
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(OrderItem.schema).delete()
    }
}
