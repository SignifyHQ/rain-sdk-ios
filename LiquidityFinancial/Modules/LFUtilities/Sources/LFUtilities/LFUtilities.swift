import Foundation
// swiftlint:disable convenience_type identifier_name

public final class LFUtilities {
  
  public let systemInfo = SystemInfo()
  
  public private(set) static var target: Configs.Target!
  
  public static func initial(target: String) {
    if let target = Configs.Target(rawValue: target) {
      self.target = target
    } else {
      fatalError("Wrong the target name \(target). It must right for setup the module")
    }
  }
  
  public static var isSimulatorOrTestFlight: Bool {
    guard let receiptURL = Bundle.main.appStoreReceiptURL else {
      return false
    }
    if receiptURL.absoluteString.contains("CoreSimulator") {
      return true
    }
      // We are running in sandbox when receipt URL ends with 'sandboxReceipt'
    let isSandbox = receiptURL.absoluteString.hasSuffix("sandboxReceipt")
    return isSandbox
  }
  
}

extension LFUtilities {
  
  public struct Configs {
    public enum Target: String {
      case Avalanche
      case Cardano
      case DogeCard
      case CauseCard
      case PrideCard
    }
  }
  
  public struct SystemInfo {
    let marketingVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
    let bundleName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "unkwnown"
  }
  
}
