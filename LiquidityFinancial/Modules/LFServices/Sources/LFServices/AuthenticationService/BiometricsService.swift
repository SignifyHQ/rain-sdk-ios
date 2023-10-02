import Foundation
import LocalAuthentication
import UIKit
import LFUtilities
import Factory

extension Container {
  public var biometricsService: Factory<BiometricsService> {
    self {
      BiometricsService()
    }.singleton
  }
}

public struct BiometricsService {
  private(set) var context = LAContext()
  
  public func authenticateWithBiometrics() async -> Bool {
    let context = LAContext()
    if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
      let localizedReason = "Log into your account"
      do {
        let success = try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: localizedReason)
        log.info("Biometrics completed with result: \(success)")
        return success
      } catch {
        return false
      }
    } else {
      log.error("Cannot evaluate authentication")
      return false
    }
  }
}
