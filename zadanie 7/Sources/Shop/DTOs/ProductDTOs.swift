import Vapor

struct ProductListItem: Codable {
    let id: UUID
    let name: String
    let price: Double
    let priceFormatted: String
    let categoryName: String
    let categoryID: UUID
}

struct ProductListDTO: Codable {
    let products: [ProductListItem]
}

struct ProductDetailDTO: Codable {
    let product: ProductListItem
}

struct ProductIndexContext: Encodable {
    let products: [ProductListItem]
}

struct ProductShowContext: Encodable {
    let product: ProductListItem
}

struct ProductEditContext: Encodable {
    let product: ProductListItem
    let categories: [CategoryListItem]
}

struct ProductCreateContext: Encodable {
    let categories: [CategoryListItem]
}

struct ProductForm: Content {
    var name: String
    var price: Double
    var categoryID: UUID
}
