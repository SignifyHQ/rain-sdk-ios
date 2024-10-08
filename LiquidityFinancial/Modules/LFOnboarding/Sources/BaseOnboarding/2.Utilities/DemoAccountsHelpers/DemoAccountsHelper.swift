import Foundation
import SwiftUI
import Combine
import NetworkUtilities
import Factory
import LFUtilities

/*
  AppStore reviewers and journalists need to log in into the app without the need of receiving an SMS.
  Therefore, we are providing them with a set of numbers they can use to log in, which will already have an account set up.
  If the app detects that one of these numbers has been used, it will manually call Twillio API to check the messages sent
  and obtain the SMS code from there.
 */
// swiftlint:disable all

public class DemoAccountsHelper {
  @LazyInjected(\.environmentService) var environmentService
  @LazyInjected(\.authorizationManager) var authorizationManager
  
  public static let shared = DemoAccountsHelper()

  // Phone numbers for accounts that should be used on `.productionTest` environment.
  private let testAccounts = [
    "+12058583181", // App Store
    "+12202721992",
    "+18304452199",
    "+14454563432",
    "+13029243162",
    "+19136755190",
    "+15086255545",
    "+19498283899"
  ]
  
  // Phone numbers for accounts that should be used on `.productionLive` environment.
  private let liveAcounts = [
    "+16266289194",
    "+18304452199",
    "+18474749336",
    "+19452073601",
    "+14258421014",
    "+13022401505",
    "+13163200851"
  ]
  
  private var currentTestAccount: String?
  private var cancellable: Cancellable?
  
  init() {
    cancellable = NotificationCenter.default
      .publisher(for: authorizationManager.logOutForcedName)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        log.warning("DemoAccountsHelper receive: forcibly logged out the user")
        guard let account = self?.currentTestAccount else { return }
        self?.didLogOut(from: account)
      }
  }
}

// MARK: - Public Functions
public extension DemoAccountsHelper {
  /// Returns whether this a demo phone number for which the app should intercept SMS from Twilio API.
  func shouldInterceptSms(number: String) -> Bool {
    testAccounts.contains(number) || liveAcounts.contains(number)
  }
  
  /// Updates the network environment to the corresponding one if the given `number` is from a demo account.
  func willSendOtp(for number: String) {
    if testAccounts.contains(number) {
      currentTestAccount = number
      environmentService.networkEnvironment = .productionTest
    } else if liveAcounts.contains(number) {
      currentTestAccount = number
      environmentService.networkEnvironment = .productionLive
    }
  }
  
  /// If the number corresponds to a test account, we will set the environment to `.productionLive` so user
  /// is able to create a _real_ account now.
  func didLogOut(from number: String) {
    if testAccounts.contains(number) {
      environmentService.networkEnvironment = .productionLive
    }
  }
  
  func getOTPInternal(for phoneNumber: String) -> Future <String?, Never> {
    return Future { promise in
      let number = phoneNumber
        .replace(string: " ", replacement: "")
        .replace(string: "(", replacement: "")
        .replace(string: ")", replacement: "")
        .replace(string: "-", replacement: "")
        .replace(string: "+", replacement: "%2B")
        .trimWhitespacesAndNewlines()
      let urlStr = APIConstants.devHost + "/v1/admin/dev-tool/sms?to=\(number)"
      guard let url = URL(string: urlStr) else {
        log.debug("Unable to get OTP internal")
        promise(.success(nil))
        return
      }
      var request = URLRequest(url: url)
      request.httpMethod = "GET"
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      URLSession.shared.dataTask(with: request) { data, response, error in
        DispatchQueue.main.async {
          if let error = error {
            log.error("Failure when fetching OTP internal API: \(error)")
            promise(.success(nil))
          } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
            do {
              let decodedResponse = try JSONDecoder().decode(APIOtpInternal.self, from: data)
              guard let data = decodedResponse.data.first else {
                log.error("OTP internal didn't return any message:\(LiquidityError.logic)")
                promise(.success(nil))
                return
              }
              let codes = self.matches(for: "[0-9]{6}", in: data.message)
              if let code = codes.first {
                promise(.success(code))
              } else {
                log.error("OTP internal didn't return any message:\(["message": data.message])")
                promise(.success(nil))
              }
            } catch {
              promise(.success(nil))
              log.error("Failure when fetching OTP internal API: \(error)")
            }
          }
        }
      }
      .resume()
    }
  }
}

// MARK: - Private Functions
private extension DemoAccountsHelper {
  func matches(for regex: String, in text: String) -> [String] {
    do {
      let regex = try NSRegularExpression(pattern: regex)
      let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
      return results.map {
        String(text[Range($0.range, in: text)!])
      }
    } catch {
      log.error("invalid regex: \(error)")
      return []
    }
  }
}

// MARK: - Types
extension DemoAccountsHelper {
  struct TwilioResponse: Codable {
    let messages: [Message]
  }
  
  struct Message: Codable {
    let body: String
  }
  
  public struct APIOtpInternal: Codable {
    let total: Int
    let data: [APIOtpInternalData]
  }
  
  public struct APIOtpInternalData: Codable {
    let from, to, message, timestamp: String
  }
}
