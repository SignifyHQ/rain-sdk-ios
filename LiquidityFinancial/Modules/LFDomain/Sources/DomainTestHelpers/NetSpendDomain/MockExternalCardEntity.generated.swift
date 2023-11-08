// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import NetspendDomain

public class MockExternalCardEntity: ExternalCardEntity {

    public init() {}

    public var cardId: String {
        get { return underlyingCardId }
        set(value) { underlyingCardId = value }
    }
    public var underlyingCardId: String!

}
