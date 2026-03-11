import Testing
import Foundation
@testable import NetworkingKit

@MainActor
struct NetworkManagerTests {

    @Test("Execute returns successful response")
    func test_whenExecuteSucceeds_thenReturnsResponse() async throws {
        let mockService = MockNetworkService(delay: 0)
        await mockService.register(
            path: "/api/test",
            response: .jsonString("{\"status\": \"ok\"}")
        )

        let manager = NetworkManager(service: mockService)
        let request = NetworkRequest.get("/api/test")

        let response = try await manager.execute(request)

        #expect(response.isSuccess)
        #expect(response.string() == "{\"status\": \"ok\"}")
    }

    @Test("Execute throws error on failure")
    func test_whenExecuteFails_thenThrowsError() async {
        let mockService = MockNetworkService(
            delay: 0,
            shouldError: true,
            errorToThrow: .noConnection
        )

        let manager = NetworkManager(service: mockService)
        let request = NetworkRequest.get("/api/test")

        await #expect(throws: NetworkError.self) {
            try await manager.execute(request)
        }
    }

    @Test("Execute with response type decodes correctly")
    func test_whenExecuteWithType_thenDecodesResponse() async throws {
        struct TestResponse: Decodable {
            let id: Int
            let name: String
        }

        let mockService = MockNetworkService(delay: 0)
        await mockService.register(
            path: "/api/user",
            response: .jsonString("{\"id\": 123, \"name\": \"John\"}")
        )

        let manager = NetworkManager(service: mockService)
        let request = NetworkRequest.get("/api/user")

        let result: TestResponse = try await manager.execute(request, responseType: TestResponse.self)

        #expect(result.id == 123)
        #expect(result.name == "John")
    }
}
