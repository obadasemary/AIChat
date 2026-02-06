//
//  TokenUsageCredentialsStore.swift
//  AIChat
//
//  Created by OpenAI on 2026-02-18.
//

import Foundation
import Security

protocol TokenUsageCredentialsStoreProtocol {
    func apiKey(for provider: TokenUsageProvider) -> String?
    func saveAPIKey(_ apiKey: String, for provider: TokenUsageProvider) throws
    func clearAPIKey(for provider: TokenUsageProvider) throws
}

struct TokenUsageCredentialsStore: TokenUsageCredentialsStoreProtocol {
    private let keychain: KeychainManaging

    init(keychain: KeychainManaging = KeychainManager()) {
        self.keychain = keychain
    }

    func apiKey(for provider: TokenUsageProvider) -> String? {
        keychain.string(forKey: provider.rawValue, service: Self.serviceName)
    }

    func saveAPIKey(_ apiKey: String, for provider: TokenUsageProvider) throws {
        let trimmed = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            try clearAPIKey(for: provider)
        } else {
            try keychain.setString(trimmed, forKey: provider.rawValue, service: Self.serviceName)
        }
    }

    func clearAPIKey(for provider: TokenUsageProvider) throws {
        try keychain.deleteString(forKey: provider.rawValue, service: Self.serviceName)
    }

    private static let serviceName = "com.obada.AIChat.TokenUsage"
}

protocol KeychainManaging {
    func string(forKey key: String, service: String) -> String?
    func setString(_ value: String, forKey key: String, service: String) throws
    func deleteString(forKey key: String, service: String) throws
}

struct KeychainManager: KeychainManaging {
    func string(forKey key: String, service: String) -> String? {
        var query = baseQuery(forKey: key, service: service)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    func setString(_ value: String, forKey key: String, service: String) throws {
        let data = Data(value.utf8)
        var query = baseQuery(forKey: key, service: service)

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        if status == errSecSuccess {
            let attributes: [String: Any] = [kSecValueData as String: data]
            let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            if updateStatus != errSecSuccess {
                throw KeychainError.unhandledStatus(updateStatus)
            }
        } else if status == errSecItemNotFound {
            query[kSecValueData as String] = data
            let addStatus = SecItemAdd(query as CFDictionary, nil)
            if addStatus != errSecSuccess {
                throw KeychainError.unhandledStatus(addStatus)
            }
        } else {
            throw KeychainError.unhandledStatus(status)
        }
    }

    func deleteString(forKey key: String, service: String) throws {
        let query = baseQuery(forKey: key, service: service)
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.unhandledStatus(status)
        }
    }

    private func baseQuery(forKey key: String, service: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
    }
}

enum KeychainError: LocalizedError {
    case unhandledStatus(OSStatus)

    var errorDescription: String? {
        switch self {
        case .unhandledStatus(let status):
            return "Keychain error: \(status)"
        }
    }
}
