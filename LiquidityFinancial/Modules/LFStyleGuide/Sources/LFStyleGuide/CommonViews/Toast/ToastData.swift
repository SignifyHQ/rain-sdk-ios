import Foundation

public struct ToastData {
  let type: ToastType
  let title: String
  let body: String?
  let duration: TimeInterval
  
  public init(
    type: ToastType,
    title: String? = nil,
    body: String? = nil,
    duration: TimeInterval = 3.0
  ) {
    self.type = type
    self.title = title ?? type.defaultTitle
    self.body = body
    self.duration = duration
  }
}
