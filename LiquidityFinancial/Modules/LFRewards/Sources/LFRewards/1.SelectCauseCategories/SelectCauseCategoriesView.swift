import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import Factory
import Services

public struct SelectCauseCategoriesView: View {
  @Injected(\.analyticsService) var analyticsService
  @StateObject private var viewModel: SelectCauseCategoriesViewModel
  
  var isPopToRoot: Bool {
    onPopToRoot != nil
  }
  
  let whereStart: RewardWhereStart
  var onPopToRoot: (() -> Void)?
  
  public init(viewModel: SelectCauseCategoriesViewModel, whereStart: RewardWhereStart = .onboarding, onPopToRoot: (() -> Void)? = nil) {
    _viewModel = .init(wrappedValue: viewModel)
    self.whereStart = whereStart
    self.onPopToRoot = onPopToRoot
  }
  
  public var body: some View {
    content
      .scrollOnOverflow()
      .background(ModuleColors.background.swiftUIColor)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          if whereStart == .onboarding {
            SkipFundraiserView {
              viewModel.skipAndDumpToYourAccount()
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
            whereStart: whereStart
          )
        }
      }
      .popup(isPresented: $viewModel.showError, style: .toast) {
        ToastView(toastMessage: LFLocalizable.genericErrorMessage)
      }
      .navigationBarBackButtonHidden(isPopToRoot)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            onPopToRoot?()
          } label: {
            CircleButton(style: .xmark)
          }
          .opacity(isPopToRoot ? 1 : 0)
        }
      }
      .onAppear {
        analyticsService.track(event: AnalyticsEvent(name: .viewsSelectFundraiserCategories))
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
