import Foundation
import AccountDomain

public struct APIUser: Codable {
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
  public let userRoundUpEnabled: Bool?
  public let referralLink, userRewardType, userAccessLevel: String?
  public let userSelectedFundraiserId: String?
  public let numberOfDevices: Int?
  public let transferLimitConfigs: [APITransferLimitConfig]
}

extension APIAddress: AddressEntity {}
extension APITransferLimitConfig: TransferLimitConfigEntity {}

extension APIUser: LFUser {
  public var userID: String {
    id ?? ""
  }
  
  public var addressEntity: AddressEntity? {
    address
  }
  
  public var transferLimitConfigsEntity: [TransferLimitConfigEntity] {
    transferLimitConfigs
  }
}

  // MARK: - AppState
public struct APIAppState: Codable {
  public let additionalProp1, additionalProp2, additionalProp3: String?
}

  // MARK: - Kyc
public struct APIKyc: Codable {
  public let id, personId, status, reviewCode: String?
  public let reviewMessage: String?
  public let results: APIResults?
  public let createdAt, modifiedAt, userId: String?
}

  // MARK: - Results
public struct APIResults: Codable {
  public let idv, address, dateOfBirth, fraud: String?
}
