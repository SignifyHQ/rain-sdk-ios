import PDFKit
import NetspendDomain
import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

public struct BankStatementView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel = BankStatementViewModel()
  
  public init() {}
  
  public var body: some View {
    content
      .padding(.top, 16)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(LFLocalizable.BankStatement.title)
            .foregroundColor(Colors.label.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        }
      }
      .background(Colors.background.swiftUIColor)
      .navigationTitle("")
      .navigationBarTitleDisplayMode(.inline)
      .onAppear(perform: viewModel.onAppear)
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
      .navigationLink(item: $viewModel.navigation) { item in
        switch item {
        case let .pdfDocument(title, url):
          DocumentViewer(title: title, url: url)
        }
      }
  }
}

private extension BankStatementView {
  var content: some View {
    VStack(spacing: 10) {
      switch viewModel.status {
      case .idle, .loading:
        loadingView
      case let .success(items):
        if items.isEmpty {
          emptyStatements
        } else {
          statementsView(statements: items)
        }
      case .failure:
        failure
      }
    }
  }
  
  var loadingView: some View {
    VStack {
      Spacer()
      LottieView(loading: .primary)
        .frame(width: 30, height: 20)
      Spacer()
    }
    .frame(max: .infinity)
  }
  
  var emptyStatements: some View {
    VStack(spacing: 12) {
      GenImages.CommonImages.icSearch.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor)
        .padding(.bottom, 12)
      Text(LFLocalizable.BankStatement.emptyTitle)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: 24))
      Text(LFLocalizable.BankStatement.emptyInfo)
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
    }
    .padding(.horizontal, 30)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
  
  func statementsView(statements: [BankStatementViewModel.UIModel]) -> some View {
    ScrollView {
      VStack {
        ForEach(statements, id: \.id) { item in
          BankStatementCell(
            title: item.name,
            detailTitle: LFLocalizable.BankStatement.created(item.desc),
            backGroundColor: Colors.secondaryBackground.swiftUIColor,
            titleColor: Colors.label.swiftUIColor
          ) {
            viewModel.selectStatement(item)
          }
        }
      }
      .padding(.horizontal, 30)
    }
    .frame(max: .infinity)
  }
  
  var failure: some View {
    VStack(spacing: 32) {
      Spacer()
      Text(LFLocalizable.BankStatement.error)
        .font(Fonts.medium.swiftUIFont(size: 14))
        .foregroundColor(Colors.label.swiftUIColor)
        .multilineTextAlignment(.center)
      FullSizeButton(title: LFLocalizable.Button.Retry.title, isDisable: false) {
        viewModel.getBankStatements()
      }
    }
    .padding(30)
    .frame(maxWidth: .infinity)
  }
}
