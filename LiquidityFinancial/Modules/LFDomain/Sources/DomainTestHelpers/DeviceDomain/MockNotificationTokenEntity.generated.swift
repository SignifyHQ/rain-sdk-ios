// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import DevicesDomain

public class MockNotificationTokenEntity: NotificationTokenEntity {

    public init() {}

    public var success: Bool {
        get { return underlyingSuccess }
        set(value) { underlyingSuccess = value }
    }
    public var underlyingSuccess: Bool!

    //MARK: - init

    public var initSuccessReceivedSuccess: Bool?
    public var initSuccessReceivedInvocations: [Bool] = []
    public var initSuccessClosure: ((Bool) -> Void)?

    public required init(success: Bool) {
        initSuccessReceivedSuccess = success
        initSuccessReceivedInvocations.append(success)
        initSuccessClosure?(success)
    }
}
