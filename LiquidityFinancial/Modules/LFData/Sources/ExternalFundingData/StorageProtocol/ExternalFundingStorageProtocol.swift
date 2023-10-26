import Combine

public protocol ExternalFundingStorageProtocol {
  func subscribeLinkedSourcesChanged(_ completion: @escaping ([LinkedSourceContact]) -> Void) -> Cancellable
  func storeLinkedSources(_ sources: [LinkedSourceContact])
  func addOrEditLinkedSource(_ source: LinkedSourceContact)
  func removeLinkedSource(id: String)
}
