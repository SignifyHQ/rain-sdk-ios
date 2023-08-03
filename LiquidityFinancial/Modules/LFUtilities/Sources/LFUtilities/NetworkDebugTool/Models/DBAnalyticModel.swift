import Foundation

public struct DBAnalyticModel: Identifiable {
  public let id: String
  public let name: String
  public let value: [String: Any]
}
