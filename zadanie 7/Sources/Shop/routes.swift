import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws -> Response in
        req.redirect(to: "/products")
    }

    try app.register(collection: CategoryController())
    try app.register(collection: ProductController())
    try app.register(collection: CartController())
    try app.register(collection: OrderController())
}
