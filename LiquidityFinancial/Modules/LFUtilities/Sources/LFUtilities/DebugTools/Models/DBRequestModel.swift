import Foundation
import UIKit

public class DBRequestModel: Codable, Identifiable, Hashable {
  public static func == (lhs: DBRequestModel, rhs: DBRequestModel) -> Bool {
    return lhs.id == rhs.id && lhs.url == rhs.url
  }
  
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(url)
  }
  
  public let id: String
  public let url: String
  public let host: String?
  public let port: Int?
  public let scheme: String?
  public let date: Date
  public let method: String
  public let headers: [String: String]
  public var credentials: [String: String]
  public var cookies: String?
  public var httpBody: Data?
  public var code: Int
  public var responseHeaders: [String: String]?
  public var dataResponse: Data?
  public var errorClientDescription: String?
  public var duration: Double?

  init(request: NSURLRequest, session: URLSession?) {
    id = UUID().uuidString
    url = request.url?.absoluteString ?? ""
    host = request.url?.host
    port = request.url?.port
    scheme = request.url?.scheme
    date = Date()
    method = request.httpMethod ?? "GET"
    credentials = [:]
    var headers = request.allHTTPHeaderFields ?? [:]
    httpBody = request.httpBody
    code = 0

    // collect all HTTP Request headers except the "Cookie" header. Many request representations treat cookies with special parameters or structures. For cookie collection, refer to the bottom part of this method
    session?.configuration.httpAdditionalHeaders?
      .filter { $0.0 != AnyHashable("Cookie") }
      .forEach { element in
        guard let key = element.0 as? String, let value = element.1 as? String else { return }
        headers[key] = value
      }
    self.headers = headers

    // if the target server uses HTTP Basic Authentication, collect username and password
    if let credentialStorage = session?.configuration.urlCredentialStorage,
       let host = host,
       let port = port
    {
      let protectionSpace = URLProtectionSpace(
        host: host,
        port: port,
        protocol: scheme,
        realm: host,
        authenticationMethod: NSURLAuthenticationMethodHTTPBasic
      )

      if let credentials = credentialStorage.credentials(for: protectionSpace)?.values {
        for credential in credentials {
          guard let user = credential.user, let password = credential.password else { continue }
          self.credentials[user] = password
        }
      }
    }

    //  collect cookies associated with the target host
    //  TODO: Add the else branch.
    /*  With the condition below, it is handled only the case where session.configuration.httpShouldSetCookies == true.
         Some developers could opt to handle cookie manually using the "Cookie" header stored in httpAdditionalHeaders
         and disabling the handling provided by URLSessionConfiguration (httpShouldSetCookies == false).
         See: https://developer.apple.com/documentation/foundation/nsurlsessionconfiguration/1411589-httpshouldsetcookies?language=objc
     */
    if let session = session, let url = request.url, session.configuration.httpShouldSetCookies {
      if let cookieStorage = session.configuration.httpCookieStorage,
         let cookies = cookieStorage.cookies(for: url), !cookies.isEmpty
      {
        self.cookies = cookies.reduce("") { $0 + "\($1.name)=\($1.value);" }
      }
    }
  }

  func initResponse(response: URLResponse) {
    guard let responseHttp = response as? HTTPURLResponse else { return }
    code = responseHttp.statusCode
    responseHeaders = responseHttp.allHeaderFields as? [String: String]
  }

  var curlRequest: String {
    var components = ["$ curl -v"]

    guard
      let _ = host
    else {
      return "$ curl command could not be created"
    }

    if method != "GET" {
      components.append("-X \(method)")
    }

    components += headers.map {
      let escapedValue = String(describing: $0.value).replacingOccurrences(of: "\"", with: "\\\"")
      return "-H \"\($0.key): \(escapedValue)\""
    }

    if let httpBodyData = httpBody, let httpBody = String(data: httpBodyData, encoding: .utf8) {
      // the following replacingOccurrences handles cases where httpBody already contains the escape \ character before the double quotation mark (") character
      var escapedBody = httpBody.replacingOccurrences(of: "\\\"", with: "\\\\\"") // \" -> \\\"
      // the following replacingOccurrences escapes the character double quotation mark (")
      escapedBody = escapedBody.replacingOccurrences(of: "\"", with: "\\\"") // " -> \"

      components.append("-d \"\(escapedBody)\"")
    }

    for credential in credentials {
      components.append("-u \(credential.0):\(credential.1)")
    }

    if let cookies = cookies {
      components.append("-b \"\(cookies[..<cookies.index(before: cookies.endIndex)])\"")
    }

    components.append("\"\(url)\"")

    return components.joined(separator: " \\\n\t")
  }
}
