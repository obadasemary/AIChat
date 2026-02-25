//
//  PurchaseManagerTests.swift
//  AIChatTests
//
//  Created by Claude on 22.02.2026.
//

import Testing
import Foundation
@testable import AIChat

struct PurchaseManagerTests {

    // MARK: - Initialization

    @Test("Init with no entitlements - entitlements is empty")
    func test_init_withNoEntitlements_entitlementsIsEmpty() async {
        let service = MockPurchaseService(activeEntitlements: [])
        let manager = await PurchaseManager(service: service)

        // Allow the configure() Task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        await #expect(manager.entitlements.isEmpty)
    }

    @Test("Init with active entitlements - entitlements are populated")
    func test_init_withActiveEntitlements_entitlementsPopulated() async {
        let entitlement = PurchasedEntitlement.mock
        let service = MockPurchaseService(activeEntitlements: [entitlement])
        let manager = await PurchaseManager(service: service)

        // Poll until configure()'s unstructured Task completes
        var entitlements: [PurchasedEntitlement] = []
        for _ in 0..<20 {
            try? await Task.sleep(nanoseconds: 50_000_000)
            entitlements = await manager.entitlements
            if !entitlements.isEmpty { break }
        }

        #expect(entitlements.isEmpty == false)
    }

    // MARK: - getProducts

    @Test("Get Products Success - returns filtered products and tracks events")
    func test_getProducts_success_returnsProductsAndTracksEvents() async throws {
        let mockLogService = MockLogService()
        let logManager = await LogManager(services: [mockLogService])
        let service = MockPurchaseService()
        let manager = await PurchaseManager(service: service, logManager: logManager)

        let productIds = [AnyProduct.mockYearly.id]
        let products = try await manager.getProducts(productIds: productIds)

        #expect(products.count == 1)
        #expect(products.first?.id == AnyProduct.mockYearly.id)
        #expect(mockLogService.trackedEvents.contains { $0.eventName == "PurMan_GetProducts_Start" })
        #expect(mockLogService.trackedEvents.contains { $0.eventName == "PurMan_GetProducts_Success" })
    }

    @Test("Get Products Failure - throws error and tracks fail event")
    func test_getProducts_failure_tracksFailEvent() async {
        let mockLogService = MockLogService()
        let logManager = await LogManager(services: [mockLogService])
        let service = MockFailingPurchaseService()
        let manager = await PurchaseManager(service: service, logManager: logManager)

        do {
            _ = try await manager.getProducts(productIds: ["any.id"])
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(mockLogService.trackedEvents.contains { $0.eventName == "PurMan_GetProducts_Fail" })
        }
    }

    // MARK: - purchaseProduct

    @Test("Purchase Product Success - returns entitlements and tracks events")
    func test_purchaseProduct_success_returnsEntitlementsAndTracksEvents() async throws {
        let entitlement = PurchasedEntitlement.mock
        let mockLogService = MockLogService()
        let logManager = await LogManager(services: [mockLogService])
        let service = MockPurchaseService(activeEntitlements: [entitlement])
        let manager = await PurchaseManager(service: service, logManager: logManager)

        let result = try await manager.purchaseProduct(productId: entitlement.productId)

        #expect(result.isEmpty == false)
        #expect(mockLogService.trackedEvents.contains { $0.eventName == "PurMan_Purchase_Start" })
        #expect(mockLogService.trackedEvents.contains { $0.eventName == "PurMan_Purchase_Success" })
    }

    @Test("Purchase Product Failure - throws error and tracks fail event")
    func test_purchaseProduct_failure_tracksFail() async {
        let mockLogService = MockLogService()
        let logManager = await LogManager(services: [mockLogService])
        let service = MockFailingPurchaseService()
        let manager = await PurchaseManager(service: service, logManager: logManager)

        do {
            _ = try await manager.purchaseProduct(productId: "any.id")
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(mockLogService.trackedEvents.contains { $0.eventName == "PurMan_Purchase_Fail" })
        }
    }

    // MARK: - restorePurchase

    @Test("Restore Purchase Success - returns entitlements and tracks events")
    func test_restorePurchase_success_returnsEntitlementsAndTracksEvents() async throws {
        let entitlement = PurchasedEntitlement.mock
        let mockLogService = MockLogService()
        let logManager = await LogManager(services: [mockLogService])
        let service = MockPurchaseService(activeEntitlements: [entitlement])
        let manager = await PurchaseManager(service: service, logManager: logManager)

        let result = try await manager.restorePurchase()

        #expect(result.isEmpty == false)
        #expect(mockLogService.trackedEvents.contains { $0.eventName == "PurMan_Restore_Start" })
        #expect(mockLogService.trackedEvents.contains { $0.eventName == "PurMan_Restore_Success" })
    }

    @Test("Restore Purchase Failure - throws error and tracks fail event")
    func test_restorePurchase_failure_tracksFail() async {
        let mockLogService = MockLogService()
        let logManager = await LogManager(services: [mockLogService])
        let service = MockFailingPurchaseService()
        let manager = await PurchaseManager(service: service, logManager: logManager)

        do {
            _ = try await manager.restorePurchase()
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(mockLogService.trackedEvents.contains { $0.eventName == "PurMan_Restore_Fail" })
        }
    }

    // MARK: - Entitlement Sorting

    @Test("Entitlements are sorted by expiration date descending")
    func test_entitlements_sortedByExpirationDateDescending() async throws {
        let now = Date()
        let earlierEntitlement = PurchasedEntitlement(
            id: "earlier",
            productId: "product.earlier",
            expirationDate: now.addingTimeInterval(7 * 24 * 3600),
            isActive: true,
            originalPurchaseDate: now,
            latestPurchaseDate: now,
            ownershipType: .purchased,
            isSandbox: true,
            isVerified: true
        )
        let laterEntitlement = PurchasedEntitlement(
            id: "later",
            productId: "product.later",
            expirationDate: now.addingTimeInterval(30 * 24 * 3600),
            isActive: true,
            originalPurchaseDate: now,
            latestPurchaseDate: now,
            ownershipType: .purchased,
            isSandbox: true,
            isVerified: true
        )

        // The service returns them in reverse order to verify sorting
        let service = MockPurchaseService(activeEntitlements: [earlierEntitlement, laterEntitlement])
        let manager = await PurchaseManager(service: service)

        // Poll until entitlements are populated (configure() uses unstructured Tasks internally)
        var entitlements: [PurchasedEntitlement] = []
        for _ in 0..<20 {
            try? await Task.sleep(nanoseconds: 50_000_000)
            entitlements = await manager.entitlements
            if !entitlements.isEmpty { break }
        }
        #expect(entitlements.first?.id == "later")
        #expect(entitlements.last?.id == "earlier")
    }
}

// MARK: - MockFailingPurchaseService

struct MockFailingPurchaseService: PurchaseServiceProtocol {

    func listenForTransactions(onTransactionUpdated: ([PurchasedEntitlement]) async -> Void) async {}

    func getUserEntitlements() async -> [PurchasedEntitlement] { [] }

    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        throw MockPurchaseError.operationFailed
    }

    func restorePurchase() async throws -> [PurchasedEntitlement] {
        throw MockPurchaseError.operationFailed
    }

    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement] {
        throw MockPurchaseError.operationFailed
    }

    enum MockPurchaseError: Error {
        case operationFailed
    }
}
