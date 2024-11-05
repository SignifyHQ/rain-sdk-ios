import GeneralFeature
import LFLocalizable
import LFUtilities
import LFStyleGuide
import SwiftUI

struct CreditLimitBreakdownView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.refresh) private var refresh
  
  @StateObject private var viewModel: CreditLimitBreakdownViewModel
  
  init(
    viewModel: CreditLimitBreakdownViewModel
  ) {
    self._viewModel = .init(wrappedValue: viewModel)
  }
  
  var body: some View {
    ScrollView {
      VStack(
        spacing: 12
      ) {
        // --- Credit limit value ---
        HStack {
          VStack(alignment: .leading) {
            Text(L10N.Common.CollateralLimitBreakdown.CreditLimit.title)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
              .foregroundColor(Colors.label.swiftUIColor.opacity(0.6))
            Text(viewModel.creditLimitFormatted)
              .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.extraLarge.value))
              .foregroundColor(Colors.whiteText.swiftUIColor)
          }
          
          Spacer()
        }
        .padding(.horizontal, 30)
        
        // --- Asset Balances section ---
        if viewModel.collateralAssets.isNotEmpty {
          VStack(
            alignment: .leading,
            spacing: 8
          ) {
            HStack {
              Text(L10N.Common.CollateralLimitBreakdown.AssetBalances.title)
                .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
                .foregroundColor(Colors.label.swiftUIColor.opacity(0.6))
              
              Spacer()
            }
            .padding(.bottom, 6)
            
            ForEach(
              viewModel.collateralAssets,
              id: \.self
            ) { asset in
              assetCell(asset: asset)
            }
          }
          .padding(.horizontal, 30)
          
          // --- Credit Limit Breakdown section ---
          VStack(
            alignment: .leading,
            spacing: 8
          ) {
            HStack {
              Text(L10N.Common.CollateralLimitBreakdown.CreditLimitBreakdown.title)
                .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
                .foregroundColor(Colors.label.swiftUIColor.opacity(0.6))
              
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
              
              BreakdownRow(
                title: L10N.Common.CollateralLimitBreakdown.CreditLimit.title,
                amount: viewModel.creditLimitFormatted,
                isDetail: false,
                isBold: true
              )
            }
            .padding(16)
            .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(9))
          }
          .padding(.horizontal, 30)
          
          Spacer()
        }
      }
    }
    .refreshable {
      viewModel.refreshData()
    }
    .frame(max: .infinity)
    .background(Colors.background.swiftUIColor)
    .track(name: String(describing: type(of: self)))
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
        title: L10N.Common.CollateralLimitBreakdown.TokenExchangeRate.title(asset.type?.title ?? "N/A"),
        amount: asset.exchangeRateFormatted
      )
    }
    
    // --- Breakdown Row Advance Rate ---
    BreakdownRow(
      title: L10N.Common.CollateralLimitBreakdown.TokenAdvanceRate.title(asset.type?.title ?? "N/A"),
      amount: asset.advanceRateFormatted
    )
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
        .font(isBold ? Fonts.bold.swiftUIFont(size: Constants.FontSize.medium.value) : Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(isDetail ? Colors.label.swiftUIColor.opacity(0.6) : Colors.label.swiftUIColor)
      
      Spacer()
      
      Text(amount)
        .font(isBold ? Fonts.bold.swiftUIFont(size: Constants.FontSize.medium.value) : Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(isDetail ? Colors.label.swiftUIColor.opacity(0.6) : Colors.label.swiftUIColor)
    }
  }
}
