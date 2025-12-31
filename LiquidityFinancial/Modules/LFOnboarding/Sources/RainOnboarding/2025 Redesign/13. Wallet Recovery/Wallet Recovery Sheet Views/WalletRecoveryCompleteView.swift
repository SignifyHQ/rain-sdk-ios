import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

public struct WalletRecoveryCompleteView: View {
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
      headerView
      
      walletRecoveryStatusImage
      
      subtitleView
      
      buttonGroup
    }
    .padding(.top, 24)
    .padding(.bottom, 16)
    .padding(.horizontal, 24)
    .background(Colors.backgroundDark.swiftUIColor)
  }
}

// MARK: - View Components
private extension WalletRecoveryCompleteView {
  var headerView: some View {
    ZStack {
      if viewModel.isWalletRecoveredSuccessfully == false {
        HStack {
          Button {
            viewModel.isWalletRecoveredSuccessfully = nil
          } label: {
            GenImages.Images.icoArrowNavBack.swiftUIImage
          }
          
          Spacer()
        }
      }
      
      HStack {
        Spacer()
        
        Text(viewModel.isWalletRecoveredSuccessfully == true ? "Recovery complete" : "Recovery unsuccessful")
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
          .multilineTextAlignment(.leading)
          .fixedSize(horizontal: false, vertical: true)
        
        Spacer()
      }
    }
  }
  
  var walletRecoveryStatusImage: some View {
    if viewModel.isWalletRecoveredSuccessfully == true {
      GenImages.Images.imgWalletRecoverySuccess.swiftUIImage
    } else {
      GenImages.Images.imgWalletRecoveryFailure.swiftUIImage
    }
  }
  
  var subtitleView: some View {
    Text(viewModel.isWalletRecoveredSuccessfully == true ? "Your account recovery is complete." : "We couldn’t find a backup for your account on iCloud. Recover using your PIN, or check that you’re signed in with the same iCloud account you used when you created this account.")
      .foregroundStyle(Colors.titlePrimary.swiftUIColor)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
      .multilineTextAlignment(.center)
      .fixedSize(horizontal: false, vertical: true)
  }
  
  var buttonGroup: some View {
    VStack(
      spacing: 12
    ) {
      FullWidthButton(
        type: .primary,
        title: viewModel.isWalletRecoveredSuccessfully == true ? "Continue to Avalanche" : "Try using PIN"
      ) {
        if viewModel.isWalletRecoveredSuccessfully == true {
          viewModel.onContinueButtonTap()
        } else {
          viewModel.onRecoverWithPinButtonTap()
        }
      }
      
      if viewModel.isWalletRecoveredSuccessfully == false {
        FullWidthButton(
          type: .alternativeBordered,
          title: "Cancel"
        ) {
          viewModel.isWalletRecoveredSuccessfully = nil
        }
      }
    }
  }
}
