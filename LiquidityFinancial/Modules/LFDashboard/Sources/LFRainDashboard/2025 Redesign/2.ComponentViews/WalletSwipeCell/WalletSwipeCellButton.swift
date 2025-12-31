import Foundation
import SwiftUI
import AccountData

struct WalletSwipeCellButton {
  let image: Image
  let backgroundColor: Color
  let action: (APIWalletAddress?) -> Void
  
  init(
    image: Image,
    backgroundColor: Color,
    action: @escaping (APIWalletAddress?) -> Void
  ) {
    self.image = image
    self.backgroundColor = backgroundColor
    self.action = action
  }
  
  init(
    image: Image,
    backgroundColor: Color,
    action: @escaping () -> Void
  ) {
    self.image = image
    self.backgroundColor = backgroundColor
    self.action = { _ in action() }
  }
}

enum WalletSwipeCellStatus: String {
  case showCell
  case showRightSlot
}

extension Notification.Name {
  static let walletSwipeCellReset = Notification.Name("com.liquidityfinancial.walletSwipeCell.reset")
}

struct WalletSwipeCellStatusKey: EnvironmentKey {
  static var defaultValue: WalletSwipeCellStatus = .showCell
}

extension EnvironmentValues {
  var walletSwipeCellStatus: WalletSwipeCellStatus {
    get { self[WalletSwipeCellStatusKey.self] }
    set {
      self[WalletSwipeCellStatusKey.self] = newValue
    }
  }
}
