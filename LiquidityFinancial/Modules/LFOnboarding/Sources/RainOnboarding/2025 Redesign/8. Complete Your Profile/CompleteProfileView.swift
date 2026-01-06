import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

public struct CompleteProfileView: View {
  @StateObject var viewModel: CompleteProfileViewModel
  
  @State private var progressBarFrame: CGRect = .zero
  @State private var dropdownFrames: [CompleteProfileCategory: CGRect] = [:]
  
  @FocusState private var focusedSearchBar: FocusedSearchBar?
  
  private let DROPDOWN_SEARCHBAR_HEIGHT: CGFloat = 52
  private let DROPDOWN_ROW_HEIGHT: CGFloat = 36
  private let DROPDOWN_EMPTY_VIEW_HEIGHT: CGFloat = 50
  // Calculate the occupation list dropdown height based on the number of rows
  private var occupationDropdownHeight: CGFloat {
    CGFloat
      .dropdownHeight(
        rowCount: viewModel.occupationListFiltered.count,
        rowHeight: DROPDOWN_ROW_HEIGHT,
        headerHeight: DROPDOWN_SEARCHBAR_HEIGHT,
        emptyViewHeight: DROPDOWN_EMPTY_VIEW_HEIGHT,
        fallbackOveralHeight: (dropdownFrames[.occupation]?.width ?? 0) * 0.7
      )
  }
  public init(
    viewModel: CompleteProfileViewModel
  ) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    ZStack {
      VStack(
        spacing: 32
      ) {
        progressView
          .readGeometry { geometry in
            progressBarFrame = geometry.frame(in: .global)
          }
        
        contentView
        
        buttonGroup
      }
      .padding(.top, 8)
      .padding(.bottom, 16)
      .padding(.horizontal, 24)
      // Adding content shape to make sure the whole screen is tappable
      .contentShape(Rectangle())
      .onTapGesture {
        viewModel.selectedCategory = nil
      }
      
      if let selectedCategory = viewModel.selectedCategory,
         let selectedCategoryFrame = dropdownFrames[selectedCategory] {
        dropdownView(
          for: selectedCategory
        )
        .frame(
          width: selectedCategoryFrame.width,
          height: selectedCategory == .occupation ? occupationDropdownHeight : (CGFloat(selectedCategory.options.count) * DROPDOWN_ROW_HEIGHT),
          alignment: .top
        )
        .background(Colors.backgroundLight.swiftUIColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .position(
          x: selectedCategoryFrame.midX,
          // Calculate the dropdown Y position
          // Adding 8 to account for VStack vertical padding
          // Adding 8 as top padding of the dropdown
          y: selectedCategoryFrame.maxY - progressBarFrame.minY + (selectedCategory == .occupation ? occupationDropdownHeight : (CGFloat(selectedCategory.options.count) * DROPDOWN_ROW_HEIGHT)) / 2 + 8 + 8
        )
      }
    }
    .background(Colors.backgroundPrimary.swiftUIColor)
    .defaultNavBar(
      onRightButtonTap: {
        viewModel.onSupportButtonTap()
      }
    )
    .toast(
      data: $viewModel.currentToast
    )
    .withLoadingIndicator(
      isShowing: $viewModel.isLoadingOccupationList
    )
    .disabled(viewModel.isLoading)
    .navigationLink(
      item: $viewModel.navigation,
      destination: { navigation in
        switch navigation {
        case .ssnInput(let additionalProfileInformation):
          SsnPassportView(
            viewModel: SsnPassportViewModel(
              additionalProfileInformation: additionalProfileInformation
            )
          )
        }
      }
    )
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension CompleteProfileView {
  var contentView: some View {
    ScrollViewReader { proxy in
      ScrollView {
        VStack(
          alignment: .leading,
          spacing: 24
        ) {
          headerView
          
          categoryViews
          
          Spacer()
        }
        .onChange(
          of: focusedSearchBar
        ) { focus in
          guard focus != nil
          else {
            return
          }
          
          DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.4
          ) {
            withAnimation(
              .easeInOut(
                duration: 0.3
              )
            ) {
              proxy.scrollTo("id-spacer")
            }
          }
        }
      }
      .frame(
        maxWidth: .infinity
      )
      .scrollIndicators(.hidden)
    }
  }
  
  var progressView: some View {
    SegmentedProgressBar(
      totalSteps: 8,
      currentStep: .constant(6)
    )
  }
  
  var headerView: some View {
    VStack(
      alignment: .leading,
      spacing: 4
    ) {
      Text("Complete your profile")
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
      
      Text("Please provide some information to help us\ncustomize your experience")
        .foregroundStyle(Colors.titleTertiary.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
  
  var categoryViews: some View {
    VStack(
      alignment: .leading,
      spacing: 16
    ) {
      ForEach(
        CompleteProfileCategory.allCases,
        id: \.self
      ) { category in
        categoryView(
          for: category
        )
        .readGeometry { geometry in
          dropdownFrames[category] = geometry.frame(in: .global)
        }
        .id(category == .spend ? "id-spacer" : "")
        .highPriorityGesture(
          TapGesture()
            .onEnded {
              viewModel.selectedCategory.toggle(to: category)
            }
        )
      }
    }
  }
  
  func categoryView(
    for category: CompleteProfileCategory
  ) -> some View {
    ZStack {
      DefaultTextField(
        title: category.title,
        placeholder: category.placeholder,
        value: .constant(viewModel.selectedOptions[category]??.value ?? .empty)
      )
      .disabled(true)
      
      HStack {
        Rectangle()
          .foregroundStyle(
            Color.clear
          )
          .contentShape(Rectangle())
        
        GenImages.Images.icoExpandDown.swiftUIImage
          .rotationEffect(
            .degrees(viewModel.selectedCategory == category ? -180 : 0)
          )
          .animation(
            .easeOut(
              duration: 0.2
            ),
            value: viewModel.selectedCategory == category
          )
      }
    }
  }
  
  func dropdownView(
    for category: CompleteProfileCategory
  ) -> some View {
    VStack(
      spacing: 0
    ) {
      if category == .occupation {
        HStack(
          spacing: 4
        ) {
          Image(
            systemName: "magnifyingglass"
          )
          .foregroundColor(Colors.backgroundLight.swiftUIColor)
          
          TextField(
            "Search occupation",
            text: $viewModel.searchQuery
          )
          .focused($focusedSearchBar, equals: .occupation)
          .textFieldStyle(PlainTextFieldStyle())
          .submitLabel(.done)
          .tint(Colors.backgroundLight.swiftUIColor)
        }
        .padding(8)
        .background(Colors.backgroundDark.swiftUIColor)
        .cornerRadius(8)
        .padding(8)
        .frame(height: DROPDOWN_SEARCHBAR_HEIGHT)
        
        Divider()
          .background(Colors.backgroundSecondary.swiftUIColor)
      }
      
      List(
        viewModel.options(for: category),
        id: \.id
      ) { item in
        HStack(
          spacing: 4
        ) {
          Text(item.value)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
            .lineLimit(1)
            .layoutPriority(1)
          
          // Adding clear rectangle to make the whole row tappable, not just the text
          Rectangle()
            .foregroundStyle(
              Color.clear
            )
            .contentShape(Rectangle())
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .padding(.horizontal, 10)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(.zero)
        .onTapGesture {
          viewModel.selectedCategory = nil
          viewModel.selectedOptions[category] = item
        }
      }
      .environment(\.defaultMinListRowHeight, DROPDOWN_ROW_HEIGHT)
      .scrollContentBackground(.hidden)
      .listStyle(.plain)
      
      // Show no results message if the filtered list of occupations is empty
      if viewModel.selectedCategory == .occupation,
         viewModel.options(for: category).isEmpty {
        HStack {
          Spacer()
          
          Text("No results found")
            .foregroundStyle(Colors.textSecondary.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          
          Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .frame(height: DROPDOWN_EMPTY_VIEW_HEIGHT)
      }
    }
    .floatingShadow()
  }
  
  var buttonGroup: some View {
    VStack(
      spacing: 12
    ) {
      FullWidthButton(
        type: .primary,
        title: "Continue",
        isDisabled: !viewModel.isContinueButtonEnabled
      ) {
        viewModel.onContinueButtonTap()
      }
    }
  }
}

// MARK: - Private Enums
extension CompleteProfileView {
  enum FocusedSearchBar: Hashable {
    case occupation
  }
}
