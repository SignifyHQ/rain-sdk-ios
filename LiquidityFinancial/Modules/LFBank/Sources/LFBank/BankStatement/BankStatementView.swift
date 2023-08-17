import PDFKit
import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

public struct BankStatementView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel = BankStatementViewModel()

  public init() {}
  
  public var body: some View {
    VStack(spacing: 10) {
      if viewModel.isLoading {
        loadingView
      } else if viewModel.showNoStatements {
        emptyStatements
      } else {
        ScrollView {
          VStack {
            statements
          }
          .padding(.horizontal, 30)
        }
      }
    }
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
  
  private var loadingView: some View {
    VStack {
      Spacer()
      LottieView(loading: .primary)
        .frame(width: 30, height: 20)
      Spacer()
    }
    .frame(max: .infinity)
  }
  
  private var emptyStatements: some View {
    VStack(spacing: 10) {
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

  private var statements: some View {
    ForEach(viewModel.statements, id: \.period) { item in
      BankStatementCell(
        title: item.period,
        detailTitle: LFLocalizable.BankStatement.created(item.period),
        backGroundColor: Colors.secondaryBackground.swiftUIColor,
        titleColor: Colors.label.swiftUIColor
      ) {
        viewModel.selectStatement(item)
      }
    }
  }
}
