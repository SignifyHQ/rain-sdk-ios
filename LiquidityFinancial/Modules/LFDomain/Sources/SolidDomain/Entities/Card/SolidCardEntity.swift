import Foundation

// sourcery: AutoMockable
public protocol SolidCardEntity {
  var id: String { get }
  var expirationMonth: String { get }
  var expirationYear: String { get }
  var panLast4: String { get }
  var type: String { get }
  var cardStatus: String { get }
  var createdAt: String? { get }
}
