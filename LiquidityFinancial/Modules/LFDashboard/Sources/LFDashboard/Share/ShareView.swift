import SwiftUI
import LFUtilities
import LFLocalizable
import LFStyleGuide

struct ShareView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: ShareViewModel

  init(viewModel: ShareViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  var body: some View {
    content
      .edgesIgnoringSafeArea(.bottom)
      .background(Colors.background.swiftUIColor)
      .defaultToolBar(icon: .xMark, navigationTitle: LFLocalizable.Share.navigationTitle)
      .popup(item: $viewModel.toastMessage, style: .toast) { message in
        ToastView(toastMessage: message)
      }
      .sheet(isPresented: $viewModel.showShareSheet) {
        ShareSheetView(activityItems: viewModel.shareActivityItems)
      }
      .navigationBarTitleDisplayMode(.inline)
      .embedInNavigation()
  }
}

// MARK: - View Components
private extension ShareView {
  var content: some View {
    VStack(spacing: 0) {
      card
        .padding([.horizontal, .top], 20)
      Spacer()
      amountToggle
      bottom
    }
    .scrollOnOverflow()
  }
  
  var card: some View {
    var card = viewModel.data.card
    card.includeDonation = viewModel.includeDonation
    return TransactionCardView(type: .shareDonation(card))
  }
  
  @ViewBuilder var amountToggle: some View {
    if viewModel.data.showAmountToggle {
      HStack {
        Text(LFLocalizable.Share.includeDonations)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor)
        Spacer()
        Toggle("", isOn: $viewModel.includeDonation)
          .toggleStyle(SwitchToggleStyle(tint: Colors.primary.swiftUIColor))
      }
      .padding(20)
      .background(Colors.secondaryBackground.swiftUIColor)
      .cornerRadius(22)
      .padding([.horizontal, .bottom], 20)
    }
  }
  
  var bottom: some View {
    VStack(spacing: 28) {
      items
      
      FullSizeButton(title: LFLocalizable.Share.cancel, isDisable: false, type: .secondary) {
        dismiss()
      }
      .padding(.horizontal, 30)
    }
    .padding(.top, 24)
    .padding(.bottom, 34)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(30, corners: [.topLeft, .topRight])
  }
  
  var items: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 26) {
        ForEach(viewModel.items.filter(\.isValid), id: \.name, content: item(_:))
        moreItem
      }
      .padding(.horizontal, 30)
    }
  }
  
  func item(_ item: ShareItem) -> some View {
    Button {
      if #available(iOS 16.0, *) {
        let renderer = ImageRenderer(content: card)
        renderer.proposedSize = .init(width: 335, height: 514)
        renderer.scale = 2
        item.share(card: renderer.uiImage)
      } else {
        item.share(card: nil)
      }
    } label: {
      VStack(spacing: 8) {
        ZStack {
          LottieView(loading: .primary)
            .frame(width: 48, height: 32)
            .hidden(!viewModel.isItemLoading(item: item))
          Image(item.image)
            .resizable()
            .frame(48)
            .hidden(viewModel.isItemLoading(item: item))
        }
        Text(item.name)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor)
      }
    }
  }
  
  var moreItem: some View {
    Button {
      viewModel.moreTapped()
    } label: {
      VStack(spacing: 8) {
        moreImage
        Text(LFLocalizable.Share.more)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor)
      }
    }
  }
  
  var moreImage: some View {
    ZStack {
      Circle()
        .foregroundColor(Colors.background.swiftUIColor)
        .frame(width: 48)
      HStack(spacing: 4) {
        ForEach(0 ..< 3) { _ in
          Circle()
            .stroke(Colors.label.swiftUIColor.opacity(0.5), lineWidth: 1.5)
            .frame(width: 5)
        }
      }
    }
  }
}
