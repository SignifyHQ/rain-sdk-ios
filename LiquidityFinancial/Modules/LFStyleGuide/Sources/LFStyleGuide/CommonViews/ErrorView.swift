import SwiftUI
import LFLocalizable
import LFUtilities
import Services
import Factory

public struct ErrorView: View {
  @Injected(\.customerSupportService) var customerSupportService
  
  @State private var isShowLogoutPopup: Bool = false
  let message: String
  
  public init(message: String) {
    self.message = message
  }
  
  public var body: some View {
    VStack {
      Spacer()
      GenImages.Images.icLogo.swiftUIImage
        .resizable()
        .scaledToFit()
        .frame(120)
      Text(LFLocalizable.Error.WeAreSorry.title)
        .padding()
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.large.value))
        .multilineTextAlignment(.center)
      Text(message)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .multilineTextAlignment(.center)
        .padding(.horizontal, 30)
      Spacer()
      FullSizeButton(
        title: LFLocalizable.Button.Logout.title,
        isDisable: false,
        type: .secondary
      ) {
        isShowLogoutPopup = true
      }
    }
    .popup(isPresented: $isShowLogoutPopup) {
      logoutPopup
    }
    .padding(30)
    .background(Colors.background.swiftUIColor, ignoresSafeAreaEdges: .all)
    .navigationBarTitleDisplayMode(.inline)
    .defaultToolBar(icon: .support, openSupportScreen: {
       customerSupportService.openSupportScreen()
    })
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - ErrorView
private extension ErrorView {
  var logoutPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.Popup.Logout.title.uppercased(),
      primary: .init(text: LFLocalizable.Popup.Logout.primaryTitle) {
        NotificationCenter.default.post(name: .forceLogoutInAnyWhere, object: nil)
        isShowLogoutPopup = false
      },
      secondary: .init(text: LFLocalizable.Popup.Logout.secondaryTitle) {
        isShowLogoutPopup = false
      }
    )
  }
}
