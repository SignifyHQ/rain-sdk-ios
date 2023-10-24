// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import DevicesDomain

public class MockDevicesRepositoryProtocol: DevicesRepositoryProtocol {

    public init() {}


    //MARK: - register

    public var registerDeviceIdTokenThrowableError: Error?
    public var registerDeviceIdTokenCallsCount = 0
    public var registerDeviceIdTokenCalled: Bool {
        return registerDeviceIdTokenCallsCount > 0
    }
    public var registerDeviceIdTokenReceivedArguments: (deviceId: String, token: String)?
    public var registerDeviceIdTokenReceivedInvocations: [(deviceId: String, token: String)] = []
    public var registerDeviceIdTokenReturnValue: NotificationTokenEntity!
    public var registerDeviceIdTokenClosure: ((String, String) async throws -> NotificationTokenEntity)?

    public func register(deviceId: String, token: String) async throws -> NotificationTokenEntity {
        if let error = registerDeviceIdTokenThrowableError {
            throw error
        }
        registerDeviceIdTokenCallsCount += 1
        registerDeviceIdTokenReceivedArguments = (deviceId: deviceId, token: token)
        registerDeviceIdTokenReceivedInvocations.append((deviceId: deviceId, token: token))
        if let registerDeviceIdTokenClosure = registerDeviceIdTokenClosure {
            return try await registerDeviceIdTokenClosure(deviceId, token)
        } else {
            return registerDeviceIdTokenReturnValue
        }
    }

    //MARK: - deregister

    public var deregisterDeviceIdTokenThrowableError: Error?
    public var deregisterDeviceIdTokenCallsCount = 0
    public var deregisterDeviceIdTokenCalled: Bool {
        return deregisterDeviceIdTokenCallsCount > 0
    }
    public var deregisterDeviceIdTokenReceivedArguments: (deviceId: String, token: String)?
    public var deregisterDeviceIdTokenReceivedInvocations: [(deviceId: String, token: String)] = []
    public var deregisterDeviceIdTokenReturnValue: NotificationTokenEntity!
    public var deregisterDeviceIdTokenClosure: ((String, String) async throws -> NotificationTokenEntity)?

    public func deregister(deviceId: String, token: String) async throws -> NotificationTokenEntity {
        if let error = deregisterDeviceIdTokenThrowableError {
            throw error
        }
        deregisterDeviceIdTokenCallsCount += 1
        deregisterDeviceIdTokenReceivedArguments = (deviceId: deviceId, token: token)
        deregisterDeviceIdTokenReceivedInvocations.append((deviceId: deviceId, token: token))
        if let deregisterDeviceIdTokenClosure = deregisterDeviceIdTokenClosure {
            return try await deregisterDeviceIdTokenClosure(deviceId, token)
        } else {
            return deregisterDeviceIdTokenReturnValue
        }
    }

}
