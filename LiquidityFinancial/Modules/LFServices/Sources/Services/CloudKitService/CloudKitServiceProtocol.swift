import Foundation
import Combine

// MARK: - CloudKitServiceProtocol
public protocol CloudKitServiceProtocol {
  var isICloudAccountAvailable: Bool { get }
}
