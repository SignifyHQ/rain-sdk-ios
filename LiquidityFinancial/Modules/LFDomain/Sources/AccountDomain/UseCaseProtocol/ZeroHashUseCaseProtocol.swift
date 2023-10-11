import Foundation

protocol ZeroHashUseCaseProtocol {
  func execute() async throws -> ZeroHashAccount
}
