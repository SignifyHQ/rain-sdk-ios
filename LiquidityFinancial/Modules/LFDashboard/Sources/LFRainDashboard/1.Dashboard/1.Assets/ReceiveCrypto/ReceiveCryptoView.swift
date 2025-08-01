import AccountData
import AccountDomain
import CoreImage.CIFilterBuiltins
import Factory
import GeneralFeature
import MeshData
import LFLocalizable
import LFStyleGuide
import LFUtilities
import Services
import SwiftUI
import UIKit

// MARK: - ReceiveCryptoView

struct ReceiveCryptoView: View {
  @Injected(\.analyticsService) var analyticsService
  
  @Environment(\.isPresented) private var isPresented
  @Environment(\.dismiss) private var dismiss
  
  @StateObject private var viewModel: ReceiveCryptoViewModel
  
  @State private var didAnimate = false
  
  @State private var movementOffset: CGFloat = 0
  @State private var qrCodeWidth: CGFloat = 0
  
  init(
    assetTitle: String,
    walletAddress: String
  ) {
    _viewModel = .init(
      wrappedValue: .init(assetTitle: assetTitle, walletAddress: walletAddress)
    )
  }
  
  var body: some View {
    VStack {
      ScrollView(showsIndicators: false) {
        header
        
        VStack(alignment: .leading) {
          qrImage
          addressView
        }
        .frame(height: 360.0, alignment: .center)
        .frame(maxWidth: .infinity)
        .background(Colors.secondaryBackground.swiftUIColor)
        .cornerRadius(32.0)
        .padding(.horizontal, 30)
        
        connectedWalletsView
          .padding(.horizontal, 30)
      }
      
      Spacer()
      
      bottomView
    }
    .padding(.top, 12)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        if viewModel.showCloseButton {
          Button {
            dismiss()
          } label: {
            CircleButton(style: .xmark)
          }
        }
      }
      
      ToolbarItem(placement: .principal) {
        Text(L10N.Common.ReceiveCryptoView.walletDetail)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor)
      }
    }
    .sheet(
      isPresented: $viewModel.isDisplaySheet
    ) {
      ShareSheet(photo: Image("QR_Code"))
    }
    .sheet(
      isPresented: $viewModel.isShareSheetViewPresented,
      content: {
        ShareSheetView(
          activityItems: viewModel.getActivityItems(),
          applicationActivities: viewModel.getApplicationActivities()
        ) { activityType, finished, activityItems, error in
          if let error = error {
            print(error.userFriendlyMessage)
            return
          }
          if let activityType = activityType {
            print(activityType)
          }
          print(finished)
          
          if let activityItems = activityItems {
            print(activityItems)
          }
        }
      }
    )
    .popup(
      item: $viewModel.toastMessage,
      style: .toast
    ) {
      ToastView(toastMessage: $0)
    }
    .readGeometry(
      perform: { proxy in
        let screenWidth = proxy.size.width
        let outerPadding: CGFloat = 30
        let innerPadding: CGFloat = 24
        
        movementOffset = (screenWidth / 2) - outerPadding - qrCodeWidth / 2 - innerPadding
      }
    )
    .onAppear(
      perform: {
        viewModel.updateCode()
        viewModel.refreshConnectedMethods()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          withAnimation(.easeOut(duration: 0.3)) {
            didAnimate = true
          }
        }
        
        analyticsService.track(event: AnalyticsEvent(name: .viewsWalletAddress))
      }
    )
    .background(Colors.background.swiftUIColor)
    .track(name: String(describing: type(of: self)))
  }
}

private extension ReceiveCryptoView {
  var header: some View {
    VStack(
      alignment: .leading,
      spacing: 2
    ) {
      Text(L10N.Common.ReceiveCryptoView.title)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .multilineTextAlignment(.leading)
      
      Text(L10N.Common.ReceiveCryptoView.subtitle)
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.5)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .multilineTextAlignment(.leading)
    }
    .frame(
      maxWidth: .infinity,
      alignment: .leading
    )
    .padding(.bottom, 8)
    .padding(.horizontal, 30)
  }
  
  var qrImage: some View {
    ZStack {
      GenImages.CommonImages.icQrBackdrop.swiftUIImage
        .resizable()
        .interpolation(.none)
        .scaledToFit()
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .frame(maxWidth: .infinity)
        .readGeometry { proxy in
          qrCodeWidth = proxy.size.height
        }
        .padding(.horizontal, 40)
        .offset(x: didAnimate ? -movementOffset : 0)
      
      Image(uiImage: viewModel.qrCode)
        .resizable()
        .interpolation(.none)
        .scaledToFit()
        .padding(5)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 40)
        .offset(x: didAnimate ? movementOffset : 0)
    }
    .frame(maxWidth: .infinity, minHeight: 180)
    .padding(.top, 24)
    .padding(.bottom, 20)
  }
  
  var addressView: some View {
    VStack(spacing: 4) {
      HStack {
        Text(L10N.Common.ReceiveCryptoView.yourAddress)
          .foregroundColor(Colors.label.swiftUIColor)
          .opacity(0.75)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .multilineTextAlignment(.leading)
        
        Spacer()
      }
      
      HStack {
        Text(viewModel.walletAddress)
          .foregroundColor(Colors.label.swiftUIColor)
          .opacity(0.5)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .multilineTextAlignment(.leading)
        
        Spacer()
        
        (didAnimate ? GenImages.CommonImages.icCopySelected.swiftUIImage : GenImages.CommonImages.icCopyUnselected.swiftUIImage)
          .resizable()
          .frame(CGSize(width: 48, height: 48))
          .foregroundColor(Colors.primary.swiftUIColor)
          .onTapGesture {
            analyticsService.track(event: AnalyticsEvent(name: .tapsCopyWalletAddress))
            viewModel.copyAddress()
          }
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.bottom, 20)
    .padding(.horizontal, 24)
  }
  
  var connectedWalletsView: some View {
    Group {
      VStack(
        alignment: .leading,
        spacing: 2
      ) {
        Text(L10N.Common.ReceiveCryptoView.ConnectedWallets.title)
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .multilineTextAlignment(.leading)
        
        Text(L10N.Common.ReceiveCryptoView.ConnectedWallets.subtitle)
          .foregroundColor(Colors.label.swiftUIColor)
          .opacity(0.5)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .multilineTextAlignment(.leading)
      }
      .padding(.vertical, 8)
      
      VStack {
        if viewModel.isLoadingConnectedMethods {
          LottieView(loading: .primary)
            .frame(width: 30, height: 20)
            .padding(.bottom, 6)
        } else {
          if viewModel.connectedMethods.isEmpty {
            VStack(
              spacing: 4
            ) {
              Text(L10N.Common.ReceiveCryptoView.ConnectedWallets.NoWallets.title)
                .foregroundColor(Colors.label.swiftUIColor)
                .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
                .multilineTextAlignment(.center)
              
              Text(L10N.Common.ReceiveCryptoView.ConnectedWallets.NoWallets.subtitle)
                .foregroundColor(Colors.label.swiftUIColor)
                .opacity(0.5)
                .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
                .multilineTextAlignment(.center)
            }
            .padding(.bottom, 8)
          } else {
            ForEach(viewModel.connectedMethods) { method in
              connectButton(of: .connected(method: method))
            }
          }
        }
        
        connectButton(of: .new)
      }
      .frame(maxWidth: .infinity)
      .padding(16)
      .background(Colors.secondaryBackground.swiftUIColor)
      .cornerRadius(32.0)
    }
  }
  
  private func connectButton(
    of type: ConnectButtonType
  ) -> some View {
    HStack {
      Text(type.buttonTitle)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.small.value))
        .multilineTextAlignment(.center)
      
      if case let .connected(method) = type,
         method.isConnectionExpired {
        GenImages.CommonImages.icErrorAlert.swiftUIImage
      }
      
      Spacer()
      
      if viewModel.loadingMeshFlowWithId == type.buttonId {
        CircleIndicatorView()
          .padding(.trailing, 6)
      } else {
        type.buttonImage
      }
    }
    .frame(height: 72)
    .padding(.leading, 16)
    .padding(.trailing, 10)
    .background(Colors.secondaryRow.swiftUIColor)
    .cornerRadius(16)
    .swipeWalletCell(
      buttons: type.actionButtons(
        with: {
          viewModel.deleteConnectedMethod(with: type.methodId)
        }
      ),
      buttonWidth: 72,
      cornerRadius: 16
    ) {
      viewModel.presentMeshFlow(for: type)
    }
  }
  
  var bottomView: some View {
    VStack {
      VStack {
        FullSizeButton(title: L10N.Common.Button.Share.title, isDisable: false, type: .secondary, icon: GenImages.CommonImages.icShare.swiftUIImage) {
          analyticsService.track(event: AnalyticsEvent(name: .tapsShareWalletAddress))
          viewModel.shareTap()
        }
      }
      .padding(.horizontal, 30)
      .padding(.top, 8)
    }
    .background(Colors.background.swiftUIColor)
  }
}

// MARK: - Helpers

enum ConnectButtonType {
  case new
  case connected(method: MeshPaymentMethod)
  
  var buttonTitle: String {
    switch self {
    case .new:
      return L10N.Common.ReceiveCryptoView.ConnectedWallets.ConnectButton.title
    case .connected(method: let method):
      return method.brokerName
    }
  }
  
  var buttonImage: Image? {
    switch self {
    case .new:
      return GenImages.CommonImages.icMeshAdd.swiftUIImage
    case .connected(let method):
      // USE BASE 64 AFTER FIX IS APPLIED
      return nil // Image.fromBase64(method.brokerBase64Logo)
    }
  }
  
  var methodId: String? {
    switch self {
    case .new:
      return nil
    case .connected(let method):
      return method.methodId
    }
  }
  
  var buttonId: String {
    switch self {
    case .new:
      return "id-add"
    case .connected(let method):
      return method.methodId
    }
  }
  
  func actionButtons(
    with action: (() -> Void)? = nil
  ) -> [SwipeWalletCellButton] {
    switch self {
    case .new:
      return []
    case .connected:
      return [
        SwipeWalletCellButton(
          image: GenImages.CommonImages.icTrash.swiftUIImage,
          backgroundColor: Colors.error.swiftUIColor
        ) {
          action?()
        }
      ]
    }
  }
}

// MARK: - ShareSheet

struct ShareSheet: UIViewControllerRepresentable {
  let photo: Image
  
  func makeUIViewController(context _: Context) -> UIActivityViewController {
    let activityItems: [Any] = [photo]
    
    let controller = UIActivityViewController(
      activityItems: activityItems,
      applicationActivities: nil
    )
    
    return controller
  }
  
  func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}
