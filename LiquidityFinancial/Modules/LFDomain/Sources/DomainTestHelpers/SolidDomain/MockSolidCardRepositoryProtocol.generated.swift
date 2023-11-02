// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidDomain

public class MockSolidCardRepositoryProtocol: SolidCardRepositoryProtocol {

    public init() {}


    //MARK: - getListCard

    public var getListCardThrowableError: Error?
    public var getListCardCallsCount = 0
    public var getListCardCalled: Bool {
        return getListCardCallsCount > 0
    }
    public var getListCardReturnValue: [SolidCardEntity]!
    public var getListCardClosure: (() async throws -> [SolidCardEntity])?

    public func getListCard() async throws -> [SolidCardEntity] {
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
    public var updateCardStatusCardIDParametersReceivedArguments: (cardID: String, parameters: SolidCardStatusParametersEntity)?
    public var updateCardStatusCardIDParametersReceivedInvocations: [(cardID: String, parameters: SolidCardStatusParametersEntity)] = []
    public var updateCardStatusCardIDParametersReturnValue: SolidCardEntity!
    public var updateCardStatusCardIDParametersClosure: ((String, SolidCardStatusParametersEntity) async throws -> SolidCardEntity)?

    public func updateCardStatus(cardID: String, parameters: SolidCardStatusParametersEntity) async throws -> SolidCardEntity {
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

}
