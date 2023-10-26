import Combine
import Foundation

public class ExternalFundingDataManager: ExternalFundingStorageProtocol {
  
  // MARK: linked sources
  public let linkedSourcesSubject = CurrentValueSubject<[LinkedSourceContact], Never>([])
  
  public func subscribeLinkedSourcesChanged(_ completion: @escaping ([LinkedSourceContact]) -> Void) -> Cancellable {
    linkedSourcesSubject.receive(on: DispatchQueue.main).sink(receiveValue: completion)
  }
  
  public func storeLinkedSources(_ sources: [LinkedSourceContact]) {
    linkedSourcesSubject.send(sources)
  }
  
  public func addOrEditLinkedSource(_ source: LinkedSourceContact) {
    var newValues = linkedSourcesSubject.value
    if let index = newValues.firstIndex(where: { $0.sourceId == source.sourceId }) {
      newValues.replaceSubrange(index...index, with: [source])
    } else {
      newValues.append(source)
    }
    linkedSourcesSubject.send(newValues)
  }
  
  public func removeLinkedSource(id: String) {
    var newValues = linkedSourcesSubject.value
    let count = newValues.count
    newValues.removeAll(where: { $0.sourceId == id })
    if count != newValues.count {
      linkedSourcesSubject.send(newValues)
    }
  }
}
