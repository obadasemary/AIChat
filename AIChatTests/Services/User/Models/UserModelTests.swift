//
//  UserModelTests.swift
//  AIChatTests
//
//  Created by Abdelrahman Mohamed on 13.07.2025.
//

import Testing
import SwiftUI
@testable import AIChat

struct UserModelTests {
    // MARK: - Test Fixtures
    
    private typealias RandomData = (
        userId: String,
        email: String?,
        isAnonymous: Bool,
        creationDate: Date?,
        creationVersion: String?,
        lastSignInDate: Date?,
        didCompleteOnboarding: Bool?,
        profileColorHex: String?
    )
    
    private func makeRandomData(includeOptionals: Bool = true) -> RandomData {
        
        let id = String.random
        let email = includeOptionals ? String.random : nil
        let isAnon = includeOptionals ? Bool.random() : false
        let creation = includeOptionals ? Date.random : nil
        let version = includeOptionals ? String.random : nil
        let signIn = includeOptionals ? Date.random : nil
        let onboard = includeOptionals ? Bool.random() : nil
        let colorHex = includeOptionals ? String.randomHexColor() : nil
        
        return (id, email, isAnon, creation, version, signIn, onboard, colorHex)
    }
    
    private func makeModel(from data: RandomData) -> UserModel {
        return UserModel(
            userId: data.userId,
            email: data.email,
            isAnonymous: data.isAnonymous,
            creationDate: data.creationDate,
            creationVersion: data.creationVersion,
            lastSignInDate: data.lastSignInDate,
            didCompleteOnboarding: data.didCompleteOnboarding,
            profileColorHex: data.profileColorHex
        )
    }
    
    @Test("UserModel default init")
    func test_defaultInit_values() {
        let data = makeRandomData(includeOptionals: false)
        let model = makeModel(from: data)
        
        #expect(model.userId == data.userId)
        #expect(model.email == nil)
        #expect(model.isAnonymous == false)
        #expect(model.creationDate == nil)
        #expect(model.creationVersion == nil)
        #expect(model.lastSignInDate == nil)
        #expect(model.didCompleteOnboarding == nil)
        #expect(model.profileColorHex == nil)
    }
    
    @Test("UserModel init with Full Data")
    func testInitializationWithFullData() {
        let data = makeRandomData()
        let user = makeModel(from: data)
        
        #expect(user.userId == data.userId)
        #expect(user.email == data.email)
        #expect(user.isAnonymous == data.isAnonymous)
        #expect(user.creationDate == data.creationDate)
        #expect(user.creationVersion == data.creationVersion)
        #expect(user.lastSignInDate == data.lastSignInDate)
        #expect(user.didCompleteOnboarding == data.didCompleteOnboarding)
        #expect(user.profileColorHex == data.profileColorHex)
    }
    
    @Test("UserModel Event Parameters")
    func testEventParameters() {
        let data = makeRandomData()
        let user = makeModel(from: data)
        let params = user.eventParameters
        
        #expect(params["user_user_id"] as? String == data.userId)
        #expect(params["user_email"] as? String == data.email)
        #expect((params["user_is_anonymous"] as? Bool) == data.isAnonymous)
        #expect(params["user_creation_date"] as? Date == data.creationDate)
        #expect(params["user_creation_version"] as? String == data.creationVersion)
        #expect(params["user_last_sign_in_date"] as? Date == data.lastSignInDate)
        #expect(params["user_did_complete_onboarding"] as? Bool == data.didCompleteOnboarding)
        #expect(params["user_profile_color_hex"] as? String == data.profileColorHex)
    }
    
    @Test("UserModel Profile Color Calculation")
    func test_profileColorCalculated_preferredAccent_whenNil() {
        let data = makeRandomData(includeOptionals: false)
        let model = makeModel(from: data)
        #expect(model.profileColorCalculated == Color.accent)
    }
    
    @Test("UserModel profileColorCalculated parses hex")
    func test_profileColorCalculated_parsesHex() {
        let data = makeRandomData()
        let hex = data.profileColorHex ?? String.randomHexColor()
        let model = UserModel(userId: data.userId, profileColorHex: hex)
        let expected = Color(hex: hex)
        #expect(model.profileColorCalculated == expected)
    }
    
    @Test("UserModel Codable")
    func test_codable_roundTrip() throws {
        let dataStruct = makeRandomData()
        let original = makeModel(from: dataStruct)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let encoded = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(UserModel.self, from: encoded)
        
        #expect(decoded.userId == dataStruct.userId)
        #expect(decoded.email == dataStruct.email)
        #expect(decoded.isAnonymous == dataStruct.isAnonymous)
        #expect(decoded.creationDate?.truncatedToSeconds() == dataStruct.creationDate?.truncatedToSeconds())
        #expect(decoded.creationVersion == dataStruct.creationVersion)
        #expect(decoded.lastSignInDate?.truncatedToSeconds() == dataStruct.lastSignInDate?.truncatedToSeconds())
        #expect(decoded.didCompleteOnboarding == dataStruct.didCompleteOnboarding)
        #expect(decoded.profileColorHex == dataStruct.profileColorHex)
    }
    
    @Test("UserModel init with AuthInfo")
    func test_init_withAuthInfo() throws {
        let data = makeRandomData(includeOptionals: false)
        let auth = UserAuthInfo(
            uid: data.userId,
            email: data.email,
            isAnonymous: data.isAnonymous,
            creationDate: data.creationDate,
            lastSignInDate: data.lastSignInDate
        )
        let model = UserModel(auth: auth, creationVersion: data.creationVersion)
        #expect(model.userId          == auth.uid)
        #expect(model.email           == auth.email)
        #expect(model.isAnonymous     == auth.isAnonymous)
        #expect(model.creationDate    == auth.creationDate)
        #expect(model.creationVersion == data.creationVersion)
        #expect(model.lastSignInDate  == auth.lastSignInDate)
    }
}
