import Fluent

struct CreateOrder: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Order.schema)
            .id()
            .field("customer_name", .string, .required)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Order.schema).delete()
    }
}
