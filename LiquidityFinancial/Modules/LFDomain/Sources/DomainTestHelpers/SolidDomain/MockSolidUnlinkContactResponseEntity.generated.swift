// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidDomain

public class MockSolidUnlinkContactResponseEntity: SolidUnlinkContactResponseEntity {

    public init() {}

    public var success: Bool {
        get { return underlyingSuccess }
        set(value) { underlyingSuccess = value }
    }
    public var underlyingSuccess: Bool!

}
