import Alamofire
import Foundation
import LFUtilities

final class LogMonitor: EventMonitor {
  let queue: DispatchQueue = .init(label: "com.liquidity.networklog")
  
  func request(_ request: Request, didCreateTask _: URLSessionTask) {
    log.debug("🚀 Firing request: \(request.description)")
  }
  
  func requestIsRetrying(_ request: Request) {
    log.info("🌀 Retrying request: \(request.description)")
  }
  
  func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
    switch response.result {
    case .success:
      if let value = response.value {
        log.debug("🚩 Finished request: \(request.description) \n \(value)")
      } else {
        log.debug("🚩 Finished request: \(request.description)")
      }
    case .failure:
      log.info(" Failed request: \(response.debugDescription)")
    }
  }
}
