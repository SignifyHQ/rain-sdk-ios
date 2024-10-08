import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities
import Services
import Factory

public struct EnterSSNView: View {
  @InjectedObject(\.onboardingDestinationObservable) var onboardingDestinationObservable
  
  @FocusState private var keyboardFocus: Bool
  @StateObject var viewModel: EnterSSNViewModel
  @State private var toastMessage: String?
  @State private var showPopup = false
  
  private let onEnterAddress: () -> Void
  
  public init(viewModel: EnterSSNViewModel, onEnterAddress: @escaping () -> Void) {
    self.onEnterAddress = onEnterAddress
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    VStack {
      VStack(alignment: .leading) {
        Text(L10N.Common.EnterSsn.title)
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: 18))
          .padding(.vertical, 12)
        secureField
        infoBullets
      }
      Spacer()
      buttons
    }
    .padding(.horizontal, 30)
    .background(Colors.background.swiftUIColor)
    .navigationTitle("")
    .defaultToolBar(
      icon: .support,
      openSupportScreen: {
        viewModel.openSupportScreen()
      },
      edgeInsets: EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0)
    )
    .popup(item: $toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .popup(isPresented: $showPopup) {
      infoPopup
    }
    .navigationLink(item: $onboardingDestinationObservable.enterSSNDestinationView) { item in
      switch item {
      case let .address(destinationView):
        destinationView
      }
    }
    .onAppear {
      viewModel.onAppear()
    }
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension EnterSSNView {
  var secureField: some View {
    TextFieldWrapper(errorValue: $viewModel.errorMessage) {
      TextField("", text: $viewModel.ssn)
        .focused($keyboardFocus)
        .primaryFieldStyle()
        .keyboardType(.namePhonePad)
        .onChange(
          of: viewModel.ssn
        ) { newValue in
          viewModel.ssn = newValue.uppercased()
        }
        .modifier(
          PlaceholderStyle(
            showPlaceHolder: viewModel.ssn.isEmpty,
            placeholder: L10N.Common.EnterSsn.placeholder
          )
        )
        .onAppear {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            keyboardFocus = true
          }
        }
    }
  }

  var infoBullets: some View {
    VStack(alignment: .leading) {
      HStack(alignment: .center) {
        GenImages.CommonImages.icLock.swiftUIImage
          .frame(width: 24, height: 24)
          .foregroundColor(Colors.label.swiftUIColor)
        Text(L10N.Common.EnterSsn.bulletOne)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .opacity(0.75)
      }
      HStack(alignment: .center) {
        GenImages.CommonImages.icTicketCircle.swiftUIImage
          .frame(width: 24, height: 24)
          .foregroundColor(Colors.label.swiftUIColor)
        Text(L10N.Common.EnterSsn.bulletTwo)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .opacity(0.75)
      }
    }
    .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
    .padding(.top, 12)
  }

  var buttons: some View {
    VStack(spacing: 24) {
      Button {
        showPopup = true
      } label: {
        HStack(spacing: 4) {
          Text(L10N.Common.EnterSsn.why)
          GenImages.CommonImages.info.swiftUIImage
        }
        .font(Fonts.regular.swiftUIFont(size: 12))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      }
      
      FullSizeButton(
        title: L10N.Common.EnterSsn.continue,
        isDisable: !viewModel.isActionAllowed,
        type: .primary
      ) {
        viewModel.onClickedContinueButton {
          onEnterAddress()
        }
      }
    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .padding(.bottom, 12)
  }

  var infoPopup: some View {
    LiquidityAlert(
      title: L10N.Common.EnterSsn.Alert.title,
      message: L10N.Custom.EnterSsn.Alert.message,
      primary: .init(text: L10N.Common.EnterSsn.Alert.okay) { showPopup = false },
      secondary: nil
    )
  }
}
