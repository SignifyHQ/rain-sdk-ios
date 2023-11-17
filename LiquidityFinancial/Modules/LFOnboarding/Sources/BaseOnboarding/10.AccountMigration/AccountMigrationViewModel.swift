import SwiftUI

@MainActor public protocol AccountMigrationViewModelProtocol: ObservableObject {
  func openSupportScreen()
  func logout()
  func requestMigration()
}
