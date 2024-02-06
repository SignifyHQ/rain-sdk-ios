// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidData
import AccountData

public class MockSolidCardAPIProtocol: SolidCardAPIProtocol {

    public init() {}


    //MARK: - getListCard

    public var getListCardIsContainClosedCardThrowableError: Error?
    public var getListCardIsContainClosedCardCallsCount = 0
    public var getListCardIsContainClosedCardCalled: Bool {
        return getListCardIsContainClosedCardCallsCount > 0
    }
    public var getListCardIsContainClosedCardReceivedIsContainClosedCard: Bool?
    public var getListCardIsContainClosedCardReceivedInvocations: [Bool] = []
    public var getListCardIsContainClosedCardReturnValue: [APISolidCard]!
    public var getListCardIsContainClosedCardClosure: ((Bool) async throws -> [APISolidCard])?

    public func getListCard(isContainClosedCard: Bool) async throws -> [APISolidCard] {
        if let error = getListCardIsContainClosedCardThrowableError {
            throw error
        }
        getListCardIsContainClosedCardCallsCount += 1
        getListCardIsContainClosedCardReceivedIsContainClosedCard = isContainClosedCard
        getListCardIsContainClosedCardReceivedInvocations.append(isContainClosedCard)
        if let getListCardIsContainClosedCardClosure = getListCardIsContainClosedCardClosure {
            return try await getListCardIsContainClosedCardClosure(isContainClosedCard)
        } else {
            return getListCardIsContainClosedCardReturnValue
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

    //MARK: - activeCard

    public var activeCardCardIDParametersThrowableError: Error?
    public var activeCardCardIDParametersCallsCount = 0
    public var activeCardCardIDParametersCalled: Bool {
        return activeCardCardIDParametersCallsCount > 0
    }
    public var activeCardCardIDParametersReceivedArguments: (cardID: String, parameters: APISolidActiveCardParameters)?
    public var activeCardCardIDParametersReceivedInvocations: [(cardID: String, parameters: APISolidActiveCardParameters)] = []
    public var activeCardCardIDParametersReturnValue: APISolidCard!
    public var activeCardCardIDParametersClosure: ((String, APISolidActiveCardParameters) async throws -> APISolidCard)?

    public func activeCard(cardID: String, parameters: APISolidActiveCardParameters) async throws -> APISolidCard {
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
    public var getCardLimitsCardIDReturnValue: APISolidCardLimits!
    public var getCardLimitsCardIDClosure: ((String) async throws -> APISolidCardLimits)?

    public func getCardLimits(cardID: String) async throws -> APISolidCardLimits {
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

    //MARK: - updateCardName

    public var updateCardNameCardIDParametersThrowableError: Error?
    public var updateCardNameCardIDParametersCallsCount = 0
    public var updateCardNameCardIDParametersCalled: Bool {
        return updateCardNameCardIDParametersCallsCount > 0
    }
    public var updateCardNameCardIDParametersReceivedArguments: (cardID: String, parameters: APISolidCardNameParameters)?
    public var updateCardNameCardIDParametersReceivedInvocations: [(cardID: String, parameters: APISolidCardNameParameters)] = []
    public var updateCardNameCardIDParametersReturnValue: APISolidCard!
    public var updateCardNameCardIDParametersClosure: ((String, APISolidCardNameParameters) async throws -> APISolidCard)?

    public func updateCardName(cardID: String, parameters: APISolidCardNameParameters) async throws -> APISolidCard {
        if let error = updateCardNameCardIDParametersThrowableError {
            throw error
        }
        updateCardNameCardIDParametersCallsCount += 1
        updateCardNameCardIDParametersReceivedArguments = (cardID: cardID, parameters: parameters)
        updateCardNameCardIDParametersReceivedInvocations.append((cardID: cardID, parameters: parameters))
        if let updateCardNameCardIDParametersClosure = updateCardNameCardIDParametersClosure {
            return try await updateCardNameCardIDParametersClosure(cardID, parameters)
        } else {
            return updateCardNameCardIDParametersReturnValue
        }
    }

    //MARK: - getCardTransactions

    public var getCardTransactionsParametersThrowableError: Error?
    public var getCardTransactionsParametersCallsCount = 0
    public var getCardTransactionsParametersCalled: Bool {
        return getCardTransactionsParametersCallsCount > 0
    }
    public var getCardTransactionsParametersReceivedParameters: APISolidCardTransactionsParameters?
    public var getCardTransactionsParametersReceivedInvocations: [APISolidCardTransactionsParameters] = []
    public var getCardTransactionsParametersReturnValue: APITransactionList!
    public var getCardTransactionsParametersClosure: ((APISolidCardTransactionsParameters) async throws -> APITransactionList)?

    public func getCardTransactions(parameters: APISolidCardTransactionsParameters) async throws -> APITransactionList {
        if let error = getCardTransactionsParametersThrowableError {
            throw error
        }
        getCardTransactionsParametersCallsCount += 1
        getCardTransactionsParametersReceivedParameters = parameters
        getCardTransactionsParametersReceivedInvocations.append(parameters)
        if let getCardTransactionsParametersClosure = getCardTransactionsParametersClosure {
            return try await getCardTransactionsParametersClosure(parameters)
        } else {
            return getCardTransactionsParametersReturnValue
        }
    }

}
