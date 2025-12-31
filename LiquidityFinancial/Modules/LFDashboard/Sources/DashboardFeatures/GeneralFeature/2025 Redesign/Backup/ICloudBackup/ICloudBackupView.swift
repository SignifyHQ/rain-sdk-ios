import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

struct ICloudBackupView: View {
  @Environment(\.dismiss) private var dismiss
  
  @StateObject private var viewModel: ICloudBackupViewModel
  
  let onSuccess: (() -> Void)?
  
  init(onSuccess: (() -> Void)? = nil) {
    self._viewModel = .init(wrappedValue: ICloudBackupViewModel())
    self.onSuccess = onSuccess
  }
  
  var body: some View {
    VStack(spacing: 32) {
      headerView
      contentView
      actionButton
    }
    .padding([.horizontal, .top], 24)
    .padding(.bottom, 16)
    .background(Colors.grey900.swiftUIColor)
    .toast(data: $viewModel.toastData)
  }
}

private extension ICloudBackupView {
  var headerView: some View {
    ZStack(alignment: .leading) {
      Button {
        dismiss()
      } label: {
        Image(systemName: "arrow.left")
          .font(.title2)
          .foregroundColor(Colors.iconPrimary.swiftUIColor)
      }
      .disabled(viewModel.state == .inProgress)
      
      Text(L10N.Common.WalletBackup.UpdateBackup.Popup.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.textPrimary.swiftUIColor)
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
  }
  
  var contentView: some View {
    VStack(
      alignment: .center,
      spacing: 24
    ) {
      stateView
      
      Text(viewModel.state.description)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.textPrimary.swiftUIColor)
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
  }
  
  @ViewBuilder
  var stateView: some View {
    switch viewModel.state {
    case .start, .completed:
      icloudImage
    case .inProgress:
      DefaultLottieView(loading: .branded)
        .frame(width: 52, height: 52)
    }
  }
  
  var icloudImage: some View {
    GenImages.Images.icoIcloud.swiftUIImage
      .resizable()
      .frame(width: 37, height: 24)
  }
  
  var actionButton: some View {
    FullWidthButton(
      title: viewModel.state.buttonTitle,
      isDisabled: viewModel.state == .inProgress,
      action: {
        switch viewModel.state {
        case .start:
          viewModel.backupPortalWalletWithIcloud {
            onSuccess?()
          }
        case .completed:
          dismiss()
        default: break
        }
      }
    )
  }
}
