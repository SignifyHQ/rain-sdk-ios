import SwiftUI
import LFBaseBank
import LFLocalizable
import LFUtilities
import LFStyleGuide
import LFServices

struct BankTransfersView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var showToast = false
  @Binding var achInformation: ACHModel
  
  var body: some View {
    VStack(alignment: .leading) {
      ScrollView(showsIndicators: false) {
        VStack(alignment: .leading, spacing: 24) {
          bankTransfersView
          GenImages.CommonImages.dash.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
          Text(LFLocalizable.BankTransfers.Disclosure.message(LFUtilities.appName))
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        }
      }
      .padding(.bottom, 16)
      FullSizeButton(title: LFLocalizable.Button.Done.title, isDisable: false) {
        dismiss()
      }
      .padding(.bottom, 20)
    }
    .padding(.horizontal, 30)
    .background(Colors.background.swiftUIColor)
    .popup(isPresented: $showToast, style: .toast) {
      ToastView(toastMessage: LFLocalizable.Toast.Copy.message)
    }
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: View Components
private extension BankTransfersView {
  var bankTransfersView: some View {
    VStack(alignment: .leading, spacing: 12) {
      sectionTitle(text: LFLocalizable.BankTransfers.Screen.title)
      Text(LFLocalizable.BankTransfers.HowTo.title(LFUtilities.appName))
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      .padding(.bottom, 4)
      howToTransferView
    }
  }
  
  func sectionTitle(text: String) -> some View {
    Text(text)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      .foregroundColor(Colors.label.swiftUIColor)
  }
  
  var howToTransferView: some View {
    VStack(alignment: .leading, spacing: 16) {
      bulletItem(text: LFLocalizable.BankTransfers.BulletOne.title)
      bulletItem(text: LFLocalizable.BankTransfers.BulletOne.title)
      accountInformation
      bulletItem(text: LFLocalizable.BankTransfers.BulletThree.title)
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
        title: LFLocalizable.BankTransfers.RoutingNumber.title,
        value: achInformation.routingNumber
      )
      Spacer()
      accountDetail(
        image: GenImages.CommonImages.icAccountNumber.swiftUIImage,
        title: LFLocalizable.BankTransfers.AccountNumber.title,
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
        image
          .foregroundColor(Colors.label.swiftUIColor)
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
