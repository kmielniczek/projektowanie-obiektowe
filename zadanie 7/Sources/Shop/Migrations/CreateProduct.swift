import Fluent

struct CreateProduct: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Product.schema)
            .id()
            .field("name", .string, .required)
            .field("price", .double, .required)
            .field(
                "category_id", .uuid, .required,
                .references(Category.schema, "id", onDelete: .cascade)
            )
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Product.schema).delete()
    }
}
