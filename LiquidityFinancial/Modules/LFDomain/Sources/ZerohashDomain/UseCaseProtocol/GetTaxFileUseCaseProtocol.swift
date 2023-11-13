import Foundation

public protocol GetTaxFileUseCaseProtocol {
  func execute(accountId: String) async throws -> [any TaxFileEntity]
}
