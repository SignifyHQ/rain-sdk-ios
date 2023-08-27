import Foundation
import SwiftUI
import LFStyleGuide

struct UserRewardRowView: View {
  let type: Kind
  let reward: UserRewardType
  let selection: Selection
  
  var body: some View {
    HStack(spacing: 0) {
      ZStack {
        Circle()
          .fill(ModuleColors.background.swiftUIColor)
          .frame(40)
        reward.image
          .foregroundColor(ModuleColors.label.swiftUIColor)
      }
      
      VStack(alignment: .leading, spacing: 0) {
        Text(reward.title ?? "")
          .font(Fonts.regular.swiftUIFont(size: 16))
          .foregroundColor(ModuleColors.label.swiftUIColor)
        if type.showSubtitle {
          Text(reward.subtitle(param: 0.75) ?? "")
            .font(Fonts.regular.swiftUIFont(size: 12))
            .foregroundColor(ModuleColors.label.swiftUIColor.opacity(0.75))
        }
      }
      .padding(.leading, 8)
      
      Spacer(minLength: 8)
      
      checkbox
    }
    .padding([.leading, .vertical], type.padding)
    .padding(.trailing, 16)
    .background(ModuleColors.secondaryBackground.swiftUIColor)
    .cornerRadius(8)
  }
  
  private var checkbox: some View {
    Group {
      switch selection {
      case .unselected:
        Circle()
          .stroke(ModuleColors.label.swiftUIColor, lineWidth: 1.5)
          .frame(20)
      case .selected:
        ZStack {
          Circle()
            .fill(
              LinearGradient(
                gradient: Gradient(colors: [Colors.Gradients.Button.gradientButton0.swiftUIColor, Colors.Gradients.Button.gradientButton1.swiftUIColor]),
                startPoint: .leading,
                endPoint: .trailing
              )
            )
            .frame(20)
          Image(systemName: "checkmark")
            .resizable()
            .frame(10)
            .foregroundColor(ModuleColors.whiteText.swiftUIColor)
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
}
