import Foundation

// sourcery: AutoMockable
public protocol SupportTicketEntity {
  var id: String { get }
  var userId: String { get }
  var title: String? { get }
  var description: String? { get }
  var type: String? { get }
  var status: String { get }
  var createdAt: String? { get }
  var updatedAt: String? { get }
  var deletedAt: String? { get }
}
