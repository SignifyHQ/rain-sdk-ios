// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidDomain

public class MockSolidCardEntity: SolidCardEntity {

    public init() {}

    public var id: String {
        get { return underlyingId }
        set(value) { underlyingId = value }
    }
    public var underlyingId: String!
    public var expirationMonth: String {
        get { return underlyingExpirationMonth }
        set(value) { underlyingExpirationMonth = value }
    }
    public var underlyingExpirationMonth: String!
    public var expirationYear: String {
        get { return underlyingExpirationYear }
        set(value) { underlyingExpirationYear = value }
    }
    public var underlyingExpirationYear: String!
    public var panLast4: String {
        get { return underlyingPanLast4 }
        set(value) { underlyingPanLast4 = value }
    }
    public var underlyingPanLast4: String!
    public var type: String {
        get { return underlyingType }
        set(value) { underlyingType = value }
    }
    public var underlyingType: String!
    public var cardStatus: String {
        get { return underlyingCardStatus }
        set(value) { underlyingCardStatus = value }
    }
    public var underlyingCardStatus: String!
    public var createdAt: String?

}
