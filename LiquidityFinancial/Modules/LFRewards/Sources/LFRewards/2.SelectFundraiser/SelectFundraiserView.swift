import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import Factory

public struct SelectFundraiserView: View {
  @StateObject private var viewModel: SelectFundraiserViewModel
  
  let whereStart: RewardWhereStart
  public init(viewModel: SelectFundraiserViewModel, whereStart: RewardWhereStart = .onboarding) {
    _viewModel = .init(wrappedValue: viewModel)
    self.whereStart = whereStart
  }

  public var body: some View {
    content
      .background(ModuleColors.background.swiftUIColor)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          if viewModel.showSkipButton {
            skipButton
          }
        }
      }
      .popup(isPresented: $viewModel.showErrorAlert, style: .toast) {
        ToastView(toastMessage: L10N.Common.SelectFundraiser.error)
      }
  }

  private var content: some View {
    VStack(alignment: .leading, spacing: 32) {
      title
      ScrollView(showsIndicators: false) {
        VStack(spacing: 16) {
          ForEach(viewModel.fundraisers, id: \.id) { fundraiser in
            item(fundraiser: fundraiser)
          }
        }
        SuggestCauseButton()
          .padding(.vertical, 16)
      }
      .frame(maxWidth: .infinity)
    }
    .padding(.horizontal, 30)
    .padding(.top, 12)
  }

  private var title: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(L10N.Common.SelectFundraiser.causes(viewModel.categoryName.uppercased()))
        .font(Fonts.regular.swiftUIFont(size: 24))
        .foregroundColor(ModuleColors.label.swiftUIColor)
    }
  }

  private var skipButton: some View {
    Group {
      if viewModel.showSkipButton {
        SkipFundraiserView {
          viewModel.skipAndDumpToYourAccount()
        }
      }
    }
  }

  private func item(fundraiser: FundraiserModel) -> some View {
    VStack(spacing: 16) {
      FundraiserItemView(fundraiser: fundraiser, whereStart: whereStart)
    }
    .background(ModuleColors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
  }
}
