//
//  PaymentCardComponent.swift
//  fidesmo-ios-library-example
//
//  Created by Kim Nordin on 2023-05-23.
//

import SwiftUI
import RxSwift
import FidesmoCore

// ObservableObject ViewModel required to read/write the State outside of the PaymentCardComponent-View
private class PaymentCardViewModel: ObservableObject {
    @Published fileprivate var panInput: String = ""
    @Published fileprivate var monthInput: Int? = nil
    @Published fileprivate var yearInput: Int? = nil
    @Published fileprivate var cvvInput: String = ""
    @Published fileprivate var error: String? = nil
    
    let requirement: DataRequirement
    
    public init(requirement: DataRequirement) {
        self.requirement = requirement
    }
    
    fileprivate var paymentCard: PaymentCard {
        PaymentCard(cardNumber: panInput, expiryMonth: monthInput ?? 1, expiryYear: yearInput ?? 1, cvv: cvvInput)
    }
    
    fileprivate func verifyPaymentCard() async -> Bool {
        guard let paymentCardInput = paymentCard.toJSONString() else { return false }
        let isValidPaymentCard = UserInteractionValidator.validateUserInteractionTypeInput(paymentCardInput, requirement: requirement) && paymentCard.isPanValid()
        let isValidCvv = paymentCard.isCvvValid()
        let isValidDate = paymentCard.isDateValid()
        
        DispatchQueue.main.async {
            if !isValidPaymentCard {
                self.error = "Invalid Payment Card"
            } else if !isValidDate {
                self.error = "Invalid Expiry Date"
            } else if !isValidCvv {
                self.error = "Invalid CVV"
            } else {
                self.error = nil
            }
        }

        let validConditions = isValidPaymentCard && isValidDate && isValidCvv
        return validConditions
    }
}

struct PaymentCardComponent: View {
    @ObservedObject private var viewModel: PaymentCardViewModel
    
    init(requirement: DataRequirement) {
        viewModel = PaymentCardViewModel(requirement: requirement)
    }
    
    var body: some View {
        VStack {
            TextField("PAN", text: $viewModel.panInput)
                .keyboardType(.numberPad)
            HStack {
                TextField("MM", value: $viewModel.monthInput, format: .number)
                    .keyboardType(.numberPad)
                TextField("YY", value: $viewModel.yearInput, format: .number)
                    .keyboardType(.numberPad)
                TextField("CVV", text: $viewModel.cvvInput)
                    .keyboardType(.numberPad)
            }
            if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
            }
        }
        .onChange(of: [viewModel.panInput, viewModel.cvvInput]) { _ in
            viewModel.error = nil
        }
        .onChange(of: [viewModel.monthInput, viewModel.yearInput]) { _ in
            viewModel.error = nil
        }
    }
}

extension PaymentCardComponent: Component {
    var value: ComponentValue {
        if let paymentJson = viewModel.paymentCard.toJSONString() {
            return (viewModel.requirement.id, paymentJson)
        } else {
            return ("", "")
        }
    }
    
    func asyncVerify() async -> Bool {
        return await viewModel.verifyPaymentCard()
    }
}
