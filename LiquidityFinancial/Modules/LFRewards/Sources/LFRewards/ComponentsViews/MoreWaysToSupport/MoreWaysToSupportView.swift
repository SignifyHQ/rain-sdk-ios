import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

struct MoreWaysToSupportView: View {
  @StateObject private var viewModel: MoreWaysToSupportViewModel
  
  @State var openSafariType: MoreWaysToSupportViewModel.OpenSafariType?
  
  init(viewModel: MoreWaysToSupportViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  var body: some View {
    content
      .background(ModuleColors.background.swiftUIColor)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(LFLocalizable.MoreWaysToSupport.title)
            .font(Fonts.regular.swiftUIFont(size: 16))
            .foregroundColor(ModuleColors.label.swiftUIColor)
        }
      }
//      .navigationLink(item: $viewModel.navigation) { navigation in
//        switch navigation {
//        case .referrals:
//          ReferralsView()
//        }
//      }
      .sheet(isPresented: $viewModel.showShare) {
        ShareView(viewModel: .init(data: .build(from: viewModel.fundraiser)))
      }
      .popup(item: $viewModel.toastMessage, style: .toast) { message in
        ToastView(toastMessage: message)
      }
      .fullScreenCover(item: $openSafariType, content: { type in
        switch type {
        case .socialURL(let url):
          SFSafariViewWrapper(url: url)
        }
      })
  }
  
  private var content: some View {
    VStack(spacing: 10) {
      share
        .style()
      photo
        .style()
      news
        .style()
      Spacer()
    }
    .padding(.top, 10)
    .padding(.horizontal, 30)
    .scrollOnOverflow()
  }
  
  private var share: some View {
    VStack(spacing: 16) {
      header(title: LFLocalizable.MoreWaysToSupport.Share.title, message: nil)
      
      HStack(spacing: 12) {
        // TODO: - Will be uncomment later. Temporarily hide this feature
        //        shareItem(image: ModuleImages.icReferrals.swiftUIImage, text: LFLocalizable.MoreWaysToSupport.Share.friends) {
        //          viewModel.inviteFriendsTapped()
        //        }
        shareItem(image: ModuleImages.icShared.swiftUIImage, text: LFLocalizable.MoreWaysToSupport.Share.cause) {
          viewModel.shareCauseTapped()
        }
      }
    }
  }
  
  private var photo: some View {
    Group {
      if let url = viewModel.fundraiser.stickerUrl {
        VStack(spacing: 16) {
          header(
            title: LFLocalizable.MoreWaysToSupport.Photo.title,
            message: LFLocalizable.MoreWaysToSupport.Photo.message
          )
          
          ZStack(alignment: .bottomTrailing) {
            CachedAsyncImage(url: url) { image in
              image
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
            } placeholder: {
              StickerPlaceholderView()
            }
            .frame(width: 112, height: 112)
            
            downloadPhoto
          }
        }
      }
    }
  }
  
  private var news: some View {
    Group {
      if !viewModel.social.isEmpty {
        VStack(spacing: 16) {
          header(
            title: LFLocalizable.MoreWaysToSupport.News.title,
            message: LFLocalizable.MoreWaysToSupport.News.message(viewModel.fundraiser.charityName)
          )
          
          HStack(spacing: 16) {
            ForEach(viewModel.social, id: \.self) { item in
              socialItem(item: item)
            }
          }
        }
      }
    }
  }
  
  private var employer: some View {
    VStack(spacing: 16) {
      header(
        title: LFLocalizable.MoreWaysToSupport.Employer.title,
        message: LFLocalizable.MoreWaysToSupport.Employer.message
      )
      FullSizeButton(title: LFLocalizable.MoreWaysToSupport.Employer.action, isDisable: false) {
        viewModel.getTaxableDonationsTapped()
      }
    }
  }
}

  // MARK: - Helpers

extension MoreWaysToSupportView {
  private func header(title: String, message: String?) -> some View {
    VStack(spacing: 8) {
      Text(title)
        .font(Fonts.regular.swiftUIFont(size: 18))
        .foregroundColor(ModuleColors.label.swiftUIColor)
      if let message = message {
        Text(message)
          .font(Fonts.regular.swiftUIFont(size: 12))
          .foregroundColor(ModuleColors.label.swiftUIColor.opacity(0.75))
          .padding(.horizontal, 16)
          .multilineTextAlignment(.center)
      }
    }
  }
  
  private func shareItem(image: Image, text: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      HStack(spacing: 8) {
        image
          .resizable()
          .frame(width: 24, height: 24)
        Text(text)
          .font(Fonts.regular.swiftUIFont(size: 12))
        Spacer()
      }
      .foregroundColor(ModuleColors.label.swiftUIColor)
      .padding(.leading, 16)
      .padding(.vertical, 8)
      .background(ModuleColors.background.swiftUIColor)
      .cornerRadius(8)
    }
  }
  
  private var downloadPhoto: some View {
    Button {
      viewModel.photoTapped()
    } label: {
      ZStack {
        Circle()
          .stroke(AngularGradient.primary(colors: Color.gradientAngular), style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
          .background(
            Circle().foregroundColor(ModuleColors.secondaryBackground.swiftUIColor)
          )
          .frame(width: 40, height: 40)
        ModuleImages.icDownload.swiftUIImage
          .foregroundColor(ModuleColors.label.swiftUIColor)
      }
    }
  }
  
  private func socialItem(item: MoreWaysToSupportViewModel.Social) -> some View {
    Button {
      openSafariType = .socialURL(item.url)
    } label: {
      ZStack {
        Circle()
          .fill(ModuleColors.background.swiftUIColor)
          .frame(width: 44, height: 44)
        Image(item.type.rawValue, bundle: .module)
          .renderingMode(.template)
          .foregroundColor(ModuleColors.label.swiftUIColor)
      }
    }
  }
}

private extension View {
  func style() -> some View {
    padding(16)
      .frame(maxWidth: .infinity)
      .background(ModuleColors.secondaryBackground.swiftUIColor)
      .cornerRadius(12)
  }
}
