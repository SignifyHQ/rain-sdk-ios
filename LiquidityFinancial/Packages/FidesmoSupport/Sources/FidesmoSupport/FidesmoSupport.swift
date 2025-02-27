import Foundation
import FidesmoCore
import CoreNfcBridge
import RxSwift

public struct FidesmoSupport {
    // App IDs for payment applications
    public static let fidesmoPayAppId = "f374c57e"
    public static let fidesmoPayStagingAppId = "af1cc990"

    public static let fidesmoPayInstallServiceId = "install"
    public static let fidesmoPayDeleteServiceId = "uninstall"

    public static let fidesmoTestAppId = "e26b8f12"
    public static let fidesmoTestInstallServiceId = "install"
    public static let fidesmoTestDeleteServiceId = "delete"

    public static let clientInfo = ClientInfo(clientType: .iphone, applicationName: "LiquidityFinancial")
    public static let apiDispatcher = FidesmoApiDispatcher(host: FidesmoApiDispatcher.fidesmoApiBaseUrl, localeStrings: "en")
    
    public static func createNFCManager(delegate: NfcConnectionDelegate) -> NfcManager {
        return NfcManager(listener: delegate)
    }
    
    public static func parseDeliveryProgress(progress: DeliveryProgress) -> String {
        switch progress {
        case .notStarted:
            return "Starting delivery..."
        case let .operationInProgress(_, dataFlow):
            switch dataFlow {
            case .talkingToServer:
                return "Talking to server..."
            case .toDevice:
                return "Sending commands to device..."
            case .toServer:
                return "Processing response from device..."
            }
        case let .finished(status):
            return status.success ? "Operation completed successfully!" : "Operation failed: \(status.message.getFormattedText())"
        default:
            return "Processing..."
        }
    }
} 