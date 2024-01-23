import Factory
import Foundation
import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

struct PatriotActView: View {
  
  @StateObject var viewModel: PatriotActViewModel
  
  @State var openSafariType: PatriotActViewModel.OpenSafariType?
  
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
      .padding(.horizontal, 30)
      
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
      },
      edgeInsets: EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0)
    )
    .navigationLink(isActive: $viewModel.shouldContinue) {
      contentViewFactory
        .createView(type: .information)
    }
    .fullScreenCover(item: $openSafariType, content: { type in
      switch type {
      case .privacy(let url):
        SFSafariViewWrapper(url: url)
      }
    })
  }
}

extension PatriotActView {
  private var title: some View {
    Text(L10N.Common.PatriotAct.title)
      .foregroundColor(Colors.label.swiftUIColor)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      .padding(.bottom, 12)
      .padding(.top, 12)
  }
  
  private var notice: some View {
    Group {
      Text(L10N.Common.PatriotAct.body)
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
        openSafariType = .privacy(url)
      }
      .frame(height: 37)
    }
    .padding(.horizontal, 30)
  }
  
  private var continueButton: some View {
    FullSizeButton(
      title: L10N.Common.Button.Continue.title,
      isDisable: !viewModel.isNoticeAccepted,
      type: .primary
    ) {
      viewModel.shouldContinue = true
    }
    .padding(.horizontal, 30)
    .padding(.bottom, 12)
  }
}
