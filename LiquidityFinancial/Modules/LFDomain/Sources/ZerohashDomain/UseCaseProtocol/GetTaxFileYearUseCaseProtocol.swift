import Foundation

public protocol GetTaxFileYearUseCaseProtocol {
  func execute(accountId: String, year: String, fileName: String) async throws -> URL
}
