import Factory
import SwiftUI
import Foundation

public class PromocodeViewModel: ObservableObject {
  
  @Published var presentationDetent: PresentationDetent = .height(370)
  @Published var isLoading: Bool = false
  
  @Published var promocode: String = ""
  @Published var isSuccessState: Bool = false
  
  var isContinueButtonEnabled: Bool {
//    if isSuccessState || promocode.trimWhitespacesAndNewlines().count > 3 {
//      return true
//    }
//    
//    return false
    
    return true
  }
  
  public init() {
    
  }
  
  func applyPromocode() {
    isLoading = true
//    defer {
//      isLoading = false
//    }
    
    DispatchQueue.main.asyncAfter(
      deadline: .now() + 2
    ) {
      self.isLoading = false
      
      withAnimation {
        self.isSuccessState = true
      }
    }
  }
  
  func resetState() {
    withAnimation(nil) {
      promocode = ""
      isSuccessState = false
    }
  }
}
