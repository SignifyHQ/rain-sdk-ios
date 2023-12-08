import Alamofire
import Foundation
import LFUtilities

final class LogMonitor: EventMonitor {
  let queue: DispatchQueue = .init(label: "com.liquidity.networklog")
  
  func request(_ request: Request, didCreateTask _: URLSessionTask) {
    log.info("[🚀 Firing request]: \(request.cURLDescription())")
  }
  
  func requestIsRetrying(_ request: Request) {
    log.info("[🌀 Retrying request]: \(request.description)")
  }
  
  func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
    switch response.result {
    case .success:
      if let jsonString = request.data?.prettyPrintedJSONString {
        let networkDuration = response.metrics.map { "\($0.taskInterval.duration)s" } ?? "None"
        let result = """
        [🚩 Finished request]: \(request.description)
        [Network Duration]: \(networkDuration)
        [Serialization Duration]: \(response.serializationDuration)
        [Result]: \(jsonString)
        """
        log.info(result)
      } else {
        log.info("[🚩 Finished request]: \(response.debugDescription)")
      }
    case .failure:
      // Handle success cases with empty response
      guard let statusCode = response.response?.statusCode,
            statusCode.isSuccess,
            response.data == nil
      else {
        log.info("[🔴 request]: \(response.debugDescription)")
        
        return
      }
      
      let networkDuration = response.metrics.map { "\($0.taskInterval.duration)s" } ?? "None"
      let result = """
      [🚩 Finished no response request]: \(request.description)
      [Network Duration]: \(networkDuration)
      """
      
      log.info(result)
    }
  }
}
