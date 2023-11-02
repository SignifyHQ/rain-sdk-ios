// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidDomain

public class MockSolidCardStatusParametersEntity: SolidCardStatusParametersEntity {

    public init() {}

    public var cardStatus: String {
        get { return underlyingCardStatus }
        set(value) { underlyingCardStatus = value }
    }
    public var underlyingCardStatus: String!

}
