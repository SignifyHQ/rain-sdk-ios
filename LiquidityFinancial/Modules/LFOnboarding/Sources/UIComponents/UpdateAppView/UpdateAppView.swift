import AccountDomain
import SwiftUI
import LFUtilities
import LFStyleGuide
import Services
import Factory
import LFLocalizable

public struct UpdateAppView: View {
  @Injected(\.customerSupportService) var customerSupportService
  
  let featureConfigModel: FeatureConfigModel
  
  public init(featureConfigModel: FeatureConfigModel) {
    self.featureConfigModel = featureConfigModel
  }
  
  var title: String {
    let str = featureConfigModel.blockingAlert?.forcedUpgrade?.title ?? L10N.Common.UpdateAppView.title
    return str.uppercased()
  }
  
  var description: AttributedString {
    let defaultMessage = L10N.Common.UpdateAppView.message(LFUtilities.bundleName)
    
    let stringDynamic = featureConfigModel.blockingAlert?.forcedUpgrade?.description ?? defaultMessage
    var attribute = AttributedString(stringDynamic.htmlAttributedString() ?? NSAttributedString(string: defaultMessage))
    attribute.font = Fonts.medium.font(size: Constants.FontSize.medium.value)
    return attribute
  }
  
  var titleButton: String {
    featureConfigModel.blockingAlert?.forcedUpgrade?.titleButton ?? L10N.Common.Button.Continue.title
  }
  
  public var body: some View {
    ZStack(alignment: .center) {
      Color.black
        .frame(max: .infinity)
        .ignoresSafeArea()
        .zIndex(1)
        .transition(.opacity)

      VStack(spacing: 0) {
        content
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)
      }
      .padding([.horizontal, .bottom], 16)
      .padding(.top, 20)
      .zIndex(2)
      .frame(width: preferredWidth, alignment: .center)
      .background(Colors.background.swiftUIColor)
      .cornerRadius(16, style: .continuous)
      .floatingShadow()
    }
  }

  private var preferredWidth: CGFloat {
    Device.screen.bounds.size.width - 60
  }

  private var content: some View {
    VStack(spacing: 0) {
      ImageConfiguration.appLogo.asset
        .resizable()
        .frame(ImageConfiguration.appLogo.size)
        .padding(.bottom, 24)

      VStack(spacing: 8) {
        Text(title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .multilineTextAlignment(.center)

        Text(description)
          .multilineTextAlignment(.center)
          .lineSpacing(1.33)
      }
      .padding(.horizontal, 16)

      VStack(spacing: 8) {
        FullSizeButton(
          title: L10N.Common.EnterSsn.continue,
          isDisable: false,
          type: .primary
        ) {
          openAppStore()
        }

        underlinedButton(title: L10N.Common.Button.ContactSupport.title, action: {
          customerSupportService.openSupportScreen()
        })
      }
      .padding(.top, 16)
    }
  }

  func openAppStore() {
    guard let appStoreURL = LFUtilities.appStoreLink, let url = URL(string: appStoreURL) else {
      return
    }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }
}

extension UpdateAppView {
  public struct ImageConfiguration {
    let asset: Image
    let size: CGSize
    
    public static var appLogo: Self {
      .init(asset: GenImages.Images.icLogo.swiftUIImage, size: .init(80))
    }
  }

  private func underlinedButton(title: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Text(title)
        .underline()
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.primary.swiftUIColor)
        .frame(height: 32)
        .frame(maxWidth: .infinity)
    }
    .padding(.horizontal, 16)
  }
}
