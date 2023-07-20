import Foundation

public struct NetSpendAnswerQuestionData: Decodable {
  public let id, externalId, firstName, lastName: String
  public let middleName, phone, email, status: String
  public let kycStatus, ofacStatus: String
}
