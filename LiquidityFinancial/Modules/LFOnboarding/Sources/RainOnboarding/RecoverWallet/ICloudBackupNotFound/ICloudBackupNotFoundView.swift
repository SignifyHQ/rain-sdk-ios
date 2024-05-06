import Foundation
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import Services
import Factory
import PortalSwift

struct ICloudBackupNotFoundView: View {
  @StateObject var viewModel: ICloudBackupNotFoundViewModel
  
  init() {
    _viewModel = .init(
      wrappedValue: ICloudBackupNotFoundViewModel()
    )
  }
  
  var body: some View {
    ZStack {
      if viewModel.isLoading {
        loadingView
      } else {
        content
      }
    }
    .background(Colors.background.swiftUIColor)
  }
}

// MARK: - View Components
private extension ICloudBackupNotFoundView {
  var content: some View {
    VStack(spacing: 24) {
      Spacer()
      mainContent
      Spacer()
      buttonGroupView
    }
    .navigationLink(item: $viewModel.navigation) { navigation in
      switch navigation {
      case .recoverByPinCode:
        EnterPinCodeView()
      }
    }
    .padding(.horizontal, 30)
    .padding(.bottom, 12)
    .track(name: String(describing: type(of: self)))
  }
  
  var loadingView: some View {
    VStack {
      Spacer()
      LottieView(loading: .primary)
        .frame(width: 30, height: 20)
      Spacer()
    }
    .frame(maxWidth: .infinity)
  }
  
  var mainContent: some View {
    VStack(spacing: 12) {
      GenImages.Images.iCloudNotFound.swiftUIImage
      Text(L10N.Common.ICloudBackupNotFound.title.uppercased())
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
      Text(L10N.Common.ICloudBackupNotFound.description)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
    }
  }
  
  var buttonGroupView: some View {
    VStack(spacing: 10) {
      FullSizeButton(
        title: L10N.Common.Button.ContactSupport.title,
        isDisable: false,
        type: .secondary,
        textColor: Colors.contrast.swiftUIColor
      ) {
        viewModel.contactSupportButtonTapped()
      }
      if viewModel.hasPasswordBackup {
        FullSizeButton(
          title: L10N.Common.ICloudBackupNotFound.TryAnotherMethod.title,
          isDisable: false
        ) {
          viewModel.tryAnotherMethodButtonTapped()
        }
      }
    }
  }
}
