import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import Factory

public struct FundraiserDetailView: View {
  public enum FundraiserDetailViewType {
    case select
    case view
  }
  
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: FundraiserDetailViewModel
  
  @State var openSafariType: FundraiserDetailViewModel.OpenSafariType?
  
  private var charity: FundraiserDetailModel.Charity? {
    viewModel.fundraiserDetail?.charity
  }
  
  let fundraiserDetailViewType: FundraiserDetailViewType
  
  public init(viewModel: FundraiserDetailViewModel, fundraiserDetailViewType: FundraiserDetailViewType = .select) {
    _viewModel = .init(wrappedValue: viewModel)
    self.fundraiserDetailViewType = fundraiserDetailViewType
  }
  
  public var body: some View {
    content
      .background(ModuleColors.background.swiftUIColor)
      .navigationBarHidden(true)
      .edgesIgnoringSafeArea(.top)
      .popup(item: $viewModel.popup) { popup in
        switch popup {
        case let .selectSuccess(message):
          selectSuccessPopup(message: message)
        case .selectError:
          selectErrorPopup
        case .geocodeError:
          geocodeErrorPopup
        }
      }
      .onAppear {
        viewModel.onAppear()
      }
      .fullScreenCover(item: $openSafariType, content: { type in
        switch type {
        case .charityURL(let url):
          SFSafariViewWrapper(url: url)
        case .fullcharityURL(let url):
          SFSafariViewWrapper(url: url)
        }
      })
  }
  
  private var content: some View {
    Group {
      if viewModel.isLoading {
        loadingView
      } else {
        VStack(spacing: 0) {
          ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
              top
              
              if let fundraiserDetailModel = viewModel.fundraiserDetail {
                widget(fundraiserDetail: fundraiserDetailModel)
              }
              
              VStack(alignment: .leading, spacing: 24) {
                description
                details
                latestDonations
                
                Spacer()
              }
              .padding(.horizontal, 30)
              .padding(.top, 20)
              .frame(maxWidth: .infinity)
              .background(ModuleColors.background.swiftUIColor)
              .cornerRadius(24)
              .padding(.top, -20)
            }
          }
          if fundraiserDetailViewType == .select {
            select
          }
        }
        .edgesIgnoringSafeArea(.bottom)
      }
    }
  }
  
  private var loadingView: some View {
    VStack {
      Spacer()
      LottieView(loading: .mix)
        .frame(width: 30, height: 20)
      Spacer()
    }
    .frame(maxWidth: .infinity)
  }
}

 // MARK: - Top

extension FundraiserDetailView {
  private var top: some View {
    ZStack(alignment: .topLeading) {
      if let urlstr = charity?.headerUrl {
        CachedAsyncImage(url: URL(string: urlstr)) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .applyImageGradient()
        } placeholder: {
          ModuleImages.bgFundraiserDetailView.swiftUIImage
        }
        .frame(minHeight: 240)
      }
      
      Button {
        dismiss()
      } label: {
        GenImages.CommonImages.icBack.swiftUIImage
      }
      .padding(.leading, 20)
      .padding(.top, 48)
    }
  }
  
  private func widget(fundraiserDetail: FundraiserDetailModel) -> some View {
    let headerAvailable = charity?.headerUrl != nil
    let type: FundraiserWidgetView.Kind = headerAvailable ? .small : .large
    let topPadding = headerAvailable ? -(FundraiserWidgetView.topNegativePadding + 24) : 0
    
    return FundraiserWidgetView(fundraiser: fundraiserDetail, type: type)
      .padding(.top, topPadding)
      .padding(.horizontal, 30)
      .padding(.bottom, 24)
  }
}

  // MARK: - Description

extension FundraiserDetailView {
  private var description: some View {
    Text(charity?.description ?? "unknown")
      .font(Fonts.regular.swiftUIFont(size: 16))
      .foregroundColor(ModuleColors.label.swiftUIColor.opacity(0.75))
      .lineSpacing(1.17)
  }
  
  private func title(_ text: String) -> some View {
    Text(text.uppercased())
      .font(Fonts.regular.swiftUIFont(size: 16))
      .foregroundColor(ModuleColors.label.swiftUIColor.opacity(0.75))
  }
}

  // MARK: - Confidence

extension FundraiserDetailView {
  private var confidence: some View {
    VStack(alignment: .leading, spacing: 16) {
      
      title(LFLocalizable.FundraiserDetail.confidence)
      
      HStack(spacing: 8) {
        ForEach(0 ..< 4) { index in
          ModuleImages.icCharityStar.swiftUIImage
            .foregroundColor(Int(charity?.confidenceValue ?? 0.0) > index ? ModuleColors.primary.swiftUIColor : ModuleColors.label.swiftUIColor.opacity(0.25))
        }
        Spacer()
      }
    }
    .padding(24)
    .background(ModuleColors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
  }
  
  private func score(value: Double) -> some View {
    HStack(alignment: .bottom, spacing: 0) {
      Text(value.formattedAmount(minFractionDigits: 2))
        .font(Fonts.bold.swiftUIFont(size: 16))
        .foregroundColor(ModuleColors.label.swiftUIColor)
      Text("/100")
        .font(Fonts.regular.swiftUIFont(size: 12))
        .foregroundColor(ModuleColors.label.swiftUIColor.opacity(0.3))
    }
  }
}

  // MARK: - Details

extension FundraiserDetailView {
  private var details: some View {
    VStack(alignment: .leading, spacing: 10) {
      
      title(LFLocalizable.FundraiserDetail.details)
        .padding(.bottom, 2)
      
      detail(image: ModuleImages.icCharityStatus.swiftUIImage, title: LFLocalizable.FundraiserDetail.status) {
        Text(LFLocalizable.FundraiserDetail.active)
          .font(Fonts.regular.swiftUIFont(size: 12))
          .foregroundColor(ModuleColors.green.swiftUIColor)
          .padding(.horizontal, 20)
          .padding(.vertical, 6)
          .background(ModuleColors.buttons.swiftUIColor)
          .cornerRadius(5)
      }
      
      detail(image: ModuleImages.icEin.swiftUIImage, title: LFLocalizable.FundraiserDetail.ein) {
        Text(charity?.ein ?? "")
          .font(Fonts.regular.swiftUIFont(size: 14))
          .foregroundColor(ModuleColors.primary.swiftUIColor)
      }
      
      if charity?.address != nil {
        Button {
          viewModel.navigateToAddress()
        } label: {
          detail(image: ModuleImages.icAddress.swiftUIImage, title: LFLocalizable.FundraiserDetail.address) {
            if viewModel.isGeocodingAddress {
              LottieView(loading: .mix)
                .frame(width: 30, height: 20)
            } else {
              CircleButton(style: .right)
            }
          }
        }
      }
      
      if let urlStr = charity?.url, let url = URL(string: urlStr) {
        Button {
          openSafariType = .charityURL(url)
        } label: {
          detail(image: ModuleImages.icWebsite.swiftUIImage, title: LFLocalizable.FundraiserDetail.website) {
            CircleButton(style: .right)
          }
        }
      }
      
      if let url = viewModel.fundraiserDetail?.fullCharityNavigatorUrl {
        Button {
          openSafariType = .fullcharityURL(url)
        } label: {
          detail(image: ModuleImages.icNavigation.swiftUIImage, title: LFLocalizable.FundraiserDetail.navigator) {
            CircleButton(style: .right)
          }
        }
      }
    }
  }
  
  private func detail<Content>(image: Image, title: String, @ViewBuilder trailing: @escaping () -> Content) -> some View where Content: View {
    HStack(spacing: 12) {
      image
        .resizable()
        .frame(24)
        .foregroundColor(ModuleColors.label.swiftUIColor)
      Text(title)
        .font(Fonts.regular.swiftUIFont(size: 12))
        .foregroundColor(ModuleColors.label.swiftUIColor)
      Spacer()
      trailing()
    }
    .padding(.horizontal, 16)
    .frame(height: 50)
    .background(ModuleColors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
  }
}

  // MARK: - Latest Donations

extension FundraiserDetailView {
  private var latestDonations: some View {
    Group {
      if !viewModel.latestDonations.isEmpty {
        VStack(alignment: .leading, spacing: 10) {
          
          title(LFLocalizable.FundraiserDetail.latestDonations)
            .padding(.bottom, 2)
          
          ForEach(viewModel.latestDonations) { transaction in
            RewardTransactionRow(item: transaction)
          }
        }
      }
    }
  }
}

  // MARK: - Select

extension FundraiserDetailView {
  private var select: some View {
    Group {
      FullSizeButton(title: LFLocalizable.SelectCause.title, isDisable: false, isLoading: $viewModel.isSelecting) {
        viewModel.apiSelectFundraiser(fundraiserId: viewModel.fundraiserID)
      }
    }
    .padding(.horizontal, 30)
    .padding(.top, 16)
    .padding(.bottom, 34)
    .background(ModuleColors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
  }
}

  // MARK: - Popup
extension FundraiserDetailView {
  private func selectSuccessPopup(message: String) -> some View {
    LiquidityAlert(
      title: LFLocalizable.FundraiserDetail.Success.title,
      message: message,
      primary: .init(text: LFLocalizable.Button.Continue.title) { viewModel.selectSuccessPrimary() },
      secondary: nil
    )
  }
  
  private var selectErrorPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.FundraiserDetail.Error.title,
      message: LFLocalizable.FundraiserDetail.Error.select,
      primary: .init(text: LFLocalizable.Button.Ok.title) { viewModel.dismissPopup() },
      secondary: nil
    )
  }
  
  private var geocodeErrorPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.FundraiserDetail.Error.title,
      message: LFLocalizable.FundraiserDetail.Error.geocode,
      primary: .init(text: LFLocalizable.Button.Ok.title) { viewModel.dismissPopup() },
      secondary: nil
    )
  }
}
