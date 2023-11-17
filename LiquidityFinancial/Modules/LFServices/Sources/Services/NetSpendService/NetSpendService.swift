import Foundation
import NetspendSdk
import FraudForce
import LFUtilities
import EnvironmentService

// swiftlint:disable force_unwrapping
enum NetSpendService {
  
  static func kickoffNetspend(networkEnvironment: NetworkEnvironment) {
    let netspendSdkColorGroup = NetspendSdkColorGroup(
      color50: "#FF0000", // Red
      color100: "#00FF00", // Green
      color200: "#0000FF", // Blue
      color300: "#FFFF00", // Yellow
      color400: "#FF00FF", // Magenta
      color500: "#00FFFF", // Cyan
      color600: "#800080", // Purple
      color700: "#FFA500", // Orange
      color800: "#808080", // Gray
      color900: "#000000"  // Black
    )
    
    let netspendSdkTheme = NetspendSdkTheme(
      neutralColor: netspendSdkColorGroup,
      defaultColor: netspendSdkColorGroup,
      accentColor: netspendSdkColorGroup,
      positiveColor: netspendSdkColorGroup,
      negativeColor: netspendSdkColorGroup,
      specialColor: netspendSdkColorGroup
    )
    
    //let apiKey = networkEnvironment == .productionTest ? Configs.NetSpend.sdkIdCert : Configs.NetSpend.sdkIdProd
    // TODO: Currently, just work with sandbox when BE setup Production we update again later
    let apiKey = Configs.NetSpend.sdkIdCert
    log.info("kickoffNetspend with apikey: \(apiKey)")
    do {
      try NetspendSdk.shared.initialize(
        sdkId: apiKey,
        theme: netspendSdkTheme,
        branding: createBranding(),
        iovationToken: FraudForce.blackbox()
      )
    } catch {
      log.error("kickoffNetspend is error: \(error)")
    }
  }
  
  private static func createBranding() -> [String: Any] {
    let data = [
      "mfeLocations": [
        //            "atmPin": iconDataURL,
        "currentPosCircleColor": "#FF3333",
        "currentPosStrokeColor": "#FFFFFF",
        //            "currentPositionIcon": iconDataURL,
        //            "feeFreeAtmPin": iconDataURL,
        //            "reloadPin": iconDataURL,
        "integrationPartnerName": "Liquidity",
        "highlightPartnerName": "Avalanche",
        "displayHighlightPartnerWithdrawalLocations": true
        //            "highlightPartnerReloadPin": iconDataURL,
        //            "highlightPartnerWithdrawalPin": iconDataURL
      ] as [String: Any]
    ]
    return data
  }
  
  static var iconDataURL: URL {
    Bundle.module.url(forResource: "icon_location", withExtension: "txt")!
  }
  
}
// swiftlint:enable force_unwrapping
