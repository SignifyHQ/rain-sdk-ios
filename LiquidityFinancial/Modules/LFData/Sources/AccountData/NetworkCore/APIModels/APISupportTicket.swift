import AccountDomain

public struct APISupportTicket: Codable {
  public let id: String
  public let userId: String
  public let title: String?
  public let description: String?
  public let type: String?
  public let status: String
  public let createdAt: String?
  public let updatedAt: String?
  public let deletedAt: String?
}

extension APISupportTicket: SupportTicketEntity {}
