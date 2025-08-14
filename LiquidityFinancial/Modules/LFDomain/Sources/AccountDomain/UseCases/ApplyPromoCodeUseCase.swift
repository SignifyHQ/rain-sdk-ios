import Foundation

public final class ApplyPromoCodeUseCase: ApplyPromoCodeUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(phoneNumber: String, promocode: String) async throws {
    try await repository.applyPromocode(phoneNumber: phoneNumber, promocode: promocode)
  }
}
