import Foundation

// sourcery: AutoMockable
protocol ZeroHashUseCaseProtocol {
  func execute() async throws -> ZeroHashAccount
}
