import Foundation
import SwiftUI
import LFUtilities
import Combine

// AppStore reviewers and journalists need to log in into the app without the need of receiving an SMS.
// Therefore, we are providing them with a set of numbers they can use to log in, which will already have an account set up.
// If the app detects that one of these numbers has been used, it will manually call Twillio API to check the messages sent
// and obtain the SMS code from there.
// swiftlint:disable all
public class DemoAccountsHelper {
  @EnvironmentObject
  var environmentManager: EnvironmentManager
  
  public static let shared = DemoAccountsHelper()
  
    /// Phone numbers for accounts that should be used on `.productionTest` environment.
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
  
    /// Phone numbers for accounts that should be used on `.productionLive` environment.
  private let liveAcounts = [
    "+16266289194",
    "+18304452199",
    "+18474749336",
    "+19452073601",
    "+14258421014",
    "+13022401505",
    "+13163200851"
  ]
  
  private let accountSID = ConfigTwilio.accountSID
  private let authToken = ConfigTwilio.authToken
  
    /// Returns whether this a demo phone number for which the app should intercept SMS from Twilio API.
  public func shouldInterceptSms(number: String) -> Bool {
    testAccounts.contains(number) || liveAcounts.contains(number)
  }
  
    /// Updates the network environment to the corresponding one if the given `number` is from a demo account.
  public func willSendOtp(for number: String) {
    if testAccounts.contains(number) {
      environmentManager.networkEnvironment = .productionTest
    } else if liveAcounts.contains(number) {
      environmentManager.networkEnvironment = .productionLive
    }
  }
  
    /// If the number corresponds to a test account, we will set the environment to `.productionLive` so user
    /// is able to create a _real_ account now.
  public func didLogOut(from number: String) {
    if testAccounts.contains(number) {
      environmentManager.networkEnvironment = .productionLive
    }
  }
  
  public func getTwilioMessages(for phoneNumber: String) -> Future <String?, Never> {
    return Future { promise in
      let number = phoneNumber
        .replace(string: " ", replacement: "")
        .replace(string: "(", replacement: "")
        .replace(string: ")", replacement: "")
        .replace(string: "-", replacement: "")
        .trimWhitespacesAndNewlines()
      let urlStr = "https://api.twilio.com/2010-04-01/Accounts/\(self.accountSID)/Messages.json?To=\(number)&PageSize=1"
      guard let urlTwilio = URL(string: urlStr) else {
        log.debug("Unable to create twilio URL")
        promise(.success(nil))
        return
      }
      var request = URLRequest(url: urlTwilio)
      request.httpMethod = "GET"
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      let authData = (self.accountSID + ":" + self.authToken).data(using: .utf8)!.base64EncodedString()
      request.addValue("Basic \(authData)", forHTTPHeaderField: "Authorization")
      
      URLSession.shared.dataTask(with: request) { data, response, error in
        DispatchQueue.main.async {
          if let error = error {
            log.error("Failure when fetching Twilio API: \(error)")
            promise(.success(nil))
          } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
            do {
              let decodedResponse = try JSONDecoder().decode(TwilioResponse.self, from: data)
              guard let message = decodedResponse.messages.first else {
                log.error("Twilio didn't return any message:\(LiquidityError.logic)")
                promise(.success(nil))
                return
              }
              let codes = self.matches(for: "[0-9]{6}", in: message.body)
              if let code = codes.first {
                promise(.success(code))
              } else {
                log.error("Twilio didn't return any message:\(["message": message.body])")
                promise(.success(nil))
              }
            } catch {
              log.error("Failure when fetching Twilio API: \(error)")
            }
          }
        }
      }
      .resume()
    }
  }
  
  private func matches(for regex: String, in text: String) -> [String] {
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

extension DemoAccountsHelper {
  struct TwilioResponse: Codable {
    let messages: [Message]
  }
  
  struct Message: Codable {
    let body: String
  }
}
