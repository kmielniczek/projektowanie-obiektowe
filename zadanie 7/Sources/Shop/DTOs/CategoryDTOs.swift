import Vapor

struct CategoryListItem: Codable {
    let id: UUID
    let name: String
}

struct CategoryListDTO: Codable {
    let categories: [CategoryListItem]
}

struct CategoryDetailDTO: Codable {
    let category: CategoryListItem
    let products: [ProductListItem]
}

struct CategoryIndexContext: Encodable {
    let categories: [CategoryListItem]
}

struct CategoryShowContext: Encodable {
    let category: CategoryListItem
    let products: [ProductListItem]
}

struct CategoryEditContext: Encodable {
    let category: CategoryListItem
}

struct CategoryForm: Content {
    var name: String
}
