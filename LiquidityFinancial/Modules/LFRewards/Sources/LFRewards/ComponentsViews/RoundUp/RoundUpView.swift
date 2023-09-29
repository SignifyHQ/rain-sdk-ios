import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

public struct RoundUpView: View {
  
  public var body: some View {
    content
      .background(ModuleColors.background.swiftUIColor)
      .popup(isPresented: $viewModel.showError, style: .toast) {
        ToastView(toastMessage: LFLocalizable.genericErrorMessage)
      }
  }

  @StateObject var viewModel: RoundUpViewModel

  public init(viewModel: RoundUpViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  private var content: some View {
    VStack(spacing: 24) {
      details
      buttons
    }
    .scrollOnOverflow()
    .padding(.vertical, 20)
  }

  private var details: some View {
    VStack(spacing: 0) {
      ModuleImages.NewUser.roundUp.swiftUIImage
        .resizable()
      VStack(spacing: 24) {
        title
        message
        GenImages.CommonImages.dash.swiftUIImage
          .foregroundColor(ModuleColors.label.swiftUIColor)
        items
      }
      .padding(.horizontal, 30)
    }
  }

  private var title: some View {
    Text(LFLocalizable.RoundUp.title)
      .font(Fonts.regular.swiftUIFont(size: 24))
      .foregroundColor(ModuleColors.label.swiftUIColor)
  }

  private var message: some View {
    Text(
      LFLocalizable.RoundUp.message(LFUtilities.appName)
    )
    .font(Fonts.regular.swiftUIFont(size: 16))
    .foregroundColor(ModuleColors.label.swiftUIColor.opacity(0.75))
    .lineLimit(3)
    .lineSpacing(6.0)
    .multilineTextAlignment(.center)
    .frame(minHeight: 72)
  }

  private var items: some View {
    func item(image: Image, text: String) -> some View {
      HStack(spacing: 12) {
        image
          .foregroundColor(ModuleColors.label.swiftUIColor)
          .frame(width: 24, height: 24)
          .padding(.top, 4)
        Text(text)
          .font(Fonts.regular.swiftUIFont(size: 16))
          .foregroundColor(ModuleColors.label.swiftUIColor.opacity(0.75))
          .fixedSize(horizontal: false, vertical: true)
        Spacer()
      }
      .padding(.trailing, 12)
      .frame(maxWidth: .infinity)
    }

    return Group {
      item(image: ModuleImages.RoundUps.roundUpsCause.swiftUIImage, text: LFLocalizable.RoundUp.itemOne)
      item(image: ModuleImages.RoundUps.roundUpsCard.swiftUIImage, text: LFLocalizable.RoundUp.itemTwo)
      item(image: ModuleImages.RoundUps.roundUpsCycle.swiftUIImage, text: LFLocalizable.RoundUp.itemThree)
    }
  }

  private var buttons: some View {
    VStack(spacing: 10) {
      DonationsDisclosureView()
      FullSizeButton(title: LFLocalizable.RoundUp.continue, isDisable: false, isLoading: $viewModel.isLoading) {
        viewModel.continueTapped()
      }
      FullSizeButton(title: LFLocalizable.RoundUp.skip, isDisable: !viewModel.isLoading, type: .secondary) {
        viewModel.skipTapped()
      }
    }
    .padding(.horizontal, 30)
  }
}

#if DEBUG

  // MARK: - RoundUpView_Previews

struct RoundUpView_Previews: PreviewProvider {
  static var previews: some View {
    RoundUpView(viewModel: .init(onFinish: {}))
  }
}
#endif
