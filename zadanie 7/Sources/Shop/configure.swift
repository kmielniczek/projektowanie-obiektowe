import Fluent
import FluentSQLiteDriver
import Leaf
import Redis
import Vapor

public func configure(_ app: Application) async throws {
    app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)

    let redisHost = Environment.get("REDIS_HOST") ?? "localhost"
    let redisPort = Int(Environment.get("REDIS_PORT") ?? "6379") ?? 6379
    app.redis.configuration = try RedisConfiguration(
        hostname: redisHost,
        port: redisPort
    )
    app.sessions.use(.redis)

    app.middleware.use(app.sessions.middleware)

    app.migrations.add(CreateCategory())
    app.migrations.add(CreateProduct())
    app.migrations.add(CreateOrder())
    app.migrations.add(CreateOrderItem())
    app.migrations.add(SeedShop())

    try await app.autoMigrate()

    app.views.use(.leaf)

    try routes(app)
}
