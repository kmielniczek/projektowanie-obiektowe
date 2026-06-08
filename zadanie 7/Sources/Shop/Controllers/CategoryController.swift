import Fluent
import Vapor

struct CategoryController: RouteCollection {
    private let cache = RedisCache()

    func boot(routes: any RoutesBuilder) throws {
        let categories = routes.grouped("categories")
        categories.get(use: index)
        categories.get("create", use: createForm)
        categories.post(use: create)
        categories.group(":categoryID") { category in
            category.get(use: show)
            category.get("edit", use: editForm)
            category.post(use: update)
            category.post("delete", use: delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> View {
        let items: [CategoryListItem]
        if let cached = try await cache.getCategories(req) {
            items = cached
        } else {
            let categories = try await Category.query(on: req.db).all()
            items = categories.compactMap(ShopMappers.categoryListItem)
            try await cache.setCategories(req, categories: items)
        }

        return try await req.view.render(
            "categories/index", CategoryIndexContext(categories: items))
    }

    @Sendable
    func createForm(req: Request) async throws -> View {
        try await req.view.render("categories/create")
    }

    @Sendable
    func create(req: Request) async throws -> Response {
        let form = try req.content.decode(CategoryForm.self)
        let category = Category(name: form.name)
        try await category.save(on: req.db)
        try await cache.invalidateCategories(req)
        return req.redirect(to: "/categories")
    }

    @Sendable
    func show(req: Request) async throws -> View {
        guard
            let categoryID = req.parameters.get("categoryID", as: UUID.self)
        else { throw Abort(.badRequest) }

        if let cached = try await cache.getCategoryDetail(req, id: categoryID) {
            return try await req.view.render(
                "categories/show",
                CategoryShowContext(
                    category: cached.category,
                    products: cached.products
                ))
        }

        guard
            let category = try await Category.find(categoryID, on: req.db)
        else { throw Abort(.notFound) }

        let products = try await Product.query(on: req.db)
            .filter(\.$category.$id == categoryID)
            .with(\.$category)
            .all()

        let productItems = products.compactMap {
            ShopMappers.productListItem($0, categoryName: $0.category.name)
        }

        guard
            let categoryItem = ShopMappers.categoryListItem(category)
        else { throw Abort(.internalServerError) }

        let detail = CategoryDetailDTO(category: categoryItem, products: productItems)
        try await cache.setCategoryDetail(req, detail: detail)

        return try await req.view.render(
            "categories/show",
            CategoryShowContext(
                category: categoryItem,
                products: productItems
            ))
    }

    @Sendable
    func editForm(req: Request) async throws -> View {
        guard let categoryID = req.parameters.get("categoryID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let category = try await Category.find(categoryID, on: req.db) else {
            throw Abort(.notFound)
        }
        guard let categoryItem = ShopMappers.categoryListItem(category) else {
            throw Abort(.internalServerError)
        }
        return try await req.view.render(
            "categories/edit", CategoryEditContext(category: categoryItem))
    }

    @Sendable
    func update(req: Request) async throws -> Response {
        guard let categoryID = req.parameters.get("categoryID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let category = try await Category.find(categoryID, on: req.db) else {
            throw Abort(.notFound)
        }
        let form = try req.content.decode(CategoryForm.self)
        category.name = form.name
        try await category.save(on: req.db)
        try await cache.invalidateCategory(req, id: categoryID)
        return req.redirect(to: "/categories/\(categoryID)")
    }

    @Sendable
    func delete(req: Request) async throws -> Response {
        guard let categoryID = req.parameters.get("categoryID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let category = try await Category.find(categoryID, on: req.db) else {
            throw Abort(.notFound)
        }
        try await category.delete(on: req.db)
        try await cache.invalidateCategory(req, id: categoryID)
        try await cache.invalidateProducts(req)
        return req.redirect(to: "/categories")
    }
}
