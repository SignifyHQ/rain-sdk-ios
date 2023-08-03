import PinwheelSDK
import SwiftUI

public struct PinWheelViewController: UIViewControllerRepresentable {
  public typealias UIViewControllerType = PinwheelViewController
  let data: PinWheelData
  
  public init(data: PinWheelData) {
    self.data = data
  }
  
  public func makeUIViewController(context: Context) -> PinwheelViewController {
    PinwheelViewController(
      token: data.token,
      delegate: data.delegate,
      config: .init(mode: .sandbox, environment: .production)
    )
  }
  
  public func updateUIViewController(_ uiViewController: PinwheelViewController, context: Context) {}
}

// MARK: - Types
extension PinWheelViewController {
  public struct PinWheelData: Identifiable {
    public let id = UUID()
    public let delegate: PinwheelDelegate
    public let token: String
    
    public init(delegate: PinwheelDelegate, token: String) {
      self.delegate = delegate
      self.token = token
    }
  }
}
