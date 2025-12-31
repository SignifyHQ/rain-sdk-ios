//
//  RadioButtonComponent.swift
//  fidesmo-ios-library-example
//
//  Created by Kim Nordin on 2023-05-26.
//

import SwiftUI
import FidesmoCore

// ObservableObject ViewModel required to read/write the State outside of the RadioButtonComponent-View
private class RadioButtonViewModel: ObservableObject {
    @Published fileprivate var pressedButtonTag: Int = 0
    let requirement: DataRequirement
    
    init(requirement: DataRequirement) {
        self.requirement = requirement
    }
}

struct RadioButtonComponent: View {
    @ObservedObject private var viewModel: RadioButtonViewModel
    
    init(requirement: DataRequirement) {
        viewModel = RadioButtonViewModel(requirement: requirement)
    }

    var body: some View {
        if let labels = viewModel.requirement.labels?.map({ $0.getFormattedText() }) {
            VStack(spacing: 10) {
                ForEach(labels.indices, id: \.self) { labelIndex in
                    let label = labels[labelIndex]
                    let isSelected = labelIndex == viewModel.pressedButtonTag
                    
                    RadioButton(label, tag: labelIndex, selected: isSelected)
                }
            }
        }
    }

    @ViewBuilder private func RadioButton(_ label: String, tag: Int, selected: Bool) -> some View {
        let buttonLabel = Label(label, systemImage: selected ? "circle.circle" : "circle")
        Button {
            viewModel.pressedButtonTag = tag
        } label: {
            buttonLabel
                .componentButton()
        }
        .tag(tag)
    }
}

extension RadioButtonComponent: Component {
    var value: ComponentValue {
        return (viewModel.requirement.id, String(viewModel.pressedButtonTag))
    }

    func verify() -> Bool {
        return UserInteractionValidator.validateUserInteractionTypeInput(value.1, requirement: viewModel.requirement)
    }
}
