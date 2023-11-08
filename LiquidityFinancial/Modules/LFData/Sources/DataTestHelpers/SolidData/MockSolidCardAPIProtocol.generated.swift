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

    //MARK: - createVGSShowToken

    public var createVGSShowTokenCardIDThrowableError: Error?
    public var createVGSShowTokenCardIDCallsCount = 0
    public var createVGSShowTokenCardIDCalled: Bool {
        return createVGSShowTokenCardIDCallsCount > 0
    }
    public var createVGSShowTokenCardIDReceivedCardID: String?
    public var createVGSShowTokenCardIDReceivedInvocations: [String] = []
    public var createVGSShowTokenCardIDReturnValue: APISolidCardShowToken!
    public var createVGSShowTokenCardIDClosure: ((String) async throws -> APISolidCardShowToken)?

    public func createVGSShowToken(cardID: String) async throws -> APISolidCardShowToken {
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
    public var createDigitalWalletLinkCardIDParametersReceivedArguments: (cardID: String, parameters: APISolidApplePayWalletParameters)?
    public var createDigitalWalletLinkCardIDParametersReceivedInvocations: [(cardID: String, parameters: APISolidApplePayWalletParameters)] = []
    public var createDigitalWalletLinkCardIDParametersReturnValue: APISolidDigitalWallet!
    public var createDigitalWalletLinkCardIDParametersClosure: ((String, APISolidApplePayWalletParameters) async throws -> APISolidDigitalWallet)?

    public func createDigitalWalletLink(cardID: String, parameters: APISolidApplePayWalletParameters) async throws -> APISolidDigitalWallet {
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
    public var createVirtualCardAccountIDReturnValue: APISolidCard!
    public var createVirtualCardAccountIDClosure: ((String) async throws -> APISolidCard)?

    public func createVirtualCard(accountID: String) async throws -> APISolidCard {
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

    //MARK: - createCardPinToken

    public var createCardPinTokenCardIDThrowableError: Error?
    public var createCardPinTokenCardIDCallsCount = 0
    public var createCardPinTokenCardIDCalled: Bool {
        return createCardPinTokenCardIDCallsCount > 0
    }
    public var createCardPinTokenCardIDReceivedCardID: String?
    public var createCardPinTokenCardIDReceivedInvocations: [String] = []
    public var createCardPinTokenCardIDReturnValue: APISolidCardPinToken!
    public var createCardPinTokenCardIDClosure: ((String) async throws -> APISolidCardPinToken)?

    public func createCardPinToken(cardID: String) async throws -> APISolidCardPinToken {
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

    //MARK: - updateRoundUpDonation

    public var updateRoundUpDonationCardIDParametersThrowableError: Error?
    public var updateRoundUpDonationCardIDParametersCallsCount = 0
    public var updateRoundUpDonationCardIDParametersCalled: Bool {
        return updateRoundUpDonationCardIDParametersCallsCount > 0
    }
    public var updateRoundUpDonationCardIDParametersReceivedArguments: (cardID: String, parameters: APISolidRoundUpDonationParameters)?
    public var updateRoundUpDonationCardIDParametersReceivedInvocations: [(cardID: String, parameters: APISolidRoundUpDonationParameters)] = []
    public var updateRoundUpDonationCardIDParametersReturnValue: APISolidCard!
    public var updateRoundUpDonationCardIDParametersClosure: ((String, APISolidRoundUpDonationParameters) async throws -> APISolidCard)?

    public func updateRoundUpDonation(cardID: String, parameters: APISolidRoundUpDonationParameters) async throws -> APISolidCard {
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

}
