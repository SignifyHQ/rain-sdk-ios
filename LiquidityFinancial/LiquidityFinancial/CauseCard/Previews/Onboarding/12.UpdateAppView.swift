import SwiftUI
import SolidOnboarding
import BaseOnboarding
import LFUtilities
import AccountData
import AccountDomain

//swiftlint:disable all
// MARK: Preview View

var appConfigModel: FeatureConfigModel {
  let model = FileHelpers.readJSONFile(forName: "AppConfigData", type: FeatureConfigModel.self)
  return model!
}

#Preview {
  UpdateAppView(featureConfigModel: appConfigModel)
}
