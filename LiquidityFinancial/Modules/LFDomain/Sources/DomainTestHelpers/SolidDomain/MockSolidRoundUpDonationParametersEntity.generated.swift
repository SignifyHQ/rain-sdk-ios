// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidDomain

public class MockSolidRoundUpDonationParametersEntity: SolidRoundUpDonationParametersEntity {

    public init() {}

    public var roundUpDonation: Bool {
        get { return underlyingRoundUpDonation }
        set(value) { underlyingRoundUpDonation = value }
    }
    public var underlyingRoundUpDonation: Bool!

}
