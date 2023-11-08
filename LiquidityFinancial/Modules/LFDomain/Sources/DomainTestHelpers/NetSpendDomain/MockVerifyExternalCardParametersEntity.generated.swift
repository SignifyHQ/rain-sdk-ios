// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import NetspendDomain

public class MockVerifyExternalCardParametersEntity: VerifyExternalCardParametersEntity {

    public init() {}

    public var transferAmount: Double {
        get { return underlyingTransferAmount }
        set(value) { underlyingTransferAmount = value }
    }
    public var underlyingTransferAmount: Double!
    public var cardId: String {
        get { return underlyingCardId }
        set(value) { underlyingCardId = value }
    }
    public var underlyingCardId: String!

}
