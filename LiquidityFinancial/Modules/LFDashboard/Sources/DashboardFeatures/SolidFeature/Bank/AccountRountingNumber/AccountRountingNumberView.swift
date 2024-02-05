import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import Services

public struct AccountRountingNumberView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var showToast = false
  @Binding var achInformation: ACHModel
  
  public init(achInformation: Binding<ACHModel>) {
    _achInformation = achInformation
  }
  
  public var body: some View {
    VStack(alignment: .leading) {
      ScrollView(showsIndicators: false) {
        VStack(alignment: .leading, spacing: 12) {
          sectionTitle(text: L10N.Common.AccountRountingNumber.Screen.title)
          accountInformation
          Text(L10N.Common.AccountRountingNumber.HowTo.title(L10N.Custom.Card.name))
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
          .padding(.bottom, 4)
          howToTransferView
        }
      }
      .padding(.bottom, 16)
    }
    .padding(.horizontal, 30)
    .background(Colors.background.swiftUIColor)
    .popup(isPresented: $showToast, style: .toast) {
      ToastView(toastMessage: L10N.Common.Toast.Copy.message)
    }
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: View Components
private extension AccountRountingNumberView {
  
  func sectionTitle(text: String) -> some View {
    Text(text)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      .foregroundColor(Colors.label.swiftUIColor)
  }
  
  var howToTransferView: some View {
    VStack(alignment: .leading, spacing: 16) {
      bulletItem(text: L10N.Common.AccountRountingNumber.BulletOne.title)
      bulletItem(text: L10N.Common.AccountRountingNumber.BulletTwo.title(L10N.Custom.Card.name))
      bulletItem(text: L10N.Common.AccountRountingNumber.BulletThree.title)
      bulletItem(text: L10N.Common.AccountRountingNumber.BulletFour.title(L10N.Custom.Card.name))
    }
  }
  
  func bulletItem(text: String) -> some View {
    HStack(alignment: .firstTextBaseline, spacing: 8) {
      Circle()
        .fill(Colors.primary.swiftUIColor)
        .frame(5)
      Text(text)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .lineSpacing(5)
    }
  }
  
  var accountInformation: some View {
    HStack {
      accountDetail(
        image: GenImages.CommonImages.icRoutingNumber.swiftUIImage,
        title: L10N.Common.AccountRountingNumber.RoutingNumber.title,
        value: achInformation.routingNumber
      )
      Spacer()
      accountDetail(
        image: GenImages.CommonImages.icAccountNumber.swiftUIImage,
        title: L10N.Common.AccountRountingNumber.AccountNumber.title,
        value: achInformation.accountNumber
      )
    }
    .padding(.horizontal, 10)
  }
  
  func accountDetail(image: Image, title: String, value: String) -> some View {
    Button {
      UIPasteboard.general.string = value
      showToast = true
    } label: {
      VStack(alignment: .leading, spacing: 8) {
        HStack(spacing: 8) {
          image
            .foregroundColor(Colors.label.swiftUIColor)
          Text(title)
            .font(Fonts.regular.swiftUIFont(size: 12))
            .foregroundColor(Colors.label.swiftUIColor)
            .opacity(0.5)
        }
        HStack(spacing: 6) {
          Text(value)
            .font(Fonts.bold.swiftUIFont(size: 13))
            .foregroundColor(Colors.primary.swiftUIColor)
          GenImages.Images.icCopyBackground.swiftUIImage
        }
      }
    }
  }
}
