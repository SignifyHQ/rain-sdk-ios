import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit
import LFUtilities
import LFLocalizable
import LFStyleGuide
import AccountDomain
import AccountData
import BaseDashboard
import LFServices
import Factory

// MARK: - ReceiveCryptoView

struct ReceiveCryptoView: View {
  @Injected(\.analyticsService) var analyticsService
  
  @Environment(\.isPresented) private var isPresented
  @Environment(\.dismiss) private var dismiss
  
  @StateObject private var viewModel: ReceiveCryptoViewModel
  
  init(assetModel: AssetModel) {
    _viewModel = .init(
      wrappedValue: .init(assetModel: assetModel)
    )
  }
  
  var body: some View {
    GeometryReader { _ in
      VStack(spacing: 0) {
        VStack {
          header
          
          VStack(alignment: .leading) {
            qrImage
            GenImages.CommonImages.dash.swiftUIImage
            addressView
          }
          .frame(height: 373.0, alignment: .center)
          .frame(maxWidth: .infinity)
          .background(Colors.secondaryBackground.swiftUIColor)
          .cornerRadius(10.0)
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
              print(error.localizedDescription)
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
          Text(LFLocalizable.ReceiveCryptoView.walletDetail)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
            .foregroundColor(Colors.label.swiftUIColor)
        }
      }
      .onAppear(perform: {
        analyticsService.track(event: AnalyticsEvent(name: .viewsWalletAddress))
      })
      .background(Colors.background.swiftUIColor)
      .track(name: String(describing: type(of: self)))
    }
  }
}

private extension ReceiveCryptoView {
  
  var header: some View {
    HStack {
      Text(LFLocalizable.ReceiveCryptoView.title.uppercased())
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.buttonTextSize.value))
        .padding(.vertical, 30)
        .multilineTextAlignment(.leading)
    }.frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 30)
  }
  
  var qrImage: some View {
    Image(uiImage: viewModel.qrCode)
      .resizable()
      .interpolation(.none)
      .scaledToFit()
      .frame(maxWidth: .infinity)
      .padding([.horizontal, .top], 40)
      .padding(.bottom, 24)
  }
  
  var addressView: some View {
    HStack {
      Text(viewModel.cryptoAddress)
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.5)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .multilineTextAlignment(.leading)
      GenImages.CommonImages.icCopy.swiftUIImage
        .resizable()
        .frame(CGSize(width: 24, height: 24))
        .foregroundColor(Colors.primary.swiftUIColor)
        .onTapGesture {
          analyticsService.track(event: AnalyticsEvent(name: .tapsCopyWalletAddress))
          viewModel.copyAddress()
        }
    }
    .frame(maxWidth: .infinity)
    .padding(.bottom, 16)
    .padding(.top, 12)
    .padding(.horizontal, 12)
  }
  
  var bottomView: some View {
    VStack {
      VStack {
        FullSizeButton(title: LFLocalizable.Button.Share.title, isDisable: false, type: .secondary, icon: GenImages.CommonImages.icShare.swiftUIImage) {
          analyticsService.track(event: AnalyticsEvent(name: .tapsShareWalletAddress))
          viewModel.shareTap()
        }
        Text(LFLocalizable.ReceiveCryptoView.servicesInfo)
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.50))
          .font(Fonts.regular.swiftUIFont(size: 10))
          .multilineTextAlignment(.center)
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
