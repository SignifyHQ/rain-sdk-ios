import Factory
import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

public struct WalletRecoveryView: View {
  @Injected(\.onboardingViewFactory) var onboardingViewFactory
  
  @StateObject var viewModel: WalletRecoveryViewModel
  
  public init(
    viewModel: WalletRecoveryViewModel
  ) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    VStack(
      spacing: 32
    ) {
      contentView
      
      Spacer()
    }
    .padding(.top, 8)
    .padding(.bottom, 16)
    .padding(.horizontal, 24)
    .background(Colors.backgroundPrimary.swiftUIColor)
    .defaultNavBar(
      onRightButtonTap: {
        viewModel.onSupportButtonTap()
      },
      isBackButtonHidden: true
    )
    .toast(
      data: $viewModel.currentToast
    )
    .withLoadingIndicator(
      isShowing: $viewModel.isLoading
    )
    .disabled(viewModel.isCloudRecoveryRunning || viewModel.isPinRecoveryRunning)
    .onAppear {
      viewModel.onAppear()
    }
    .sheetWithContentHeight(
      isPresented: $viewModel.isEnterPinPresented,
      content: {
        WalletRecoveryPinView(
          viewModel: viewModel
        )
        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled()
        .onAppear {
          viewModel.pin = .empty
        }
      }
    )
    .sheetWithContentHeight(
      isPresented: isRecoveryCompleteSheetPresented,
      content: {
        WalletRecoveryCompleteView(
          viewModel: viewModel
        )
        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled()
      }
    )
    .navigationLink(
      item: $viewModel.navigation,
      destination: { navigation in
        onboardingViewFactory.createView(for: navigation)
      }
    )
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension WalletRecoveryView {
  var contentView: some View {
    VStack(
      alignment: .leading,
      spacing: 24
    ) {
      headerView
      
      recoveryMethodsView
    }
    .frame(
      maxWidth: .infinity
    )
  }
  
  var headerView: some View {
    VStack(
      alignment: .leading,
      spacing: 4
    ) {
      Text("Recover your wallet")
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
      
      Text("Looks like you’re logging in with a new device.\nChoose how you want to recover your account. ")
        .foregroundStyle(Colors.titleTertiary.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
  
  var recoveryMethodsView: some View {
    VStack(
      alignment: .leading,
      spacing: 12
    ) {
      FullWidthButton(
        type: .alternativeBordered,
        backgroundColor: .clear,
        icon: GenImages.Images.icoWalletRecoveryCloud.swiftUIImage,
        iconPlacement: .leading(spacing: 12),
        title: "Recover using iCloud",
        font: Fonts.semiBold.swiftUIFont(size: Constants.FontSize.medium.value),
        contentAlignment: .leading,
        isDisabled: viewModel.isPinRecoveryRunning,
        isLoading: $viewModel.isCloudRecoveryRunning
      ) {
        viewModel.onRecoverWithCloudButtonTap()
      }
      
      FullWidthButton(
        type: .alternativeBordered,
        backgroundColor: .clear,
        icon: GenImages.Images.icoWalletRecoveryPin.swiftUIImage,
        iconPlacement: .leading(spacing: 12),
        title: "Recover using PIN",
        font: Fonts.semiBold.swiftUIFont(size: Constants.FontSize.medium.value),
        contentAlignment: .leading,
        isDisabled: viewModel.isCloudRecoveryRunning,
        isLoading: $viewModel.isPinRecoveryRunning
      ) {
        viewModel.onRecoverWithPinButtonTap()
      }
    }
  }
}

//MARK: - Helper Functions
extension WalletRecoveryView {
  private var isRecoveryCompleteSheetPresented: Binding<Bool> {
    Binding<Bool>(
      get: {
        viewModel.isWalletRecoveredSuccessfully != nil
      },
      set: { isPresenting in
        if !isPresenting {
          viewModel.isWalletRecoveredSuccessfully = nil
        }
      }
    )
  }
}

// MARK: - Private Enums
extension WalletRecoveryView {}
