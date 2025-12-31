import Foundation
import Combine
import GeneralFeature
import AccountDomain
import AccountData
import MeshData
import MeshDomain
import LFUtilities
import Factory
import CoreImage.CIFilterBuiltins
import UIKit
import LFLocalizable
import RainDomain
import LFStyleGuide

@MainActor
class AddToCardViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.meshRepository) var meshRepository
  @LazyInjected(\.rainRepository) var rainRepository
  
  @Published var qrCode = UIImage()
  @Published var isShowingShareSheetView = false
  @Published var isShowingLearnMore: Bool = false
  @Published var reauthorizeConnectionMethod: MeshPaymentMethod?
  @Published var removeConnectionMethod: MeshPaymentMethod?
  @Published var toastData: ToastData?
  @Published var isLoading: Bool = false
  @Published var isLoadingConnectedMethods: Bool = false
  @Published var loadingMeshFlowWithId: String?
  @Published var walletAddress: String?
  private var loadedConnectedMethods: Bool = false
  private var cancellables = Set<AnyCancellable>()
  
  @Published var connectedMethods: [MeshPaymentMethod] = []
  
  private var isRefreshingAllData: Bool = false
  
  lazy var launchMeshFlowUseCase: LaunchMeshFlowUseCaseProtocol = {
    LaunchMeshFlowUseCase(repository: meshRepository)
  }()
  
  lazy var getConnectedMethodsUseCase: GetConnectedMethodsUseCaseProtocol = {
    GetConnectedMethodsUseCase(repository: meshRepository)
  }()
  
  lazy var deleteConnectedMethodUseCase: DeleteConnectedMethodUseCaseProtocol = {
    DeleteConnectedMethodUseCase(repository: meshRepository)
  }()
  
  lazy var getCollateralContractUseCase: GetCollateralUseCaseProtocol = {
    GetCollateralUseCase(repository: rainRepository)
  }()

  init(
  ) {
    observeCollateralChanges()
  }
}

// MARK: - Binding Observables
private extension AddToCardViewModel {
  func observeCollateralChanges() {
    accountDataManager
      .collateralContractSubject
      .sink { [weak self] rainCollateral in
        self?.walletAddress = rainCollateral?.address
        self?.updateQRCode()
      }
      .store(in: &cancellables)
  }
}

// MARK: - Handling UI/UX Logic
extension AddToCardViewModel {}

// MARK: - Handling Interations
extension AddToCardViewModel {
  func onCopyAddressButtonTap() {
    UIPasteboard.general.string = walletAddress
    toastData = ToastData(type: .success, title: L10N.Common.Toast.Copied.message)
  }
  
  func onShareButtonTap() {
    isShowingShareSheetView = true
  }
  
  func onRefreshPull(
  ) async {
    guard !isRefreshingAllData
    else {
      return
    }
    
    defer {
      isRefreshingAllData = false
    }
    
    isRefreshingAllData = true
    
    do {
      let collateralResponse = try await getCollateralContractUseCase.execute()
      try await fetchConnectedMethods()
      
      accountDataManager.storeCollateralContract(collateralResponse)
    } catch {
      toastData = ToastData(
        type: .error,
        title: error.userFriendlyMessage
      )
    }
  }
  
  func presentMeshFlow(
    for type: ConnectButtonType
  ) {
    guard loadingMeshFlowWithId == nil else { return }
    
    // Return methodId for a previously connected method. If connection is expired or if connecting a new method -> return nil
    let methodId: String? = {
      if case let .connected(method) = type,
         !method.isConnectionExpired {
        return method.methodId
      }
      
      return nil
    }()
    
    Task {
      loadingMeshFlowWithId = type.buttonId
      defer {
        loadingMeshFlowWithId = nil
      }
      
      do {
        try await launchMeshFlowUseCase.execute(methodId: methodId)
      } catch {
        toastData = ToastData(type: .error, title: error.userFriendlyMessage)
      }
    }
  }
  
  func refreshConnectedMethods(
  ) {
    Task {
      guard !isRefreshingAllData
      else {
        return
      }
      
      defer {
        isLoadingConnectedMethods = false
      }
      
      if !loadedConnectedMethods {
        loadedConnectedMethods = true
        isLoadingConnectedMethods = true
      }
      
      do {
        try await fetchConnectedMethods()
      } catch {
        toastData = ToastData(type: .error, title: error.userFriendlyMessage)
      }
    }
  }
  
  func deleteConnectedMethod(
    with method: MeshPaymentMethod
  ) {
    guard loadingMeshFlowWithId == nil
    else {
      return
    }
    
    Task {
      loadingMeshFlowWithId = method.methodId
      defer {
        loadingMeshFlowWithId = nil
      }
      
      do {
        try await deleteConnectedMethodUseCase.execute(methodId: method.methodId)
        try await fetchConnectedMethods()
        toastData = ToastData(type: .success, title: L10N.Common.Toast.RemovedConnection.message(method.brokerName))
      } catch {
        toastData = ToastData(type: .error, title: error.userFriendlyMessage)
      }
    }
  }
  
  private func fetchConnectedMethods() async throws {
    guard let connectedMethods = try await getConnectedMethodsUseCase.execute() as? [MeshPaymentMethod]
    else {
      return
    }
    
    self.connectedMethods = connectedMethods
  }
  
  func updateQRCode() {
    guard let walletAddress else {
      return
    }
    
    qrCode = generateQRCode(from: walletAddress)
  }

  func getActivityItems() -> [AnyObject] {
    var objectsToShare = [AnyObject]()

    if let shareImageObj = qrCode.resizedWidth(toWidth: 200) {
      objectsToShare.append(shareImageObj)
    }

    return objectsToShare
  }

  func getApplicationActivities() -> [UIActivity]? {
    nil
  }
}

// MARK: - APIs Handler
extension AddToCardViewModel {
  func refreshCollateralData(
  ) {
    guard !isRefreshingAllData
    else {
      return
    }
    
    Task { @MainActor in
      isLoading = true
      defer {
        isLoading = false
      }
      
      let collateralResponse = try await getCollateralContractUseCase.execute()
      
      accountDataManager.storeCollateralContract(collateralResponse)
    }
  }
}

// MARK: - Helper Functions
extension AddToCardViewModel {
  private func generateQRCode(from string: String) -> UIImage {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    filter.message = Data(string.utf8)

    guard let outputImage = filter.outputImage
    else {
      return UIImage()
    }
    
    let invertedFilter = CIFilter.colorInvert()
    invertedFilter.setValue(outputImage, forKey: kCIInputImageKey)
    
    guard let outputInvertedImage = invertedFilter.outputImage,
          let cgimg = context.createCGImage(outputInvertedImage, from: outputInvertedImage.extent)
    else {
      return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    return UIImage(cgImage: cgimg)
  }
}
