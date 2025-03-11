import GeneralFeature
import LFLocalizable
import LFUtilities
import LFStyleGuide
import SwiftUI

public struct CreditLimitBreakdownView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.refresh) private var refresh
  
  @StateObject private var viewModel: CreditLimitBreakdownViewModel
  
  public init(
    viewModel: CreditLimitBreakdownViewModel
  ) {
    self._viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    Group {
      if viewModel.isLoadingData {
        loadingView
      } else {
        ScrollView {
          contents
            .padding(.horizontal, 30)
        }
      }
    }
    .onAppear(
      perform: {
        viewModel.refreshData()
      }
    )
    .refreshable {
      viewModel.refreshData()
    }
    .frame(max: .infinity)
    .background(Colors.background.swiftUIColor)
    .track(name: String(describing: type(of: self)))
  }
  
  private var contents: some View {
    VStack(
      spacing: 12
    ) {
      // --- Available to spend value ---
      HStack {
        VStack(
          alignment: .leading,
          spacing: 3
        ) {
          Text(L10N.Common.CollateralLimitBreakdown.SpendingPower.title)
            .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.medium.value))
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
          Text(viewModel.creditBalances.spendingPowerFormatted)
            .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.extraLarge.value))
            .foregroundColor(Colors.whiteText.swiftUIColor)
          Text("\(viewModel.creditBalances.creditLimitFormatted) \(L10N.Common.CollateralLimitBreakdown.AssetValue.title)")
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.6))
        }
        
        Spacer()
      }
      
      // --- Assets section ---
      if viewModel.collateralAssets.isNotEmpty {
        VStack(
          alignment: .leading,
          spacing: 8
        ) {
          HStack {
            Text(L10N.Common.CollateralLimitBreakdown.AssetBalances.title)
              .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.medium.value))
              .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
            
            Spacer()
          }
          
          Text(L10N.Common.CollateralLimitBreakdown.AssetBalances.disclaimer)
            .foregroundColor(Colors.label.swiftUIColor)
            .opacity(0.5)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
            .multilineTextAlignment(.leading)
          
          ForEach(
            viewModel.collateralAssets,
            id: \.self
          ) { asset in
            assetCell(asset: asset)
          }
        }
        .padding(.top, 5)
        
        // --- Credit Limit Breakdown section ---
        VStack(
          alignment: .leading,
          spacing: 8
        ) {
          HStack {
            Text(L10N.Common.CollateralLimitBreakdown.CreditLimitBreakdown.title)
              .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.medium.value))
              .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
            
            Spacer()
          }
          .padding(.top, 4)
          .padding(.bottom, 6)
          
          VStack {
            ForEach(
              viewModel.collateralAssets,
              id: \.self
            ) { asset in
              breakdownRow(asset: asset)
            }
            
            Divider().background(Color.gray)
              .padding(.vertical, 1)
            
            BreakdownRow(
              title: L10N.Common.CollateralLimitBreakdown.AssetValue.title,
              amount: viewModel.creditBalances.creditLimitFormatted,
              isDetail: false
            )
            .padding(.bottom, 1)
            
            Text(L10N.Common.CollateralLimitBreakdown.SpendingPower.disclaimer)
              .foregroundColor(Colors.label.swiftUIColor)
              .opacity(0.5)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
              .multilineTextAlignment(.leading)
            
            Divider().background(Color.gray)
              .padding(.vertical, 1)
            
            BreakdownRow(
              title: L10N.Common.CollateralLimitBreakdown.PendingCharges.title,
              amount: viewModel.creditBalances.pendingChargesFormatted,
              isDetail: true
            )
            
            BreakdownRow(
              title: L10N.Common.CollateralLimitBreakdown.PendingLiquidation.title,
              amount: viewModel.creditBalances.pendingLiquidationFormatted,
              isDetail: true
            )
            
            Divider().background(Color.gray)
              .padding(.vertical, 1)
            
            BreakdownRow(
              title: L10N.Common.CollateralLimitBreakdown.SpendingPower.title,
              amount: viewModel.creditBalances.spendingPowerFormatted,
              isDetail: false,
              isBold: true
            )
          }
          .padding(16)
          .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(9))
        }
        
        Spacer()
      }
    }
  }
}

// MARK: - View Components
private extension CreditLimitBreakdownView {
  // TODO (Volo): Make this a reusable component
  @ViewBuilder
  func assetCell(
    asset: AssetModel
  ) -> some View {
    if let assetType = asset.type {
      Button {
        // No action here needed for now
      } label: {
        HStack(spacing: 8) {
          assetType.image
          
          Text(assetType.title)
            .foregroundColor(Colors.label.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          
          Spacer()
          
          VStack(
            alignment: .trailing,
            spacing: 2
          ) {
            Text(asset.availableBalanceFormatted)
              .foregroundColor(Colors.label.swiftUIColor)
              .font(Fonts.Inter.bold.swiftUIFont(size: Constants.FontSize.medium.value))
            
            if let bottomBalance = asset.availableUsdBalanceFormatted {
              Text(bottomBalance)
                .foregroundColor(Colors.label.swiftUIColor.opacity(0.6))
                .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
            }
          }
        }
        .frame(height: 56)
        .padding(.horizontal, 16)
        .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(9))
      }
    }
  }
  
  @ViewBuilder
  func breakdownRow(
    asset: AssetModel
  ) -> some View {
    // --- Breakdown Row Title ---
    BreakdownRow(
      title: L10N.Common.CollateralLimitBreakdown.TokenAdded.title(asset.type?.title ?? "N/A"),
      amount: asset.availableBalanceFormatted,
      isDetail: false
    )
    .padding(.top, 2)
    
    // --- Breakdown Row Exchange Rate ---
    if asset.hasExchangeRate {
      BreakdownRow(
        title: L10N.Common.CollateralLimitBreakdown.TokenExchangeRate.title,
        amount: asset.exchangeRateFormatted
      )
    }
    
    // --- Breakdown Row Advance Rate ---
    BreakdownRow(
      title: L10N.Common.CollateralLimitBreakdown.TokenAdvanceRate.title,
      amount: asset.advanceRateFormatted
    )
  }
  
  // TODO(Volo): Need to make this a reusable view
  var loadingView: some View {
    VStack {
      Spacer()
      
      LottieView(
        loading: .primary
      )
      .frame(
        width: 30,
        height: 20
      )
      
      Spacer()
    }
    .frame(max: .infinity)
  }
}

struct BreakdownRow: View {
  var title: String
  var amount: String
  var isDetail: Bool = true
  var isBold: Bool = false
  
  var body: some View {
    HStack {
      Text(title)
        .font(isBold ? Fonts.semiBold.swiftUIFont(size: Constants.FontSize.medium.value) : Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(isDetail ? Colors.label.swiftUIColor.opacity(0.6) : Colors.label.swiftUIColor)
      
      Spacer()
      
      Text(amount)
        .font(isBold ? Fonts.semiBold.swiftUIFont(size: Constants.FontSize.medium.value) : Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(isDetail ? Colors.label.swiftUIColor.opacity(0.6) : Colors.label.swiftUIColor)
    }
  }
}
