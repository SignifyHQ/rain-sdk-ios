import SwiftUI
import LFStyleGuide
import LFAccessibility
import LFUtilities

struct BottomSheetView: View {
  @StateObject private var viewModel = FidesmoViewModel()
  @Environment(\.scenePhase) var scenePhase
  
  @Binding var isPresented: Bool
  @Binding var sheetHeight: CGFloat
  
  @State private var selectedPage: Int = 0
  @State private var title: String = "Let's get started"
  @State private var keyboardHeight: CGFloat = 0
  
  private var pages: [(title: String, height: CGFloat, view: AnyView)] {
    [
      ("Let's get started", 380, AnyView(fidesmoStepOne())),
      ("Let’s connect your card", 350, AnyView(fidesmoStepTwo())),
      ("Ready to Scan", 350, AnyView(fidesmoStepThree())),
      ("Finished!", 350, AnyView(fidesmoStepFour()))
    ]
  }
  
  @State var openSafariType: FidesmoViewModel.OpenSafariType?
  
  var body: some View {
    VStack {
      header
      pages[selectedPage].view
    }
    .padding(.top, 25)
    .padding(.bottom, 5)
    .padding(.horizontal, 25)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(hex: "#09080A"))
    .onAppear {
      observeKeyboardNotifications()
    }
    .onDisappear {
      NotificationCenter.default.removeObserver(self)
    }
    .onChange(
      of: selectedPage
    ) { newValue in
      guard pages.indices.contains(newValue)
      else {
        return
      }
      
      sheetHeight = pages[newValue].height
      title = pages[newValue].title
    }
    .fullScreenCover(item: $openSafariType) { type in
      switch type {
      case .terms:
        if let url = viewModel.getURL(tappedString: viewModel.terms) {
          SFSafariViewWrapper(url: url)
        }
      }
    }
  }
  
  private var header: some View {
    ZStack {
      HStack {
        Spacer()
        Text(title)
          .font(Fonts.semiBold.swiftUIFont(size: 20))
          .foregroundColor(Colors.label.swiftUIColor)
          .frame(maxWidth: .infinity, alignment: .center)
        Spacer()
      }
      
      if [0, 1, 2].contains(selectedPage) {
        HStack {
          Button(
            action: {
              cancelDelivery()
              
              if selectedPage == 0 {
                isPresented = false
              } else {
                selectedPage -= 1
              }
            }
          ) {
            Image(systemName: "arrow.left")
              .font(.title2)
              .foregroundColor(.primary)
          }
          
          Spacer()
        }
      }
    }
  }
  
  @ViewBuilder
  private func fidesmoStepOne() -> some View {
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
          viewModel.terms
        ],
        style: .fillColor(Colors.termAndPrivacy.color)
      ) { tappedString in
        switch tappedString {
        case viewModel.terms:
          openSafariType = .terms
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
        selectedPage = 1
      }
    }
  }
  
  @ViewBuilder
  private func fidesmoStepTwo() -> some View {
    VStack(alignment: .center) {
      Button {
        selectedPage = 2
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
        isPresented = false
      }
    }
  }
  
  @ViewBuilder
  private func fidesmoStepThree() -> some View {
    VStack(alignment: .center) {
      if viewModel.deliveryType == .notStarted && viewModel.dataRequirements.isEmpty {
        holdYourDeviceView
        
        Spacer()
      }
      
      if case let .operationInProgress(description, dataFlow) = viewModel.deliveryProgress {
        if case .toDevice = dataFlow {
          Text("Delivery Progress")
            .font(Fonts.regular.swiftUIFont(size: 16))
            .foregroundColor(Colors.label.swiftUIColor)
            .frame(maxWidth: .infinity)
            .padding(.top)
          
          Text("\(viewModel.currentStep) of \(description?.totalSteps ?? 5)")
            .font(Fonts.regular.swiftUIFont(size: 14))
            .foregroundColor(Colors.label.swiftUIColor)
            .frame(maxWidth: .infinity)
        } else {
          Text("Talking to Server...")
            .font(Fonts.regular.swiftUIFont(size: 16))
            .foregroundColor(Colors.label.swiftUIColor)
            .frame(maxWidth: .infinity)
            .padding(.top)
        }
        
        holdYourDeviceView
        
        Spacer()
      } else {
        ComponentViewBuilder(
          dataRequirements: $viewModel.dataRequirements,
          responseHandler: $viewModel.userResponseHandler,
          actionHandler: $viewModel.userActionHandler,
          deliveryProgress: $viewModel.deliveryProgress,
          dataRequirementUUID: $viewModel.dataRequirementUUID
        )
        
        Spacer()
      }
      
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
    }
    .frame(maxWidth: .infinity)
    .onAppear {
      viewModel.onAppear()
    }
    .onChange(of: viewModel.deliveryType) {
      if $0 == .none && viewModel.dataRequirements.isEmpty,
         let responseHandler = viewModel.userResponseHandler {
        responseHandler(viewModel.userDataResponse)
      }
    }
    .onChange(of: viewModel.dataRequirements) {
      if let _ = $0.first(
        where: { requirement in
          requirement.type == .image
        }
      ) {
        sheetHeight = 550
      } else {
        sheetHeight = 350
      }
    }
    .onChange(of: viewModel.deliveryProgress) {
      switch $0 {
      case .operationInProgress(_, let dataFlow):
        sheetHeight = 400
        
        if case .toDevice = dataFlow {
          DispatchQueue.main.async {
            self.viewModel.deliveryType = .transceive
          }
        }
      case .finished(let status):
        if status.success {
          selectedPage = 3
        } else {
          isPresented = false
        }
      default:
        sheetHeight = 350
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
  
  private var holdYourDeviceView: some View {
    Group {
      GenImages.CommonImages.icNfc.swiftUIImage
        .padding(.vertical, 25)
      
      Text("Hold your card against the top edge of the back of your phone.")
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)
        .lineSpacing(1.2)
        .fixedSize(horizontal: false, vertical: true)
        .font(Fonts.regular.swiftUIFont(size: 18))
        .foregroundColor(Colors.label.swiftUIColor)
    }
  }
  
  @ViewBuilder
  private func fidesmoStepFour() -> some View {
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
        isPresented = false
      }
    }
    .frame(maxWidth: .infinity)
  }
    
  private func cancelDelivery() {
    if let onCancel = viewModel.onCancelDelivery {
      onCancel()
      viewModel.onCancelDelivery = nil
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
