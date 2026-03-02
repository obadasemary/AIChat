//
//  TaskExtensionTests.swift
//  AIChatTests
//

import Testing
@testable import AIChat

struct TaskExtensionTests {

    @Test func test_taskNoop_completesImmediately() async throws {
        try await Task<Void, Error>.noop.value
    }

    @Test func test_taskNoopNever_completesImmediately() async {
        await Task<Void, Never>.noop.value
    }

}
