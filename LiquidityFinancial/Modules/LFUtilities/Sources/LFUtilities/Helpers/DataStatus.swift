import Foundation

extension String: Error {}

public enum DataStatus<T: Equatable> {
  case idle
  case loading
  case success([T])
  case failure(Error)
}
