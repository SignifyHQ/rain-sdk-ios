import Foundation

// sourcery: AutoMockable
public protocol GetOccupationListUseCaseProtocol {
  func execute() async throws -> [OccupationEntity]
}
