import Redis
import Vapor

struct RedisCache {
    private static let ttlSeconds = 300

    func invalidateCategories(_ req: Request) async throws {
        _ = try await req.redis.delete(RedisKey("categories:all")).get()
    }

    func invalidateCategory(_ req: Request, id: UUID) async throws {
        _ = try await req.redis.delete(RedisKey("category:\(id.uuidString)")).get()
        try await invalidateCategories(req)
    }

    func invalidateProducts(_ req: Request) async throws {
        _ = try await req.redis.delete(RedisKey("products:all")).get()
    }

    func invalidateProduct(_ req: Request, id: UUID) async throws {
        _ = try await req.redis.delete(RedisKey("product:\(id.uuidString)")).get()
        try await invalidateProducts(req)
    }

    func invalidateOrders(_ req: Request) async throws {
        _ = try await req.redis.delete(RedisKey("orders:all")).get()
    }

    func invalidateOrder(_ req: Request, id: UUID) async throws {
        _ = try await req.redis.delete(RedisKey("order:\(id.uuidString)")).get()
        try await invalidateOrders(req)
    }

    func getCategories(_ req: Request) async throws -> [CategoryListItem]? {
        try await req.redis.get(RedisKey("categories:all"), asJSON: CategoryListDTO.self)?
            .categories
    }

    func setCategories(_ req: Request, categories: [CategoryListItem]) async throws {
        try await req.redis.setex(
            RedisKey("categories:all"),
            toJSON: CategoryListDTO(categories: categories),
            expirationInSeconds: Self.ttlSeconds
        )
    }

    func getCategoryDetail(_ req: Request, id: UUID) async throws -> CategoryDetailDTO? {
        try await req.redis.get(
            RedisKey("category:\(id.uuidString)"), asJSON: CategoryDetailDTO.self)
    }

    func setCategoryDetail(_ req: Request, detail: CategoryDetailDTO) async throws {
        try await req.redis.setex(
            RedisKey("category:\(detail.category.id.uuidString)"),
            toJSON: detail,
            expirationInSeconds: Self.ttlSeconds
        )
    }

    func getProducts(_ req: Request) async throws -> [ProductListItem]? {
        try await req.redis.get(RedisKey("products:all"), asJSON: ProductListDTO.self)?.products
    }

    func setProducts(_ req: Request, products: [ProductListItem]) async throws {
        try await req.redis.setex(
            RedisKey("products:all"),
            toJSON: ProductListDTO(products: products),
            expirationInSeconds: Self.ttlSeconds
        )
    }

    func getProductDetail(_ req: Request, id: UUID) async throws -> ProductDetailDTO? {
        try await req.redis.get(RedisKey("product:\(id.uuidString)"), asJSON: ProductDetailDTO.self)
    }

    func setProductDetail(_ req: Request, detail: ProductDetailDTO) async throws {
        try await req.redis.setex(
            RedisKey("product:\(detail.product.id.uuidString)"),
            toJSON: detail,
            expirationInSeconds: Self.ttlSeconds
        )
    }

    func getOrders(_ req: Request) async throws -> [OrderListItem]? {
        try await req.redis.get(RedisKey("orders:all"), asJSON: OrderListDTO.self)?.orders
    }

    func setOrders(_ req: Request, orders: [OrderListItem]) async throws {
        try await req.redis.setex(
            RedisKey("orders:all"),
            toJSON: OrderListDTO(orders: orders),
            expirationInSeconds: Self.ttlSeconds
        )
    }

    func getOrderDetail(_ req: Request, id: UUID) async throws -> OrderDetailDTO? {
        try await req.redis.get(RedisKey("order:\(id.uuidString)"), asJSON: OrderDetailDTO.self)
    }

    func setOrderDetail(_ req: Request, detail: OrderDetailDTO) async throws {
        try await req.redis.setex(
            RedisKey("order:\(detail.order.id.uuidString)"),
            toJSON: detail,
            expirationInSeconds: Self.ttlSeconds
        )
    }
}

enum ShopFormatters {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    static func formatPrice(_ value: Double) -> String {
        String(format: "%.2f", value)
    }

    static func formatDate(_ date: Date?) -> String {
        guard let date else { return "-" }
        return dateFormatter.string(from: date)
    }
}

enum ShopMappers {
    static func categoryListItem(_ category: Category) -> CategoryListItem? {
        guard let id = category.id else { return nil }
        return CategoryListItem(id: id, name: category.name)
    }

    static func productListItem(_ product: Product, categoryName: String) -> ProductListItem? {
        guard let id = product.id else { return nil }
        return ProductListItem(
            id: id,
            name: product.name,
            price: product.price,
            priceFormatted: ShopFormatters.formatPrice(product.price),
            categoryName: categoryName,
            categoryID: product.$category.id
        )
    }

    static func orderListItem(_ order: Order, total: Double) -> OrderListItem? {
        guard let id = order.id else { return nil }
        return OrderListItem(
            id: id,
            customerName: order.customerName,
            createdAt: ShopFormatters.formatDate(order.createdAt),
            total: total,
            totalFormatted: ShopFormatters.formatPrice(total)
        )
    }

    static func orderTotal(_ items: [OrderItem]) -> Double {
        items.reduce(0) { partial, item in
            partial + (item.product.price * Double(item.quantity))
        }
    }

    static func orderListItem(_ item: OrderItem) -> OrderItemsListItem {
        OrderItemsListItem(
            productName: item.product.name,
            quantity: item.quantity,
            price: item.product.price,
            priceFormatted: ShopFormatters.formatPrice(item.product.price),
            subtotalFormatted: ShopFormatters.formatPrice(
                item.product.price * Double(item.quantity))
        )
    }

    static func orderDetail(_ order: Order) -> OrderDetailDTO? {
        guard let listItem = orderListItem(order, total: orderTotal(order.orderItems)) else {
            return nil
        }
        let cartItems = order.orderItems.map(orderListItem)
        return OrderDetailDTO(order: listItem, cartItems: cartItems, total: listItem.total)
    }
}
