import Foundation
import SwiftUI
import AccountData

struct SwipeWalletCellButton {
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

enum WalletCellStatus: String {
  case showCell
  case showRightSlot
}

extension Notification.Name {
  static let swipeWalletCellReset = Notification.Name("com.liquidityfinancial.swipeWalletCell.reset")
}

struct WalletCellStatusKey: EnvironmentKey {
  static var defaultValue: WalletCellStatus = .showCell
}

extension EnvironmentValues {
  var walletCellStatus: WalletCellStatus {
    get { self[WalletCellStatusKey.self] }
    set {
      self[WalletCellStatusKey.self] = newValue
    }
  }
}
