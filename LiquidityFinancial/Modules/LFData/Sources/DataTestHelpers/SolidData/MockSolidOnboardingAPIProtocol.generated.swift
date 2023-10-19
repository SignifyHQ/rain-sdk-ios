// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidData

public class MockSolidOnboardingAPIProtocol: SolidOnboardingAPIProtocol {

    public init() {}


    //MARK: - getOnboardingStep

    public var getOnboardingStepThrowableError: Error?
    public var getOnboardingStepCallsCount = 0
    public var getOnboardingStepCalled: Bool {
        return getOnboardingStepCallsCount > 0
    }
    public var getOnboardingStepReturnValue: APISolidOnboardingStep!
    public var getOnboardingStepClosure: (() async throws -> APISolidOnboardingStep)?

    public func getOnboardingStep() async throws -> APISolidOnboardingStep {
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
    public var createPersonParametersReceivedParameters: APISolidPersonParameters?
    public var createPersonParametersReceivedInvocations: [APISolidPersonParameters] = []
    public var createPersonParametersReturnValue: Bool!
    public var createPersonParametersClosure: ((APISolidPersonParameters) async throws -> Bool)?

    public func createPerson(parameters: APISolidPersonParameters) async throws -> Bool {
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
