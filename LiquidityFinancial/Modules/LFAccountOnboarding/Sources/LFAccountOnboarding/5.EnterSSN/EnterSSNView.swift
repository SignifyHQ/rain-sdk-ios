import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities

struct EnterSSNView: View {
  @StateObject private var viewModel = EnterSSNViewModel(isVerifySSN: true)

  @State private var navigation: Navigation?
  @State private var toastMessage: String?
  @State private var showPopup = false
  @FocusState private var keyboardFocus: Bool

  var body: some View {
    VStack {
      VStack(alignment: .leading) {
        Text(LFLocalizable.EnterSsn.title)
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: 18))
          .padding(.vertical, 12)
          .onTapGesture {
            viewModel.magicFillAccount()
          }
        secureField
        infoBullets
      }
      Spacer()
      buttons
    }
    .padding(.horizontal, 30)
    .background(Colors.background.swiftUIColor)
    .navigationTitle("")
    .defaultToolBar(icon: .intercom, openIntercom: {
      viewModel.openIntercom()
    })
    .popup(item: $toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .popup(isPresented: $showPopup) {
      infoPopup
    }
    .navigationLink(item: $navigation) { item in
      switch item {
      case .passport:
        EnterPassportView()
      case .address:
        AddressView()
      }
    }
  }

  private var secureField: some View {
    TextFieldWrapper(errorValue: $viewModel.errorMessage) {
      SecureField("", text: $viewModel.ssn)
        .focused($keyboardFocus)
        .primaryFieldStyle()
        .keyboardType(.numberPad)
        .limitInputLength(
          value: $viewModel.ssn,
          length: Constants.MaxCharacterLimit.fullSSNLength.value
        )
        .modifier(
          PlaceholderStyle(
            showPlaceHolder: viewModel.ssn.isEmpty,
            placeholder: LFLocalizable.EnterSsn.placeholder
          )
        )
        .onAppear {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            keyboardFocus = true
          }
        }
    }
  }

  private var infoBullets: some View {
    VStack(alignment: .leading) {
      HStack(alignment: .center) {
        GenImages.CommonImages.icLock.swiftUIImage
          .frame(width: 24, height: 24)
          .foregroundColor(Colors.label.swiftUIColor)
        Text(LFLocalizable.EnterSsn.bulletOne)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .opacity(0.75)
      }
      HStack(alignment: .center) {
        GenImages.CommonImages.icTicketCircle.swiftUIImage
          .frame(width: 24, height: 24)
          .foregroundColor(Colors.label.swiftUIColor)
        Text(LFLocalizable.EnterSsn.bulletTwo)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .opacity(0.75)
      }
    }
    .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
    .padding(.top, 12)
  }

  private var buttons: some View {
    VStack(spacing: 24) {
      Button {
        showPopup = true
      } label: {
        HStack(spacing: 4) {
          Text(LFLocalizable.EnterSsn.why)
          GenImages.CommonImages.info.swiftUIImage
        }
        .font(Fonts.regular.swiftUIFont(size: 12))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      }

      VStack(spacing: 10) {
//        FullSizeButton(
//          title: LFLocalizable.EnterSsn.noSsn,
//          isDisable: false,
//          type: .secondary
//        ) {
//          navigation = .passport
//        }
        
        FullSizeButton(
          title: LFLocalizable.EnterSsn.continue,
          isDisable: !viewModel.isActionAllowed,
          type: .primary
        ) {
          navigation = .address
        }
      }
    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .padding(.bottom, 12)
  }

  private var infoPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.EnterSsn.Alert.title,
      message: LFLocalizable.EnterSsn.Alert.message,
      primary: .init(text: LFLocalizable.EnterSsn.Alert.okay) { showPopup = false },
      secondary: nil
    )
  }

}

extension EnterSSNView {
  enum Navigation {
    case passport
    case address
  }
}

#if DEBUG
struct EnterSSNView_Previews: PreviewProvider {
  static var previews: some View {
    EnterSSNView()
      .previewLayout(PreviewLayout.sizeThatFits)
      .previewDisplayName("Default preview")
  }
}
#endif
