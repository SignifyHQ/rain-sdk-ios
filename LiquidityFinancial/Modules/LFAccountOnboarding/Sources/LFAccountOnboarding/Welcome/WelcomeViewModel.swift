import Foundation

@MainActor
public class WelcomeViewModel: ObservableObject {
  
  public init() {
  }

  @Published var isLoading = false
  @Published var showError = false

  func orderCardTapped() {
    
  }

}
