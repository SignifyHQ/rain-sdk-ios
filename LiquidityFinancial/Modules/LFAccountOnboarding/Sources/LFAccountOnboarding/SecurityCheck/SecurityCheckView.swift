import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

struct SecurityCheckView: View {
  @StateObject private var viewModel = SecurityCheckViewModel()
  @State var selection: Int?
  @State var showIndicator = false
  @State var toastMessage: String?
  @FocusState var keyboardFocus: Bool
  
  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      Text(LFLocalizable.SecurityCheck.Last4SSN.screenTitle)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .padding(.vertical, 12)
      ssnTextField
      informationView
      Spacer()
      footerView
    }
    .padding(.horizontal, 30)
    .background(Colors.background.swiftUIColor)
    .onAppear {
      // TODO: Will be implemented later
      // analyticsService.track(event: Event(name: .viewedSSN))
      viewModel.updateUserDetails()
    }
    .popup(item: $toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .popup(isPresented: $viewModel.isShowLogoutPopup) {
      logoutPopup
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          viewModel.openIntercom()
        } label: {
          GenImages.CommonImages.icChat.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
        }
      }
    }
    // TODO: Will be implemented later
    // .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension SecurityCheckView {
  var ssnTextField: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(LFLocalizable.SecurityCheck.Last4SSN.textFieldTitle)
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      TextFieldWrapper(errorValue: $viewModel.errorMessage) {
        SecureField("", text: $viewModel.ssn)
          .focused($keyboardFocus)
          .primaryFieldStyle()
          .keyboardType(.numberPad)
          .limitInputLength(
            value: $viewModel.ssn,
            length: Constants.MaxCharacterLimit.ssnLength.value
          )
          .placeholderStyle(
            showPlaceholder: viewModel.ssn.isEmpty,
            placeholder: Constants.Default.ssnPlaceholder.rawValue
          )
          .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
              keyboardFocus = true
            }
          }
      }
    }
  }
  
  func informationSSNCell(imageAsset: ImageAsset, description: String) -> some View {
    HStack {
      imageAsset.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor)
      Text(description)
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
    }
  }
  
  var informationView: some View {
    VStack(alignment: .leading, spacing: 12) {
      informationSSNCell(
        imageAsset: GenImages.CommonImages.icLock,
        description: LFLocalizable.SecurityCheck.Encrypt.cellText
      )
      informationSSNCell(
        imageAsset: GenImages.CommonImages.icTicketCircle,
        description: LFLocalizable.SecurityCheck.NoCreditCheck.cellText
      )
    }
  }
  
  var footerView: some View {
    VStack(alignment: .leading, spacing: 10) {
      FullSizeButton(
        title: LFLocalizable.Button.Continue.title,
        isDisable: viewModel.isDisableButton,
        isLoading: $viewModel.isLoading
      ) {
        viewModel.callAddDeviceApi()
      }
      FullSizeButton(
        title: LFLocalizable.Button.Logout.title,
        isDisable: false,
        type: .secondary
      ) {
        viewModel.showLogoutPopup()
      }
    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .padding(.bottom, 16)
  }
  
  var logoutPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.Popup.Logout.title.uppercased(),
      primary: .init(text: LFLocalizable.Popup.Logout.primaryTitle) {
        viewModel.logout()
      },
      secondary: .init(text: LFLocalizable.Popup.Logout.secondaryTitle) {
        viewModel.hideLogoutPopup()
      }
    )
  }
}
