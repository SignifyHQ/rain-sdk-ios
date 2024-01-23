import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

public struct ShareView: View {
  public init(viewModel: ShareViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    content
      .edgesIgnoringSafeArea(.bottom)
      .background(ModuleColors.background.swiftUIColor)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            dismiss()
          } label: {
            CircleButton(style: .xmark)
          }
        }
        
        ToolbarItem(placement: .principal) {
          Text(L10N.Common.FundraiserActions.share)
            .font(Fonts.regular.swiftUIFont(size: 16))
            .foregroundColor(ModuleColors.label.swiftUIColor)
        }
      }
      .popup(item: $viewModel.toastMessage, style: .toast) { message in
        ToastView(toastMessage: message)
      }
      .sheet(isPresented: $viewModel.showShareSheet) {
        ShareSheetView(activityItems: viewModel.shareActivityItems)
      }
      .navigationBarTitleDisplayMode(.inline)
      .embedInNavigation()
  }
  
  @StateObject private var viewModel: ShareViewModel
  @Environment(\.dismiss) private var dismiss
  
  private var content: some View {
    VStack(spacing: 0) {
      card
        .padding([.horizontal, .top], 20)
      Spacer()
      amountToggle
      bottom
    }
    .scrollOnOverflow()
  }
  
  private var card: some View {
    var card = viewModel.data.card
    card.includeDonation = viewModel.includeDonation
    return CardView(type: .shareDonation(card))
  }
  
  private var amountToggle: some View {
    Group {
      if viewModel.data.showAmountToggle {
        HStack {
          Text(L10N.Common.Share.includeDonations)
            .font(Fonts.regular.swiftUIFont(size: 16))
            .foregroundColor(ModuleColors.label.swiftUIColor)
          Spacer()
          Toggle("", isOn: $viewModel.includeDonation)
            .toggleStyle(SwitchToggleStyle(tint: ModuleColors.primary.swiftUIColor))
        }
        .padding(20)
        .background(ModuleColors.secondaryBackground.swiftUIColor)
        .cornerRadius(22)
        .padding([.horizontal, .bottom], 20)
      }
    }
  }
  
  private var bottom: some View {
    VStack(spacing: 28) {
      items
      FullSizeButton(title: L10N.Common.Share.cancel, isDisable: false, type: .secondary) {
        dismiss()
      }
      .padding(.horizontal, 30)
    }
    .padding(.top, 24)
    .padding(.bottom, 34)
    .background(ModuleColors.secondaryBackground.swiftUIColor)
    .cornerRadius(30, corners: [.topLeft, .topRight])
  }
  
  private var items: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 26) {
        ForEach(viewModel.items.filter(\.isValid), id: \.name, content: item(_:))
        moreItem
      }
      .padding(.horizontal, 30)
    }
  }
  
  private func item(_ item: ShareItem) -> some View {
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
          
          item.image
            .resizable()
            .frame(48)
            .hidden(viewModel.isItemLoading(item: item))
        }
        Text(item.name)
          .font(Fonts.regular.swiftUIFont(size: 12))
          .foregroundColor(ModuleColors.label.swiftUIColor)
      }
    }
  }
  
  private var moreItem: some View {
    Button {
      viewModel.moreTapped()
    } label: {
      VStack(spacing: 8) {
        moreImage
        Text(L10N.Common.Share.more)
          .font(Fonts.regular.swiftUIFont(size: 12))
          .foregroundColor(ModuleColors.label.swiftUIColor)
      }
    }
  }
  
  private var moreImage: some View {
    ZStack {
      Circle()
        .foregroundColor(ModuleColors.background.swiftUIColor)
        .frame(width: 48)
      
      HStack(spacing: 4) {
        ForEach(0 ..< 3) { _ in
          Circle()
            .stroke(ModuleColors.label.swiftUIColor.opacity(0.5), lineWidth: 1.5)
            .frame(width: 5)
        }
      }
    }
  }
}
