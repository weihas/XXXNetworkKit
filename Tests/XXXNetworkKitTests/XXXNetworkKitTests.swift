import Testing
@testable import XXXNetworkModel
@testable import XXXNetworkKit

@Suite
struct UserTest {
    
    @Test
    func scopes() async throws {
        
        struct Scope: Codable {
            let scopes: [String]
            let openid: String?
        }
        
        let result = try await XXXAPIProvider.shared.request(XXXAPI.User.scopes, to: Scope.self)
        #expect(!result.scopes.isEmpty)
        #expect(result.openid != nil)
    }
    
    @Test
    func info() async throws {
        let user = try await XXXAPIProvider.shared.request(XXXAPI.User.info, to: User.self)
        #expect(user.openid != nil)
    }


    @Test
    func union_id() async throws {
        let result = try await XXXAPIProvider.shared.request(XXXAPI.User.union_id)
        #expect(result["union_id"].string != nil)
    }
}
