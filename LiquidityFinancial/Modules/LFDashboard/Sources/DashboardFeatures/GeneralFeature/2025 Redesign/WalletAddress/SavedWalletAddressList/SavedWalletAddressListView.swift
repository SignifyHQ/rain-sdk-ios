import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import Services
import AccountData

public struct SavedWalletAddressListView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: SavedWalletAddressListViewModel
  
  public init() {
    _viewModel = .init(wrappedValue: SavedWalletAddressListViewModel())
  }
  
  public var body: some View {
    VStack(alignment: .leading, spacing: 32) {
      if viewModel.isLoading {
        VStack(alignment: .center) {
          DefaultLottieView(loading: .branded)
            .frame(width: 52, height: 52)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .init(horizontal: .center, vertical: .center))
      } else if viewModel.wallets.isNotEmpty {
        contentView
      } else {
        emptyView
      }
    }
    .appNavBar(navigationTitle: L10N.Common.SavedWalletAddressList.Screen.title)
    .padding(.horizontal, 24)
    .background(Colors.baseAppBackground2.swiftUIColor)
    .toast(data: $viewModel.toastData)
    .navigationBarTitleDisplayMode(.inline)
    .track(name: String(describing: type(of: self)))
    .navigationLink(item: $viewModel.navigation) { item in
      switch item {
      case .createWalletAddress:
        CreateNewWalletAddressView(accountId: viewModel.accountId) {
          nickname in
          viewModel.showCreatedWalletToast(nickname: nickname)
        }
      case .editWalletAddress(let wallet):
        EditWalletAddressView(
          accountId: viewModel.accountId,
          wallet: wallet
        ) { nickname in
          viewModel.showDeletedWalletToast(nickname: nickname)
        }
      }
    }
  }
}

// MARK: View Components
extension SavedWalletAddressListView {
  var contentView: some View {
    VStack(spacing: 32) {
      listView
      Spacer()
      footerView
        .padding(.bottom, 16)
    }
  }
  
  var listView: some View {
    ScrollView(showsIndicators: false) {
      LazyVStack(spacing: 12) {
        ForEach(viewModel.wallets, id: \.id) { wallet in
          walletNicknameCell(with: wallet)
        }
      }
      .padding(.top, 8)
    }
  }
  
  var emptyView: some View {
    VStack(spacing: 32) {
      VStack(spacing: 12) {
        GenImages.Images.icoEmpty.swiftUIImage
          .resizable()
          .frame(width: 32, height: 32)
        Text(L10N.Common.SavedWalletAddressList.NoData.title)
          .foregroundColor(Colors.textTertiary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .multilineTextAlignment(.center)
      }
      .padding(.horizontal, 24)
      Spacer()
      footerView
        .padding(.bottom, 16)
    }
  }
  
  var footerView: some View {
    FullWidthButton(
      title: L10N.Common.SavedWalletAddressList.SaveANew.Button.title
    ) {
      viewModel.onCreateNewWalletTapped()
    }
  }
  
  func walletNicknameCell(with wallet: APIWalletAddress) -> some View {
    HStack(spacing: 12) {
      Text(wallet.nickname ?? "")
        .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.small.value))
        .foregroundColor(Colors.label.swiftUIColor)
      Spacer()
      
      Button {
        viewModel.onEditWalletTap(wallet: wallet)
      } label: {
        GenImages.Images.icoEdit.swiftUIImage
          .resizable()
          .frame(width: 24, height: 24)
      }
    }
    .padding(.leading, 24)
    .padding(.trailing, 12)
    .frame(height: 48)
    .cornerRadius(24)
    .overlay {
      RoundedRectangle(cornerRadius: 24)
        .strokeBorder(Colors.grey300.swiftUIColor, lineWidth: 1)
    }
  }
}
