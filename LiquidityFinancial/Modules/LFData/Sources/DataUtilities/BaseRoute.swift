import Foundation
import LFNetwork

extension LFRoute {
  public var baseURL: URL {
    APIConstants.baseURL
  }
  
  public var productID: String {
    switch DataUtilities.target {
    case .Avalanche: return APIConstants.avalencheID
    case .Cardano: return APIConstants.cardanoID
    case .DogeCard: return APIConstants.dogeCard
    case .CauseCard: return APIConstants.causeCard
    case .PrideCard: return APIConstants.prideCard
    case .none:
      fatalError("Wrong the target name. It must right for setup the API")
    }
  }
  
  public var httpHeaders: HttpHeaders {
    [
      "Content-Type": "application/json",
      "productId": productID
    ]
  }
}
