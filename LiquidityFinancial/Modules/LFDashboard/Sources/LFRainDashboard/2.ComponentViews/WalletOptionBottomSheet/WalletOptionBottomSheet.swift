import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import Services
import GeneralFeature

struct WalletOptionBottomSheet: View {
  let title: String
  let assetTitle: String
  let action: ((WalletType) -> Void)?
  
  init(title: String, assetTitle: String, action: @escaping (WalletType) -> Void) {
    self.title = title
    self.assetTitle = assetTitle
    self.action = action
  }
  
  var body: some View {
    VStack(spacing: 10) {
      RoundedRectangle(cornerRadius: 4)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.35))
        .frame(width: 32, height: 4)
        .padding(.top, 6)
      Text(title.uppercased())
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .padding(.vertical, 14)
      walletTypeCell(with: .internalWallet)
      walletTypeCell(with: .externalWallet)
      Spacer()
    }
    .padding(.horizontal, 30)
    .background(Colors.secondaryBackground.swiftUIColor)
    .customPresentationDetents(height: 228)
    .ignoresSafeArea(edges: .bottom)
  }
}

// MARK: - View Components
private extension WalletOptionBottomSheet {
  func walletTypeCell(with type: WalletType) -> some View {
    Button {
      action?(type)
    } label: {
      HStack(spacing: 12) {
        if type == .internalWallet {
          Circle()
            .stroke(Colors.primary.swiftUIColor, lineWidth: 1)
            .frame(width: 32, height: 32)
            .overlay(
              Text("M")
                .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
                .foregroundColor(Colors.label.swiftUIColor)
            )
            .padding(.leading, -4)
        } else {
          GenImages.CommonImages.walletAddress.swiftUIImage
        }
        Text(type.getTitle(asset: assetTitle))
          .font(
            Fonts.regular.swiftUIFont(size: Constants.FontSize.regular.value)
          )
        Spacer()
        GenImages.Images.forwardButton.swiftUIImage
      }
      .foregroundColor(Colors.label.swiftUIColor)
      .frame(height: 56)
      .padding(.horizontal, 16)
      .background(Colors.buttons.swiftUIColor)
      .cornerRadius(9)
    }
  }
}
