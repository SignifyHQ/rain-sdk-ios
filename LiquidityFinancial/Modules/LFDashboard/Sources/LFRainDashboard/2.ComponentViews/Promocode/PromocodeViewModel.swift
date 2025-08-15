import Factory
import SwiftUI
import Foundation

public class PromocodeViewModel: ObservableObject {
  
  @Published var presentationDetent: PresentationDetent = .height(370)
  @Published var isLoading: Bool = false
  
  @Published var promocode: String = "" {
    didSet {
      errorMessage = nil
    }
  }
  @Published var isSuccessState: Bool = false
  @Published var errorMessage: String?
  
  var isContinueButtonEnabled: Bool {
    if isSuccessState || promocode.trimWhitespacesAndNewlines().count > 3 {
      return true
    }
    
    return false
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
