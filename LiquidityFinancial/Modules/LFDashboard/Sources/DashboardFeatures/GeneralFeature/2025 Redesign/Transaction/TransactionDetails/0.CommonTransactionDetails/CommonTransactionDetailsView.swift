import Foundation
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

struct CommonTransactionDetailsView<Content: View>: View {
  @ViewBuilder let content: Content?
  @StateObject private var viewModel: CommonTransactionDetailsViewModel
  @State var openSafariType: CommonTransactionDetailsViewModel.OpenSafariType?
  
  init(transaction: TransactionModel, content: Content? = EmptyView(), isCryptoBalance: Bool = false) {
    _viewModel = .init(
      wrappedValue: CommonTransactionDetailsViewModel(
        transaction: transaction,
        isCryptoBalance: isCryptoBalance
      )
    )
    self.content = content
  }
  
  var body: some View {
    VStack {
      VStack(spacing: 20) {
        VStack(spacing: 12) {
          headerView
          amountView
        }
        .padding([.horizontal, .top], 20)
        
        lineView
        
        dateTimeView
          .padding(.horizontal, 20)
        
        lineView
        
        if let content = content {
          content
        }
        
        reportProblemView
          .padding(.horizontal, 20)
      }
      .overlay {
        RoundedRectangle(cornerRadius: 24)
          .strokeBorder(Colors.greyDefault.swiftUIColor, lineWidth: 1)
      }
    }
    .frame(maxWidth: .infinity)
    .navigationBarTitleDisplayMode(.inline)
    .background(Colors.baseAppBackground2.swiftUIColor)
    .fullScreenCover(item: $openSafariType, content: { type in
      switch type {
      case .disclosure(let url):
        SFSafariViewWrapper(url: url)
      }
    })
  }
}

// MARK: View Components
private extension CommonTransactionDetailsView {
  var headerView: some View {
    VStack(spacing: 4) {
      transactionIconView
      
      Text(viewModel.typeDisplay)
        .foregroundColor(Colors.textPrimary.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
    }
  }
  
  var amountView: some View {
    VStack(
      spacing: 4
    ) {
      Text(viewModel.amountValue)
        .foregroundColor(viewModel.colorForType)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      
      if let localAmountFormatted = viewModel.transaction.localAmountFormatted {
        Text(localAmountFormatted)
          .foregroundColor(viewModel.colorForType)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      }
      
      if let status = viewModel.transaction.status {
        Text(status.localizedDescription())
          .foregroundColor(status.color)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      }
    }
  }
  
  var transactionIconView: some View {
    let transactionImageUrlString = viewModel.transaction.enrichedMerchantIcon
    let transactionImageUrl = URL(string: transactionImageUrlString ?? .empty)
    
    return CachedAsyncImage(
      url: transactionImageUrl
    ) { image in
      image
        .resizable()
        .interpolation(.high)
        .frame(32)
        .clipShape(Circle())
    } placeholder: {
      viewModel.transaction.transactionIcon?
        .resizable()
        .frame(32)
    }
  }
  
  var dateTimeView: some View {
    VStack(spacing: 12) {
      timeCell(title: L10N.Common.TransactionDetails.Info.transactionDate, value: viewModel.transaction.createdDate)
      
      timeCell(title: L10N.Common.TransactionDetails.Info.transactionTime, value: viewModel.transaction.completedTime)
    }
  }
  
  @ViewBuilder
  func timeCell(
    title: String,
    value: String
  ) -> some View {
    HStack(alignment: .top, spacing: 8) {
      Text(title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.grey200.swiftUIColor)
      
      Spacer()
      
      Text(value)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.textPrimary.swiftUIColor)
        .multilineTextAlignment(.trailing)
    }
  }
  
  var checkedCircle: some View {
    ZStack {
      Circle()
        .fill(Colors.successDefault.swiftUIColor)
        .frame(width: 24, height: 24)
      Image(systemName: "checkmark")
        .foregroundColor(.white)
        .font(.system(size: 12, weight: .bold))
    }
  }
  
  var uncheckedCircle: some View {
    Circle()
      .stroke(Colors.greyDefault.swiftUIColor, lineWidth: 2)
      .frame(width: 24, height: 24)
  }
  
  var reportProblemView: some View {
    VStack(
      alignment: .center,
      spacing: 3
    ) {
      Text(L10N.Common.TransactionDetails.ReportProblem.title)
        .foregroundColor(Colors.textSecondary.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
      
      Button {
        viewModel.onReportProblemButtonTap()
      } label: {
        Text(L10N.Common.TransactionDetails.ReportProblem.button)
          .foregroundColor(Colors.textSecondary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .underline(true, color: Colors.textSecondary.swiftUIColor)
      }
    }
    .padding(.bottom, 20)
  }
  
  var lineView: some View {
    Divider()
      .frame(height: 1)
      .background(Colors.greyDefault.swiftUIColor)
      .frame(maxWidth: .infinity)
  }
}
