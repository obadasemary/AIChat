//
//  AvatarAttributesTests.swift
//  AIChatTests
//
//  Created by Abdelrahman Mohamed on 01.02.2026.
//

import Testing
@testable import AIChat
import Foundation

struct AvatarAttributesTests {

    // MARK: - CharacterOption Tests

    @Test("CharacterOption Default Value")
    func test_characterOptionDefault_shouldReturnRobot() {
        #expect(CharacterOption.default == .robot)
    }

    @Test("CharacterOption Plural - Irregular Plurals")
    func test_whenCharacterIsMan_thenPluralShouldBeMen() {
        #expect(CharacterOption.man.plural == "men")
    }

    @Test("CharacterOption Plural - Woman")
    func test_whenCharacterIsWoman_thenPluralShouldBeWomen() {
        #expect(CharacterOption.woman.plural == "women")
    }

    @Test("CharacterOption Plural - Criminal Lawyer")
    func test_whenCharacterIsCriminalLawyer_thenPluralShouldBeCriminalLawyers() {
        #expect(CharacterOption.criminalLawyer.plural == "criminal lawyers")
    }

    @Test("CharacterOption Plural - Regular Plurals")
    func test_whenCharacterHasRegularPlural_thenAppendS() {
        #expect(CharacterOption.alien.plural == "aliens")
        #expect(CharacterOption.dog.plural == "dogs")
        #expect(CharacterOption.cat.plural == "cats")
        #expect(CharacterOption.robot.plural == "robots")
        #expect(CharacterOption.lawyer.plural == "lawyers")
        #expect(CharacterOption.strategist.plural == "strategists")
        #expect(CharacterOption.consultant.plural == "consultants")
    }

    @Test("CharacterOption StartsWithVowel - Vowel Cases")
    func test_whenCharacterStartsWithVowel_thenReturnTrue() {
        #expect(CharacterOption.alien.startsWithVowel == true)
    }

    @Test("CharacterOption StartsWithVowel - Consonant Cases")
    func test_whenCharacterStartsWithConsonant_thenReturnFalse() {
        #expect(CharacterOption.man.startsWithVowel == false)
        #expect(CharacterOption.woman.startsWithVowel == false)
        #expect(CharacterOption.dog.startsWithVowel == false)
        #expect(CharacterOption.cat.startsWithVowel == false)
        #expect(CharacterOption.robot.startsWithVowel == false)
        #expect(CharacterOption.lawyer.startsWithVowel == false)
        #expect(CharacterOption.criminalLawyer.startsWithVowel == false)
        #expect(CharacterOption.strategist.startsWithVowel == false)
        #expect(CharacterOption.consultant.startsWithVowel == false)
    }

    @Test("CharacterOption Raw Values")
    func test_characterOptionRawValues_shouldMatchExpected() {
        #expect(CharacterOption.man.rawValue == "man")
        #expect(CharacterOption.woman.rawValue == "woman")
        #expect(CharacterOption.alien.rawValue == "alien")
        #expect(CharacterOption.dog.rawValue == "dog")
        #expect(CharacterOption.cat.rawValue == "cat")
        #expect(CharacterOption.robot.rawValue == "robot")
        #expect(CharacterOption.lawyer.rawValue == "lawyer")
        #expect(CharacterOption.criminalLawyer.rawValue == "criminal lawyer")
        #expect(CharacterOption.strategist.rawValue == "strategist")
        #expect(CharacterOption.consultant.rawValue == "consultant")
    }

    // MARK: - CharacterAction Tests

    @Test("CharacterAction Default Value")
    func test_characterActionDefault_shouldReturnFighting() {
        #expect(CharacterAction.default == .fighting)
    }

    @Test("CharacterAction Raw Values - Basic Actions")
    func test_characterActionRawValues_basicActions() {
        #expect(CharacterAction.smiling.rawValue == "smiling")
        #expect(CharacterAction.sitting.rawValue == "sitting")
        #expect(CharacterAction.eating.rawValue == "eating")
        #expect(CharacterAction.drinking.rawValue == "drinking")
        #expect(CharacterAction.walking.rawValue == "walking")
        #expect(CharacterAction.running.rawValue == "running")
        #expect(CharacterAction.jumping.rawValue == "jumping")
        #expect(CharacterAction.sleeping.rawValue == "sleeping")
    }

    @Test("CharacterAction Raw Values - Professional Actions")
    func test_characterActionRawValues_professionalActions() {
        #expect(CharacterAction.consulting.rawValue == "consulting")
        #expect(CharacterAction.presenting.rawValue == "presenting")
        #expect(CharacterAction.negotiating.rawValue == "negotiating")
        #expect(CharacterAction.meeting.rawValue == "meeting")
        #expect(CharacterAction.analyzing.rawValue == "analyzing")
        #expect(CharacterAction.advising.rawValue == "advising")
        #expect(CharacterAction.reviewing.rawValue == "reviewing")
    }

    // MARK: - CharacterLocation Tests

    @Test("CharacterLocation Default Value")
    func test_characterLocationDefault_shouldReturnSpace() {
        #expect(CharacterLocation.default == .space)
    }

    @Test("CharacterLocation Raw Values - Basic Locations")
    func test_characterLocationRawValues_basicLocations() {
        #expect(CharacterLocation.park.rawValue == "park")
        #expect(CharacterLocation.mall.rawValue == "mall")
        #expect(CharacterLocation.museum.rawValue == "museum")
        #expect(CharacterLocation.city.rawValue == "city")
        #expect(CharacterLocation.mountain.rawValue == "mountain")
        #expect(CharacterLocation.desert.rawValue == "desert")
        #expect(CharacterLocation.forest.rawValue == "forest")
        #expect(CharacterLocation.beach.rawValue == "beach")
        #expect(CharacterLocation.ocean.rawValue == "ocean")
        #expect(CharacterLocation.space.rawValue == "space")
    }

    @Test("CharacterLocation Raw Values - Professional Locations")
    func test_characterLocationRawValues_professionalLocations() {
        #expect(CharacterLocation.office.rawValue == "office")
        #expect(CharacterLocation.courthouse.rawValue == "courthouse")
        #expect(CharacterLocation.boardroom.rawValue == "boardroom")
        #expect(CharacterLocation.conference.rawValue == "conference")
        #expect(CharacterLocation.lawFirm.rawValue == "law firm")
    }

    // MARK: - AvatarDescriptionBuilder Tests

    @Test("AvatarDescriptionBuilder Initialization")
    func test_avatarDescriptionBuilderInit_shouldSetProperties() {
        let builder = AvatarDescriptionBuilder(
            characterOption: .robot,
            characterAction: .fighting,
            characterLocation: .space
        )

        #expect(builder.characterOption == .robot)
        #expect(builder.characterAction == .fighting)
        #expect(builder.characterLocation == .space)
    }

    @Test("AvatarDescriptionBuilder Character Description")
    func test_avatarDescriptionBuilder_shouldGenerateCorrectDescription() {
        let builder = AvatarDescriptionBuilder(
            characterOption: .robot,
            characterAction: .fighting,
            characterLocation: .space
        )

        #expect(builder.characterDescription == "A robot that is fighting in the space")
    }

    @Test("AvatarDescriptionBuilder Character Description With Vowel")
    func test_whenCharacterStartsWithVowel_thenDescriptionUsesAn() {
        let builder = AvatarDescriptionBuilder(
            characterOption: .alien,
            characterAction: .walking,
            characterLocation: .desert
        )

        #expect(builder.characterDescription == "An alien that is walking in the desert")
    }

    @Test("AvatarDescriptionBuilder Character Description With Professional Options")
    func test_whenUsingProfessionalOptions_thenDescriptionIsCorrect() {
        let builder = AvatarDescriptionBuilder(
            characterOption: .lawyer,
            characterAction: .presenting,
            characterLocation: .courthouse
        )

        #expect(builder.characterDescription == "A lawyer that is presenting in the courthouse")
    }

    @Test("AvatarDescriptionBuilder Event Parameters")
    func test_avatarDescriptionBuilder_shouldGenerateEventParameters() {
        let builder = AvatarDescriptionBuilder(
            characterOption: .consultant,
            characterAction: .consulting,
            characterLocation: .office
        )

        let params = builder.eventParameters

        #expect(params["character_option"] as? String == "consultant")
        #expect(params["character_action"] as? String == "consulting")
        #expect(params["character_location"] as? String == "office")
        #expect(params["character_description"] as? String == "A consultant that is consulting in the office")
    }

    @Test("AvatarDescriptionBuilder Codable")
    func test_avatarDescriptionBuilder_shouldBeEncodableAndDecodable() throws {
        let original = AvatarDescriptionBuilder(
            characterOption: .strategist,
            characterAction: .analyzing,
            characterLocation: .boardroom
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AvatarDescriptionBuilder.self, from: data)

        #expect(decoded.characterOption == original.characterOption)
        #expect(decoded.characterAction == original.characterAction)
        #expect(decoded.characterLocation == original.characterLocation)
    }
}
