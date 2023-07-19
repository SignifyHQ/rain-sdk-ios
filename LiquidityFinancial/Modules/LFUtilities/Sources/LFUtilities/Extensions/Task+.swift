import Foundation
import SwiftUI

public extension Task where Success == Never, Failure == Never {
    // Once iOS 15 support is dropped, we can use native `Task.sleep()` instead.
  static func sleep(seconds: Double) async throws {
    let duration = UInt64(seconds * 1_000_000_000)
    try await Task.sleep(nanoseconds: duration)
  }
}
