// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import NetspendDomain

public class MockNSCardRepositoryProtocol: NSCardRepositoryProtocol {

    public init() {}


    //MARK: - getListCard

    public var getListCardThrowableError: Error?
    public var getListCardCallsCount = 0
    public var getListCardCalled: Bool {
        return getListCardCallsCount > 0
    }
    public var getListCardReturnValue: [CardEntity]!
    public var getListCardClosure: (() async throws -> [CardEntity])?

    public func getListCard() async throws -> [CardEntity] {
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

    //MARK: - createCard

    public var createCardSessionIDThrowableError: Error?
    public var createCardSessionIDCallsCount = 0
    public var createCardSessionIDCalled: Bool {
        return createCardSessionIDCallsCount > 0
    }
    public var createCardSessionIDReceivedSessionID: String?
    public var createCardSessionIDReceivedInvocations: [String] = []
    public var createCardSessionIDReturnValue: CardEntity!
    public var createCardSessionIDClosure: ((String) async throws -> CardEntity)?

    public func createCard(sessionID: String) async throws -> CardEntity {
        if let error = createCardSessionIDThrowableError {
            throw error
        }
        createCardSessionIDCallsCount += 1
        createCardSessionIDReceivedSessionID = sessionID
        createCardSessionIDReceivedInvocations.append(sessionID)
        if let createCardSessionIDClosure = createCardSessionIDClosure {
            return try await createCardSessionIDClosure(sessionID)
        } else {
            return createCardSessionIDReturnValue
        }
    }

    //MARK: - getCard

    public var getCardCardIDSessionIDThrowableError: Error?
    public var getCardCardIDSessionIDCallsCount = 0
    public var getCardCardIDSessionIDCalled: Bool {
        return getCardCardIDSessionIDCallsCount > 0
    }
    public var getCardCardIDSessionIDReceivedArguments: (cardID: String, sessionID: String)?
    public var getCardCardIDSessionIDReceivedInvocations: [(cardID: String, sessionID: String)] = []
    public var getCardCardIDSessionIDReturnValue: CardEntity!
    public var getCardCardIDSessionIDClosure: ((String, String) async throws -> CardEntity)?

    public func getCard(cardID: String, sessionID: String) async throws -> CardEntity {
        if let error = getCardCardIDSessionIDThrowableError {
            throw error
        }
        getCardCardIDSessionIDCallsCount += 1
        getCardCardIDSessionIDReceivedArguments = (cardID: cardID, sessionID: sessionID)
        getCardCardIDSessionIDReceivedInvocations.append((cardID: cardID, sessionID: sessionID))
        if let getCardCardIDSessionIDClosure = getCardCardIDSessionIDClosure {
            return try await getCardCardIDSessionIDClosure(cardID, sessionID)
        } else {
            return getCardCardIDSessionIDReturnValue
        }
    }

    //MARK: - lockCard

    public var lockCardCardIDSessionIDThrowableError: Error?
    public var lockCardCardIDSessionIDCallsCount = 0
    public var lockCardCardIDSessionIDCalled: Bool {
        return lockCardCardIDSessionIDCallsCount > 0
    }
    public var lockCardCardIDSessionIDReceivedArguments: (cardID: String, sessionID: String)?
    public var lockCardCardIDSessionIDReceivedInvocations: [(cardID: String, sessionID: String)] = []
    public var lockCardCardIDSessionIDReturnValue: CardEntity!
    public var lockCardCardIDSessionIDClosure: ((String, String) async throws -> CardEntity)?

    public func lockCard(cardID: String, sessionID: String) async throws -> CardEntity {
        if let error = lockCardCardIDSessionIDThrowableError {
            throw error
        }
        lockCardCardIDSessionIDCallsCount += 1
        lockCardCardIDSessionIDReceivedArguments = (cardID: cardID, sessionID: sessionID)
        lockCardCardIDSessionIDReceivedInvocations.append((cardID: cardID, sessionID: sessionID))
        if let lockCardCardIDSessionIDClosure = lockCardCardIDSessionIDClosure {
            return try await lockCardCardIDSessionIDClosure(cardID, sessionID)
        } else {
            return lockCardCardIDSessionIDReturnValue
        }
    }

    //MARK: - unlockCard

    public var unlockCardCardIDSessionIDThrowableError: Error?
    public var unlockCardCardIDSessionIDCallsCount = 0
    public var unlockCardCardIDSessionIDCalled: Bool {
        return unlockCardCardIDSessionIDCallsCount > 0
    }
    public var unlockCardCardIDSessionIDReceivedArguments: (cardID: String, sessionID: String)?
    public var unlockCardCardIDSessionIDReceivedInvocations: [(cardID: String, sessionID: String)] = []
    public var unlockCardCardIDSessionIDReturnValue: CardEntity!
    public var unlockCardCardIDSessionIDClosure: ((String, String) async throws -> CardEntity)?

    public func unlockCard(cardID: String, sessionID: String) async throws -> CardEntity {
        if let error = unlockCardCardIDSessionIDThrowableError {
            throw error
        }
        unlockCardCardIDSessionIDCallsCount += 1
        unlockCardCardIDSessionIDReceivedArguments = (cardID: cardID, sessionID: sessionID)
        unlockCardCardIDSessionIDReceivedInvocations.append((cardID: cardID, sessionID: sessionID))
        if let unlockCardCardIDSessionIDClosure = unlockCardCardIDSessionIDClosure {
            return try await unlockCardCardIDSessionIDClosure(cardID, sessionID)
        } else {
            return unlockCardCardIDSessionIDReturnValue
        }
    }

    //MARK: - closeCard

    public var closeCardReasonCardIDSessionIDThrowableError: Error?
    public var closeCardReasonCardIDSessionIDCallsCount = 0
    public var closeCardReasonCardIDSessionIDCalled: Bool {
        return closeCardReasonCardIDSessionIDCallsCount > 0
    }
    public var closeCardReasonCardIDSessionIDReceivedArguments: (reason: CloseCardReasonEntity, cardID: String, sessionID: String)?
    public var closeCardReasonCardIDSessionIDReceivedInvocations: [(reason: CloseCardReasonEntity, cardID: String, sessionID: String)] = []
    public var closeCardReasonCardIDSessionIDReturnValue: CardEntity!
    public var closeCardReasonCardIDSessionIDClosure: ((CloseCardReasonEntity, String, String) async throws -> CardEntity)?

    public func closeCard(reason: CloseCardReasonEntity, cardID: String, sessionID: String) async throws -> CardEntity {
        if let error = closeCardReasonCardIDSessionIDThrowableError {
            throw error
        }
        closeCardReasonCardIDSessionIDCallsCount += 1
        closeCardReasonCardIDSessionIDReceivedArguments = (reason: reason, cardID: cardID, sessionID: sessionID)
        closeCardReasonCardIDSessionIDReceivedInvocations.append((reason: reason, cardID: cardID, sessionID: sessionID))
        if let closeCardReasonCardIDSessionIDClosure = closeCardReasonCardIDSessionIDClosure {
            return try await closeCardReasonCardIDSessionIDClosure(reason, cardID, sessionID)
        } else {
            return closeCardReasonCardIDSessionIDReturnValue
        }
    }

    //MARK: - orderPhysicalCard

    public var orderPhysicalCardAddressSessionIDThrowableError: Error?
    public var orderPhysicalCardAddressSessionIDCallsCount = 0
    public var orderPhysicalCardAddressSessionIDCalled: Bool {
        return orderPhysicalCardAddressSessionIDCallsCount > 0
    }
    public var orderPhysicalCardAddressSessionIDReceivedArguments: (address: AddressCardParametersEntity, sessionID: String)?
    public var orderPhysicalCardAddressSessionIDReceivedInvocations: [(address: AddressCardParametersEntity, sessionID: String)] = []
    public var orderPhysicalCardAddressSessionIDReturnValue: CardEntity!
    public var orderPhysicalCardAddressSessionIDClosure: ((AddressCardParametersEntity, String) async throws -> CardEntity)?

    public func orderPhysicalCard(address: AddressCardParametersEntity, sessionID: String) async throws -> CardEntity {
        if let error = orderPhysicalCardAddressSessionIDThrowableError {
            throw error
        }
        orderPhysicalCardAddressSessionIDCallsCount += 1
        orderPhysicalCardAddressSessionIDReceivedArguments = (address: address, sessionID: sessionID)
        orderPhysicalCardAddressSessionIDReceivedInvocations.append((address: address, sessionID: sessionID))
        if let orderPhysicalCardAddressSessionIDClosure = orderPhysicalCardAddressSessionIDClosure {
            return try await orderPhysicalCardAddressSessionIDClosure(address, sessionID)
        } else {
            return orderPhysicalCardAddressSessionIDReturnValue
        }
    }

    //MARK: - verifyCVVCode

    public var verifyCVVCodeVerifyRequestCardIDSessionIDThrowableError: Error?
    public var verifyCVVCodeVerifyRequestCardIDSessionIDCallsCount = 0
    public var verifyCVVCodeVerifyRequestCardIDSessionIDCalled: Bool {
        return verifyCVVCodeVerifyRequestCardIDSessionIDCallsCount > 0
    }
    public var verifyCVVCodeVerifyRequestCardIDSessionIDReceivedArguments: (verifyRequest: VerifyCVVCodeParametersEntity, cardID: String, sessionID: String)?
    public var verifyCVVCodeVerifyRequestCardIDSessionIDReceivedInvocations: [(verifyRequest: VerifyCVVCodeParametersEntity, cardID: String, sessionID: String)] = []
    public var verifyCVVCodeVerifyRequestCardIDSessionIDReturnValue: VerifyCVVCodeEntity!
    public var verifyCVVCodeVerifyRequestCardIDSessionIDClosure: ((VerifyCVVCodeParametersEntity, String, String) async throws -> VerifyCVVCodeEntity)?

    public func verifyCVVCode(verifyRequest: VerifyCVVCodeParametersEntity, cardID: String, sessionID: String) async throws -> VerifyCVVCodeEntity {
        if let error = verifyCVVCodeVerifyRequestCardIDSessionIDThrowableError {
            throw error
        }
        verifyCVVCodeVerifyRequestCardIDSessionIDCallsCount += 1
        verifyCVVCodeVerifyRequestCardIDSessionIDReceivedArguments = (verifyRequest: verifyRequest, cardID: cardID, sessionID: sessionID)
        verifyCVVCodeVerifyRequestCardIDSessionIDReceivedInvocations.append((verifyRequest: verifyRequest, cardID: cardID, sessionID: sessionID))
        if let verifyCVVCodeVerifyRequestCardIDSessionIDClosure = verifyCVVCodeVerifyRequestCardIDSessionIDClosure {
            return try await verifyCVVCodeVerifyRequestCardIDSessionIDClosure(verifyRequest, cardID, sessionID)
        } else {
            return verifyCVVCodeVerifyRequestCardIDSessionIDReturnValue
        }
    }

    //MARK: - setPin

    public var setPinRequestParamCardIDSessionIDThrowableError: Error?
    public var setPinRequestParamCardIDSessionIDCallsCount = 0
    public var setPinRequestParamCardIDSessionIDCalled: Bool {
        return setPinRequestParamCardIDSessionIDCallsCount > 0
    }
    public var setPinRequestParamCardIDSessionIDReceivedArguments: (requestParam: SetPinRequestEntity, cardID: String, sessionID: String)?
    public var setPinRequestParamCardIDSessionIDReceivedInvocations: [(requestParam: SetPinRequestEntity, cardID: String, sessionID: String)] = []
    public var setPinRequestParamCardIDSessionIDReturnValue: CardEntity!
    public var setPinRequestParamCardIDSessionIDClosure: ((SetPinRequestEntity, String, String) async throws -> CardEntity)?

    public func setPin(requestParam: SetPinRequestEntity, cardID: String, sessionID: String) async throws -> CardEntity {
        if let error = setPinRequestParamCardIDSessionIDThrowableError {
            throw error
        }
        setPinRequestParamCardIDSessionIDCallsCount += 1
        setPinRequestParamCardIDSessionIDReceivedArguments = (requestParam: requestParam, cardID: cardID, sessionID: sessionID)
        setPinRequestParamCardIDSessionIDReceivedInvocations.append((requestParam: requestParam, cardID: cardID, sessionID: sessionID))
        if let setPinRequestParamCardIDSessionIDClosure = setPinRequestParamCardIDSessionIDClosure {
            return try await setPinRequestParamCardIDSessionIDClosure(requestParam, cardID, sessionID)
        } else {
            return setPinRequestParamCardIDSessionIDReturnValue
        }
    }

    //MARK: - getApplePayToken

    public var getApplePayTokenSessionIdCardIdThrowableError: Error?
    public var getApplePayTokenSessionIdCardIdCallsCount = 0
    public var getApplePayTokenSessionIdCardIdCalled: Bool {
        return getApplePayTokenSessionIdCardIdCallsCount > 0
    }
    public var getApplePayTokenSessionIdCardIdReceivedArguments: (sessionId: String, cardId: String)?
    public var getApplePayTokenSessionIdCardIdReceivedInvocations: [(sessionId: String, cardId: String)] = []
    public var getApplePayTokenSessionIdCardIdReturnValue: (any GetApplePayTokenEntity)!
    public var getApplePayTokenSessionIdCardIdClosure: ((String, String) async throws -> any GetApplePayTokenEntity)?

    public func getApplePayToken(sessionId: String, cardId: String) async throws -> any GetApplePayTokenEntity {
        if let error = getApplePayTokenSessionIdCardIdThrowableError {
            throw error
        }
        getApplePayTokenSessionIdCardIdCallsCount += 1
        getApplePayTokenSessionIdCardIdReceivedArguments = (sessionId: sessionId, cardId: cardId)
        getApplePayTokenSessionIdCardIdReceivedInvocations.append((sessionId: sessionId, cardId: cardId))
        if let getApplePayTokenSessionIdCardIdClosure = getApplePayTokenSessionIdCardIdClosure {
            return try await getApplePayTokenSessionIdCardIdClosure(sessionId, cardId)
        } else {
            return getApplePayTokenSessionIdCardIdReturnValue
        }
    }

    //MARK: - postApplePayToken

    public var postApplePayTokenSessionIdCardIdBodyDataThrowableError: Error?
    public var postApplePayTokenSessionIdCardIdBodyDataCallsCount = 0
    public var postApplePayTokenSessionIdCardIdBodyDataCalled: Bool {
        return postApplePayTokenSessionIdCardIdBodyDataCallsCount > 0
    }
    public var postApplePayTokenSessionIdCardIdBodyDataReceivedArguments: (sessionId: String, cardId: String, bodyData: [String: Any])?
    public var postApplePayTokenSessionIdCardIdBodyDataReceivedInvocations: [(sessionId: String, cardId: String, bodyData: [String: Any])] = []
    public var postApplePayTokenSessionIdCardIdBodyDataReturnValue: PostApplePayTokenEntity!
    public var postApplePayTokenSessionIdCardIdBodyDataClosure: ((String, String, [String: Any]) async throws -> PostApplePayTokenEntity)?

    public func postApplePayToken(sessionId: String, cardId: String, bodyData: [String: Any]) async throws -> PostApplePayTokenEntity {
        if let error = postApplePayTokenSessionIdCardIdBodyDataThrowableError {
            throw error
        }
        postApplePayTokenSessionIdCardIdBodyDataCallsCount += 1
        postApplePayTokenSessionIdCardIdBodyDataReceivedArguments = (sessionId: sessionId, cardId: cardId, bodyData: bodyData)
        postApplePayTokenSessionIdCardIdBodyDataReceivedInvocations.append((sessionId: sessionId, cardId: cardId, bodyData: bodyData))
        if let postApplePayTokenSessionIdCardIdBodyDataClosure = postApplePayTokenSessionIdCardIdBodyDataClosure {
            return try await postApplePayTokenSessionIdCardIdBodyDataClosure(sessionId, cardId, bodyData)
        } else {
            return postApplePayTokenSessionIdCardIdBodyDataReturnValue
        }
    }

}
