//
//  ButtonComponent.swift
//  fidesmo-ios-library-example
//
//  Created by Kim Nordin on 2023-05-24.
//

import SwiftUI
import FidesmoCore

// ObservableObject ViewModel required to read/write the State outside of the ButtonComponent-View
private class ButtonViewModel: ObservableObject {
    @Published fileprivate var pressedButtonTag: Int = 0
    private let pressHandler: () async -> Void
    let requirement: DataRequirement
    
    init(requirement: DataRequirement, pressHandler: @escaping () async -> Void) {
        self.requirement = requirement
        self.pressHandler = pressHandler
    }
    
    fileprivate func pressedButton(_ index: Int) {
        pressedButtonTag = index
        Task {
            await pressHandler()
        }
    }
}

struct ButtonComponent: View {
    @ObservedObject private var viewModel: ButtonViewModel
    
    init(requirement: DataRequirement, pressHandler: @escaping () async -> Void = {}) {
        viewModel = ButtonViewModel(requirement: requirement, pressHandler: pressHandler)
    }

    var body: some View {
        if let labels = viewModel.requirement.labels?.map({$0.getFormattedText()}) {
            VStack {
                ForEach(labels.indices, id: \.self) { labelIndex in
                    let buttonLabel = labels[labelIndex]
                    Button {
                        viewModel.pressedButton(labelIndex)
                    } label: {
                        Text(buttonLabel)
                            .componentButton()
                    }
                }
            }
        }
    }
}

extension ButtonComponent: Component {
    var value: ComponentValue {
        return (viewModel.requirement.id, String(viewModel.pressedButtonTag))
    }

    func verify() -> Bool {
        return UserInteractionValidator.validateUserInteractionTypeInput(value.1, requirement: viewModel.requirement)
    }
}
