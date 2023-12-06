import CoreLocation
import MapKit
import SwiftUI
import Factory
import RewardData
import RewardDomain
import LFUtilities
import LFLocalizable

@MainActor
public class FundraiserDetailViewModel: ObservableObject {
  enum OpenSafariType: Identifiable {
    var id: String {
      switch self {
      case .charityURL(let url):
        return url.absoluteString
      case .fullcharityURL(let url):
        return url.absoluteString
      }
    }
    
    case charityURL(URL)
    case fullcharityURL(URL)
  }
  
  @LazyInjected(\.rewardRepository) var rewardRepository
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  
  @Published var isGeocodingAddress = false
  @Published var isSelecting = false
  @Published var isLoading = false
  @Published var popup: Popup?
  @Published var fundraiserDetail: FundraiserDetailModel?
  
  lazy var rewardUseCase: RewardUseCase = {
    RewardUseCase(repository: rewardRepository)
  }()
  
  var latestDonations: [RewardTransactionRowModel] {
    let latestDonations = fundraiserDetail?.latestDonations ?? []
    return latestDonations.compactMap({ RewardTransactionRowModel(latestDonation: $0) })
  }
  
  var fundraiserID: String
  let whereStart: RewardWhereStart
  
  public init(fundraiserID: String, whereStart: RewardWhereStart = .onboarding) {
    self.fundraiserID = fundraiserID
    self.whereStart = whereStart
  }
  
  public init(fundraiserDetail: FundraiserDetailModel, whereStart: RewardWhereStart = .onboarding) {
    self.fundraiserDetail = fundraiserDetail
    self.whereStart = whereStart
    self.fundraiserID = ""
  }
  
  func onAppear() {
    apiFetchDetailFundraiser()
  }
  
  func skipAndDumpToYourAccount() {
    NotificationCenter.default.post(name: .selectedReward, object: nil, userInfo: ["route": RewardFlowRoute.yourAccount])
  }
  
  func apiFetchDetailFundraiser() {
    guard fundraiserDetail == nil, !fundraiserID.isEmpty else { return }
    Task {
      defer { isLoading = false }
      isLoading = true
      do {
        let enity = try await rewardUseCase.getFundraisersDetail(fundraiserID: fundraiserID)
        fundraiserDetail = FundraiserDetailModel(enity: enity)
        rewardDataManager.update(fundraisersDetail: enity)
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
        let entity = try await rewardUseCase.selectFundraiser(body: body)
        rewardDataManager.update(selectedFundraiserID: entity.userSelectedFundraiserId ?? "")
        
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
    switch whereStart {
    case .dashboard:
      NotificationCenter.default.post(name: .selectedFundraisersSuccess, object: nil)
    case .onboarding:
      skipAndDumpToYourAccount()
    }
  }
}

  // MARK: - Types

extension FundraiserDetailViewModel {
  enum Popup {
    case selectSuccess(String)
    case selectError
    case geocodeError
  }
}
