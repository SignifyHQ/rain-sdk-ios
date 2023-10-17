import Foundation
import Combine
import Factory
import SwiftUI

@MainActor public protocol AccountLockedViewModelProtocol: ObservableObject {
  func openSupportScreen()
  func logout()
}
