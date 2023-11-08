// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import NetspendDomain

public class MockExternalBankStatusEntity: ExternalBankStatusEntity {

    public init() {}

    public var errorCode: String?
    public var depositStatus: String?
    public var withdrawStatus: String?
    public var documents: [String]?
    public var description: String?
    public var missingSteps: [String]?

}
