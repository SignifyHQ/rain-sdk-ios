import Combine
import LinkKit

class PlaidLinkViewModel: ObservableObject {

  //TODO: Publishing changes from within view updates is not allowed, this will cause undefined behavior.
  @Published var handler: LinkKit.Handler?
  
  init() {
  }
}
