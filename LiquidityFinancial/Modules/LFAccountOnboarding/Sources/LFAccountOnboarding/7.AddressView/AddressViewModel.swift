import Combine
import SmartyStreets
import PhoneNumberKit
import SwiftUI
import LFUtilities

@MainActor
final class AddressViewModel: ObservableObject {
  private var subscriptions = Set<AnyCancellable>()
  private var pauseAutocomplete = false
  private var isSuggesionTapped: Bool = false

  init() {
    $addressLine1
      .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
      .dropFirst(2)
      .removeDuplicates()
      .sink { [weak self] value in
        guard let self = self else { return }
        guard !self.pauseAutocomplete else {
          self.pauseAutocomplete = false
          return
        }
        self.fetchAddress(query: value.capitalized)
      }
      .store(in: &subscriptions)
  }

  enum Navigation {
    case kyc
    case cardName
  }

  @Published var isActionAllowed: Bool = false
  @Published var displaySuggestions: Bool = false
  @Published var navigation: Navigation?
  @Published var addressList: [AddressData] = []

  @Published var addressLine1: String = "" {
    didSet {
      isAllDataFilled()
    }
  }

  @Published var addressLine2: String = "" {
    didSet {
      isAllDataFilled()
    }
  }

  @Published var city: String = "" {
    didSet {
      isAllDataFilled()
    }
  }

  @Published var state: String = "" {
    didSet {
      isAllDataFilled()
    }
  }

  @Published var zipCode: String = "" {
    didSet {
      isAllDataFilled()
    }
  }

  func stopSuggestions() {
    displaySuggestions = false
  }

  func select(suggestion: AddressData) {
    pauseAutocomplete = true
    addressLine1 = suggestion.addressline1
    city = suggestion.city
    state = suggestion.state
    zipCode = suggestion.zipcode
    displaySuggestions = false
  }

  func action() {
  }

  private var isStateValid: Bool {
    if LFUtility.cryptoEnabled {
      return !Constants.supportedStates.contains(state.uppercased())
    } else {
      return true
    }
  }
}

private extension AddressViewModel {
  func isAllDataFilled() {
    isActionAllowed = (!addressLine1.trimWhitespacesAndNewlines().isEmpty) &&
    (!city.trimWhitespacesAndNewlines().isEmpty) &&
    (!state.trimWhitespacesAndNewlines().isEmpty) &&
    (!zipCode.trimWhitespacesAndNewlines().isEmpty)
  }
}

extension AddressViewModel {
  func fetchAddress(query: String) {
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

      let suggestions: [AddressData] = lookup.result?.suggestions?.map {
        AddressData(
          addressline1: $0.streetLine ?? "",
          city: $0.city ?? "",
          state: $0.state ?? "",
          zipcode: $0.zipcode ?? ""
        )
      } ?? []

      DispatchQueue.main.async {
        self?.addressList = suggestions
        self?.displaySuggestions = !suggestions.isEmpty
      }
    }
  }
}
