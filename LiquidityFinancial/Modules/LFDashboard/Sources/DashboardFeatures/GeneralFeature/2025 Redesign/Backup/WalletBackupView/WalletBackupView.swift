import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import AccountData

public struct WalletBackupView: View {
  @StateObject private var viewModel: WalletBackupViewModel
  
  public init() {
    _viewModel = .init(wrappedValue: WalletBackupViewModel())
  }
  
  public var body: some View {
    ZStack {
      if viewModel.isLoading {
        loadingView
      } else {
        content
      }
    }
    .padding(.horizontal, 24)
    .padding(.top, 4)
    .padding(.bottom, 16)
    .background(Colors.baseAppBackground2.swiftUIColor)
    .appNavBar(navigationTitle: L10N.Common.WalletBackup.Screen.title)
    .sheetWithContentHeight(item: $viewModel.popup, content: { popup in
      switch popup {
      case .settingICloud:
        ICloudBackupView {
          viewModel.fetchBackupMethods(isAnimated: false)
        }
      case .enterNewPin:
        PinCodeBackupView(
          purpose: .enterNewPin,
          onContinue: { pin in
            viewModel.popup = .confirmPin(pin)
          }
        )
      case .confirmPin(let pin):
        PinCodeBackupView(
          purpose: .confirm(pin),
          onBack: {
            viewModel.popup = .enterNewPin
          }
        )
      }
    })
    .navigationBarTitleDisplayMode(.inline)
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: View Components
private extension WalletBackupView {
  var content: some View {
    VStack(alignment: .leading, spacing: 16) {
      backupMethodView(method: .iCloud)
      backupMethodView(method: .password)
      Spacer()
      complianceView
    }
  }
  
  var loadingView: some View {
    VStack {
      DefaultLottieView(loading: .branded)
        .frame(width: 52, height: 52)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
  
  func backupMethodView(method: WalletBackupViewModel.BackupMethod) -> some View {
    let isBackedUp = viewModel.backupMethods.contains(method)
    
    return VStack(alignment: .leading, spacing: 16) {
      HStack(alignment: .top) {
        method.imageView
        Spacer()
        if isBackedUp {
          // TODO: Update when having API response
          switch method {
          case .iCloud:
            Text(L10N.Common.WalletBackup.Icloud.lastUpdated(viewModel.lastUpdatedCloudBackupAt ?? "N/A"))
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
              .foregroundColor(Colors.textTertiary.swiftUIColor)
          case .password:
            activeView
          }
        } else {
          inactiveView
        }
      }
      
      backupMethodDescription(method: method)
      
      FullWidthButton(
        backgroundColor: Colors.grey400.swiftUIColor, title: method.buttonTitle
      ) {
        viewModel.onBackupItemTapped(method: method)
      }
    }
    .padding(16)
    .overlay {
      RoundedRectangle(cornerRadius: 36)
        .stroke(Colors.greyDefault.swiftUIColor, lineWidth: 1)
    }
  }
  
  func backupMethodDescription(method: WalletBackupViewModel.BackupMethod) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(method.title)
        .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.textPrimary.swiftUIColor)
      
      Text(method.description)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.textPrimary.swiftUIColor)
        .multilineTextAlignment(.leading)
    }
  }
  
  var activeView: some View {
    HStack(spacing: 4) {
      Image(systemName: "checkmark.circle.fill")
        .resizable()
        .frame(width: 14, height: 14, alignment: .center)
        .foregroundColor(Colors.success700.swiftUIColor)
      
      Text(L10N.Common.WalletBackup.Status.active)
        .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.success700.swiftUIColor)
    }
    .padding(.vertical, 6)
    .padding(.horizontal, 8)
    .background(Colors.success100.swiftUIColor)
    .clipShape(Capsule())
  }
  
  var inactiveView: some View {
    HStack(spacing: 4) {
      Image(systemName: "exclamationmark.triangle.fill")
        .resizable()
        .frame(width: 14, height: 14, alignment: .center)
        .foregroundColor(Colors.error700.swiftUIColor)
      
      Text(L10N.Common.WalletBackup.Status.inactive)
        .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.error700.swiftUIColor)
    }
    .padding(.vertical, 6)
    .padding(.horizontal, 8)
    .background(Colors.error100.swiftUIColor)
    .clipShape(Capsule())
  }
  
  var complianceView: some View {
    HStack(alignment: .top, spacing: 12) {
      GenImages.Images.icoCompliance.swiftUIImage
        .resizable()
        .frame(32)
      
      Text(L10N.Common.WalletBackup.note)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.textTertiary.swiftUIColor)
    }
    .frame(maxWidth: .infinity)
  }
}
