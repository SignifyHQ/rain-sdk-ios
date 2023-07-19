import NetspendSdk
import UIKit
import FraudForce
import LFUtilities

public enum KickoffService {
  public static func kickoff(application: UIApplication, launchingOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    kickoffNetspend()
  }
}

extension KickoffService {
  static func kickoffNetspend() {
    let netspendSdkColorGroup = NetspendSdkColorGroup(
      color50: "",
      color100: "",
      color200: "",
      color300: "",
      color400: "",
      color500: "",
      color600: "",
      color700: "",
      color800: "",
      color900: ""
    )
    let netspendSdkTheme = NetspendSdkTheme(
      neutralColor: netspendSdkColorGroup,
      defaultColor: netspendSdkColorGroup,
      accentColor: netspendSdkColorGroup,
      positiveColor: netspendSdkColorGroup,
      negativeColor: netspendSdkColorGroup,
      specialColor: netspendSdkColorGroup
    )
    do {
      try NetspendSdk.shared.initialize(
        sdkId: Configs.NetSpend.sdkId,
        theme: netspendSdkTheme,
        branding: [:],
        iovationToken: FraudForce.blackbox()
      )
    } catch {
      log.error("kickoffNetspend is error: \(error)")
    }
  }
}
