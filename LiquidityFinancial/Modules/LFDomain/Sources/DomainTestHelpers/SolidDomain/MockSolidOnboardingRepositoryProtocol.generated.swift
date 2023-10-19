// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidDomain

public class MockSolidOnboardingRepositoryProtocol: SolidOnboardingRepositoryProtocol {

    public init() {}


    //MARK: - getOnboardingStep

    public var getOnboardingStepThrowableError: Error?
    public var getOnboardingStepCallsCount = 0
    public var getOnboardingStepCalled: Bool {
        return getOnboardingStepCallsCount > 0
    }
    public var getOnboardingStepReturnValue: SolidOnboardingStepEntity!
    public var getOnboardingStepClosure: (() async throws -> SolidOnboardingStepEntity)?

    public func getOnboardingStep() async throws -> SolidOnboardingStepEntity {
        if let error = getOnboardingStepThrowableError {
            throw error
        }
        getOnboardingStepCallsCount += 1
        if let getOnboardingStepClosure = getOnboardingStepClosure {
            return try await getOnboardingStepClosure()
        } else {
            return getOnboardingStepReturnValue
        }
    }

    //MARK: - createPerson

    public var createPersonParametersThrowableError: Error?
    public var createPersonParametersCallsCount = 0
    public var createPersonParametersCalled: Bool {
        return createPersonParametersCallsCount > 0
    }
    public var createPersonParametersReceivedParameters: SolidPersonParametersEntity?
    public var createPersonParametersReceivedInvocations: [SolidPersonParametersEntity] = []
    public var createPersonParametersReturnValue: Bool!
    public var createPersonParametersClosure: ((SolidPersonParametersEntity) async throws -> Bool)?

    public func createPerson(parameters: SolidPersonParametersEntity) async throws -> Bool {
        if let error = createPersonParametersThrowableError {
            throw error
        }
        createPersonParametersCallsCount += 1
        createPersonParametersReceivedParameters = parameters
        createPersonParametersReceivedInvocations.append(parameters)
        if let createPersonParametersClosure = createPersonParametersClosure {
            return try await createPersonParametersClosure(parameters)
        } else {
            return createPersonParametersReturnValue
        }
    }

}
