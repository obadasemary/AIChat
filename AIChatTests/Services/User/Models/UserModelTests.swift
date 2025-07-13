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
    
    @Test("UserModel default init")
    func test_defaultInit_values() {
        
        let model = UserModel(userId: "user123")
        
        #expect(model.userId == "user123")
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
        let randomUserId = String.random
        let randomEmail = String.random
        let randomIsAnonymous = Bool.random()
        let randomCreationDate = Date.random
        let randomCreationVersion = String.random
        let randomLastSignInDate = Date.random
        let randomDidCompleteOnboarding = Bool.random()
        let randomProfileColorHex = String.randomHexColor()
        
        let user = UserModel(
            userId: randomUserId,
            email: randomEmail,
            isAnonymous: randomIsAnonymous,
            creationDate: randomCreationDate,
            creationVersion: randomCreationVersion,
            lastSignInDate: randomLastSignInDate,
            didCompleteOnboarding: randomDidCompleteOnboarding,
            profileColorHex: randomProfileColorHex
        )
        
        #expect(user.userId == randomUserId)
        #expect(user.email == randomEmail)
        #expect(user.isAnonymous == randomIsAnonymous)
        #expect(user.creationDate == randomCreationDate)
        #expect(user.creationVersion == randomCreationVersion)
        #expect(user.lastSignInDate == randomLastSignInDate)
        #expect(user.didCompleteOnboarding == randomDidCompleteOnboarding)
        #expect(user.profileColorHex == randomProfileColorHex)
    }
    
    @Test("UserModel Event Parameters")
    func testEventParameters() {
        let randomUserId = String.random
        let randomEmail = String.random
        let randomIsAnonymous = Bool.random()
        let randomCreationDate = Date.random
        let randomCreationVersion = String.random
        let randomLastSignInDate = Date.random
        let randomDidCompleteOnboarding = Bool.random()
        let randomProfileColorHex = String.randomHexColor()
        
        let user = UserModel(
            userId: randomUserId,
            email: randomEmail,
            isAnonymous: randomIsAnonymous,
            creationDate: randomCreationDate,
            creationVersion: randomCreationVersion,
            lastSignInDate: randomLastSignInDate,
            didCompleteOnboarding: randomDidCompleteOnboarding,
            profileColorHex: randomProfileColorHex
        )
        
        let params = user.eventParameters
        #expect(params["user_user_id"] as? String == randomUserId)
        #expect(params["user_email"] as? String == randomEmail)
        #expect((params["user_is_anonymous"] as? Bool) == randomIsAnonymous)
        #expect(params["user_creation_date"] as? Date == randomCreationDate)
        #expect(params["user_creation_version"] as? String == randomCreationVersion)
        #expect(params["user_last_sign_in_date"] as? Date == randomLastSignInDate)
        #expect(params["user_did_complete_onboarding"] as? Bool == randomDidCompleteOnboarding)
        #expect(params["user_profile_color_hex"] as? String == randomProfileColorHex)
    }
    
    @Test("UserModel Profile Color Calculation")
    func test_profileColorCalculated_preferredAccent_whenNil() {
        let randomUserId = String.random
        
        let model = UserModel(userId: randomUserId)
        #expect(model.profileColorCalculated == Color.accent)
    }
    
    @Test("UserModel Profile Color Calculation")
    func test_profileColorCalculated_parsesHex() {
        let randomUserId = String.random
        let randomProfileColorHex = String.randomHexColor()
        let hex   = randomProfileColorHex
        let model = UserModel(userId: randomUserId, profileColorHex: hex)
        let expected = Color(hex: hex)
        
        #expect(model.profileColorCalculated == expected)
    }
    
    @Test("UserModel Codable")
    func test_codable_roundTrip() throws {
        let randomUserId = String.random
        let randomEmail = String.random
        let randomIsAnonymous = Bool.random()
        let randomCreationDate = Date.random
        let randomCreationVersion = String.random
        let randomLastSignInDate = Date.random
        let randomDidCompleteOnboarding = Bool.random()
        let randomProfileColorHex = String.randomHexColor()
        
        let original = UserModel(
            userId: randomUserId,
            email: randomEmail,
            isAnonymous: randomIsAnonymous,
            creationDate: randomCreationDate,
            creationVersion: randomCreationVersion,
            lastSignInDate: randomLastSignInDate,
            didCompleteOnboarding: randomDidCompleteOnboarding,
            profileColorHex: randomProfileColorHex
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(UserModel.self, from: data)
        
        #expect(decoded.userId == original.userId)
        #expect(decoded.email == original.email)
        #expect(decoded.isAnonymous == original.isAnonymous)
        #expect(
            decoded.creationDate == original
                .creationDate?
                .truncatedToSeconds()
        )
        #expect(decoded.creationVersion == original.creationVersion)
        #expect(
            decoded.lastSignInDate == original
                .lastSignInDate?
                .truncatedToSeconds()
        )
        #expect(decoded.didCompleteOnboarding == original.didCompleteOnboarding)
        #expect(decoded.profileColorHex == original.profileColorHex)
    }
    
    @Test("UserModel init with AuthInfo")
    func test_init_withAuthInfo() throws {
            
        let randomUserId = String.random
        let randomEmail = String.random
        let randomIsAnonymous = Bool.random()
        let randomCreationDate = Date.random
        let randomCreationVersion = String.random
        let randomLastSignInDate = Date.random
        
        let auth = UserAuthInfo(
            uid: randomUserId,
            email: randomEmail,
            isAnonymous: randomIsAnonymous,
            creationDate: randomCreationDate,
            lastSignInDate: randomLastSignInDate
        )
            
        let model = UserModel(auth: auth, creationVersion: randomCreationVersion)
            
        #expect(model.userId          == auth.uid)
        #expect(model.email           == auth.email)
        #expect(model.isAnonymous     == auth.isAnonymous)
        #expect(model.creationDate    == auth.creationDate)
        #expect(model.creationVersion == randomCreationVersion)
        #expect(model.lastSignInDate  == auth.lastSignInDate)
    }
}
