import Foundation

// swiftlint:disable discouraged_optional_boolean
public struct APIUser: Decodable {
  public let id: String?
  public let appState: APIAppState?
  public let firstName, lastName, fullName, phone: String?
  public let phoneVerified: Bool?
  public let email: String?
  public let emailVerified: Bool?
  public let dateOfBirth: String?
  public let address: APIAddress?
  public let createdAt, modifiedAt, productId, idType: String?
  public let idNumber: String?
  public let kyc: APIKyc?
  public let programId, language: String?
  public let metadata: APIAppState?
  public let status, chosenName, profileImage, accountReviewStatus: String?
  public let showIdv: Bool?
  public let referralLink, userRewardType, userAccessLevel: String?
}

  // MARK: - Address
public struct APIAddress: Decodable {
  public let addressType, line1, line2, city: String?
  public let state, postalCode, country: String?
}

  // MARK: - AppState
public struct APIAppState: Decodable {
  public let additionalProp1, additionalProp2, additionalProp3: String?
}

  // MARK: - Kyc
public struct APIKyc: Decodable {
  public let id, personId, status, reviewCode: String?
  public let reviewMessage: String?
  public let results: APIResults?
  public let createdAt, modifiedAt, userId: String?
}

  // MARK: - Results
public struct APIResults: Decodable {
  public let idv, address, dateOfBirth, fraud: String?
}
