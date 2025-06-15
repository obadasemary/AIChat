//
//  FileManager+EXT.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 15.06.2025.
//

import Foundation
import CryptoKit

extension FileManager {
    /// Saves a Codable object as an encrypted .txt file in the specified directory (defaults to Documents).
    /// - Parameters:
    ///   - value: The Codable object to save. Pass nil to delete the file.
    ///   - key: The filename key (without extension).
    ///   - password: A password string used to derive the encryption key.
    ///   - directory: The search path directory (default is .documentDirectory).
    /// - Throws: Errors on encoding, encryption, or file operations.
    static func saveDocument<T: Codable>(
        key: String,
        value: T?,
        password: String,
        in directory: SearchPathDirectory = .documentDirectory
    ) throws {
        let url = getDocumentURL(for: key, in: directory)
        // Remove file if value is nil
        guard let value else {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            return
        }
        // Encode object to JSON data
        let jsonData = try JSONEncoder().encode(value)
        // Encrypt data
        let sealedBox = try AES.GCM.seal(jsonData, using: deriveKey(from: password))
        guard let combined = sealedBox.combined else {
            throw NSError(domain: "FileManagerExtension", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to combine encrypted data."])
        }
        // Ensure directory exists
        let directoryURL = directoryURL(for: directory)
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        // Write encrypted data atomically
        try combined.write(to: url, options: .atomic)
    }

    /// Reads and decrypts a Codable object from a .txt file.
    /// - Parameters:
    ///   - key: The filename key (without extension).
    ///   - password: The password string used to derive the encryption key.
    ///   - directory: The search path directory (default is .documentDirectory).
    /// - Returns: The decoded object, or nil if file does not exist.
    /// - Throws: Errors on decryption or decoding.
    static func getDocument<T: Codable>(
        key: String,
        password: String,
        in directory: SearchPathDirectory = .documentDirectory
    ) throws -> T? {
        let url = getDocumentURL(for: key, in: directory)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        let combined = try Data(contentsOf: url)
        let sealedBox = try AES.GCM.SealedBox(combined: combined)
        let decryptedData = try AES.GCM.open(sealedBox, using: deriveKey(from: password))
        return try JSONDecoder().decode(T.self, from: decryptedData)
    }

    // MARK: - Helpers

    private static func deriveKey(from password: String) -> SymmetricKey {
        let hash = SHA256.hash(data: Data(password.utf8))
        return SymmetricKey(data: Data(hash))
    }

    private static func getDocumentURL(
        for key: String,
        in directory: SearchPathDirectory
    ) -> URL {
        directoryURL(for: directory)
            .appendingPathComponent("\(key).txt")
    }

    private static func directoryURL(for directory: SearchPathDirectory) -> URL {
        FileManager.default
            .urls(for: directory, in: .userDomainMask)
            .first!
    }
}
