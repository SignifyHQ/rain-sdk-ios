import Combine
import LinkKit

class PlaidLinkViewModel: ObservableObject {

  @Published var handler: LinkKit.Handler?
  
  init() {
  }
}
