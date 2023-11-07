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
    viewModel: PatriotActViewModel = PatriotActViewModel(),
    contentViewFactory: SolidContentViewFactory = Container.shared.contenViewFactory.callAsFunction(EnvironmentManager())
  ) {
    _viewModel = .init(wrappedValue: viewModel)
    self.contentViewFactory = contentViewFactory
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
            .resizable().frame(width: 24, height: 24)
        } else {
          GenImages.CommonImages.termsCheckboxDeselected.swiftUIImage
            .resizable().frame(width: 24, height: 24)
            .foregroundColor(Colors.Buttons.highlightButton.swiftUIColor)
        }
      }
      .onTapGesture {
        viewModel.isNoticeAccepted.toggle()
      }
      .padding(.bottom, 5)
      let agreementString = LFLocalizable.PatriotAct.Agreements.partiotActNotice
      let link = LFLocalizable.PatriotAct.Links.partiotActNotice

      TextTappable(
        text: agreementString,
        fontSize: Constants.FontSize.ultraSmall.value,
        links: [link],
        style: .underlined(Colors.label.color)
      ) { tappedString in
        guard let url = URL(string: LFUtilities.termsURL) else { return } // Todo(Volo): - Replace with actual URL from config
        openURL(url)
      }
      .frame(height: 40)
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
