import Foundation

public struct APIAnswerQuestionData: Decodable {
  public let id, externalId, firstName, lastName: String
  public let phone, email, status: String
  public let kycStatus, ofacStatus: String
}
