import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

struct SelectFundraiserView: View {
  @StateObject private var viewModel: SelectFundraiserViewModel

  let destination: AnyView
  init(viewModel: SelectFundraiserViewModel, destination: AnyView) {
    _viewModel = .init(wrappedValue: viewModel)
    self.destination = destination
  }

  var body: some View {
    content
      .background(ModuleColors.background.swiftUIColor)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          if viewModel.showSkipButton {
            skipButton
          }
        }
      }
      .navigationLink(item: $viewModel.navigation) { navigation in
        switch navigation {
        case .agreement:
          destination
        }
      }
      .popup(isPresented: $viewModel.showErrorAlert, style: .toast) {
        ToastView(toastMessage: LFLocalizable.SelectFundraiser.error)
      }
  }

  private var content: some View {
    VStack(alignment: .leading, spacing: 32) {
      title
      ScrollView(showsIndicators: false) {
        VStack(spacing: 16) {
          ForEach(viewModel.fundraisers) { fundraiser in
            item(fundraiser: fundraiser)
          }
        }
        SuggestCauseButton()
          .padding(.vertical, 16)
      }
      .frame(maxWidth: .infinity)
    }
    .padding(.horizontal, 30)
    .padding(.top, 20)
  }

  private var title: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(LFLocalizable.SelectFundraiser.title)
        .font(Fonts.regular.swiftUIFont(size: 24))
        .foregroundColor(ModuleColors.label.swiftUIColor)
      
      Text(LFLocalizable.SelectFundraiser.subtitle)
        .font(Fonts.regular.swiftUIFont(size: 16))
        .foregroundColor(ModuleColors.label.swiftUIColor.opacity(0.75))
    }
  }

  private var skipButton: some View {
    Group {
      if viewModel.showSkipButton {
        SkipFundraiserView {
          viewModel.navigation = .agreement
        }
      }
    }
  }

  private func item(fundraiser: FundraiserModel) -> some View {
    VStack(spacing: 16) {
      FundraiserItemView(fundraiser: fundraiser, destination: destination)
    }
    .background(ModuleColors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
  }
}
