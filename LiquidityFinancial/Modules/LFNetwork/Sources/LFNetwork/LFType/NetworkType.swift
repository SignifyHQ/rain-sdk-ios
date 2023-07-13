import Combine
import Foundation

public protocol NetworkType {
  
  associatedtype R: LFRoute
  
  func request(_ route: R) -> AnyPublisher<Response, LFNetworkError>
  func request<T>(_ route: R, target: T.Type, decoder: JSONDecoder) -> AnyPublisher<T, LFNetworkError> where T: Decodable
  func request<T, E>(_ route: R, target: T.Type, failure: E.Type, decoder: JSONDecoder) -> AnyPublisher<T, LFNetworkError> where T: Decodable, E: DesignatedError
  func request(_ route: R) async throws -> Response
  func request<T>(_ route: R, target: T.Type, decoder: JSONDecoder) async throws -> T where T: Decodable
  func request<T, E>(_ route: R, target: T.Type, failure: E.Type, decoder: JSONDecoder) async throws -> T where T: Decodable, E: DesignatedError
}
