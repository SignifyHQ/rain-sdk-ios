import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable

public struct SelectCauseCategoriesView: View {
  
  @StateObject private var viewModel: SelectCauseCategoriesViewModel
  
  let destination: AnyView
  let whereStart: RewardWhereStart
  public init(viewModel: SelectCauseCategoriesViewModel, destination: AnyView, whereStart: RewardWhereStart = .onboarding) {
    _viewModel = .init(wrappedValue: viewModel)
    self.destination = destination
    self.whereStart = whereStart
  }
  
  public var body: some View {
    content
      .scrollOnOverflow()
      .background(ModuleColors.background.swiftUIColor)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          if whereStart == .onboarding {
            SkipFundraiserView {
              viewModel.navigation = .agreement
            }
          }
        }
      }
      .navigationLink(item: $viewModel.navigation) { navigation in
        switch navigation {
        case let .selectFundraiser(cause, fundraisers):
          SelectFundraiserView(
            viewModel: SelectFundraiserViewModel(
              causeModel: cause,
              fundraisers: fundraisers,
              showSkipButton: false),
            destination: destination,
            whereStart: whereStart
          )
        case .agreement:
          destination
        }
      }
      .popup(isPresented: $viewModel.showError, style: .toast) {
        ToastView(toastMessage: LFLocalizable.genericErrorMessage)
      }
      .onAppear {
        //TODO: Update later
        //analyticsService.track(event: Event(name: .viewsSelectFundraiserCategories))
      }
  }
  
  private var content: some View {
    VStack(alignment: .leading, spacing: 0) {
      title
      grid
      Spacer()
      bottom
    }
    .padding(.top, 8)
  }
  
  private var title: some View {
    VStack(alignment: .leading, spacing: 8) {
      
      Text(LFLocalizable.CausesFilter.title)
        .font(Fonts.regular.swiftUIFont(size: 24))
        .foregroundColor(ModuleColors.label.swiftUIColor)
      
      Text(LFLocalizable.CausesFilter.subtitle)
        .font(Fonts.regular.swiftUIFont(size: 16))
        .foregroundColor(ModuleColors.label.swiftUIColor.opacity(0.75))
    }
    .padding(.horizontal, 18)
    .padding(.bottom, 8)
  }
  
  private var grid: some View {
    ScrollView {
      LazyVGrid(columns: .init(repeating: .init(.flexible()), count: 3), spacing: 12) {
        ForEach(viewModel.causes, content: gridItem(cause:))
      }
      .padding(.horizontal, 30)
      .padding(.top, 32)
      .padding(.bottom, 8)
    }
  }
  
  private var bottom: some View {
    VStack(alignment: .leading, spacing: 12) {
      DonationsDisclosureView()
      continueButton
    }
    .padding(.horizontal, 30)
  }
  
  private var continueButton: some View {
    FullSizeButton(title: LFLocalizable.CausesFilter.continue, isDisable: $viewModel.selected.isEmpty, isLoading: $viewModel.isLoading) {
      viewModel.continueTapped()
    }
  }
  
  private func gridItem(cause: CauseModel) -> some View {
    CauseItemView(cause: cause)
      .applyIf(viewModel.isSelected(cause: cause)) {
        $0.overlay(
          RoundedRectangle(cornerRadius: 10)
            .stroke(AngularGradient.primary(colors: Color.gradientAngular))
        )
      }
      .onTapGesture {
        viewModel.onTap(cause: cause)
      }
  }
}
