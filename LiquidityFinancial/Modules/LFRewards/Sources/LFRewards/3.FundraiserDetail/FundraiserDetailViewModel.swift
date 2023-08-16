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
        //analyticsService.track(event: Event(name: .selectedFundraiserSuccess, params: fundraiser.selectedEventParams))
        let message = LFLocalizable.FundraiserSelection.allowedBeforeAccountCreation(fundraiser.name)
        popup = .selectSuccess(message)
      } catch {
        log.error(error.localizedDescription)
        popup = .selectError
      }
    }
  }
  
  func navigateToAddress() {
    guard let address = fundraiserDetail?.charity?.address else { return }
    isGeocodingAddress = true
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(address) { [weak self] placemarks, error in
      guard let self = self else { return }
      self.isGeocodingAddress = false
      if let error = error {
        log.error("Failed to geocode address \(address) - error :\(error)")
        self.popup = .geocodeError
      } else if let location = placemarks?.first?.location {
        let place = MKPlacemark(coordinate: location.coordinate)
        let mapItem = MKMapItem(placemark: place)
        mapItem.name = self.fundraiserDetail?.charityName
        mapItem.openInMaps()
      } else {
        log.error("No location found after geocoding address \(address)")
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
