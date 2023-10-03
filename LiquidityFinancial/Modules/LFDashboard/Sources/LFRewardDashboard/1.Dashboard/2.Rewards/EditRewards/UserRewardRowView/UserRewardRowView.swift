import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import LFRewards

struct UserRewardRowView: View {
  let type: Kind
  let reward: UserRewardType
  let selection: Selection
  
  var body: some View {
    HStack(spacing: 0) {
      ZStack {
        Circle()
          .fill(Colors.background.swiftUIColor)
          .frame(40)
        if let image = reward.image {
          image
            .foregroundColor(Colors.label.swiftUIColor)
        }
      }
      
      VStack(alignment: .leading, spacing: 0) {
        if let title = reward.title {
          Text(title)
            .font(Fonts.regular.swiftUIFont(size: 16))
            .foregroundColor(Colors.label.swiftUIColor)
        }
        
        if type.showSubtitle {
          if let subtitle = reward.subtitle(param: 0.75) {
            Text(subtitle)
              .font(Fonts.regular.swiftUIFont(size: 12))
              .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
          }
        }
      }
      .padding(.leading, 8)
      
      Spacer(minLength: 8)
      
      checkbox
    }
    .padding([.leading, .vertical], type.padding)
    .padding(.trailing, 16)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(8)
  }
  
  private var checkbox: some View {
    Group {
      switch selection {
      case .unselected:
        EmptyView()
        Circle()
          .stroke(Colors.label.swiftUIColor.opacity(0.15), lineWidth: 1.5)
          .frame(20)
      case .selected:
        ZStack {
          Circle()
            .fill(LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .leading, endPoint: .trailing))
            .frame(20)

          GenImages.CommonImages.icCheckmark.swiftUIImage
            .resizable()
            .frame(10)
            .foregroundColor(Colors.contrast.swiftUIColor)
        }
      case .loading:
        LottieView(loading: .primary)
          .frame(width: 30, height: 20)
      }
    }
  }
}

extension UserRewardRowView {
  enum Kind {
    case short
    case full
    
    var padding: CGFloat {
      switch self {
      case .short: return 8
      case .full: return 16
      }
    }
    
    var showSubtitle: Bool {
      switch self {
      case .short: return false
      case .full: return true
      }
    }
  }
  
  enum Selection {
    case unselected
    case selected
    case loading
  }
  
  var gradientColors: [Color] {
    [
      Colors.Gradients.Button.gradientButton0.swiftUIColor,
      Colors.Gradients.Button.gradientButton1.swiftUIColor
    ]
  }
}

#if DEBUG

  // MARK: - UserRewardRowView_Previews

struct UserRewardRowView_Previews: PreviewProvider {
  static var previews: some View {
    VStack(alignment: .leading) {
      Spacer()
      
      Text("Short")
      UserRewardRowView(type: .short, reward: .donation, selection: .selected)
      UserRewardRowView(type: .short, reward: .cashBack, selection: .unselected)
      
      Spacer()
        .frame(height: 40)
      
      Text("Full")
      UserRewardRowView(type: .full, reward: .donation, selection: .unselected)
      UserRewardRowView(type: .full, reward: .cashBack, selection: .loading)
      
      Spacer()
    }
    .padding(20)
    .background(Colors.background.swiftUIColor)
  }
}

#endif
