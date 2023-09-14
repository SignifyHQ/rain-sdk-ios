import Foundation
import UIKit

public class DBStorage {
  public static let shared: DBStorage = .init()

  private var keyRequests = [String]()
  private let cacheRequest = DBCache<DBRequestModel.ID, DBRequestModel>()

  private var keyAnalytics = [String]()
  private let cacheAnalytic = DBCache<DBAnalyticModel.ID, DBAnalyticModel>()

  func saveRequest(request: DBRequestModel?) {
    guard let request = request else {
      return
    }
    keyRequests.insert(request.id, at: 0)
    cacheRequest.insert(request, forKey: request.id)
  }

  func getRequests() -> [DBRequestModel] {
    var requests = [DBRequestModel]()
    for key in keyRequests {
      if let request = cacheRequest.value(forKey: key) {
        requests.append(request)
      }
    }
    requests.removeDuplicates()
    return requests
  }

  func saveAnalytic(analytic: DBAnalyticModel?) {
    guard let analytic = analytic else {
      return
    }
    keyAnalytics.insert(analytic.id, at: 0)
    cacheAnalytic.insert(analytic, forKey: analytic.id)
  }

  func getAnalytics() -> [DBAnalyticModel] {
    var analytics = [DBAnalyticModel]()
    for key in keyAnalytics {
      if let analytic = cacheAnalytic.value(forKey: key) {
        analytics.append(analytic)
      }
    }
    return analytics
  }

  func removeAll() {
    cacheRequest.removeAll()
    cacheAnalytic.removeAll()
  }
}

extension Array where Element: Hashable {
  func removingDuplicates() -> [Element] {
    var addedDict = [Element: Bool]()
    
    return filter {
      addedDict.updateValue(true, forKey: $0) == nil
    }
  }
  
  mutating func removeDuplicates() {
    self = self.removingDuplicates()
  }
}
