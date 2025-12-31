import Foundation

// sourcery: AutoMockable
public protocol RainCardDetailEntity {
  var userId: String? { get }
  var cardId: String? { get }
  var rainPersonId: String? { get }
  var rainCardId: String? { get }
  var cardType: String? { get }
  var cardStatus: String? { get }
  var last4: String? { get }
  var expMonth: String? { get }
  var expYear: String? { get }
  var limitAmount: Double? { get }
  var limitFrequency: String? { get }
  var createdAt: String? { get }
  var tokenExperiences: [String]? { get }
  var updatedAt: String? { get }
  var shippingAddressEntity: RainCardShippingAddressEntity? { get }
}
