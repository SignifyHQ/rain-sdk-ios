import Foundation
import PinwheelSDK
import LFUtilities

public class PinWheelService: PinwheelDelegate {
  public var onDismiss: ((String?) -> Void)?
  public var onSuccess: (() -> Void)?
  
  public init() {}
  
  public nonisolated func onEvent(name: PinwheelSDK.PinwheelEventType, event: PinwheelSDK.PinwheelEventPayload?) {
    log.info("PinWheel name: \(name), event: \(String(describing: event))")
  }
  
  public nonisolated func onExit(_ error: PinwheelSDK.PinwheelError?) {
    log.info("Link exit, with error: \(String(describing: error))")
    if let error = error {
      Haptic.notification(.error).generate()
      onDismiss?("Failed to link: \(error.message)")
    } else {
      onDismiss?(nil)
    }
  }
  
  public nonisolated func onSuccess(_ result: PinwheelSDK.PinwheelSuccessPayload) {
    log.info("Link success, result: \(result)")
    Haptic.notification(.success).generate()
    onDismiss?("Direct deposit link success")
    onSuccess?()
  }
  
  public nonisolated func onLogin(_ result: PinwheelSDK.PinwheelLoginPayload) {
  }
  
  public nonisolated func onLoginAttempt(_ result: PinwheelSDK.PinwheelLoginAttemptPayload) {
  }
  
  public nonisolated func onError(_ error: PinwheelSDK.PinwheelError) {
  }
}
