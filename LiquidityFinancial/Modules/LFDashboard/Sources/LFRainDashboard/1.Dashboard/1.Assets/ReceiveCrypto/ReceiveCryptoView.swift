import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit
import LFUtilities
import LFLocalizable
import LFStyleGuide
import AccountDomain
import AccountData
import GeneralFeature
import Services
import Factory

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
    VStack(spacing: 0) {
      VStack {
        header
        
        VStack(alignment: .leading) {
          qrImage
          addressView
        }
        .frame(height: 373.0, alignment: .center)
        .frame(maxWidth: .infinity)
        .background(Colors.secondaryBackground.swiftUIColor)
        .cornerRadius(32.0)
        .padding(.horizontal, 30)
        
        Spacer()
        
        bottomView
      }
      .padding(.top, 12)
      .onAppear {
        viewModel.updateCode()
      }
      .sheet(isPresented: $viewModel.isDisplaySheet) {
        ShareSheet(photo: Image("QR_Code"))
      }
      .sheet(isPresented: $viewModel.isShareSheetViewPresented, content: {
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
      })
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
    }
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
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.buttonTextSize.value))
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
    .padding(.top, 8)
    .padding(.bottom, 20)
    .padding(.horizontal, 24)
  }
  
  var bottomView: some View {
    VStack {
      VStack {
        FullSizeButton(title: L10N.Common.Button.Share.title, isDisable: false, type: .secondary, icon: GenImages.CommonImages.icShare.swiftUIImage) {
          analyticsService.track(event: AnalyticsEvent(name: .tapsShareWalletAddress))
          viewModel.shareTap()
        }
//        Text(L10N.Common.ReceiveCryptoView.servicesInfo)
//          .foregroundColor(Colors.label.swiftUIColor.opacity(0.50))
//          .font(Fonts.regular.swiftUIFont(size: 10))
//          .multilineTextAlignment(.center)
      }
      .padding(.horizontal, 30)
      .padding(.top, 8)
    }
    .background(Colors.background.swiftUIColor)
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
