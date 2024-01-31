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

    //MARK: - createVGSShowToken

    public var createVGSShowTokenCardIDThrowableError: Error?
    public var createVGSShowTokenCardIDCallsCount = 0
    public var createVGSShowTokenCardIDCalled: Bool {
        return createVGSShowTokenCardIDCallsCount > 0
    }
    public var createVGSShowTokenCardIDReceivedCardID: String?
    public var createVGSShowTokenCardIDReceivedInvocations: [String] = []
    public var createVGSShowTokenCardIDReturnValue: SolidCardShowTokenEntity!
    public var createVGSShowTokenCardIDClosure: ((String) async throws -> SolidCardShowTokenEntity)?

    public func createVGSShowToken(cardID: String) async throws -> SolidCardShowTokenEntity {
        if let error = createVGSShowTokenCardIDThrowableError {
            throw error
        }
        createVGSShowTokenCardIDCallsCount += 1
        createVGSShowTokenCardIDReceivedCardID = cardID
        createVGSShowTokenCardIDReceivedInvocations.append(cardID)
        if let createVGSShowTokenCardIDClosure = createVGSShowTokenCardIDClosure {
            return try await createVGSShowTokenCardIDClosure(cardID)
        } else {
            return createVGSShowTokenCardIDReturnValue
        }
    }

    //MARK: - createDigitalWalletLink

    public var createDigitalWalletLinkCardIDParametersThrowableError: Error?
    public var createDigitalWalletLinkCardIDParametersCallsCount = 0
    public var createDigitalWalletLinkCardIDParametersCalled: Bool {
        return createDigitalWalletLinkCardIDParametersCallsCount > 0
    }
    public var createDigitalWalletLinkCardIDParametersReceivedArguments: (cardID: String, parameters: SolidApplePayParametersEntity)?
    public var createDigitalWalletLinkCardIDParametersReceivedInvocations: [(cardID: String, parameters: SolidApplePayParametersEntity)] = []
    public var createDigitalWalletLinkCardIDParametersReturnValue: SolidDigitalWalletEntity!
    public var createDigitalWalletLinkCardIDParametersClosure: ((String, SolidApplePayParametersEntity) async throws -> SolidDigitalWalletEntity)?

    public func createDigitalWalletLink(cardID: String, parameters: SolidApplePayParametersEntity) async throws -> SolidDigitalWalletEntity {
        if let error = createDigitalWalletLinkCardIDParametersThrowableError {
            throw error
        }
        createDigitalWalletLinkCardIDParametersCallsCount += 1
        createDigitalWalletLinkCardIDParametersReceivedArguments = (cardID: cardID, parameters: parameters)
        createDigitalWalletLinkCardIDParametersReceivedInvocations.append((cardID: cardID, parameters: parameters))
        if let createDigitalWalletLinkCardIDParametersClosure = createDigitalWalletLinkCardIDParametersClosure {
            return try await createDigitalWalletLinkCardIDParametersClosure(cardID, parameters)
        } else {
            return createDigitalWalletLinkCardIDParametersReturnValue
        }
    }

    //MARK: - createVirtualCard

    public var createVirtualCardAccountIDThrowableError: Error?
    public var createVirtualCardAccountIDCallsCount = 0
    public var createVirtualCardAccountIDCalled: Bool {
        return createVirtualCardAccountIDCallsCount > 0
    }
    public var createVirtualCardAccountIDReceivedAccountID: String?
    public var createVirtualCardAccountIDReceivedInvocations: [String] = []
    public var createVirtualCardAccountIDReturnValue: SolidCardEntity!
    public var createVirtualCardAccountIDClosure: ((String) async throws -> SolidCardEntity)?

    public func createVirtualCard(accountID: String) async throws -> SolidCardEntity {
        if let error = createVirtualCardAccountIDThrowableError {
            throw error
        }
        createVirtualCardAccountIDCallsCount += 1
        createVirtualCardAccountIDReceivedAccountID = accountID
        createVirtualCardAccountIDReceivedInvocations.append(accountID)
        if let createVirtualCardAccountIDClosure = createVirtualCardAccountIDClosure {
            return try await createVirtualCardAccountIDClosure(accountID)
        } else {
            return createVirtualCardAccountIDReturnValue
        }
    }

    //MARK: - updateRoundUpDonation

    public var updateRoundUpDonationCardIDParametersThrowableError: Error?
    public var updateRoundUpDonationCardIDParametersCallsCount = 0
    public var updateRoundUpDonationCardIDParametersCalled: Bool {
        return updateRoundUpDonationCardIDParametersCallsCount > 0
    }
    public var updateRoundUpDonationCardIDParametersReceivedArguments: (cardID: String, parameters: SolidRoundUpDonationParametersEntity)?
    public var updateRoundUpDonationCardIDParametersReceivedInvocations: [(cardID: String, parameters: SolidRoundUpDonationParametersEntity)] = []
    public var updateRoundUpDonationCardIDParametersReturnValue: SolidCardEntity!
    public var updateRoundUpDonationCardIDParametersClosure: ((String, SolidRoundUpDonationParametersEntity) async throws -> SolidCardEntity)?

    public func updateRoundUpDonation(cardID: String, parameters: SolidRoundUpDonationParametersEntity) async throws -> SolidCardEntity {
        if let error = updateRoundUpDonationCardIDParametersThrowableError {
            throw error
        }
        updateRoundUpDonationCardIDParametersCallsCount += 1
        updateRoundUpDonationCardIDParametersReceivedArguments = (cardID: cardID, parameters: parameters)
        updateRoundUpDonationCardIDParametersReceivedInvocations.append((cardID: cardID, parameters: parameters))
        if let updateRoundUpDonationCardIDParametersClosure = updateRoundUpDonationCardIDParametersClosure {
            return try await updateRoundUpDonationCardIDParametersClosure(cardID, parameters)
        } else {
            return updateRoundUpDonationCardIDParametersReturnValue
        }
    }

    //MARK: - createCardPinToken

    public var createCardPinTokenCardIDThrowableError: Error?
    public var createCardPinTokenCardIDCallsCount = 0
    public var createCardPinTokenCardIDCalled: Bool {
        return createCardPinTokenCardIDCallsCount > 0
    }
    public var createCardPinTokenCardIDReceivedCardID: String?
    public var createCardPinTokenCardIDReceivedInvocations: [String] = []
    public var createCardPinTokenCardIDReturnValue: SolidCardPinTokenEntity!
    public var createCardPinTokenCardIDClosure: ((String) async throws -> SolidCardPinTokenEntity)?

    public func createCardPinToken(cardID: String) async throws -> SolidCardPinTokenEntity {
        if let error = createCardPinTokenCardIDThrowableError {
            throw error
        }
        createCardPinTokenCardIDCallsCount += 1
        createCardPinTokenCardIDReceivedCardID = cardID
        createCardPinTokenCardIDReceivedInvocations.append(cardID)
        if let createCardPinTokenCardIDClosure = createCardPinTokenCardIDClosure {
            return try await createCardPinTokenCardIDClosure(cardID)
        } else {
            return createCardPinTokenCardIDReturnValue
        }
    }

    //MARK: - activeCard

    public var activeCardCardIDParametersThrowableError: Error?
    public var activeCardCardIDParametersCallsCount = 0
    public var activeCardCardIDParametersCalled: Bool {
        return activeCardCardIDParametersCallsCount > 0
    }
    public var activeCardCardIDParametersReceivedArguments: (cardID: String, parameters: SolidActiveCardParametersEntity)?
    public var activeCardCardIDParametersReceivedInvocations: [(cardID: String, parameters: SolidActiveCardParametersEntity)] = []
    public var activeCardCardIDParametersReturnValue: SolidCardEntity!
    public var activeCardCardIDParametersClosure: ((String, SolidActiveCardParametersEntity) async throws -> SolidCardEntity)?

    public func activeCard(cardID: String, parameters: SolidActiveCardParametersEntity) async throws -> SolidCardEntity {
        if let error = activeCardCardIDParametersThrowableError {
            throw error
        }
        activeCardCardIDParametersCallsCount += 1
        activeCardCardIDParametersReceivedArguments = (cardID: cardID, parameters: parameters)
        activeCardCardIDParametersReceivedInvocations.append((cardID: cardID, parameters: parameters))
        if let activeCardCardIDParametersClosure = activeCardCardIDParametersClosure {
            return try await activeCardCardIDParametersClosure(cardID, parameters)
        } else {
            return activeCardCardIDParametersReturnValue
        }
    }

    //MARK: - getCardLimits

    public var getCardLimitsCardIDThrowableError: Error?
    public var getCardLimitsCardIDCallsCount = 0
    public var getCardLimitsCardIDCalled: Bool {
        return getCardLimitsCardIDCallsCount > 0
    }
    public var getCardLimitsCardIDReceivedCardID: String?
    public var getCardLimitsCardIDReceivedInvocations: [String] = []
    public var getCardLimitsCardIDReturnValue: SolidCardLimitsEntity!
    public var getCardLimitsCardIDClosure: ((String) async throws -> SolidCardLimitsEntity)?

    public func getCardLimits(cardID: String) async throws -> SolidCardLimitsEntity {
        if let error = getCardLimitsCardIDThrowableError {
            throw error
        }
        getCardLimitsCardIDCallsCount += 1
        getCardLimitsCardIDReceivedCardID = cardID
        getCardLimitsCardIDReceivedInvocations.append(cardID)
        if let getCardLimitsCardIDClosure = getCardLimitsCardIDClosure {
            return try await getCardLimitsCardIDClosure(cardID)
        } else {
            return getCardLimitsCardIDReturnValue
        }
    }

}
