import CoreLocation
import MapKit
import SwiftUI
import Factory
import RewardData
import RewardDomain
import LFUtilities
import LFLocalizable

@MainActor
class FundraiserDetailViewModel: ObservableObject {
  @LazyInjected(\.rewardRepository) var rewardRepository
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  
//  @Published var latestDonations: [TransactionModel] = []
  @Published var isGeocodingAddress = false
  @Published var isSelecting = false
  @Published var isLoading = false
  @Published var popup: Popup?
  @Published var fundraiserDetail: FundraiserDetailModel?
  @Published var navigation: Navigation?
  
  lazy var rewardUseCase: RewardUseCase = {
    RewardUseCase(repository: rewardRepository)
  }()
  
  var fundraiserID: String {
    fundraiser.id
  }
  
  let fundraiser: FundraiserModel
  
  init(fundraiser: FundraiserModel) {
    self.fundraiser = fundraiser
  }
  
  func apiFetchDetailFundraiser() {
    guard fundraiserDetail == nil else { return }
    Task {
      defer { isLoading = false }
      isLoading = true
      do {
        let enity = try await rewardUseCase.getFundraisersDetail(fundraiserID: fundraiserID)
        fundraiserDetail = FundraiserDetailModel(enity: enity)
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
  
  func apiSelectFundraiser(fundraiserId: String) {
    Task {
      defer { isSelecting = false }
      isSelecting = true
      do {
        let body: [String: Any] = [
          "updateSelectedFundraiserRequest": [
            "fundraiserId": fundraiserID
          ]
        ]
        _ = try await rewardUseCase.selectFundraiser(body: body)
        let message = LFLocalizable.FundraiserSelection.allowedBeforeAccountCreation(fundraiserDetail?.name ?? "")
        popup = .selectSuccess(message)
      } catch {
        log.error(error.localizedDescription)
        popup = .selectError
      }
    }
  }
  
  func navigateToAddress() {
    guard let address = fundraiserDetail?.charity?.address else { return }
    Task { @MainActor in
      defer { isGeocodingAddress = false }
      isGeocodingAddress = true
      do {
        let geocoder = CLGeocoder()
        // Create Address String
        let country: String
        if #available(iOS 16.0, *) {
          country = Locale.Region.unitedStates.identifier
        } else {
          country = Locale.current.regionCode ?? "US"
        }
        let address = "\(country), \(address)"
        let placemarks = try await geocoder.geocodeAddressString(address)
        if let location = placemarks.first?.location {
          let place = MKPlacemark(coordinate: location.coordinate)
          let mapItem = MKMapItem(placemark: place)
          mapItem.name = self.fundraiserDetail?.charityName
          mapItem.openInMaps()
        } else {
          log.error("No location found after geocoding address \(address)")
          self.popup = .geocodeError
        }
      } catch {
        log.error("Failed to geocode address \(address) - error :\(error)")
        self.popup = .geocodeError
      }
    }
  }
  
  func dismissPopup() {
    popup = nil
  }
  
  func selectSuccessPrimary() {
    dismissPopup()
    navigation = .agreement
  }
  
  private func loadLatestDonations() {

  }
}

  // MARK: - Types

extension FundraiserDetailViewModel {
  enum Navigation {
    case agreement
  }
  
  enum Popup {
    case selectSuccess(String)
    case selectError
    case geocodeError
  }
}
