// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidData

public class MockSolidCardAPIProtocol: SolidCardAPIProtocol {

    public init() {}


    //MARK: - getListCard

    public var getListCardThrowableError: Error?
    public var getListCardCallsCount = 0
    public var getListCardCalled: Bool {
        return getListCardCallsCount > 0
    }
    public var getListCardReturnValue: [APISolidCard]!
    public var getListCardClosure: (() async throws -> [APISolidCard])?

    public func getListCard() async throws -> [APISolidCard] {
        if let error = getListCardThrowableError {
            throw error
        }
        getListCardCallsCount += 1
        if let getListCardClosure = getListCardClosure {
            return try await getListCardClosure()
        } else {
            return getListCardReturnValue
        }
    }

    //MARK: - updateCardStatus

    public var updateCardStatusCardIDParametersThrowableError: Error?
    public var updateCardStatusCardIDParametersCallsCount = 0
    public var updateCardStatusCardIDParametersCalled: Bool {
        return updateCardStatusCardIDParametersCallsCount > 0
    }
    public var updateCardStatusCardIDParametersReceivedArguments: (cardID: String, parameters: APISolidCardStatusParameters)?
    public var updateCardStatusCardIDParametersReceivedInvocations: [(cardID: String, parameters: APISolidCardStatusParameters)] = []
    public var updateCardStatusCardIDParametersReturnValue: APISolidCard!
    public var updateCardStatusCardIDParametersClosure: ((String, APISolidCardStatusParameters) async throws -> APISolidCard)?

    public func updateCardStatus(cardID: String, parameters: APISolidCardStatusParameters) async throws -> APISolidCard {
        if let error = updateCardStatusCardIDParametersThrowableError {
            throw error
        }
        updateCardStatusCardIDParametersCallsCount += 1
        updateCardStatusCardIDParametersReceivedArguments = (cardID: cardID, parameters: parameters)
        updateCardStatusCardIDParametersReceivedInvocations.append((cardID: cardID, parameters: parameters))
        if let updateCardStatusCardIDParametersClosure = updateCardStatusCardIDParametersClosure {
            return try await updateCardStatusCardIDParametersClosure(cardID, parameters)
        } else {
            return updateCardStatusCardIDParametersReturnValue
        }
    }

    //MARK: - closeCard

    public var closeCardCardIDThrowableError: Error?
    public var closeCardCardIDCallsCount = 0
    public var closeCardCardIDCalled: Bool {
        return closeCardCardIDCallsCount > 0
    }
    public var closeCardCardIDReceivedCardID: String?
    public var closeCardCardIDReceivedInvocations: [String] = []
    public var closeCardCardIDReturnValue: Bool!
    public var closeCardCardIDClosure: ((String) async throws -> Bool)?

    public func closeCard(cardID: String) async throws -> Bool {
        if let error = closeCardCardIDThrowableError {
            throw error
        }
        closeCardCardIDCallsCount += 1
        closeCardCardIDReceivedCardID = cardID
        closeCardCardIDReceivedInvocations.append(cardID)
        if let closeCardCardIDClosure = closeCardCardIDClosure {
            return try await closeCardCardIDClosure(cardID)
        } else {
            return closeCardCardIDReturnValue
        }
    }

}
