import GeneralFeature
import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftTooltip
import SwiftUI

public struct AssetsBreakdownView: View {
  @StateObject var viewModel: AssetsBreakdownViewModel
  
  public init(
    viewModel: AssetsBreakdownViewModel
  ) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    ZStack {
      VStack() {
        contentView
      }
      .padding(.bottom, 16)
      .padding(.horizontal, 24)
    }
    .background(Colors.backgroundPrimary.swiftUIColor)
    .toast(
      data: $viewModel.currentToast
    )
    .withLoadingIndicator(
      isShowing: $viewModel.isLoadingData
    )
    .onAppear(
      perform: {
        viewModel.onAppear()
      }
    )
    .refreshable {
      await viewModel.onRefreshPull()
    }
    .navigationLink(
      item: $viewModel.navigation,
      destination: { navigation in
        switch navigation {
        case .addToCard:
          AddToCardView()
        }
      }
    )
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension AssetsBreakdownView {
  var contentView: some View {
    ScrollView {
      VStack(
        alignment: .leading,
        spacing: 24
      ) {
        spendingPowerView
        
        buttonGroup
        
        if viewModel.collateralAssets.isNotEmpty {
          availableAssetsView
        }
      }
      .frame(
        maxWidth: .infinity
      )
      .padding(.top, 8)
      .background(Colors.backgroundPrimary.swiftUIColor)
      .scrollIndicators(.hidden)
    }
    .simultaneousGesture(
      DragGesture()
        .onChanged { _ in
          if viewModel.shouldShowTooltipWithId != nil {
            viewModel.shouldShowTooltipWithId = nil
          }
          
          if viewModel.shouldShowTotalAvailabelTooltip {
            viewModel.shouldShowTotalAvailabelTooltip = false
          }
        }
    )
  }
  
  var spendingPowerView: some View {
    VStack(
      alignment: .leading,
      spacing: 10
    ) {
      Text(L10N.Common.Assets.SpendingPower.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .multilineTextAlignment(.leading)
      
      HStack {
        VStack(
          alignment: .leading,
          spacing: 2
        ) {
          Text(viewModel.creditBalances.spendingPowerFormatted)
            .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.large.value))
            .multilineTextAlignment(.leading)
          
          Text(L10N.Common.Assets.SpendingPower.TotlaAssetValue.title(viewModel.totalAssetValueFormatted))
            .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.small.value))
            .foregroundStyle(Colors.blue300.swiftUIColor)
            .multilineTextAlignment(.leading)
        }
        
        Spacer()
      }
    }
    .padding(12)
    .overlay(
      RoundedRectangle(
        cornerRadius: 18
      )
      .inset(
        by: 0.5
      )
      .stroke(
        Colors.grey300.swiftUIColor,
        lineWidth: 1
      )
    )
  }
  
  var buttonGroup: some View {
    FullWidthButton(
      type: .alternativeLight,
      title: L10N.Common.Assets.AddFunds.Button.title
    ) {
      viewModel.onAddFundsButtonTap()
    }
  }
  
  var availableAssetsView: some View {
    VStack(
      alignment: .leading,
      spacing: 12
    ) {
      // Available to spend section header
      HStack {
        VStack(
          alignment: .leading,
          spacing: 4
        ) {
          Text(L10N.Common.Assets.AvailableAssets.Header.title)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
            .multilineTextAlignment(.leading)
          
          Text(L10N.Common.Assets.AvailableAssets.Header.subtitle)
            .foregroundStyle(Colors.textSecondary.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
            .multilineTextAlignment(.leading)
        }
        
        Spacer()
      }
      // List of the available assets with amounts and USD values
      VStack(
        spacing: 0
      ) {
        ForEach(
          viewModel.collateralAssets,
          id: \.self
        ) { asset in
          assetCell(asset: asset)
        }
      }
      
      VStack(
        spacing: 12
      ) {
        // Breakdown of active assets header
        HStack {
          Text(L10N.Common.Assets.AssetBreakdown.Header.title)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
            .multilineTextAlignment(.leading)
          
          Spacer()
          
          GenImages.Images.icoExpandDown.swiftUIImage
            .resizable()
            .frame(32)
            .rotationEffect(
              .degrees(viewModel.isBreakdownExpanded ? 0 : -180)
            )
            .animation(
              .easeOut(
                duration: 0.2
              ),
              value: viewModel.isBreakdownExpanded
            )
        }
        .background(Colors.backgroundPrimary.swiftUIColor)
        .zIndex(1)
        .onTapGesture {
          withAnimation(
            .spring(
              response: 0.5,
              dampingFraction: viewModel.isBreakdownExpanded ? 0.85 : 0.7
            )
          ) {
            viewModel.isBreakdownExpanded.toggle()
          }
        }
        
        if viewModel.isBreakdownExpanded {
          Group {
            // Breakdown list of the active assets
            VStack(
              spacing: 12
            ) {
              ForEach(
                viewModel.collateralAssets
                // Only show the non-zero balance assets in the breakdown
                  .filter { asset in
                    !asset.isAvailableBalanceRoundedZero
                  },
                id: \.self
              ) { asset in
                breakdownCell(asset: asset)
              }
            }
            // Breakdown summary section
            breakdownSummarySectionView
          }
          .transition(
            .move(
              edge: .top
            )
            .combined(
              with: .opacity
            )
          )
          .zIndex(0)
        }
      }
      .clipped()
    }
  }
  
  @ViewBuilder
  func assetCell(
    asset: AssetModel
  ) -> some View {
    if let assetType = asset.type {
      Button {
        // No action here needed for now
      } label: {
        HStack(
          spacing: 10
        ) {
          assetType
            .icon?
            .resizable()
            .frame(32)
          
          VStack(
            alignment: .leading,
            spacing: 2
          ) {
            Text(assetType.symbol ?? "N/A")
              .foregroundStyle(Colors.textPrimary.swiftUIColor)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
            
            if let name = assetType.name {
              Text(name)
                .foregroundColor(Colors.textTertiary.swiftUIColor)
                .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
            }
          }
          
          Spacer()
          
          VStack(
            alignment: .trailing,
            spacing: 2
          ) {
            Text(asset.availableBalanceFormatted)
              .foregroundStyle(Colors.textPrimary.swiftUIColor)
              .font(Fonts.Inter.semiBold.swiftUIFont(size: Constants.FontSize.small.value))
            
            if let bottomBalance = asset.totalUsdBalanceFormatted {
              Text(bottomBalance)
                .foregroundColor(Colors.textTertiary.swiftUIColor)
                .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
            }
          }
        }
        .padding(.vertical, 12)
      }
    }
  }
  
  @ViewBuilder
  func breakdownCell(
    asset: AssetModel
  ) -> some View {
    if let assetType = asset.type {
      VStack(
        spacing: 12
      ) {
        VStack(
          spacing: 8
        ) {
          // Asset in the card row
          HStack(
            spacing: 8
          ) {
            assetType
              .icon?
              .resizable()
              .frame(20)
            
            Text(L10N.Common.Assets.AssetBreakdown.Rows.InTheCard.title(assetType.symbol ?? "N/A"))
              .foregroundStyle(Colors.textSecondary.swiftUIColor)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
            
            Spacer()
            
            Text(asset.availableBalanceFormatted)
              .foregroundStyle(Colors.textSecondary.swiftUIColor)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          }
          // Market price row
          HStack(
            spacing: 8
          ) {
            Text(L10N.Common.Assets.AssetBreakdown.Rows.MarketPrice.title)
              .foregroundStyle(Colors.textSecondary.swiftUIColor)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
            
            Spacer()
            
            Text(asset.exchangeRateFormatted)
              .foregroundStyle(Colors.textSecondary.swiftUIColor)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          }
          // Total value row
          HStack(
            spacing: 8
          ) {
            Text(L10N.Common.Assets.AssetBreakdown.Rows.TotalTokenValue.title(assetType.symbol ?? "N/A"))
              .foregroundStyle(Colors.blue300.swiftUIColor)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
            
            Spacer()
            
            Text(asset.totalUsdBalanceFormatted ?? "N/A")
              .foregroundStyle(Colors.blue300.swiftUIColor)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          }
          // Available to spend row
          HStack(
            spacing: 0
          ) {
            Text(L10N.Common.Assets.AssetBreakdown.Rows.AvailableToSpend.title(asset.advanceRateFormatted))
              .foregroundStyle(Colors.textPrimary.swiftUIColor)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
            
            // Show "?" button for assets with advance rate < 100 only
            if asset.hasAdvanceRate {
              Button {
                viewModel.shouldShowTooltipWithId = asset.id
              } label: {
                GenImages.Images.icoSupport.swiftUIImage
                  .resizable()
                  .frame(24)
              }
              .tooltip(
                text: L10N.Common.Assets.AssetBreakdown.Rows.AvailableToSpend.Tooltip.body(assetType.symbol ?? "N/A"),
                isPresented: .stringEquals($viewModel.shouldShowTooltipWithId, asset.id),
                pointerPosition: .bottomCenter,
                config: toolTipConfiguration()
              )
            }
            
            Spacer()
            
            Text(asset.availableToSpendUsdBalanceFormatted ?? "N/A")
              .foregroundStyle(Colors.textPrimary.swiftUIColor)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          }
        }
        
        Divider()
          .background(Colors.dividerPrimary.swiftUIColor)
      }
    }
  }
  
  var breakdownSummarySectionView: some View {
    VStack(
      spacing: 12
    ) {
      VStack(
        spacing: 8
      ) {
        // Total asset value row
        HStack(
        ) {
          Text(L10N.Common.Assets.AssetBreakdown.Rows.TotalAssetValue.title)
            .foregroundStyle(Colors.blue300.swiftUIColor)
            .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.medium.value))
          
          Spacer()
          
          Text(viewModel.totalAssetValueFormatted)
            .foregroundStyle(Colors.blue300.swiftUIColor)
            .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.medium.value))
        }
        // Total available to spend value row
        HStack(
          spacing: 0
        ) {
          Text(L10N.Common.Assets.AssetBreakdown.TotalAvailableToSpend.title)
            .foregroundStyle(Colors.textPrimary.swiftUIColor)
            .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.medium.value))
          
          Button {
            viewModel.shouldShowTotalAvailabelTooltip = true
          } label: {
            GenImages.Images.icoSupport.swiftUIImage
              .resizable()
              .frame(24)
          }
          .tooltip(
            text: L10N.Common.Assets.AssetBreakdown.TotalAvailableToSpend.tooltip,
            isPresented: $viewModel.shouldShowTotalAvailabelTooltip,
            pointerPosition: .bottomCenter,
            config: toolTipConfiguration()
          )
          
          Spacer()
          
          Text(viewModel.creditBalances.creditLimitFormatted)
            .foregroundStyle(Colors.textPrimary.swiftUIColor)
            .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.medium.value))
        }
      }
      // Divider
      Divider()
        .background(Colors.dividerPrimary.swiftUIColor)
      
      VStack(
        spacing: 8
      ) {
        // Pending charges row
        HStack(
        ) {
          Text(L10N.Common.Assets.AssetBreakdown.Rows.PendingCharges.title)
            .foregroundStyle(Colors.grey300.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          
          Spacer()
          
          Text(viewModel.creditBalances.pendingChargesFormatted)
            .foregroundStyle(Colors.grey300.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        }
        // Pending liquidations row
        HStack(
        ) {
          Text(L10N.Common.Assets.AssetBreakdown.Rows.PendingLiquidations.title)
            .foregroundStyle(Colors.grey300.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          
          Spacer()
          
          Text(viewModel.creditBalances.pendingLiquidationFormatted)
            .foregroundStyle(Colors.grey300.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        }
      }
      // Divider
      Divider()
        .background(Colors.dividerPrimary.swiftUIColor)
      // Spending power row
      HStack(
      ) {
        Text(L10N.Common.Assets.AssetBreakdown.Rows.SpendingPower.title)
          .foregroundStyle(Colors.textPrimary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.headline.value))
        
        Spacer()
        
        Text(viewModel.creditBalances.spendingPowerFormatted)
          .foregroundStyle(Colors.textPrimary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.headline.value))
      }
      // Footer disclosure text
      HStack {
        Text(L10N.Common.Assets.AssetBreakdown.disclosure)
          .multilineTextAlignment(.leading)
          .foregroundStyle(Colors.grey300.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .padding(.bottom, 16)
        
        Spacer()
      }
    }
  }
}

// MARK: - Helper Methods
extension AssetsBreakdownView {
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

// MARK: - Private Enums
extension AssetsBreakdownView {}
