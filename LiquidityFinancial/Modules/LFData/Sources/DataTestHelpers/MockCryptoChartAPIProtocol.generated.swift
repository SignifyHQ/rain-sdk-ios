// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import CryptoChartData
import Foundation

public class MockCryptoChartAPIProtocol: CryptoChartAPIProtocol {

    public init() {}


    //MARK: - getCMCSymbolHistories

    public var getCMCSymbolHistoriesSymbolPeriodThrowableError: Error?
    public var getCMCSymbolHistoriesSymbolPeriodCallsCount = 0
    public var getCMCSymbolHistoriesSymbolPeriodCalled: Bool {
        return getCMCSymbolHistoriesSymbolPeriodCallsCount > 0
    }
    public var getCMCSymbolHistoriesSymbolPeriodReceivedArguments: (symbol: String, period: String)?
    public var getCMCSymbolHistoriesSymbolPeriodReceivedInvocations: [(symbol: String, period: String)] = []
    public var getCMCSymbolHistoriesSymbolPeriodReturnValue: [APICMCSymbolHistories]!
    public var getCMCSymbolHistoriesSymbolPeriodClosure: ((String, String) async throws -> [APICMCSymbolHistories])?

    public func getCMCSymbolHistories(symbol: String, period: String) async throws -> [APICMCSymbolHistories] {
        if let error = getCMCSymbolHistoriesSymbolPeriodThrowableError {
            throw error
        }
        getCMCSymbolHistoriesSymbolPeriodCallsCount += 1
        getCMCSymbolHistoriesSymbolPeriodReceivedArguments = (symbol: symbol, period: period)
        getCMCSymbolHistoriesSymbolPeriodReceivedInvocations.append((symbol: symbol, period: period))
        if let getCMCSymbolHistoriesSymbolPeriodClosure = getCMCSymbolHistoriesSymbolPeriodClosure {
            return try await getCMCSymbolHistoriesSymbolPeriodClosure(symbol, period)
        } else {
            return getCMCSymbolHistoriesSymbolPeriodReturnValue
        }
    }

}
