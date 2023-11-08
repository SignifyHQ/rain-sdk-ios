// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidDomain

public class MockSolidDigitalWalletEntity: SolidDigitalWalletEntity {

    public init() {}

    public var wallet: String {
        get { return underlyingWallet }
        set(value) { underlyingWallet = value }
    }
    public var underlyingWallet: String!
    public var applePayEntity: SolidApplePayEntity?

}
