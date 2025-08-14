import Foundation

public protocol ApplyPromoCodeUseCaseProtocol {
  func execute(phoneNumber: String, promocode: String) async throws
}
