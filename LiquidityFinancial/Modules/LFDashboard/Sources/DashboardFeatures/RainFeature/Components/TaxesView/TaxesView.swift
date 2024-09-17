import Foundation
import LFStyleGuide
import LFUtilities
import LFLocalizable
import SwiftUI

public struct TaxesView: View {
  public init() {}
  
  public var body: some View {
    content
      .onAppear {
        viewModel.onAppear()
      }
      .background(Colors.background.swiftUIColor)
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(L10N.Common.Taxes.navigationTitle)
            .font(Fonts.regular.swiftUIFont(size: 16))
            .foregroundColor(Colors.label.swiftUIColor)
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .navigationLink(item: $viewModel.navigation) { item in
        switch item {
        case let .document(title, url):
          DocumentViewer(title: title, url: url)
        }
      }
  }
  
  @StateObject private var viewModel = TaxesViewModel()
  
  private var content: some View {
    Group {
//      switch viewModel.status {
//      case .idle, .loading:
//        loading
//      case let .success(items):
//        if items.isEmpty {
//          emptyTaxView
//        } else {
//          rows(items: items)
//        }
//      case .failure:
//        failure
//      }
    }
  }
}

extension TaxesView {
  private var loading: some View {
    Group {
      LottieView(loading: .primary)
        .frame(width: 45, height: 30)
    }
    .frame(max: .infinity)
  }
  
  private var failure: some View {
    VStack(spacing: 32) {
      Spacer()
      Text(L10N.Common.Taxes.error)
        .font(Fonts.medium.swiftUIFont(size: 14))
        .foregroundColor(Colors.label.swiftUIColor)
        .multilineTextAlignment(.center)
      FullSizeButton(title: L10N.Common.Taxes.retry, isDisable: false) {
        viewModel.retryTapped()
      }
    }
    .padding(30)
    .frame(maxWidth: .infinity)
  }
  
//  @ViewBuilder
//  private func rows(items: [APITaxFile]) -> some View {
//    ScrollView {
//      VStack(spacing: 10) {
//        ForEach(items) { item in
//          ArrowButton(image: nil, title: item.name ?? "", value: item.value, isLoading: .constant(item == viewModel.loadingTaxFile), action: {
//            viewModel.selected(taxFile: item)
//          })
//        }
//        
//        Spacer()
//      }
//      .padding(.horizontal, 30)
//      .padding(.vertical, 20)
//    }
//  }
  
  private var emptyTaxView: some View {
    VStack(spacing: 12) {
      GenImages.CommonImages.icSearch.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor)
        .padding(.bottom, 12)
      Text(L10N.Common.Taxes.Empty.title)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: 24))
      
      Text(L10N.Common.Taxes.Empty.message)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .font(Fonts.regular.swiftUIFont(size: 16))
    }
    .padding(.horizontal, 30)
    .frame(max: .infinity)
  }
}

//private extension APITaxFile {
//  var createAtDate: Date {
//    LiquidityDateFormatter.iso8601WithMilliseconds.parseToDate(from: createdAt ?? "") ?? Date()
//  }
//  
//  var value: String {
//    L10N.Common.Taxes.value(createAtDate)
//  }
//}

#if DEBUG

  // MARK: - TaxesView_Previews

struct TaxesView_Previews: PreviewProvider {
  static var previews: some View {
    TaxesView()
      .embedInNavigation()
  }
}
#endif
