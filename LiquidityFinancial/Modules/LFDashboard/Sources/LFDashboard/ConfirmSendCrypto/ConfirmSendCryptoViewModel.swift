import Foundation

class ConfirmSendCryptoViewModel: ObservableObject {
  @Published var showIndicator: Bool = false
  @Published var toastMessage: String?
  

  let amount: Double
  let address: String
  let nickname: String = ""

  init(amount: Double, address: String) {
    self.amount = amount
    self.address = address
  }
  
  var amountInput: String {
    amount.roundTo3fStr()
  }
  
  func confirmButtonClicked() {
    
  }
}
