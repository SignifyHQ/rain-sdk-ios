import LFLocalizable
import LFStyleGuide
import LFUtilities
import Services
import SwiftTooltip
import SwiftUI

public struct TransactionsView: View {
  @Environment(\.scenePhase) private var scenePhase
  
  @StateObject private var viewModel: TransactionsViewModel
  @StateObject var transactionFilterViewModel: TransactionsFilterViewModel = TransactionsFilterViewModel()

  public init(
    currencyType: String,
    contractAddress: String? = nil,
    cardID: String? = nil,
    transactionTypes: [String] = []
  ) {
    _viewModel = .init(
      wrappedValue: .init(
        currencyType: currencyType,
        contractAddress: contractAddress,
        cardID: cardID ?? .empty,
        transactionTypes: transactionTypes
      )
    )
  }
  
  public var body: some View {
    VStack {
      if viewModel.isLoading {
        loadingView
      } else {
        contentView
      }
    }
    .padding(.horizontal, 24)
    .background(Colors.baseAppBackground2.swiftUIColor)
    .appNavBar(navigationTitle: L10N.Common.Transactions.Screen.title)
    .sheetWithContentHeight(
      isPresented: Binding(
        get: { viewModel.presentedFilterSheet != nil },
        set: { newValue in
          if !newValue {
            viewModel.presentedFilterSheet = nil
          }
        }
      )
    ) {
      TransactionsFilterSheetView(
        viewModel: transactionFilterViewModel,
        presentedFilterSheet: $viewModel.presentedFilterSheet
      )
      .onAppear(
        perform: {
          transactionFilterViewModel.filterConfiguration = viewModel.filterConfiguration
        }
      )
    }
    .navigationLink(item: $viewModel.transactionDetail) { item in
      TransactionDetailsView(
        method: .transactionID(item.id),
        kind: item.detailType,
        isPopToRoot: false
      )
    }
    .onChange(
      of: transactionFilterViewModel.didApplyChanges
    ) { _ in
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        viewModel.filterConfiguration = transactionFilterViewModel.filterConfiguration
        viewModel.loadInitialData()
      }
    }
    .track(name: String(describing: type(of: self)))
  }
}

extension TransactionsView {
  var contentView: some View {
    VStack(
      spacing: 24
    ) {
      DefaultSearchBar(searchText: $viewModel.searchText)
      
      HStack {
        ForEach(TransactionsFilterButtonType.allCases) { type in
          filterButton(type: type)
        }
        
        Spacer()
      }
      
      VStack(
        spacing: 10
      ) {
        showMerchantCurrencyView
        listView
      }
    }
  }
  
  var listView: some View {
    ScrollView(
      showsIndicators: false
    ) {
      LazyVStack(
        spacing: 0
      ) {
        ForEach($viewModel.filteredTransactions, id: \.id) { $monthSection in
          Section(
            header: headerSectionView(section: monthSection)
              .onTapGesture {
                withAnimation(
                  .spring(
                    response: 0.5,
                    dampingFraction: viewModel.expandedSections[monthSection.month] == true ? 0.85 : 0.7
                  )
                ) {
                  monthSection.isExpanded.toggle()
                  viewModel.expandedSections[monthSection.month] = monthSection.isExpanded
                }
              }
          ) {
            if monthSection.isExpanded {
              ForEach(monthSection.items) { transaction in
                TransactionItemView(
                  transaction: transaction,
                  isShowingMerchantCurrency: viewModel.isShowingMerchantCurrency
                ) {
                  viewModel.selectedTransaction(transaction)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                .listRowBackground(Colors.background.swiftUIColor)
                .onAppear {
                  viewModel.loadMoreIfNeccessary(transaction: transaction)
                }
              }
              .transition(
                .move(
                  edge: .top
                )
                .combined(
                  with: .opacity
                )
              )
            }
          }
        }
      }
      
      if viewModel.isLoadingMore {
        DefaultLottieView(loading: .ctaFast)
          .frame(width: 24, height: 24)
      }
    }
    .simultaneousGesture(
      DragGesture()
        .onChanged { _ in
          if viewModel.isMerchantCurrencyTooltipShown {
            viewModel.isMerchantCurrencyTooltipShown = false
          }
        }
    )
  }
  
  func headerSectionView(section: TransactionSection) -> some View {
    VStack(spacing: 12) {
      HStack {
        Text(section.month)
          .foregroundColor(Colors.textTertiary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .frame(maxWidth: .infinity, alignment: .leading)
        
        GenImages.Images.icoExpandDown.swiftUIImage
          .resizable()
          .frame(24)
          .rotationEffect(
            .degrees(section.isExpanded ? 0 : -180)
          )
          .animation(
            .easeOut(
              duration: 0.2
            ),
            value: section.isExpanded
          )
      }
      .padding(.top, 12)
      .padding(.horizontal, 8)
      
      Divider()
        .frame(height: 1)
        .background(Colors.greyDefault.swiftUIColor)
        .frame(maxWidth: .infinity)
    }
    .background(Colors.baseAppBackground2.swiftUIColor)
  }
  
  func filterButton(
    type: TransactionsFilterButtonType
  ) -> some View {
    Button(
      action: {
        viewModel.presentedFilterSheet = type
      }, label: {
        if let image = type.image {
          image
        }
        
        if let title = type.title {
          HStack(spacing: 4) {
            if let appliedFiltersCount = viewModel.appliedFilters[type],
               appliedFiltersCount > 0 {
              Text("\(title) (\(appliedFiltersCount))")
            } else {
              Text(title)
            }
            
            GenImages.Images.icoExpandDown.swiftUIImage
              .resizable()
              .frame(width: 16, height: 16)
          }
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        }
      }
    )
    .frame(height: 32, alignment: .center)
    .padding(.horizontal, 12)
    .background(Colors.buttonSurfaceSecondary.swiftUIColor)
    .foregroundColor(Colors.textPrimary.swiftUIColor)
    .cornerRadius(16)
    .overlay {
      RoundedRectangle(cornerRadius: 16)
        .stroke(Colors.greyDefault.swiftUIColor, lineWidth: 1)
    }
  }
  
  var showMerchantCurrencyView: some View {
    Toggle(
      isOn: $viewModel.isShowingMerchantCurrency
    ) {
      HStack(
        spacing: 8
      ) {
        Text(L10N.Common.Transactions.ShowMerchantCurrency.title)
          .foregroundColor(Colors.textPrimary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          //.frame(maxWidth: .infinity, alignment: .leading)
        
        Button {
          viewModel.isMerchantCurrencyTooltipShown.toggle()
        } label: {
          GenImages.Images.icoSupport.swiftUIImage
            .resizable()
            .frame(24)
        }
        .tooltip(
          text: L10N.Common.Transactions.ShowMerchantCurrency.Tooltip.body,
          isPresented: $viewModel.isMerchantCurrencyTooltipShown,
          pointerPosition: .bottomCenter,
          config: toolTipConfiguration()
        )
        
        Spacer()
      }
    }
    .padding(.horizontal, 8)
  }
  
  var loadingView: some View {
    VStack(alignment: .center) {
      Spacer()
      DefaultLottieView(loading: .branded)
        .frame(width: 52, height: 52)
      Spacer()
    }
    .frame(maxWidth: .infinity)
  }
}

// MARK: - Helper Methods
extension TransactionsView {
  private func toolTipConfiguration(
  ) -> SwiftTooltip.Configuration {
    SwiftTooltip.Configuration(
      textColor: .black,
      textFont: Fonts.regular.uiFont(size: Constants.FontSize.ultraSmall.value),
      color: Colors.grey25.swiftUIColor.uiColor,
      backgroundColor: .clear,
      shadowColor: .clear,
      shadowOffset: .zero,
      shadowOpacity: .zero,
      shadowRadius: 0,
      dismissBehavior: .dismissOnTapEverywhere
    )
  }
}
