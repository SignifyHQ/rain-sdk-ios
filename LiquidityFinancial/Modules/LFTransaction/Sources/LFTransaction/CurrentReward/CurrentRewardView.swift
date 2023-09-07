import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import AccountDomain
import AccountData

public struct CurrentRewardView: View {
  
  @StateObject private var viewModel = CurrentRewardViewModel()
  
  public init() {}
  
  public var body: some View {
    stateContentView
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(LFLocalizable.AccountView.rewards)
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      }
    }
    .background(Colors.background.swiftUIColor)
    .navigationBarTitleDisplayMode(.inline)
    .frame(
      maxWidth: .infinity,
      maxHeight: .infinity
    )
    .onAppear {
      viewModel.onAppear()
    }
  }
  
  func contentView(rewards: [APIUserRewards], specialrewards: [APIUserRewards]) -> some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        if !rewards.isEmpty {
          section(title: LFLocalizable.Account.Reward.Session.normal) {
            ForEach(rewards) { item in
              
              rowView(title: item.name ?? "", desc: LFLocalizable.Account.Reward.Item.descUpToBack("\(item.returnRate ?? 0.0)")) {
                
              }
            }
          }
        }
        
        if !specialrewards.isEmpty {
          section(title: LFLocalizable.Account.Reward.Session.special) {
            ForEach(specialrewards) { item in
              rowView(title: item.name ?? "", desc: LFLocalizable.Account.Reward.Item.descUpToBack("\(item.returnRate ?? 0.0)")) {
                
              }
            }
          }
        }
        
        Spacer()
          .frame(maxHeight: .infinity)
      }
      .padding(.top, 30)
      .padding(.bottom, 12)
      .padding(.horizontal, 30.0)
    }
  }
  
  @ViewBuilder
  var stateContentView: some View {
    Group {
      switch viewModel.status {
      case .idle, .loading:
        loadingView
      case let .success(model):
        if model.isEmpty {
          emptyView
        } else {
          contentView(rewards: model.first?.rewards ?? [], specialrewards: model.first?.pecialrewards ?? [])
        }
      case .failure:
        failureView
      }
    }
  }
  
  func section<V: View>(title: String, @ViewBuilder content: () -> V) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      content()
    }
  }
  
  func rowView(title: String, desc: String, action: @escaping () -> Void) -> some View {
    Button {
      action()
    } label: {
      VStack(alignment: .leading, spacing: 10) {
        Text(title)
          .font(Fonts.regular.swiftUIFont(size: 14))
          .foregroundColor(Colors.label.swiftUIColor)
          .opacity(0.75)
          .frame(maxWidth: .infinity, alignment: .leading)
          .multilineTextAlignment(.leading)
        Text(desc)
          .font(Fonts.regular.swiftUIFont(size: 20))
          .foregroundColor(Colors.label.swiftUIColor)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .padding(.leading, 16)
    .padding(.trailing, 12)
    .frame(height: 80)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
  }
  
  @ViewBuilder var loadingView: some View {
    Group {
      LottieView(loading: .primary)
        .frame(width: 45, height: 30)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
  
  private var failureView: some View {
    VStack(spacing: 32) {
      Spacer()
      Text(LFLocalizable.Account.Reward.error)
        .font(Fonts.medium.swiftUIFont(size: 14))
        .foregroundColor(Colors.label.swiftUIColor)
        .multilineTextAlignment(.center)
      FullSizeButton(title: LFLocalizable.Account.Reward.retry, isDisable: false) {
        viewModel.retryTapped()
      }
    }
    .padding(30)
    .frame(maxWidth: .infinity)
  }
  
  private var emptyView: some View {
    VStack(spacing: 10) {
      Text(LFLocalizable.Account.Reward.Empty.title)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: 24))
      
      Text(LFLocalizable.Account.Reward.Empty.message)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .font(Fonts.regular.swiftUIFont(size: 16))
    }
    .padding(.horizontal, 30)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
