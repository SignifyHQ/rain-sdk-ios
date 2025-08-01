import Foundation
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

@MainActor
class ReceiveCryptoViewModel: ObservableObject {
  
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  
  @LazyInjected(\.meshRepository) var meshRepository
  
  @Published var isDisplaySheet: Bool = false
  @Published var qrCode = UIImage()
  @Published var isShareSheetViewPresented = false
  @Published var showCloseButton = false
  @Published var toastMessage: String?
  
  @Published var isLoadingConnectedMethods: Bool = false
  @Published var loadingMeshFlowWithId: String?
  private var loadedConnectedMethods: Bool = false
  
  @Published var connectedMethods: [MeshPaymentMethod] = []
  
  let assetTitle: String
  let walletAddress: String
  
  lazy var launchMeshFlowUseCase: LaunchMeshFlowUseCaseProtocol = {
    LaunchMeshFlowUseCase(repository: meshRepository)
  }()
  
  lazy var getConnectedMethodsUseCase: GetConnectedMethodsUseCaseProtocol = {
    GetConnectedMethodsUseCase(repository: meshRepository)
  }()
  
  lazy var deleteConnectedMethodUseCase: DeleteConnectedMethodUseCaseProtocol = {
    DeleteConnectedMethodUseCase(repository: meshRepository)
  }()
  
  init(assetTitle: String, walletAddress: String) {
    self.assetTitle = assetTitle
    self.walletAddress = walletAddress
  }
}

// MARK: - View Handle
extension ReceiveCryptoViewModel {
  func copyAddress() {
    UIPasteboard.general.string = walletAddress
    toastMessage = L10N.Common.ReceiveCryptoView.Copied.info
  }
  
  func shareTap() {
    isShareSheetViewPresented = true
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
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func refreshConnectedMethods(
    animated: Bool = false
  ) {
    Task {
      if animated || !loadedConnectedMethods {
        loadedConnectedMethods = true
        isLoadingConnectedMethods = true
      }
      
      defer {
        isLoadingConnectedMethods = false
      }
      
      do {
        try await fetchConnectedMethods()
      } catch {
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func deleteConnectedMethod(
    with id: String?
  ) {
    guard let methodId = id,
          loadingMeshFlowWithId == nil
    else {
      return
    }
    
    Task {
      loadingMeshFlowWithId = methodId
      defer {
        loadingMeshFlowWithId = nil
      }
      
      do {
        try await deleteConnectedMethodUseCase.execute(methodId: methodId)
        try await fetchConnectedMethods()
      } catch {
        toastMessage = error.userFriendlyMessage
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
  
  func updateCode() {
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

  func generateQRCode(from string: String) -> UIImage {
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
