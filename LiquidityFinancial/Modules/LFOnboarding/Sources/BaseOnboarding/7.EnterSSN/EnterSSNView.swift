import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities
import LFServices
import Factory

public struct EnterSSNView: View {
  
  @Injected(\.analyticsService)
  var analyticsService
  @StateObject
  var viewModel: EnterSSNViewModel
  @InjectedObject(\.baseOnboardingDestinationObservable)
  var baseOnboardingDestinationObservable
  @State
  private var toastMessage: String?
  @State
  private var showPopup = false
  @FocusState
  private var keyboardFocus: Bool
  
  let onEnterAddress: () -> Void
  public init(viewModel: EnterSSNViewModel, onEnterAddress: @escaping () -> Void) {
    self.onEnterAddress = onEnterAddress
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    VStack {
      VStack(alignment: .leading) {
        Text(LFLocalizable.EnterSsn.title)
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
    .defaultToolBar(icon: .support, openSupportScreen: {
      viewModel.openSupportScreen()
    })
    .popup(item: $toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .popup(isPresented: $showPopup) {
      infoPopup
    }
    .navigationLink(item: $baseOnboardingDestinationObservable.enterSSNDestinationView) { item in
      switch item {
      case let .enterPassport(destinationView):
        destinationView
      case let .address(destinationView):
        destinationView
      }
    }
    .onAppear(perform: {
      analyticsService.track(event: AnalyticsEvent(name: .viewedSSN))
    })
    .track(name: String(describing: type(of: self)))
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
      
      FullSizeButton(
        title: LFLocalizable.EnterSsn.continue,
        isDisable: !viewModel.isActionAllowed,
        type: .primary
      ) {
        analyticsService.track(event: AnalyticsEvent(name: .ssnCompleted))
        onEnterAddress()
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
