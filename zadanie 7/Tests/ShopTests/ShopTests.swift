@testable import Shop
import VaporTesting
import Testing

@Suite("App Tests", .serialized)
struct ShopTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await test(app)
            try await app.autoRevert()
        } catch {
            try? await app.autoRevert()
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test("Root redirects to products")
    func rootRedirect() async throws {
        try await withApp { app in
            try await app.testing().test(.GET, "", afterResponse: { res async in
                #expect(res.status == .seeOther)
                #expect(res.headers.first(name: .location) == "/products")
            })
        }
    }

    @Test("Products page loads")
    func productsPage() async throws {
        try await withApp { app in
            try await app.testing().test(.GET, "products", afterResponse: { res async in
                #expect(res.status == .ok)
            })
        }
    }
}
