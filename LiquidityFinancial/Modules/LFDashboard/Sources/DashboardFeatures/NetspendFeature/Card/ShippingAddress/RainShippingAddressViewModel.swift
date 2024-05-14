import Combine
import SwiftUI
import Services
import SmartyStreets
import LFUtilities

@MainActor
final class RainShippingAddressViewModel: ObservableObject {
  @Published var shouldEnableContinueButton: Bool = false
  @Published var displaySuggestions: Bool = false
  @Published var mainAddress: String = .empty
  @Published var subAddress: String = .empty
  @Published var city: String = .empty
  @Published var state: String = .empty
  @Published var zipCode: String = .empty
  
  @Published var addressList: [ShippingAddress] = []
  
  @Binding var shippingAddress: ShippingAddress?
  
  private var pauseAutocomplete = false
  private var cancellables = Set<AnyCancellable>()
  
  init(shippingAddress: Binding<ShippingAddress?>) {
    _shippingAddress = shippingAddress
    mainAddress = shippingAddress.wrappedValue?.line1 ?? String.empty
    subAddress = shippingAddress.wrappedValue?.line2 ?? String.empty
    city = shippingAddress.wrappedValue?.city ?? String.empty
    state = shippingAddress.wrappedValue?.state ?? String.empty
    zipCode = shippingAddress.wrappedValue?.postalCode ?? String.empty
    
    observeUserInput()
    observeAddressSuggestion()
  }
}

// MARK: - View Helpers
extension RainShippingAddressViewModel {
  func saveAddress() {
    shippingAddress = ShippingAddress(
      line1: mainAddress,
      line2: subAddress.isEmpty ? shippingAddress?.line2 : subAddress,
      city: city,
      state: state,
      postalCode: zipCode,
      country: shippingAddress?.country
    )
  }
  
  func select(suggestion: ShippingAddress) {
    pauseAutocomplete = true
    mainAddress = suggestion.line1
    city = suggestion.city
    state = suggestion.state
    zipCode = suggestion.postalCode
    displaySuggestions = false
  }
}

// MARK: - Private Functions
private extension RainShippingAddressViewModel {
  func observeUserInput() {
    Publishers.CombineLatest4($mainAddress, $subAddress, $city, $zipCode)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _, _, _, _ in
        self?.isAllDataFilled()
      }
      .store(in: &cancellables)
    
    $state
      .receive(on: DispatchQueue.main)
      .sink { [weak self] state in
        guard let self else { return }
        
        self.isAllDataFilled()
      }
      .store(in: &cancellables)
  }
  
  func observeAddressSuggestion() {
    $mainAddress
      .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
      .dropFirst(2)
      .removeDuplicates()
      .sink { [weak self] value in
        guard let self = self else { return }
        guard !self.pauseAutocomplete else {
          self.pauseAutocomplete = false
          return
        }
        
        self.fetchAddressSuggestion(query: value.capitalized)
      }
      .store(in: &cancellables)
  }

  func isAllDataFilled() {
    let requiredFields: [String] = [
      mainAddress.trimWhitespacesAndNewlines(),
      city.trimWhitespacesAndNewlines(),
      state.trimWhitespacesAndNewlines(),
      zipCode.trimWhitespacesAndNewlines()
    ]
    
    shouldEnableContinueButton = requiredFields.allSatisfy { !$0.isEmpty }
  }
  
  func fetchAddressSuggestion(query: String) {
    guard query.count > 2 else {
      displaySuggestions = false
      return
    }
    
    let id = Constants.smartyStreetsId
    let hostname = Constants.smartyStreetsHostName
    let client = ClientBuilder(id: id, hostname: hostname)
      .withLicenses(licenses: [Constants.smartyStreetsLicense])
      .buildUSAutocompleteProApiClient()
    
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      var lookup = USAutocompleteProLookup().withSearch(search: query)
      var error: NSError?
      _ = client.sendLookup(lookup: &lookup, error: &error)
      
      let suggestions: [ShippingAddress] = lookup.result?.suggestions?.map {
        ShippingAddress(
          line1: $0.streetLine ?? .empty,
          city: $0.city ?? .empty,
          state: $0.state ?? .empty,
          postalCode: $0.zipcode ?? .empty
        )
      } ?? []
      
      DispatchQueue.main.async {
        self?.addressList = suggestions
        self?.displaySuggestions = !suggestions.isEmpty
      }
    }
  }
}
