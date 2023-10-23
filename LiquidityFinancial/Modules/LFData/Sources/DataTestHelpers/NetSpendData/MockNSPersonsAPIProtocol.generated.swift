// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import NetSpendData

public class MockNSPersonsAPIProtocol: NSPersonsAPIProtocol {

    public init() {}


    //MARK: - sessionInit

    public var sessionInitThrowableError: Error?
    public var sessionInitCallsCount = 0
    public var sessionInitCalled: Bool {
        return sessionInitCallsCount > 0
    }
    public var sessionInitReturnValue: APINSJwkToken!
    public var sessionInitClosure: (() async throws -> APINSJwkToken)?

    public func sessionInit() async throws -> APINSJwkToken {
        if let error = sessionInitThrowableError {
            throw error
        }
        sessionInitCallsCount += 1
        if let sessionInitClosure = sessionInitClosure {
            return try await sessionInitClosure()
        } else {
            return sessionInitReturnValue
        }
    }

    //MARK: - establishSession

    public var establishSessionDeviceDataThrowableError: Error?
    public var establishSessionDeviceDataCallsCount = 0
    public var establishSessionDeviceDataCalled: Bool {
        return establishSessionDeviceDataCallsCount > 0
    }
    public var establishSessionDeviceDataReceivedDeviceData: EstablishSessionParameters?
    public var establishSessionDeviceDataReceivedInvocations: [EstablishSessionParameters] = []
    public var establishSessionDeviceDataReturnValue: APIEstablishedSessionData!
    public var establishSessionDeviceDataClosure: ((EstablishSessionParameters) async throws -> APIEstablishedSessionData)?

    public func establishSession(deviceData: EstablishSessionParameters) async throws -> APIEstablishedSessionData {
        if let error = establishSessionDeviceDataThrowableError {
            throw error
        }
        establishSessionDeviceDataCallsCount += 1
        establishSessionDeviceDataReceivedDeviceData = deviceData
        establishSessionDeviceDataReceivedInvocations.append(deviceData)
        if let establishSessionDeviceDataClosure = establishSessionDeviceDataClosure {
            return try await establishSessionDeviceDataClosure(deviceData)
        } else {
            return establishSessionDeviceDataReturnValue
        }
    }

    //MARK: - getAgreement

    public var getAgreementThrowableError: Error?
    public var getAgreementCallsCount = 0
    public var getAgreementCalled: Bool {
        return getAgreementCallsCount > 0
    }
    public var getAgreementReturnValue: APIAgreementData!
    public var getAgreementClosure: (() async throws -> APIAgreementData)?

    public func getAgreement() async throws -> APIAgreementData {
        if let error = getAgreementThrowableError {
            throw error
        }
        getAgreementCallsCount += 1
        if let getAgreementClosure = getAgreementClosure {
            return try await getAgreementClosure()
        } else {
            return getAgreementReturnValue
        }
    }

    //MARK: - createAccountPerson

    public var createAccountPersonPersonInfoSessionIdThrowableError: Error?
    public var createAccountPersonPersonInfoSessionIdCallsCount = 0
    public var createAccountPersonPersonInfoSessionIdCalled: Bool {
        return createAccountPersonPersonInfoSessionIdCallsCount > 0
    }
    public var createAccountPersonPersonInfoSessionIdReceivedArguments: (personInfo: AccountPersonParameters, sessionId: String)?
    public var createAccountPersonPersonInfoSessionIdReceivedInvocations: [(personInfo: AccountPersonParameters, sessionId: String)] = []
    public var createAccountPersonPersonInfoSessionIdReturnValue: APIAccountPersonData!
    public var createAccountPersonPersonInfoSessionIdClosure: ((AccountPersonParameters, String) async throws -> APIAccountPersonData)?

    public func createAccountPerson(personInfo: AccountPersonParameters, sessionId: String) async throws -> APIAccountPersonData {
        if let error = createAccountPersonPersonInfoSessionIdThrowableError {
            throw error
        }
        createAccountPersonPersonInfoSessionIdCallsCount += 1
        createAccountPersonPersonInfoSessionIdReceivedArguments = (personInfo: personInfo, sessionId: sessionId)
        createAccountPersonPersonInfoSessionIdReceivedInvocations.append((personInfo: personInfo, sessionId: sessionId))
        if let createAccountPersonPersonInfoSessionIdClosure = createAccountPersonPersonInfoSessionIdClosure {
            return try await createAccountPersonPersonInfoSessionIdClosure(personInfo, sessionId)
        } else {
            return createAccountPersonPersonInfoSessionIdReturnValue
        }
    }

    //MARK: - getQuestion

    public var getQuestionSessionIdThrowableError: Error?
    public var getQuestionSessionIdCallsCount = 0
    public var getQuestionSessionIdCalled: Bool {
        return getQuestionSessionIdCallsCount > 0
    }
    public var getQuestionSessionIdReceivedSessionId: String?
    public var getQuestionSessionIdReceivedInvocations: [String] = []
    public var getQuestionSessionIdReturnValue: APIQuestionData!
    public var getQuestionSessionIdClosure: ((String) async throws -> APIQuestionData)?

    public func getQuestion(sessionId: String) async throws -> APIQuestionData {
        if let error = getQuestionSessionIdThrowableError {
            throw error
        }
        getQuestionSessionIdCallsCount += 1
        getQuestionSessionIdReceivedSessionId = sessionId
        getQuestionSessionIdReceivedInvocations.append(sessionId)
        if let getQuestionSessionIdClosure = getQuestionSessionIdClosure {
            return try await getQuestionSessionIdClosure(sessionId)
        } else {
            return getQuestionSessionIdReturnValue
        }
    }

    //MARK: - putQuestion

    public var putQuestionSessionIdEncryptedDataThrowableError: Error?
    public var putQuestionSessionIdEncryptedDataCallsCount = 0
    public var putQuestionSessionIdEncryptedDataCalled: Bool {
        return putQuestionSessionIdEncryptedDataCallsCount > 0
    }
    public var putQuestionSessionIdEncryptedDataReceivedArguments: (sessionId: String, encryptedData: String)?
    public var putQuestionSessionIdEncryptedDataReceivedInvocations: [(sessionId: String, encryptedData: String)] = []
    public var putQuestionSessionIdEncryptedDataReturnValue: Bool!
    public var putQuestionSessionIdEncryptedDataClosure: ((String, String) async throws -> Bool)?

    public func putQuestion(sessionId: String, encryptedData: String) async throws -> Bool {
        if let error = putQuestionSessionIdEncryptedDataThrowableError {
            throw error
        }
        putQuestionSessionIdEncryptedDataCallsCount += 1
        putQuestionSessionIdEncryptedDataReceivedArguments = (sessionId: sessionId, encryptedData: encryptedData)
        putQuestionSessionIdEncryptedDataReceivedInvocations.append((sessionId: sessionId, encryptedData: encryptedData))
        if let putQuestionSessionIdEncryptedDataClosure = putQuestionSessionIdEncryptedDataClosure {
            return try await putQuestionSessionIdEncryptedDataClosure(sessionId, encryptedData)
        } else {
            return putQuestionSessionIdEncryptedDataReturnValue
        }
    }

    //MARK: - getWorkflows

    public var getWorkflowsThrowableError: Error?
    public var getWorkflowsCallsCount = 0
    public var getWorkflowsCalled: Bool {
        return getWorkflowsCallsCount > 0
    }
    public var getWorkflowsReturnValue: APIWorkflowsData!
    public var getWorkflowsClosure: (() async throws -> APIWorkflowsData)?

    public func getWorkflows() async throws -> APIWorkflowsData {
        if let error = getWorkflowsThrowableError {
            throw error
        }
        getWorkflowsCallsCount += 1
        if let getWorkflowsClosure = getWorkflowsClosure {
            return try await getWorkflowsClosure()
        } else {
            return getWorkflowsReturnValue
        }
    }

    //MARK: - getDocuments

    public var getDocumentsSessionIdThrowableError: Error?
    public var getDocumentsSessionIdCallsCount = 0
    public var getDocumentsSessionIdCalled: Bool {
        return getDocumentsSessionIdCallsCount > 0
    }
    public var getDocumentsSessionIdReceivedSessionId: String?
    public var getDocumentsSessionIdReceivedInvocations: [String] = []
    public var getDocumentsSessionIdReturnValue: APIDocumentData!
    public var getDocumentsSessionIdClosure: ((String) async throws -> APIDocumentData)?

    public func getDocuments(sessionId: String) async throws -> APIDocumentData {
        if let error = getDocumentsSessionIdThrowableError {
            throw error
        }
        getDocumentsSessionIdCallsCount += 1
        getDocumentsSessionIdReceivedSessionId = sessionId
        getDocumentsSessionIdReceivedInvocations.append(sessionId)
        if let getDocumentsSessionIdClosure = getDocumentsSessionIdClosure {
            return try await getDocumentsSessionIdClosure(sessionId)
        } else {
            return getDocumentsSessionIdReturnValue
        }
    }

    //MARK: - uploadDocuments

    public var uploadDocumentsPathDocumentDataThrowableError: Error?
    public var uploadDocumentsPathDocumentDataCallsCount = 0
    public var uploadDocumentsPathDocumentDataCalled: Bool {
        return uploadDocumentsPathDocumentDataCallsCount > 0
    }
    public var uploadDocumentsPathDocumentDataReceivedArguments: (path: PathDocumentParameters, documentData: DocumentParameters)?
    public var uploadDocumentsPathDocumentDataReceivedInvocations: [(path: PathDocumentParameters, documentData: DocumentParameters)] = []
    public var uploadDocumentsPathDocumentDataReturnValue: APIDocumentData.RequestedDocument!
    public var uploadDocumentsPathDocumentDataClosure: ((PathDocumentParameters, DocumentParameters) async throws -> APIDocumentData.RequestedDocument)?

    public func uploadDocuments(path: PathDocumentParameters, documentData: DocumentParameters) async throws -> APIDocumentData.RequestedDocument {
        if let error = uploadDocumentsPathDocumentDataThrowableError {
            throw error
        }
        uploadDocumentsPathDocumentDataCallsCount += 1
        uploadDocumentsPathDocumentDataReceivedArguments = (path: path, documentData: documentData)
        uploadDocumentsPathDocumentDataReceivedInvocations.append((path: path, documentData: documentData))
        if let uploadDocumentsPathDocumentDataClosure = uploadDocumentsPathDocumentDataClosure {
            return try await uploadDocumentsPathDocumentDataClosure(path, documentData)
        } else {
            return uploadDocumentsPathDocumentDataReturnValue
        }
    }

    //MARK: - getAuthorizationCode

    public var getAuthorizationCodeSessionIdThrowableError: Error?
    public var getAuthorizationCodeSessionIdCallsCount = 0
    public var getAuthorizationCodeSessionIdCalled: Bool {
        return getAuthorizationCodeSessionIdCallsCount > 0
    }
    public var getAuthorizationCodeSessionIdReceivedSessionId: String?
    public var getAuthorizationCodeSessionIdReceivedInvocations: [String] = []
    public var getAuthorizationCodeSessionIdReturnValue: APIAuthorizationCode!
    public var getAuthorizationCodeSessionIdClosure: ((String) async throws -> APIAuthorizationCode)?

    public func getAuthorizationCode(sessionId: String) async throws -> APIAuthorizationCode {
        if let error = getAuthorizationCodeSessionIdThrowableError {
            throw error
        }
        getAuthorizationCodeSessionIdCallsCount += 1
        getAuthorizationCodeSessionIdReceivedSessionId = sessionId
        getAuthorizationCodeSessionIdReceivedInvocations.append(sessionId)
        if let getAuthorizationCodeSessionIdClosure = getAuthorizationCodeSessionIdClosure {
            return try await getAuthorizationCodeSessionIdClosure(sessionId)
        } else {
            return getAuthorizationCodeSessionIdReturnValue
        }
    }

    //MARK: - postAgreement

    public var postAgreementBodyThrowableError: Error?
    public var postAgreementBodyCallsCount = 0
    public var postAgreementBodyCalled: Bool {
        return postAgreementBodyCallsCount > 0
    }
    public var postAgreementBodyReceivedBody: [String: Any]?
    public var postAgreementBodyReceivedInvocations: [[String: Any]] = []
    public var postAgreementBodyReturnValue: Bool!
    public var postAgreementBodyClosure: (([String: Any]) async throws -> Bool)?

    public func postAgreement(body: [String: Any]) async throws -> Bool {
        if let error = postAgreementBodyThrowableError {
            throw error
        }
        postAgreementBodyCallsCount += 1
        postAgreementBodyReceivedBody = body
        postAgreementBodyReceivedInvocations.append(body)
        if let postAgreementBodyClosure = postAgreementBodyClosure {
            return try await postAgreementBodyClosure(body)
        } else {
            return postAgreementBodyReturnValue
        }
    }

    //MARK: - getSession

    public var getSessionSessionIdThrowableError: Error?
    public var getSessionSessionIdCallsCount = 0
    public var getSessionSessionIdCalled: Bool {
        return getSessionSessionIdCallsCount > 0
    }
    public var getSessionSessionIdReceivedSessionId: String?
    public var getSessionSessionIdReceivedInvocations: [String] = []
    public var getSessionSessionIdReturnValue: APISessionData!
    public var getSessionSessionIdClosure: ((String) async throws -> APISessionData)?

    public func getSession(sessionId: String) async throws -> APISessionData {
        if let error = getSessionSessionIdThrowableError {
            throw error
        }
        getSessionSessionIdCallsCount += 1
        getSessionSessionIdReceivedSessionId = sessionId
        getSessionSessionIdReceivedInvocations.append(sessionId)
        if let getSessionSessionIdClosure = getSessionSessionIdClosure {
            return try await getSessionSessionIdClosure(sessionId)
        } else {
            return getSessionSessionIdReturnValue
        }
    }

}
