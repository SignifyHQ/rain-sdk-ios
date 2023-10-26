import Factory

extension Container {
  public var externalFundingDataManager: Factory<any ExternalFundingStorageProtocol> {
    self { ExternalFundingDataManager() }.singleton
  }
}
