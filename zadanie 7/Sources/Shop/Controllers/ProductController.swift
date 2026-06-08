import Fluent
import Vapor

struct ProductController: RouteCollection {
    private let cache = RedisCache()

    func boot(routes: any RoutesBuilder) throws {
        let products = routes.grouped("products")
        products.get(use: index)
        products.get("create", use: createForm)
        products.post(use: create)
        products.group(":productID") { product in
            product.get(use: show)
            product.get("edit", use: editForm)
            product.post(use: update)
            product.post("delete", use: delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> View {
        let items: [ProductListItem]
        if let cached = try await cache.getProducts(req) {
            items = cached
        } else {
            let products = try await Product.query(on: req.db).with(\.$category).all()
            items = products.compactMap {
                ShopMappers.productListItem($0, categoryName: $0.category.name)
            }

            try await cache.setProducts(req, products: items)
        }

        return try await req.view.render("products/index", ProductIndexContext(products: items))
    }

    @Sendable
    func createForm(req: Request) async throws -> View {
        let categories = try await Category.query(on: req.db).all()
        let items = categories.compactMap(ShopMappers.categoryListItem)
        return try await req.view.render("products/create", ProductCreateContext(categories: items))
    }

    @Sendable
    func create(req: Request) async throws -> Response {
        let form = try req.content.decode(ProductForm.self)
        let product = Product(name: form.name, price: form.price, categoryID: form.categoryID)

        try await product.save(on: req.db)
        try await cache.invalidateProducts(req)
        try await cache.invalidateCategory(req, id: form.categoryID)

        return req.redirect(to: "/products")
    }

    @Sendable
    func show(req: Request) async throws -> View {
        guard let productID = req.parameters.get("productID", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        if let cached = try await cache.getProductDetail(req, id: productID) {
            return try await req.view.render(
                "products/show", ProductShowContext(product: cached.product))
        }

        let product = try await Product.query(on: req.db)
            .filter(\.$id == productID)
            .with(\.$category)
            .first()
        guard let product else {
            throw Abort(.notFound)
        }
        guard
            let productItem = ShopMappers.productListItem(
                product, categoryName: product.category.name)
        else {
            throw Abort(.internalServerError)
        }
        try await cache.setProductDetail(req, detail: ProductDetailDTO(product: productItem))

        return try await req.view.render("products/show", ProductShowContext(product: productItem))
    }

    @Sendable
    func editForm(req: Request) async throws -> View {
        guard let productID = req.parameters.get("productID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        let product = try await Product.query(on: req.db)
            .filter(\.$id == productID)
            .with(\.$category)
            .first()
        guard let product else {
            throw Abort(.notFound)
        }
        let categories = try await Category.query(on: req.db).all()

        guard
            let productItem = ShopMappers.productListItem(
                product, categoryName: product.category.name)
        else {
            throw Abort(.internalServerError)
        }

        let categoryItems = categories.compactMap(ShopMappers.categoryListItem)

        return try await req.view.render(
            "products/edit",
            ProductEditContext(
                product: productItem,
                categories: categoryItems
            ))
    }

    @Sendable
    func update(req: Request) async throws -> Response {
        guard let productID = req.parameters.get("productID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let product = try await Product.find(productID, on: req.db) else {
            throw Abort(.notFound)
        }
        let oldCategoryID = product.$category.id
        let form = try req.content.decode(ProductForm.self)
        product.name = form.name
        product.price = form.price
        product.$category.id = form.categoryID

        try await product.save(on: req.db)
        try await cache.invalidateProduct(req, id: productID)
        try await cache.invalidateCategory(req, id: oldCategoryID)
        try await cache.invalidateCategory(req, id: form.categoryID)

        return req.redirect(to: "/products/\(productID)")
    }

    @Sendable
    func delete(req: Request) async throws -> Response {
        guard let productID = req.parameters.get("productID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let product = try await Product.find(productID, on: req.db) else {
            throw Abort(.notFound)
        }
        let categoryID = product.$category.id

        try await product.delete(on: req.db)
        try await cache.invalidateProduct(req, id: productID)
        try await cache.invalidateCategory(req, id: categoryID)

        return req.redirect(to: "/products")
    }
}
