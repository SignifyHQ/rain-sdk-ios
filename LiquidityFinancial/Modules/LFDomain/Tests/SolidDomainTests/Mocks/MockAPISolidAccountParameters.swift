import SolidDomain

struct MockAPISolidAccountParameters: SolidAccountEntity {
  public let id: String
  public let externalAccountId: String?
  public let currency: String
  public let availableBalance: Double
  public let availableUsdBalance: Double
  
  init(id: String, externalAccountId: String?, currency: String, availableBalance: Double, availableUsdBalance: Double) {
    self.id = id
    self.externalAccountId = externalAccountId
    self.currency = currency
    self.availableBalance = availableBalance
    self.availableUsdBalance = availableUsdBalance
  }
  
  static var mockData: MockAPISolidAccountParameters {
    MockAPISolidAccountParameters(
      id: "mock_id",
      externalAccountId: "mock_external_account_id",
      currency: "mock_currency",
      availableBalance: 0.0,
      availableUsdBalance: 100.0
    )
  }
}
