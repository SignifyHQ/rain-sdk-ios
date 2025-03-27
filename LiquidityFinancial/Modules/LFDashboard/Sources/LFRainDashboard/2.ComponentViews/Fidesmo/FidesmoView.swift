import SwiftUI
import LFStyleGuide

struct FidesmoView: View {
  @StateObject private var viewModel = FidesmoViewModel()
  @Environment(\.scenePhase) var scenePhase
  
  var body: some View {
    VStack {
      if viewModel.showLogger {
        LogView(logText: $viewModel.logText)
          .frame(maxHeight: 200)
          .fixedSize(horizontal: false, vertical: true)
      }
      
      Text("Data Requirement Views")
        .bold()
        .padding(.bottom, 15)
      
      if case let .operationInProgress(description, dataFlow) = viewModel.deliveryProgress {
        if case .toDevice = dataFlow {
          Text("Delivery Progress")
            .bold()
            .frame(maxWidth: .infinity)
          Text("\(viewModel.currentStep) of \(description?.totalSteps ?? 5)")
            .frame(maxWidth: .infinity)
        } else {
          ProgressView() {
            Text("Talking to Server")
              .bold()
              .frame(maxWidth: .infinity)
          }
        }
      } else {
        ComponentViewBuilder(
          dataRequirements: $viewModel.dataRequirements,
          responseHandler: $viewModel.userResponseHandler,
          actionHandler: $viewModel.userActionHandler,
          deliveryProgress: $viewModel.deliveryProgress,
          dataRequirementUUID: $viewModel.dataRequirementUUID
        )
      }
      
      Spacer()
      
      let deliveryDisabled = viewModel.deliveryType != .notStarted && viewModel.deliveryType != .transceive
      FullSizeButton(
        title: viewModel.deliveryType != .transceive ? "Scan your Device first" : "Deliver to Device",
        isDisable: deliveryDisabled
      ) {
        switch viewModel.deliveryType {
        case .notStarted, .transceive:
          if case .finished = viewModel.deliveryProgress {
            viewModel.deliveryProgress = .notStarted
          }
          
          viewModel.nfcManager?.startNfcDiscovery(message: "Hold your iPhone near an NFC Fidesmo tag")
        default: break
        }
      }
      
      let cancelDisabled = viewModel.onCancelDelivery == nil
      FullSizeButton(
        title: "Cancel ongoing delivery",
        isDisable: cancelDisabled,
        type: .secondary
      ) {
        if let onCancel = viewModel.onCancelDelivery {
          onCancel()
          viewModel.onCancelDelivery = nil
        }
      }
    }
    .padding()
    .onAppear {
      viewModel.onAppear()
    }
    .onChange(of: viewModel.deliveryType) {
      if $0 == .none && viewModel.dataRequirements.isEmpty,
         let responseHandler = viewModel.userResponseHandler {
        responseHandler(viewModel.userDataResponse)
      }
    }
    .onChange(of: viewModel.deliveryProgress) {
      switch $0 {
      case .operationInProgress(_, let dataFlow):
        if case .toDevice = dataFlow {
          DispatchQueue.main.async {
            self.viewModel.deliveryType = .transceive
          }
        }
      default: break
      }
    }
    .onChange(of: scenePhase) { newScenePhase in
      switch newScenePhase {
      case .active:
        switch viewModel.deliveryProgress {
        case let .needsUserInteraction(requirements, responseHandler):
          viewModel.proceedFromOpenUrlRequirement(requirements: requirements, handler: responseHandler)
        default:  break
        }
      default: break
      }
    }
  }
}

struct LogView: View {
  @Binding var logText: String
  @State var toggleLogger: Bool = false
  @State var showToggler: Bool = false
  private let chunkSize = 1000
  
  init(showToggler: Bool = false, logText: Binding<String>) {
    self.showToggler = showToggler
    toggleLogger = !showToggler
    _logText = logText
  }
  
  var body: some View {
    VStack {
      if showToggler {
        HStack(alignment: .lastTextBaseline) {
          Button {
            withAnimation {
              toggleLogger.toggle()
            }
          } label: {
            Label(toggleLogger ? "Hide Logger" : "Show Logger", systemImage: toggleLogger ? "chevron.up" : "chevron.down")
          }
        }
      }
      if toggleLogger {
        ScrollViewReader { proxy in
          ScrollView {
            VStack(alignment: .leading) {
              ForEach(splitText(logText, size: chunkSize), id: \.self) { chunk in
                Text(chunk)
              }
            }
            .id(1)
            .onChange(of: logText) { _ in
              proxy.scrollTo(1, anchor: .bottom)
            }
          }
          .frame(maxHeight: showToggler ? 200 : .infinity)
        }
      }
    }
    .padding(.bottom)
  }
  
  private func splitText(_ text: String, size: Int) -> [String] {
    var chunks: [String] = []
    var currentIndex = text.startIndex
    
    while currentIndex < text.endIndex {
      let endIndex = text.index(currentIndex, offsetBy: chunkSize, limitedBy: text.endIndex) ?? text.endIndex
      let chunk = String(text[currentIndex..<endIndex])
      chunks.append(chunk)
      currentIndex = endIndex
    }
    
    return chunks
  }
}

struct BottomSheetView: View {
  @Binding var isPresented: Bool
  @Binding var sheetHeight: CGFloat
  
  @State var selectedPage: Int = 0 {
    didSet {
      sheetHeight = pages[selectedPage].height
      title = pages[selectedPage].title
    }
  }
  
  @State private var title: String = "Let's get started"
  @State private var keyboardHeight: CGFloat = 0
  
  private var pages: [any SheetPage] {
    [
      FidesmoStepOne(onNext: { selectedPage = 1 }),
      FidesmoStepTwo(onNext: { selectedPage = 2 }, onCancel: { isPresented = false }),
      FidesmoStepThree(onNext: { selectedPage = 3 }, onCancel: { isPresented = false }),
      FidesmoStepFour(onNext: { selectedPage = 4 }, onCancel: { isPresented = false }),
      FidesmoStepFive(onNext: { selectedPage = 5 }, onCancel: { isPresented = false }),
      FidesmoStepSix(onNext: { isPresented = false })
    ]
  }
  
  private var pageViews: [AnyView] {
    pages.map { AnyView($0) }
  }
  
  var body: some View {
    VStack {
      header
      pageViews[selectedPage]
    }
    .padding(.top, 25)
    .padding(.bottom, 5)
    .padding(.horizontal, 25)
    .frame(
      maxWidth: .infinity,
      maxHeight: .infinity
    )
    .background(Color(hex: "#09080A"))
    .onAppear {
      observeKeyboardNotifications()
    }
    .onDisappear {
      NotificationCenter.default.removeObserver(self)
    }
  }
  
  private var header: some View {
    HStack {
      if pages[selectedPage].shouldShowBackButton {
        Button(
          action: {
            guard selectedPage != 0
            else {
              isPresented = false
              return
            }
            
            selectedPage -= 1
          }
        ) {
          Image(
            systemName: "arrow.left"
          )
          .font(.title2)
          .foregroundColor(.primary)
        }
      }
      
      Spacer()
      
      Text(title)
        .font(Fonts.semiBold.swiftUIFont(size: 20))
        .foregroundColor(Colors.label.swiftUIColor)
        .frame(maxWidth: .infinity, alignment: .center)
      
      Spacer()
    }
  }
  
  private func observeKeyboardNotifications() {
    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
      if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
        withAnimation(.easeInOut) {
          keyboardHeight = keyboardFrame.height
        }
      }
    }
    
    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
      withAnimation(.easeInOut) {
        keyboardHeight = 0
      }
    }
  }
}

struct FidesmoStepOne: SheetPage {
  var shouldShowBackButton: Bool = true
  var height: CGFloat = 380
  var title: String = "Let's get started"
  
  let onNext: () -> Void
  
  var body: some View {
    VStack(alignment: .center) {
      GenImages.CommonImages.icAvalancheFidesmo.swiftUIImage
        .padding(.vertical, 25)
      
      Text("Connect your Limited edition Avalanche Card to enjoy secure and seamless contactless payments.")
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)
        .lineSpacing(1.2)
        .font(Fonts.regular.swiftUIFont(size: 18))
        .foregroundColor(Colors.label.swiftUIColor)
      
      Spacer()
      
      TextTappable(
        text: "By tapping Next you agree to the Fidesmo Terms and Conditions.",
        textAlignment: .left,
        textColor: Colors.label.color.withAlphaComponent(0.75),
        fontSize: Constants.FontSize.ultraSmall.value,
        links: [
          "Fidesmo Terms and Conditions"
        ],
        style: .fillColor(Colors.termAndPrivacy.color)
      ) { tappedString in
        switch tappedString {
        default:
          break
        }
      }
      .accessibilityIdentifier(LFAccessibility.PhoneNumber.conditionTextTappable)
      .frame(height: 50)
      .padding(.bottom, 0)
      
      FullSizeButton(
        title: "Next",
        isDisable: false
      ) {
        onNext()
      }
    }
  }
}


struct FidesmoStepTwo: SheetPage {
  var shouldShowBackButton: Bool = true
  var height: CGFloat = 350
  var title: String = "Let’s connect your card"
  
  let onNext: () -> Void
  let onCancel: () -> Void
  
  var body: some View {
    VStack(alignment: .center) {
      Button {
        onNext()
      } label: {
        GenImages.CommonImages.icConnectNfc.swiftUIImage
      }
      .padding(.vertical, 25)
      
      Text("Tap the connect button to begin the process.")
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)
        .lineSpacing(1.2)
        .font(Fonts.regular.swiftUIFont(size: 18))
        .foregroundColor(Colors.label.swiftUIColor)
      
      Spacer()
      
      FullSizeButton(
        title: "Cancel",
        isDisable: false,
        type: .tertiary
      ) {
        onCancel()
      }
    }
  }
}

struct FidesmoStepThree: SheetPage {
  var shouldShowBackButton: Bool = true
  var height: CGFloat = 350
  var title: String = "Ready to Scan"
  
  let onNext: () -> Void
  let onCancel: () -> Void
  
  var body: some View {
    VStack(alignment: .center) {
      Button {
        onNext()
      } label: {
        GenImages.CommonImages.icNfc.swiftUIImage
      }
      .padding(.vertical, 25)
      
      Text("Hold your card against the top edge of the back of your phone.")
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)
        .lineSpacing(1.2)
        .font(Fonts.regular.swiftUIFont(size: 18))
        .foregroundColor(Colors.label.swiftUIColor)
      
      Spacer()
      
      FullSizeButton(
        title: "Cancel",
        isDisable: false,
        type: .tertiary
      ) {
        onCancel()
      }
    }
    .frame(maxWidth: .infinity)
  }
}

struct FidesmoStepFour: SheetPage {
  var shouldShowBackButton: Bool = true
  var height: CGFloat = 550
  var title: String = "Activation"
  
  let onNext: () -> Void
  let onCancel: () -> Void
  
  var body: some View {
    VStack(alignment: .center) {
      Text("How would you like to activate your payment card?")
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)
        .lineSpacing(1.2)
        .font(Fonts.regular.swiftUIFont(size: 18))
        .foregroundColor(Colors.label.swiftUIColor)
        .padding(.top, 20)
      
      GenImages.CommonImages.unavailableCard.swiftUIImage
        .padding(.vertical, 25)
      
      Spacer()
      
      FullSizeButton(
        title: "Receive SMS code on *******4304",
        isDisable: false,
        type: .tertiary
      ) {
        onNext()
      }
      
      FullSizeButton(
        title: "Receive code to ch***@raincards.xyz",
        isDisable: false,
        type: .tertiary
      ) {
        onNext()
      }
      
      FullSizeButton(
        title: "Activate later",
        isDisable: false,
        type: .alternative
      ) {
        //onCancel()
      }
    }
    .frame(maxWidth: .infinity)
  }
}

struct FidesmoStepFive: SheetPage {
  var shouldShowBackButton: Bool = true
  var height: CGFloat = 650
  var title: String = "Activation code"
  
  @FocusState private var isTextFieldFocused: Bool
  
  let onNext: () -> Void
  let onCancel: () -> Void
  
  @State var error: String? = nil
  @State var otp: String = ""
  
  var body: some View {
    GeometryReader { geometry in
      ScrollView {
        VStack(alignment: .center) {
          Text("Enter the activation code received by SMS to *******4304 from your bank the code is valid for 30 minutes.")
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .lineSpacing(1.2)
            .font(Fonts.regular.swiftUIFont(size: 18))
            .foregroundColor(Colors.label.swiftUIColor)
            .padding(.top, 20)
          
          GenImages.CommonImages.unavailableCard.swiftUIImage
            .padding(.vertical, 25)
          
          Spacer()
          
          TextFieldWrapper(errorValue: $error) {
            TextField(
              "Activation code",
              text: $otp
            )
            .limitInputLength(value: $otp, length: 6)
            .primaryFieldStyle()
            .disableAutocorrection(true)
            .keyboardType(.numberPad)
            .focused($isTextFieldFocused)
          }
          
          FullSizeButton(
            title: "Next",
            isDisable: false,
            type: .tertiary
          ) {
            onNext()
            isTextFieldFocused = false
          }
          
          FullSizeButton(
            title: "Resend code",
            isDisable: false,
            type: .tertiary
          ) {
            //onNext()
          }
          
          FullSizeButton(
            title: "Activate later",
            isDisable: false,
            type: .alternative
          ) {
            //onCancel()
          }
        }
        .frame(minHeight: geometry.size.height)
      }
      .frame(maxHeight: .infinity)
      .scrollIndicators(.hidden)
    }
  }
}

struct FidesmoStepSix: SheetPage {
  var shouldShowBackButton: Bool = false
  var height: CGFloat = 350
  var title: String = "Finished!"
  
  let onNext: () -> Void
  
  var body: some View {
    VStack(alignment: .center) {
      GenImages.CommonImages.icLogo.swiftUIImage
      .padding(.vertical, 25)
      
      Text("CARD ACTIVATED")
        .frame(maxWidth: .infinity, alignment: .center)
        .lineSpacing(1.2)
        .font(Fonts.regular.swiftUIFont(size: 26))
        .foregroundColor(Colors.label.swiftUIColor)
      
      Spacer()
      
      FullSizeButton(
        title: "Done",
        isDisable: false,
        type: .alternative
      ) {
        onNext()
      }
    }
    .frame(maxWidth: .infinity)
  }
}

protocol SheetPage: View {
  var shouldShowBackButton: Bool { get }
  var height: CGFloat { get }
  var title: String { get }
}

