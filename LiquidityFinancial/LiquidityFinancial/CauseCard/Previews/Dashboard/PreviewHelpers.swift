import Foundation
import LFUtilities
import AccountData
import Factory
import AuthorizationManager
import OnboardingData

//swiftlint:disable all
struct PreviewHelpers {
  //We can mock tokens for loading data when using preview for the Dashboard Module
  //You can run an app in the simulator and get a token then update it there
  //The token will cache in driveddata, so you only need to call it once
  static func mockUserLogin() {
    guard LFConfiguration.isPreview else { return }
    UserDefaults.environmentSelection = "productionTest"
    Container.shared.accountDataManager.resolve().stored(phone: "+1....")
    let accessToken = APIAccessTokens(
      accessToken: "",
      tokenType: "Bearer",
      refreshToken: "",
      expiresIn: 86_400
    )
    Container.shared.authorizationManager.resolve().refreshWith(apiToken: accessToken)
  }
  
}
