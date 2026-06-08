import Fluent

struct SeedShop: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let existing = try await Category.query(on: database).count()
        guard existing == 0 else { return }

        let electronics = Category(name: "Electronics")
        let books = Category(name: "Books")
        try await electronics.save(on: database)
        try await books.save(on: database)

        guard let electronicsID = electronics.id, let booksID = books.id else { return }

        let laptop = Product(name: "Laptop", price: 3999.99, categoryID: electronicsID)
        let mouse = Product(name: "Mouse", price: 99.99, categoryID: electronicsID)
        let novel = Product(name: "Swift Programming", price: 49.99, categoryID: booksID)
        try await laptop.save(on: database)
        try await mouse.save(on: database)
        try await novel.save(on: database)
    }

    func revert(on database: any Database) async throws {
        try await OrderItem.query(on: database).delete()
        try await Order.query(on: database).delete()
        try await Product.query(on: database).delete()
        try await Category.query(on: database).delete()
    }
}
