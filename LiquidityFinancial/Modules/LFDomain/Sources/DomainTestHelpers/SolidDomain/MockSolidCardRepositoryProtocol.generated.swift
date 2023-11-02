// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import SolidDomain

public class MockSolidCardRepositoryProtocol: SolidCardRepositoryProtocol {

    public init() {}


    //MARK: - getListCard

    public var getListCardThrowableError: Error?
    public var getListCardCallsCount = 0
    public var getListCardCalled: Bool {
        return getListCardCallsCount > 0
    }
    public var getListCardReturnValue: [SolidCardEntity]!
    public var getListCardClosure: (() async throws -> [SolidCardEntity])?

    public func getListCard() async throws -> [SolidCardEntity] {
        if let error = getListCardThrowableError {
            throw error
        }
        getListCardCallsCount += 1
        if let getListCardClosure = getListCardClosure {
            return try await getListCardClosure()
        } else {
            return getListCardReturnValue
        }
    }

}
