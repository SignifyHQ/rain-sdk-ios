import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

struct CompleteYourProfileView: View {
  @Environment(\.dismiss) var dismiss
  
  @StateObject private var viewModel = CompleteYourProfileViewModel()
  
  @State private var scrollViewFrame: CGRect = .zero
  @State private var dropdownFrames: [CompleteProfileCategory: CGRect] = [:]
  
  init() {
    UITableView.appearance().backgroundColor = UIColor(Colors.background.swiftUIColor)
    UITableView.appearance().separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
  }
  
  var body: some View {
    Group {
      if viewModel.isLoadingOccupationList {
        loadingView
      } else {
        content
      }
    }
    .onAppear {
      viewModel.onAppear()
    }
    .background(Colors.background.swiftUIColor)
    .popup(
      item: $viewModel.toastMessage,
      style: .toast
    ) {
      ToastView(toastMessage: $0)
    }
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension CompleteYourProfileView {
  var content: some View {
    VStack {
      ScrollViewReader { proxy in
        ZStack {
          ScrollView {
            VStack(alignment: .leading) {
              Text("COMPLETE YOUR PROFILE")
                .foregroundColor(Colors.label.swiftUIColor)
                .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
                .padding(.vertical, 16)
              
              Text("Please provide some information to help us customize your experience")
                .foregroundColor(Colors.label.swiftUIColor)
                .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
                .padding(.bottom, 16)
              
              textFieldView
            }
            .padding(.horizontal, 32)
          }
          .simultaneousGesture(
            TapGesture()
              .onEnded {
                viewModel.selectedCategory = nil
              }
          )
          .readGeometry { geometry in
            scrollViewFrame = geometry.frame(in: .global)
          }
          
          if let selectedCategory = viewModel.selectedCategory,
             let selectedCategoryFrame = dropdownFrames[selectedCategory] {
            dropdownView(for: selectedCategory)
              .frame(
                width: selectedCategoryFrame.width,
                height: selectedCategoryFrame.height * 3.5,
                alignment: .top
              )
              .background(Colors.secondaryBackground.swiftUIColor)
              .clipShape(RoundedRectangle(cornerRadius: 4))
              .position(
                x: selectedCategoryFrame.midX,
                y: selectedCategoryFrame.maxY + selectedCategoryFrame.height * 3.5 / 2 - scrollViewFrame.minY + 5
              )
          }
        }
      }
      
      continueButton
    }
    .navigationTitle(String.empty)
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden(viewModel.isLoading)
    .defaultToolBar(
      icon: .support,
      openSupportScreen: {
        viewModel.openSupportScreen()
      }
    )
  }
  
  func categoryView(
    category: CompleteProfileCategory
  ) -> some View {
    VStack(alignment: .leading) {
      Text(category.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
      
      HStack {
        Text(viewModel.selectedOptions[category]?.map { $0.value } ?? category.placeholder)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .frame(height: 42)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.leading, 10)
        
        Spacer()
        
        GenImages.CommonImages.icArrowDown.swiftUIImage
          .tint(Colors.label.swiftUIColor)
          .rotationEffect(
            .degrees(viewModel.selectedCategory == category ? 180 : 0)
          )
          .padding(.trailing, 10)
      }
      .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(4))
    }
  }
  
  var textFieldView: some View {
    VStack(alignment: .leading, spacing: 25) {
      ForEach(CompleteProfileCategory.allCases, id: \.self) { category in
        categoryView(
          category: category
        )
        .readGeometry { geometry in
          dropdownFrames[category] = geometry.frame(in: .global)
        }
        .onTapGesture {
          viewModel.selectedCategory.toggle(to: category)
        }
      }
    }
  }
  
  var continueButton: some View {
    FullSizeButton(
      title: L10N.Common.Button.Continue.title,
      isDisable: !viewModel.isContinueButtonEnabled,
      isLoading: $viewModel.isLoading,
      type: .primary
    ) {
      viewModel.selectedCategory = nil
      
      viewModel.onContinueButtonTapped()
    }
    .padding(.horizontal, 30)
    .padding(.bottom, 12)
  }
  
  func dropdownView(
    for category: CompleteProfileCategory
  ) -> some View {
    List(
      viewModel.options(for: category),
      id: \.id
    ) { item in
      HStack {
        Text(item.value)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .padding(.leading, 12)
          .layoutPriority(1)
        
        // Adding clear rectangle to make the whole row tappable, not just the text
        Rectangle()
          .foregroundStyle(
            Color.clear
          )
          .contentShape(Rectangle())
      }
      .listRowBackground(Color.clear)
      .listRowSeparatorTint(Colors.label.swiftUIColor.opacity(0.16))
      .listRowInsets(.none)
      .onTapGesture {
        viewModel.selectedCategory = nil
        viewModel.selectedOptions[category] = item
      }
    }
    .scrollContentBackground(.hidden)
    .listStyle(.plain)
    .floatingShadow()
  }
  
  var loadingView: some View {
    VStack {
      Spacer()
      
      LottieView(
        loading: .primary
      )
      .frame(
        width: 30,
        height: 20
      )
      
      Spacer()
    }
    .frame(max: .infinity)
  }
}
