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

public struct AddToCardView: View {
  @Injected(\.analyticsService) var analyticsService
  
  @StateObject private var viewModel: AddToCardViewModel
  
  @State private var didAnimate = false
  @State private var movementOffset: CGFloat = 0
  @State private var qrCodeWidth: CGFloat = 0
  @State private var screenWidth: CGFloat = 0

  private let horizontalPadding: CGFloat = 24
  
  public init(
  ) {
    _viewModel = .init(
      wrappedValue: .init()
    )
  }
  
  public var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(spacing: 24) {
        headerView
        
        if viewModel.isLoading {
          loadingView
        } else if let walletAddress = viewModel.walletAddress,
           !walletAddress.isEmpty {
          readyCardView
        } else {
          pendingCardView
        }
      }
      .padding(.horizontal, horizontalPadding)
      .padding(.top, 4)
    }
    .appNavBar(
      navigationTitle: L10N.Common.AddToCardView.Screen.title
    )
    .refreshable {
      await viewModel.onRefreshPull()
    }
    .sheet(
      isPresented: $viewModel.isShowingShareSheetView,
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
    .toast(data: $viewModel.toastData)
    .sheetWithContentHeight(isPresented: $viewModel.isShowingLearnMore) {
      LearnMoreView()
    }
    .sheetWithContentHeight(
      isPresented: Binding(
        get: { viewModel.reauthorizeConnectionMethod != nil },
        set: { newValue in
          if !newValue {
            viewModel.reauthorizeConnectionMethod = nil
          }
        }
      )
    ) {
      if let reauthorizeConnectionMethod = viewModel.reauthorizeConnectionMethod {
        ReauthorizeConnectionView(method: reauthorizeConnectionMethod) {
          viewModel.reauthorizeConnectionMethod = nil
          viewModel.presentMeshFlow(for: .new)
        }
      }
    }
    .sheetWithContentHeight(
      isPresented: Binding(
        get: { viewModel.removeConnectionMethod != nil },
        set: { newValue in
          if !newValue {
            viewModel.removeConnectionMethod = nil
          }
        }
      )
    ) {
      if let removeConnectionMethod = viewModel.removeConnectionMethod {
        RemoveConnectionView(method: removeConnectionMethod) {
          viewModel.removeConnectionMethod = nil
          viewModel.deleteConnectedMethod(with: removeConnectionMethod)
        }
      }
    }
    .readGeometry(
      perform: { proxy in
        screenWidth = proxy.size.width
        calculateMovementOffset()
      }
    )
    .onChange(of: qrCodeWidth) { _ in
      calculateMovementOffset()
    }
    .onChange(of: movementOffset) { newOffset in
      if newOffset > 0 && !didAnimate {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          withAnimation(.easeOut(duration: 0.3)) {
            didAnimate = true
          }
        }
      }
    }
    .onAppear(
      perform: {
        viewModel.refreshConnectedMethods()
        analyticsService.track(event: AnalyticsEvent(name: .viewsWalletAddress))
      }
    )
    .background(Colors.baseAppBackground2.swiftUIColor)
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension AddToCardView {
  var headerView: some View {
    VStack(
      alignment: .leading,
      spacing: 4
    ) {
      Text(L10N.Common.AddToCardView.Header.title)
        .foregroundColor(Colors.textPrimary.swiftUIColor)
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
        .multilineTextAlignment(.leading)
      
      HStack(alignment: .top, spacing: 4 ) {
        GenImages.Images.icoWarning.swiftUIImage
          .resizable()
          .frame(width: 20, height: 20)
        
        TextTappable(
          text: L10N.Common.AddToCardView.Header.subtitle,
          textAlignment: .natural,
          verticalTextAlignment: .top,
          textColor: Colors.textSecondary.color,
          fontSize: Constants.FontSize.small.value,
          links: [
            L10N.Common.AddToCardView.Header.learnMoreLink
          ],
          style: .underlined(Colors.blue300.color),
          weight: .regular
        ) { _ in
          viewModel.isShowingLearnMore = true
        }
      }
    }
    .frame(
      maxWidth: .infinity,
      alignment: .leading
    )
    .background(Colors.baseAppBackground2.swiftUIColor)
  }
  
  var loadingView: some View {
    GeometryReader { geometry in
      VStack(alignment: .center) {
        DefaultLottieView(loading: .branded)
          .frame(width: 52, height: 52)
      }
      .frame(width: geometry.size.width, height: geometry.size.height)
      .background(Colors.grey500.swiftUIColor)
      .cornerRadius(32.0)
    }
    .aspectRatio(1, contentMode: .fit)
    .frame(maxWidth: .infinity)
  }
  
  var pendingCardView: some View {
    GeometryReader { geometry in
      VStack(alignment: .center, spacing: 16) {
        DefaultLottieView(loading: .branded)
          .frame(width: 52, height: 52)
        
        Text(L10N.Common.AddToCardView.PendingWallets.title)
          .foregroundColor(Colors.textPrimary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity, alignment: .center)
      }
      .frame(width: geometry.size.width, height: geometry.size.height)
      .background(Colors.grey500.swiftUIColor)
      .cornerRadius(32.0)
    }
    .aspectRatio(1, contentMode: .fit)
    .frame(maxWidth: .infinity)
  }
  
  var readyCardView: some View {
    VStack(spacing: 24) {
      VStack(alignment: .leading, spacing: 12) {
        qrImageView
        addressView
      }
      .frame(height: 372.0, alignment: .center)
      .frame(maxWidth: .infinity)
      .background(Colors.grey500.swiftUIColor)
      .cornerRadius(32.0)
      
      connectedWalletsView
    }
  }
  
  var qrImageView: some View {
    ZStack {
      GenImages.Images.icoQrBackdrop.swiftUIImage
        .resizable()
        .interpolation(.high)
        .scaledToFit()
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .frame(maxWidth: .infinity)
        .readGeometry { proxy in
          qrCodeWidth = proxy.size.height
        }
        .padding(.horizontal, 16)
        .offset(x: didAnimate ? -movementOffset : 0)
      
      Image(uiImage: viewModel.qrCode)
        .resizable()
        .interpolation(.high)
        .scaledToFit()
        .padding(4)
        .background(Colors.grey900.swiftUIColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .offset(x: didAnimate ? movementOffset : 0)
    }
    .frame(maxWidth: .infinity, minHeight: 180)
    .padding(.top, 16)
  }
  
  var addressView: some View {
    VStack(alignment: .leading, spacing: 12) {
      VStack(alignment: .leading, spacing: 4) {
        Text(L10N.Common.AddToCardView.CardAddress.title)
          .foregroundColor(Colors.textPrimary.swiftUIColor)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .multilineTextAlignment(.leading)
        
        if let walletAddress = viewModel.walletAddress {
          Text(walletAddress)
            .foregroundColor(Colors.textPrimary.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
            .multilineTextAlignment(.leading)
        }
      }
      
      addressActionsView
    }
    .frame(maxWidth: .infinity)
    .padding(.bottom, 16)
    .padding(.horizontal, 16)
  }
  
  var addressActionsView: some View {
    HStack(spacing: 12) {
      FullWidthButton(
        type: .alternative,
        height: 40,
        icon: GenImages.Images.icoCopy.swiftUIImage,
        iconPlacement: .trailing(spacing: 4),
        title: L10N.Common.Common.Copy.Button.title,
        font: Fonts.medium.swiftUIFont(size: Constants.FontSize.ultraSmall.value)
      ) {
        analyticsService.track(event: AnalyticsEvent(name: .tapsCopyWalletAddress))
        viewModel.onCopyAddressButtonTap()
      }
      
      FullWidthButton(
        type: .alternative,
        height: 40,
        icon: GenImages.Images.icoShare.swiftUIImage,
        iconPlacement: .trailing(spacing: 4),
        title: L10N.Common.Common.Share.Button.title,
        font: Fonts.medium.swiftUIFont(size: Constants.FontSize.ultraSmall.value)
      ) {
        analyticsService.track(event: AnalyticsEvent(name: .tapsShareWalletAddress))
        viewModel.onShareButtonTap()
      }
    }
  }
  
  var connectedWalletsView: some View {
    VStack(
      alignment: .leading,
      spacing: 24
    ) {
      VStack(
        alignment: .leading,
        spacing: 4
      ) {
        Text(L10N.Common.AddToCardView.ConnectedWallets.title)
          .foregroundColor(Colors.textPrimary.swiftUIColor)
          .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
          .multilineTextAlignment(.leading)
        
        Text(L10N.Common.AddToCardView.ConnectedWallets.subtitle)
          .foregroundColor(Colors.textSecondary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .multilineTextAlignment(.leading)
      }
      
      VStack(spacing: 8) {
        if viewModel.isLoadingConnectedMethods {
          DefaultLottieView(
            loading: .ctaFast
          )
          .frame(
            width: 20,
            height: 20
          )
          .padding(.bottom, 6)
        } else {
          if viewModel.connectedMethods.isEmpty {
            Text(L10N.Common.AddToCardView.ConnectedWallets.NoWallets.title)
              .foregroundColor(Colors.textPrimary.swiftUIColor)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
              .multilineTextAlignment(.center)
              .frame(height: 20)
              .padding(.bottom, 6)
          } else {
            ForEach(viewModel.connectedMethods) { method in
              connectButton(of: .connected(method: method))
            }
          }
        }
        
        connectButton(of: .new)
      }
      .frame(maxWidth: .infinity)
      .padding(12)
      .background(Colors.grey500.swiftUIColor)
      .cornerRadius(32.0)
    }
  }
  
  private func connectButton(
    of type: ConnectButtonType
  ) -> some View {
    HStack {
      Text(type.buttonTitle)
        .foregroundColor(Colors.textPrimary.swiftUIColor)
        .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.small.value))
        .multilineTextAlignment(.center)
      
      if case let .connected(method) = type,
         method.isConnectionExpired {
        GenImages.CommonImages.icErrorAlert.swiftUIImage
          .onTapGesture {
            viewModel.reauthorizeConnectionMethod = method
          }
      }
      
      Spacer()
      
      if viewModel.loadingMeshFlowWithId == type.buttonId {
        CircleIndicatorView()
          .padding(.trailing, 6)
      } else {
        type.buttonImage
      }
    }
    .frame(height: 60)
    .padding(.leading, 24)
    .padding(.trailing, 12)
    .overlay(
      RoundedRectangle(cornerRadius: 30)
        .inset(by: 0.5)
        .stroke(Colors.grey300.swiftUIColor, lineWidth: 1)
    )
    .walletSwipeCell(
      buttons: type.swipeActionButtons(
        with: {
          if case let .connected(method) = type {
            viewModel.removeConnectionMethod = method
          }
        }
      ),
      buttonWidth: 60,
      cornerRadius: 32
    ) {
      viewModel.presentMeshFlow(for: type)
    }
  }

  func calculateMovementOffset() {
    guard screenWidth > 0, qrCodeWidth > 0 else {
      return
    }

    let outerPadding: CGFloat = horizontalPadding
    let innerPadding: CGFloat = 16

    movementOffset = (screenWidth / 2) - outerPadding - qrCodeWidth / 2 - innerPadding
  }
}

// MARK: - Helper Methods
enum ConnectButtonType {
  case new
  case connected(method: MeshPaymentMethod)

  var buttonTitle: String {
    switch self {
    case .new:
      return L10N.Common.AddToCardView.ConnectedWallets.ConnectButton.title
    case .connected(let method):
      return method.brokerName
    }
  }
  
  var buttonImage: Image? {
    switch self {
    case .new:
      return GenImages.Images.icoMeshAdd.swiftUIImage
    case .connected:
      // USE BASE 64 AFTER FIX IS APPLIED
      return nil//Image.fromBase64(method.brokerBase64Logo)
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
  
  func swipeActionButtons(
    with action: (() -> Void)? = nil
  ) -> [WalletSwipeCellButton] {
    switch self {
    case .new:
      return []
    case .connected:
      return [
        WalletSwipeCellButton(
          image: GenImages.Images.icoTrash.swiftUIImage,
          backgroundColor: Colors.red400.swiftUIColor
        ) {
          action?()
        }
      ]
    }
  }
  
  // TODO: Remove when removing the old folder
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
