import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import LFAccessibility
import LFAuthentication
import RainFeature
import RainDomain
import Services

struct MyProfileView: View {
  @StateObject private var viewModel = MyProfileViewModel()
  
  var body: some View {
    VStack(spacing: 24) {
      VStack(spacing: 20) {
        userImage
        nameView
      }
      accountInfo
      Spacer()
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal, 24)
    .padding(.top, 4)
    .background(Colors.baseAppBackground2.swiftUIColor)
    .appNavBar(navigationTitle: L10N.Common.MyProfile.Screen.title)
  }
}

// MARK: - View Components
private extension MyProfileView {
  var userImage: some View {
    ZStack {
      Circle()
        .fill(Colors.grey500.swiftUIColor)
        .frame(76)
        .overlay {
          GenImages.Images.icoProfile.swiftUIImage
            .resizable()
            .frame(width: 32, height: 32, alignment: .center)
            .foregroundColor(.white)
        }
      Circle()
        .stroke(
          Colors.grey300.swiftUIColor,
          style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
        )
        .frame(76)
    }
  }
  
  var nameView: some View {
    Text(viewModel.name)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.headline.value))
      .foregroundColor(Colors.textPrimary.swiftUIColor)
      .multilineTextAlignment(.center)
  }
  
  var accountInfo: some View {
    VStack(alignment: .leading, spacing: 0) {
      informationCell(
        image: GenImages.Images.icoPhone.swiftUIImage,
        title: L10N.Common.MyProfile.Info.PhoneNumber.title,
        value: viewModel.phoneNumber
      )
      informationCell(
        image: GenImages.Images.icoMail.swiftUIImage,
        title: L10N.Common.MyProfile.Info.Email.title,
        value: viewModel.email
      )
      informationCell(
        image: GenImages.Images.icoAddress.swiftUIImage,
        title: L10N.Common.MyProfile.Info.Address.title,
        value: viewModel.address
      )
    }
  }
  
  func informationCell(image: Image, title: String, value: String) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 12) {
        image
          .resizable()
          .scaledToFit()
          .frame(24)
          .foregroundColor(.white)
        
        VStack(alignment: .leading, spacing: 6) {
          Text(title)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
            .foregroundColor(Colors.textSecondary.swiftUIColor)
          
          Text(value)
            .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
            .foregroundColor(Colors.textPrimary.swiftUIColor)
        }
        .lineLimit(2)
      }
      
      lineView
    }
    .padding(.horizontal, 8)
    .padding(.top, 12)
  }
  
  var lineView: some View {
    Divider()
      .frame(height: 1)
      .background(Colors.greyDefault.swiftUIColor)
      .frame(maxWidth: .infinity)
  }
}
