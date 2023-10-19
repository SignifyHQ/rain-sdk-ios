// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import NetSpendData
import NetSpendDomain

public class MockNSExternalFundingAPIProtocol: NSExternalFundingAPIProtocol {

    public init() {}


    //MARK: - set

    public var setRequestSessionIDThrowableError: Error?
    public var setRequestSessionIDCallsCount = 0
    public var setRequestSessionIDCalled: Bool {
        return setRequestSessionIDCallsCount > 0
    }
    public var setRequestSessionIDReceivedArguments: (request: ExternalCardParameters, sessionID: String)?
    public var setRequestSessionIDReceivedInvocations: [(request: ExternalCardParameters, sessionID: String)] = []
    public var setRequestSessionIDReturnValue: APIExternalCard!
    public var setRequestSessionIDClosure: ((ExternalCardParameters, String) async throws -> APIExternalCard)?

    public func set(request: ExternalCardParameters, sessionID: String) async throws -> APIExternalCard {
        if let error = setRequestSessionIDThrowableError {
            throw error
        }
        setRequestSessionIDCallsCount += 1
        setRequestSessionIDReceivedArguments = (request: request, sessionID: sessionID)
        setRequestSessionIDReceivedInvocations.append((request: request, sessionID: sessionID))
        if let setRequestSessionIDClosure = setRequestSessionIDClosure {
            return try await setRequestSessionIDClosure(request, sessionID)
        } else {
            return setRequestSessionIDReturnValue
        }
    }

    //MARK: - getPinWheelToken

    public var getPinWheelTokenSessionIDThrowableError: Error?
    public var getPinWheelTokenSessionIDCallsCount = 0
    public var getPinWheelTokenSessionIDCalled: Bool {
        return getPinWheelTokenSessionIDCallsCount > 0
    }
    public var getPinWheelTokenSessionIDReceivedSessionID: String?
    public var getPinWheelTokenSessionIDReceivedInvocations: [String] = []
    public var getPinWheelTokenSessionIDReturnValue: APIPinWheelToken!
    public var getPinWheelTokenSessionIDClosure: ((String) async throws -> APIPinWheelToken)?

    public func getPinWheelToken(sessionID: String) async throws -> APIPinWheelToken {
        if let error = getPinWheelTokenSessionIDThrowableError {
            throw error
        }
        getPinWheelTokenSessionIDCallsCount += 1
        getPinWheelTokenSessionIDReceivedSessionID = sessionID
        getPinWheelTokenSessionIDReceivedInvocations.append(sessionID)
        if let getPinWheelTokenSessionIDClosure = getPinWheelTokenSessionIDClosure {
            return try await getPinWheelTokenSessionIDClosure(sessionID)
        } else {
            return getPinWheelTokenSessionIDReturnValue
        }
    }

    //MARK: - getACHInfo

    public var getACHInfoSessionIDThrowableError: Error?
    public var getACHInfoSessionIDCallsCount = 0
    public var getACHInfoSessionIDCalled: Bool {
        return getACHInfoSessionIDCallsCount > 0
    }
    public var getACHInfoSessionIDReceivedSessionID: String?
    public var getACHInfoSessionIDReceivedInvocations: [String] = []
    public var getACHInfoSessionIDReturnValue: APIACHInfo!
    public var getACHInfoSessionIDClosure: ((String) async throws -> APIACHInfo)?

    public func getACHInfo(sessionID: String) async throws -> APIACHInfo {
        if let error = getACHInfoSessionIDThrowableError {
            throw error
        }
        getACHInfoSessionIDCallsCount += 1
        getACHInfoSessionIDReceivedSessionID = sessionID
        getACHInfoSessionIDReceivedInvocations.append(sessionID)
        if let getACHInfoSessionIDClosure = getACHInfoSessionIDClosure {
            return try await getACHInfoSessionIDClosure(sessionID)
        } else {
            return getACHInfoSessionIDReturnValue
        }
    }

    //MARK: - getLinkedSources

    public var getLinkedSourcesSessionIDThrowableError: Error?
    public var getLinkedSourcesSessionIDCallsCount = 0
    public var getLinkedSourcesSessionIDCalled: Bool {
        return getLinkedSourcesSessionIDCallsCount > 0
    }
    public var getLinkedSourcesSessionIDReceivedSessionID: String?
    public var getLinkedSourcesSessionIDReceivedInvocations: [String] = []
    public var getLinkedSourcesSessionIDReturnValue: APILinkedSourcesResponse!
    public var getLinkedSourcesSessionIDClosure: ((String) async throws -> APILinkedSourcesResponse)?

    public func getLinkedSources(sessionID: String) async throws -> APILinkedSourcesResponse {
        if let error = getLinkedSourcesSessionIDThrowableError {
            throw error
        }
        getLinkedSourcesSessionIDCallsCount += 1
        getLinkedSourcesSessionIDReceivedSessionID = sessionID
        getLinkedSourcesSessionIDReceivedInvocations.append(sessionID)
        if let getLinkedSourcesSessionIDClosure = getLinkedSourcesSessionIDClosure {
            return try await getLinkedSourcesSessionIDClosure(sessionID)
        } else {
            return getLinkedSourcesSessionIDReturnValue
        }
    }

    //MARK: - deleteLinkedSource

    public var deleteLinkedSourceSessionIdSourceIdSourceTypeThrowableError: Error?
    public var deleteLinkedSourceSessionIdSourceIdSourceTypeCallsCount = 0
    public var deleteLinkedSourceSessionIdSourceIdSourceTypeCalled: Bool {
        return deleteLinkedSourceSessionIdSourceIdSourceTypeCallsCount > 0
    }
    public var deleteLinkedSourceSessionIdSourceIdSourceTypeReceivedArguments: (sessionId: String, sourceId: String, sourceType: String)?
    public var deleteLinkedSourceSessionIdSourceIdSourceTypeReceivedInvocations: [(sessionId: String, sourceId: String, sourceType: String)] = []
    public var deleteLinkedSourceSessionIdSourceIdSourceTypeReturnValue: APIUnlinkBankResponse!
    public var deleteLinkedSourceSessionIdSourceIdSourceTypeClosure: ((String, String, String) async throws -> APIUnlinkBankResponse)?

    public func deleteLinkedSource(sessionId: String, sourceId: String, sourceType: String) async throws -> APIUnlinkBankResponse {
        if let error = deleteLinkedSourceSessionIdSourceIdSourceTypeThrowableError {
            throw error
        }
        deleteLinkedSourceSessionIdSourceIdSourceTypeCallsCount += 1
        deleteLinkedSourceSessionIdSourceIdSourceTypeReceivedArguments = (sessionId: sessionId, sourceId: sourceId, sourceType: sourceType)
        deleteLinkedSourceSessionIdSourceIdSourceTypeReceivedInvocations.append((sessionId: sessionId, sourceId: sourceId, sourceType: sourceType))
        if let deleteLinkedSourceSessionIdSourceIdSourceTypeClosure = deleteLinkedSourceSessionIdSourceIdSourceTypeClosure {
            return try await deleteLinkedSourceSessionIdSourceIdSourceTypeClosure(sessionId, sourceId, sourceType)
        } else {
            return deleteLinkedSourceSessionIdSourceIdSourceTypeReturnValue
        }
    }

    //MARK: - newTransaction

    public var newTransactionParametersTypeSessionIdThrowableError: Error?
    public var newTransactionParametersTypeSessionIdCallsCount = 0
    public var newTransactionParametersTypeSessionIdCalled: Bool {
        return newTransactionParametersTypeSessionIdCallsCount > 0
    }
    public var newTransactionParametersTypeSessionIdReceivedArguments: (parameters: ExternalTransactionParameters, type: ExternalTransactionType, sessionId: String)?
    public var newTransactionParametersTypeSessionIdReceivedInvocations: [(parameters: ExternalTransactionParameters, type: ExternalTransactionType, sessionId: String)] = []
    public var newTransactionParametersTypeSessionIdReturnValue: APIExternalTransactionResponse!
    public var newTransactionParametersTypeSessionIdClosure: ((ExternalTransactionParameters, ExternalTransactionType, String) async throws -> APIExternalTransactionResponse)?

    public func newTransaction(parameters: ExternalTransactionParameters, type: ExternalTransactionType, sessionId: String) async throws -> APIExternalTransactionResponse {
        if let error = newTransactionParametersTypeSessionIdThrowableError {
            throw error
        }
        newTransactionParametersTypeSessionIdCallsCount += 1
        newTransactionParametersTypeSessionIdReceivedArguments = (parameters: parameters, type: type, sessionId: sessionId)
        newTransactionParametersTypeSessionIdReceivedInvocations.append((parameters: parameters, type: type, sessionId: sessionId))
        if let newTransactionParametersTypeSessionIdClosure = newTransactionParametersTypeSessionIdClosure {
            return try await newTransactionParametersTypeSessionIdClosure(parameters, type, sessionId)
        } else {
            return newTransactionParametersTypeSessionIdReturnValue
        }
    }

    //MARK: - externalCardTransactionFee

    public var externalCardTransactionFeeParametersTypeSessionIdThrowableError: Error?
    public var externalCardTransactionFeeParametersTypeSessionIdCallsCount = 0
    public var externalCardTransactionFeeParametersTypeSessionIdCalled: Bool {
        return externalCardTransactionFeeParametersTypeSessionIdCallsCount > 0
    }
    public var externalCardTransactionFeeParametersTypeSessionIdReceivedArguments: (parameters: ExternalTransactionParameters, type: ExternalTransactionType, sessionId: String)?
    public var externalCardTransactionFeeParametersTypeSessionIdReceivedInvocations: [(parameters: ExternalTransactionParameters, type: ExternalTransactionType, sessionId: String)] = []
    public var externalCardTransactionFeeParametersTypeSessionIdReturnValue: APIExternalCardFeeResponse!
    public var externalCardTransactionFeeParametersTypeSessionIdClosure: ((ExternalTransactionParameters, ExternalTransactionType, String) async throws -> APIExternalCardFeeResponse)?

    public func externalCardTransactionFee(parameters: ExternalTransactionParameters, type: ExternalTransactionType, sessionId: String) async throws -> APIExternalCardFeeResponse {
        if let error = externalCardTransactionFeeParametersTypeSessionIdThrowableError {
            throw error
        }
        externalCardTransactionFeeParametersTypeSessionIdCallsCount += 1
        externalCardTransactionFeeParametersTypeSessionIdReceivedArguments = (parameters: parameters, type: type, sessionId: sessionId)
        externalCardTransactionFeeParametersTypeSessionIdReceivedInvocations.append((parameters: parameters, type: type, sessionId: sessionId))
        if let externalCardTransactionFeeParametersTypeSessionIdClosure = externalCardTransactionFeeParametersTypeSessionIdClosure {
            return try await externalCardTransactionFeeParametersTypeSessionIdClosure(parameters, type, sessionId)
        } else {
            return externalCardTransactionFeeParametersTypeSessionIdReturnValue
        }
    }

    //MARK: - verifyCard

    public var verifyCardSessionIdCardIdAmountThrowableError: Error?
    public var verifyCardSessionIdCardIdAmountCallsCount = 0
    public var verifyCardSessionIdCardIdAmountCalled: Bool {
        return verifyCardSessionIdCardIdAmountCallsCount > 0
    }
    public var verifyCardSessionIdCardIdAmountReceivedArguments: (sessionId: String, cardId: String, amount: Double)?
    public var verifyCardSessionIdCardIdAmountReceivedInvocations: [(sessionId: String, cardId: String, amount: Double)] = []
    public var verifyCardSessionIdCardIdAmountReturnValue: APIVerifyExternalCardResponse!
    public var verifyCardSessionIdCardIdAmountClosure: ((String, String, Double) async throws -> APIVerifyExternalCardResponse)?

    public func verifyCard(sessionId: String, cardId: String, amount: Double) async throws -> APIVerifyExternalCardResponse {
        if let error = verifyCardSessionIdCardIdAmountThrowableError {
            throw error
        }
        verifyCardSessionIdCardIdAmountCallsCount += 1
        verifyCardSessionIdCardIdAmountReceivedArguments = (sessionId: sessionId, cardId: cardId, amount: amount)
        verifyCardSessionIdCardIdAmountReceivedInvocations.append((sessionId: sessionId, cardId: cardId, amount: amount))
        if let verifyCardSessionIdCardIdAmountClosure = verifyCardSessionIdCardIdAmountClosure {
            return try await verifyCardSessionIdCardIdAmountClosure(sessionId, cardId, amount)
        } else {
            return verifyCardSessionIdCardIdAmountReturnValue
        }
    }

    //MARK: - getFundingStatus

    public var getFundingStatusSessionIDThrowableError: Error?
    public var getFundingStatusSessionIDCallsCount = 0
    public var getFundingStatusSessionIDCalled: Bool {
        return getFundingStatusSessionIDCallsCount > 0
    }
    public var getFundingStatusSessionIDReceivedSessionID: String?
    public var getFundingStatusSessionIDReceivedInvocations: [String] = []
    public var getFundingStatusSessionIDReturnValue: APIExternalFundingsatus!
    public var getFundingStatusSessionIDClosure: ((String) async throws -> APIExternalFundingsatus)?

    public func getFundingStatus(sessionID: String) async throws -> APIExternalFundingsatus {
        if let error = getFundingStatusSessionIDThrowableError {
            throw error
        }
        getFundingStatusSessionIDCallsCount += 1
        getFundingStatusSessionIDReceivedSessionID = sessionID
        getFundingStatusSessionIDReceivedInvocations.append(sessionID)
        if let getFundingStatusSessionIDClosure = getFundingStatusSessionIDClosure {
            return try await getFundingStatusSessionIDClosure(sessionID)
        } else {
            return getFundingStatusSessionIDReturnValue
        }
    }

    //MARK: - getCardRemainingAmount

    public var getCardRemainingAmountSessionIDTypeThrowableError: Error?
    public var getCardRemainingAmountSessionIDTypeCallsCount = 0
    public var getCardRemainingAmountSessionIDTypeCalled: Bool {
        return getCardRemainingAmountSessionIDTypeCallsCount > 0
    }
    public var getCardRemainingAmountSessionIDTypeReceivedArguments: (sessionID: String, type: String)?
    public var getCardRemainingAmountSessionIDTypeReceivedInvocations: [(sessionID: String, type: String)] = []
    public var getCardRemainingAmountSessionIDTypeReturnValue: [APITransferLimitConfig]!
    public var getCardRemainingAmountSessionIDTypeClosure: ((String, String) async throws -> [APITransferLimitConfig])?

    public func getCardRemainingAmount(sessionID: String, type: String) async throws -> [APITransferLimitConfig] {
        if let error = getCardRemainingAmountSessionIDTypeThrowableError {
            throw error
        }
        getCardRemainingAmountSessionIDTypeCallsCount += 1
        getCardRemainingAmountSessionIDTypeReceivedArguments = (sessionID: sessionID, type: type)
        getCardRemainingAmountSessionIDTypeReceivedInvocations.append((sessionID: sessionID, type: type))
        if let getCardRemainingAmountSessionIDTypeClosure = getCardRemainingAmountSessionIDTypeClosure {
            return try await getCardRemainingAmountSessionIDTypeClosure(sessionID, type)
        } else {
            return getCardRemainingAmountSessionIDTypeReturnValue
        }
    }

    //MARK: - getBankRemainingAmount

    public var getBankRemainingAmountSessionIDTypeThrowableError: Error?
    public var getBankRemainingAmountSessionIDTypeCallsCount = 0
    public var getBankRemainingAmountSessionIDTypeCalled: Bool {
        return getBankRemainingAmountSessionIDTypeCallsCount > 0
    }
    public var getBankRemainingAmountSessionIDTypeReceivedArguments: (sessionID: String, type: String)?
    public var getBankRemainingAmountSessionIDTypeReceivedInvocations: [(sessionID: String, type: String)] = []
    public var getBankRemainingAmountSessionIDTypeReturnValue: [APITransferLimitConfig]!
    public var getBankRemainingAmountSessionIDTypeClosure: ((String, String) async throws -> [APITransferLimitConfig])?

    public func getBankRemainingAmount(sessionID: String, type: String) async throws -> [APITransferLimitConfig] {
        if let error = getBankRemainingAmountSessionIDTypeThrowableError {
            throw error
        }
        getBankRemainingAmountSessionIDTypeCallsCount += 1
        getBankRemainingAmountSessionIDTypeReceivedArguments = (sessionID: sessionID, type: type)
        getBankRemainingAmountSessionIDTypeReceivedInvocations.append((sessionID: sessionID, type: type))
        if let getBankRemainingAmountSessionIDTypeClosure = getBankRemainingAmountSessionIDTypeClosure {
            return try await getBankRemainingAmountSessionIDTypeClosure(sessionID, type)
        } else {
            return getBankRemainingAmountSessionIDTypeReturnValue
        }
    }

}
