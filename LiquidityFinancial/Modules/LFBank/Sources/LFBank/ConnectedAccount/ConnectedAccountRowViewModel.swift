import Combine
import UIKit
import Factory
import NetSpendData
import LFUtilities
import LFLocalizable

class ConnectedAccountRowViewModel: ObservableObject {

  @Published var sourceData: APILinkedSourceData
  
  init(sourceData: APILinkedSourceData) {
    self.sourceData = sourceData
  }
  
  var title: String {
    switch sourceData.sourceType {
    case .externalCard:
      return LFLocalizable.ConnectedView.Row.externalCard(sourceData.last4)
    case .externalBank:
      return LFLocalizable.ConnectedView.Row.externalBank(sourceData.name ?? "", sourceData.last4)
    }
  }
  
  var showVerified: Bool {
    sourceData.requiredFlow == nil || (sourceData.requiredFlow?.isEmpty ?? true)
  }
}
