import Combine
import UIKit
import Factory
import LFUtilities
import LFLocalizable
import ExternalFundingData

class ConnectedAccountRowViewModel: ObservableObject {

  @Published var sourceData: LinkedSourceContact
  
  init(sourceData: LinkedSourceContact) {
    self.sourceData = sourceData
  }
  
  var title: String {
    switch sourceData.sourceType {
    case .card:
      return LFLocalizable.ConnectedView.Row.externalCard(sourceData.last4)
    case .bank:
      return LFLocalizable.ConnectedView.Row.externalBank(sourceData.name ?? "", sourceData.last4)
    }
  }
}
