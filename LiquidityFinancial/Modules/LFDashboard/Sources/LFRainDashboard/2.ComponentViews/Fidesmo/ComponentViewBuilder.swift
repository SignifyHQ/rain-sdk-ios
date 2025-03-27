//
//  ComponentViewBuilder.swift
//  fidesmo-ios-library-example
//
//  Created by Kim Nordin on 2023-05-22.
//

import SwiftUI
import RxSwift
import FidesmoCore

struct ComponentViewBuilder: View {
    @State private var componentViews = [AnyView]()
    @State private var components = [Component]()
    
    @Binding var dataRequirements: [DataRequirement]
    @Binding var responseHandler: UserResponseHandler?
    @Binding var actionHandler: UserActionHandler?
    @Binding var deliveryProgress: DeliveryProgress
    @Binding var dataRequirementUUID: UUID

    private let ignoreId = "ignore-value"
    private var finishedStatus = ""
    
    init(dataRequirements: Binding<[DataRequirement]>, responseHandler: Binding<UserResponseHandler?>, actionHandler: Binding<UserActionHandler?>, deliveryProgress: Binding<DeliveryProgress>, dataRequirementUUID: Binding<UUID>) {
        _dataRequirements = dataRequirements
        _responseHandler = responseHandler
        _actionHandler = actionHandler
        _deliveryProgress = deliveryProgress
        _dataRequirementUUID = dataRequirementUUID
    }

    var body: some View {
        ScrollView {
            if case .finished(let status) = deliveryProgress {
                Text("Delivery finished! \nSucceeded: \(status.success)\nMessage: \(status.message.getFormattedText())\n\nYou can start again by scanning the device")
            }
            VStack(spacing: 10) {
                ForEach(componentViews.indices, id: \.self) { componentIndex in
                    componentViews[componentIndex]
                }
            }
        }
        .onChange(of: dataRequirements) {
            getComponents(requirements: $0)
        }
        .onChange(of: dataRequirementUUID) { _ in
            getComponents(requirements: dataRequirements)
        }
    }

    private func getComponents(requirements: [DataRequirement]) {
        components.removeAll()
        componentViews.removeAll()

        requirements.forEach { requirement in
            var newComponent: Component?
            var newComponentView: (AnyView)?

            switch requirement.type {
            case .text:
                let component = StaticTextComponent(requirement: requirement)
                newComponent = component
                newComponentView = AnyView(component)
            case .date:
                let component = DatePickerComponent(requirement: requirement)
                newComponent = component
                newComponentView = AnyView(component)
            case .option(.button):
                let component = ButtonComponent(requirement: requirement, pressHandler: sendUserResponse)
                newComponent = component
                newComponentView = AnyView(component)
            case .option(.radio):
                let component = RadioButtonComponent(requirement: requirement)
                newComponent = component
                newComponentView = AnyView(component)
            case let .edit(format):
                switch format {
                case .number:
                    let component = NumberInputComponent(requirement: requirement, obfuscated: false)
                    newComponent = component
                    newComponentView = AnyView(component)
                case .obfuscatedNumber:
                    let component = NumberInputComponent(requirement: requirement, obfuscated: true)
                    newComponent = component
                    newComponentView = AnyView(component)
                default:
                    let component = TextInputComponent(requirement: requirement)
                    newComponent = component
                    newComponentView = AnyView(component)
                }
            case .image:
                let component = ImageComponent(requirement: requirement)
                newComponent = component
                newComponentView = AnyView(component)
            case .checkbox:
                let component = CheckComponent(requirement: requirement)
                newComponent = component
                newComponentView = AnyView(component)
            case .paymentcard:
                let component = PaymentCardComponent(requirement: requirement)
                newComponent = component
                newComponentView = AnyView(component)
            case .appAuth, .openUrl, .webActivation:
                let component = AuthenticationComponent(requirement: requirement, nextHandler: sendUserResponse)
                newComponent = component
                newComponentView = AnyView(component)
            default:
                let component = StaticTextComponent(requirement: requirement)
                newComponent = component
                newComponentView = AnyView(component)
            }

            if let component = newComponent, let componentView = newComponentView {
                components.append(component)
                componentViews.append(componentView)
            }
        }
        renderConditionalNextButton()
    }

    private func renderConditionalNextButton() {
        switch deliveryProgress {
        case .notStarted, .finished, .needsUserAction, .needsUserInteraction:
            if !dataRequirements.isEmpty && !dataRequirements.contains(where: { $0.type == .option(.button) }) {
                dataRequirements.append(nextButtonRequirement())
            }
        default: break
        }
    }

    private func nextButtonRequirement() -> DataRequirement {
        let nextButtonRequirement = DataRequirement(label: nil, labels: [ParametrisedTranslation(text: "Next")], id: ignoreId, type: .option(.button), appUrl: "", appStoreId: "", mandatory: false)
        return nextButtonRequirement
    }

    private func binding(from newRequirements: [DataRequirement]) -> Binding<[DataRequirement]> {
        Binding(
            get: { newRequirements },
            set: { dataRequirements = $0 }
        )
    }
    
    private func sendUserResponse() async {
        Task {
            var isInputValid = components.reduce(true) { (previous, component) -> Bool in
                return component.verify() && previous
            }
            
            if isInputValid {
                for component in components {
                    isInputValid = await component.asyncVerify() && isInputValid
                    if !isInputValid { break } // Exit early if verification fails
                }
            }
            
            if isInputValid {
                var userResponses = UserDataResponse()
                components.forEach { component in
                    if component.value.0 != ignoreId {
                        userResponses[component.value.0] = component.value.1
                    }
                }

                if case .needsUserAction = deliveryProgress {
                    actionHandler?(true)
                } else {
                    responseHandler?(userResponses)
                }
            }
        }
    }
}
