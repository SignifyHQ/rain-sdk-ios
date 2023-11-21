import Factory
import Foundation
import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

struct PatriotActView: View {
  @Environment(\.openURL) var openURL
  
  @StateObject var viewModel: PatriotActViewModel
  
  var contentViewFactory: SolidContentViewFactory
  
  init(
    viewModel: PatriotActViewModel = PatriotActViewModel()
  ) {
    _viewModel = .init(wrappedValue: viewModel)
    self.contentViewFactory = Container.shared.contenViewFactory.callAsFunction()
  }
  
  var body: some View {
    VStack {
      VStack(alignment: .leading) {
        title
        notice
      }
      .padding(.horizontal, 32)
      
      Spacer()
      
      agreement
      continueButton
    }
    .frame(maxWidth: .infinity)
    .background(Colors.background.swiftUIColor)
    .defaultToolBar(
      icon: .support,
      openSupportScreen: {
        viewModel.openSupportScreen()
      }
    )
    .navigationLink(isActive: $viewModel.shouldContinue) {
      contentViewFactory
        .createView(type: .information)
    }
  }
}

extension PatriotActView {
  private var title: some View {
    Text(LFLocalizable.PatriotAct.title)
      .foregroundColor(Colors.label.swiftUIColor)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      .padding(.bottom, 12)
  }
  
  private var notice: some View {
    Group {
      Text(LFLocalizable.PatriotAct.body)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .lineSpacing(1.33)
        .multilineTextAlignment(.leading)
    }
  }
  
  private var agreement: some View {
    HStack(spacing: 5) {
      Group {
        if viewModel.isNoticeAccepted {
          GenImages.Images.termsCheckboxSelected.swiftUIImage
            .resizable()
            .frame(width: 24, height: 24)
        } else {
          GenImages.CommonImages.termsCheckboxDeselected.swiftUIImage
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(Colors.Buttons.highlightButton.swiftUIColor)
        }
      }
      .onTapGesture {
        viewModel.isNoticeAccepted.toggle()
      }
      .padding(.bottom, 5)
      
      TextTappable(
        text: viewModel.patriotActString,
        fontSize: Constants.FontSize.ultraSmall.value,
        links: [viewModel.patriotActlink],
        style: .underlined(Colors.label.color)
      ) { tappedString in
        guard let url = viewModel.getUrl(for: tappedString) else { return }
        openURL(url)
      }
      .frame(height: 37)
    }
    .padding(.horizontal, 30)
  }
  
  private var continueButton: some View {
    FullSizeButton(
      title: LFLocalizable.Button.Continue.title,
      isDisable: !viewModel.isNoticeAccepted,
      type: .primary
    ) {
      viewModel.shouldContinue = true
    }
    .padding(.horizontal, 30)
    .padding(.bottom, 12)
  }
}
