import SwiftUI
import UIKit
import RainSDK
import Web3
import Combine

struct BuildEIP712MessageDemoView: View {
  @StateObject private var viewModel = BuildEIP712MessageDemoViewModel()
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    ScrollView {
        VStack(spacing: 24) {
          // Header
          headerSection
          
          // Status
          statusSection
          
          // Input Section
          inputSection
          
          // Actions
          actionsSection
          
          // Result Section
          if let result = viewModel.result {
            resultSection(result: result)
          }
        }
        .padding()
      }
      .navigationTitle("Build EIP-712 Message")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Done") {
            dismiss()
          }
        }
      }
  }
  
  // MARK: - Header Section
  
  private var headerSection: some View {
    VStack(spacing: 8) {
      Image(systemName: "doc.text.fill")
        .font(.system(size: 50))
        .foregroundColor(.blue)
      
      Text("EIP-712 Message Builder")
        .font(.title2)
        .fontWeight(.bold)
      
      Text("Generate EIP-712 compliant messages for admin signatures")
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding(.vertical)
  }
  
  // MARK: - Status Section
  
  private var statusSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Circle()
          .fill(viewModel.isProcessing ? Color.orange : (viewModel.result != nil ? Color.green : Color.gray))
          .frame(width: 12, height: 12)
        
        Text(viewModel.statusMessage)
          .font(.body)
      }
      
      if let error = viewModel.error {
        Text("Error: \(error.localizedDescription)")
          .font(.caption)
          .foregroundColor(.red)
          .padding()
          .background(Color.red.opacity(0.1))
          .cornerRadius(8)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
  
  // MARK: - Input Section
  
  private var inputSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Parameters")
        .font(.headline)
      
      Group {
        inputField(title: "Chain ID", text: $viewModel.chainId, placeholder: "e.g., 43113")
        inputField(title: "Collateral Proxy Address", text: $viewModel.collateralProxyAddress, placeholder: "0x...")
        inputField(title: "Wallet Address", text: $viewModel.walletAddress, placeholder: "0x...")
        inputField(title: "Token Address", text: $viewModel.tokenAddress, placeholder: "0x...")
        inputField(title: "Amount", text: $viewModel.amount, placeholder: "e.g., 100.0")
        inputField(title: "Decimals", text: $viewModel.decimals, placeholder: "e.g., 18")
        inputField(title: "Recipient Address", text: $viewModel.recipientAddress, placeholder: "0x...")
        inputField(title: "Nonce (optional)", text: $viewModel.nonce, placeholder: "Leave empty to auto-fetch")
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }
  
  private func inputField(title: String, text: Binding<String>, placeholder: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.subheadline)
        .foregroundColor(.secondary)
      
      TextField(placeholder, text: text)
        .textFieldStyle(.roundedBorder)
        .autocapitalization(.none)
        .disableAutocorrection(true)
    }
  }
  
  // MARK: - Actions Section
  
  private var actionsSection: some View {
    Button(action: {
      hideKeyboard()
      Task {
        await viewModel.buildMessage()
      }
    }) {
      HStack {
        if viewModel.isProcessing {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
        } else {
          Image(systemName: "play.circle.fill")
        }
        
        Text("Build Message")
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(viewModel.canBuild ? Color.blue : Color.gray)
      .foregroundColor(.white)
      .cornerRadius(12)
    }
    .disabled(!viewModel.canBuild || viewModel.isProcessing)
  }
  
  // MARK: - Result Section
  
  private func resultSection(result: (message: String, salt: String)) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("Result")
          .font(.headline)
        
        Spacer()
        
        Button(action: {
          UIPasteboard.general.string = result.message
          viewModel.showCopyFeedback = true
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            viewModel.showCopyFeedback = false
          }
        }) {
          HStack(spacing: 4) {
            Image(systemName: "doc.on.doc")
            Text("Copy Message")
          }
          .font(.caption)
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(8)
        }
      }
      
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Text("Salt (Hex)")
            .font(.subheadline)
            .foregroundColor(.secondary)
          
          Spacer()
          
          Button(action: {
            UIPasteboard.general.string = result.salt
            viewModel.showCopyFeedback = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
              viewModel.showCopyFeedback = false
            }
          }) {
            Image(systemName: "doc.on.doc")
              .font(.caption)
              .foregroundColor(.blue)
          }
        }
        
        Text(result.salt)
          .font(.system(.body, design: .monospaced))
          .padding()
          .background(Color(.systemBackground))
          .cornerRadius(8)
          .textSelection(.enabled)
      }
      
      VStack(alignment: .leading, spacing: 8) {
        Text("EIP-712 Message (JSON)")
          .font(.subheadline)
          .foregroundColor(.secondary)
        
        ScrollView {
          Text(result.message)
            .font(.system(.caption, design: .monospaced))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .textSelection(.enabled)
        }
        .frame(maxHeight: 200)
      }
      
      // Next Step Button
      NavigationLink(destination: BuildWithdrawTransactionDemoView(
        chainId: viewModel.chainId,
        contractAddress: nil, // User needs to provide this
        proxyAddress: viewModel.collateralProxyAddress,
        tokenAddress: viewModel.tokenAddress,
        amount: viewModel.amount,
        decimals: viewModel.decimals,
        recipientAddress: viewModel.recipientAddress,
        expiresAt: nil, // Will use default
        signatureData: result.salt, // Use salt as signatureData
        adminSalt: result.salt, // Use salt from EIP-712 message as adminSalt
        adminSignature: nil // User needs to provide this
      )) {
        HStack {
          Image(systemName: "arrow.right.circle.fill")
          Text("Next: Build Withdraw Transaction")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.green)
        .foregroundColor(.white)
        .cornerRadius(12)
      }
      .padding(.top, 8)
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
    .overlay(
      Group {
        if viewModel.showCopyFeedback {
          Text("Copied!")
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            .transition(.opacity)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
      .padding(16)
      .animation(.easeInOut, value: viewModel.showCopyFeedback)
    )
  }
}

#Preview {
  BuildEIP712MessageDemoView()
}
