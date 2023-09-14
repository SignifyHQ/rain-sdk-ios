import Foundation
import UIKit

//swiftlint:disable all

class DBRequestModelBeautifier {
  static func overview(request: DBRequestModel) -> NSMutableAttributedString {
    let url = NSMutableAttributedString().bold("URL: ").normal(request.url + "\n")
    let method = NSMutableAttributedString().bold("Method: ").normal(request.method + "\n")
    let responseCode = NSMutableAttributedString().bold("Response Code: ").normal((request.code != 0 ? "\(request.code)" : "-") + "\n")
    let requestStartTime = NSMutableAttributedString().bold("Request Start Time: ").normal((request.date.stringWithFormat(dateFormat: "MMM d yyyy - HH:mm:ss") ?? "-") + "\n")
    let duration = NSMutableAttributedString().bold("Duration: ").normal(request.duration?.formattedMilliseconds() ?? "-" + "\n")
    let final = NSMutableAttributedString()
    for attr in [url, method, responseCode, requestStartTime, duration] {
      final.append(attr)
    }
    return final
  }

  static func header(_ headers: [String: String]?) -> NSMutableAttributedString {
    guard let headerDictionary = headers else {
      return NSMutableAttributedString(string: "-")
    }
    let final = NSMutableAttributedString()
    for (key, value) in headerDictionary {
      final.append(NSMutableAttributedString().bold(key).normal(" " + value + "\n"))
    }
    return final
  }

  static func body(_ body: Data?, splitLength: Int? = nil, completion: @escaping (String) -> Void) {
    DispatchQueue.global().async {
      completion(DBRequestModelBeautifier.body(body, splitLength: splitLength))
    }
  }

  static func body(_ body: Data?, splitLength: Int? = nil) -> String {
    guard body != nil else {
      return "-"
    }

    if let data = splitLength != nil ? String(data: body!, encoding: .utf8)?.characters(n: splitLength!) : String(data: body!, encoding: .utf8) {
      return data.prettyPrintedJSON ?? data
    }

    return "-"
  }

  static func txtExport(request: DBRequestModel) -> String {
    var txt = ""
    txt.append("*** Overview *** \n")
    txt.append(overview(request: request).string + "\n\n")
    txt.append("*** Request Header *** \n")
    txt.append(header(request.headers).string + "\n\n")
    txt.append("*** Request Body *** \n")
    txt.append(body(request.httpBody) + "\n\n")
    txt.append("*** Response Header *** \n")
    txt.append(header(request.responseHeaders).string + "\n\n")
    txt.append("*** Response Body *** \n")
    txt.append(body(request.dataResponse) + "\n\n")
    txt.append("------------------------------------------------------------------------\n")
    txt.append("------------------------------------------------------------------------\n")
    txt.append("------------------------------------------------------------------------\n\n\n\n")
    return txt
  }

  static func curlExport(request: DBRequestModel) -> String {
    var txt = ""
    txt.append("*** Overview *** \n")
    txt.append(overview(request: request).string + "\n\n")
    txt.append("*** curl Request *** \n")
    txt.append(request.curlRequest + "\n\n")
    txt.append("*** Response Header *** \n")
    txt.append(header(request.responseHeaders).string + "\n\n")
    txt.append("*** Response Body *** \n")
    txt.append(body(request.dataResponse) + "\n\n")
    txt.append("------------------------------------------------------------------------\n")
    txt.append("------------------------------------------------------------------------\n")
    txt.append("------------------------------------------------------------------------\n\n\n\n")
    return txt
  }
}

extension NSMutableAttributedString {
  @discardableResult
  func bold(_ text: String) -> NSMutableAttributedString {
    let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 15)]
    let boldString = NSMutableAttributedString(string: text, attributes: attrs)
    append(boldString)
    return self
  }

  @discardableResult
  func normal(_ text: String) -> NSMutableAttributedString {
    let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14)]
    let normal = NSMutableAttributedString(string: text, attributes: attrs)
    append(normal)
    return self
  }

  func chageTextColor(to color: UIColor) -> NSMutableAttributedString {
    addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location: 0, length: string.count))
    return self
  }
}

extension Dictionary {
  var prettyPrintedJSON: String? {
    do {
      let data: Data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
      return String(data: data, encoding: .utf8)
    } catch _ {
      return nil
    }
  }
}

extension String {
  var prettyPrintedJSON: String? {
    guard let stringData = data(using: .utf8),
          let object = try? JSONSerialization.jsonObject(with: stringData, options: []),
          let jsonData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
          let formattedJSON = String(data: jsonData, encoding: .utf8) else { return nil }

    return formattedJSON.replacingOccurrences(of: "\\/", with: "/")
  }
}

extension String {
  // substrings of equal length
  func characters(n: Int) -> String {
    String(prefix(n))
  }
}
