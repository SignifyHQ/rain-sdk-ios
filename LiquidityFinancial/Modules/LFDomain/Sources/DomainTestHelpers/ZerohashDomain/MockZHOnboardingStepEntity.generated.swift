// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import ZerohashDomain
import AccountDomain

public class MockZHOnboardingStepEntity: ZHOnboardingStepEntity {

    public init() {}

    public var missingSteps: [String] = []

    //MARK: - init

    public var initMissingStepsReceivedMissingSteps: [String]?
    public var initMissingStepsReceivedInvocations: [[String]] = []
    public var initMissingStepsClosure: (([String]) -> Void)?

    public required init(missingSteps: [String]) {
        initMissingStepsReceivedMissingSteps = missingSteps
        initMissingStepsReceivedInvocations.append(missingSteps)
        initMissingStepsClosure?(missingSteps)
    }
}
