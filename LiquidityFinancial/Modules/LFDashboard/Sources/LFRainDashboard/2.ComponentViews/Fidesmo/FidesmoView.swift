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
          viewModel.deliveryType = .transceive
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
    .toolbar {
      Button {
        viewModel.showLogger.toggle()
      } label: {
        Image(systemName: viewModel.showLogger ? "list.clipboard.fill" : "list.clipboard")
      }
      Button {
        viewModel.showAppService.toggle()
      } label: {
        Image(systemName: viewModel.showAppService ? "key.icloud.fill" : "key.icloud")
      }
      .disabled(viewModel.deliveryType != .notStarted)
    }
    .alert("App and Service ID", isPresented: $viewModel.showAppService) {
      TextField("App ID", text: $viewModel.appId)
        .textInputAutocapitalization(.never)
      TextField("Service ID", text: $viewModel.serviceId)
        .textInputAutocapitalization(.never)
      Button("OK", role: .cancel) { }
    } message: {
      Text("Set the App and Service ID for a Service Delivery")
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
  
  // Splits a String into chunks of a specified size.
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
