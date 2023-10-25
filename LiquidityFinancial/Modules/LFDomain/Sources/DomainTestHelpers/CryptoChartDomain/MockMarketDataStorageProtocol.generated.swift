// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import CryptoChartDomain
import Combine

public class MockMarketDataStorageProtocol: MarketDataStorageProtocol {

    public init() {}


    //MARK: - subscribeLineModelsChanged

    public var subscribeLineModelsChangedCallsCount = 0
    public var subscribeLineModelsChangedCalled: Bool {
        return subscribeLineModelsChangedCallsCount > 0
    }
    public var subscribeLineModelsChangedReceivedCompletion: (([String]) -> Void)?
    public var subscribeLineModelsChangedReceivedInvocations: [(([String]) -> Void)] = []
    public var subscribeLineModelsChangedReturnValue: Cancellable!
    public var subscribeLineModelsChangedClosure: ((@escaping ([String]) -> Void) -> Cancellable)?

    public func subscribeLineModelsChanged(_ completion: @escaping ([String]) -> Void) -> Cancellable {
        subscribeLineModelsChangedCallsCount += 1
        subscribeLineModelsChangedReceivedCompletion = completion
        subscribeLineModelsChangedReceivedInvocations.append(completion)
        if let subscribeLineModelsChangedClosure = subscribeLineModelsChangedClosure {
            return subscribeLineModelsChangedClosure(completion)
        } else {
            return subscribeLineModelsChangedReturnValue
        }
    }

}
