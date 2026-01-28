import SwiftUI
import UIKit
import RainSDK
import Combine
import Web3
import Web3ContractABI
import web3swift
import Web3Core

struct BuildWithdrawTransactionDemoView: View {
  @StateObject private var viewModel: BuildWithdrawTransactionDemoViewModel
  @Environment(\.dismiss) private var dismiss
  
  init(
    chainId: String? = nil,
    contractAddress: String? = nil,
    proxyAddress: String? = nil,
    tokenAddress: String? = nil,
    amount: String? = nil,
    decimals: String? = nil,
    recipientAddress: String? = nil,
    expiresAt: String? = nil,
    signatureData: String? = nil,
    adminSalt: String? = nil,
    adminSignature: String? = nil
  ) {
    let vm = BuildWithdrawTransactionDemoViewModel()
    if let chainId = chainId { vm.chainId = chainId }
    if let contractAddress = contractAddress { vm.contractAddress = contractAddress }
    if let proxyAddress = proxyAddress { vm.proxyAddress = proxyAddress }
    if let tokenAddress = tokenAddress { vm.tokenAddress = tokenAddress }
    if let amount = amount { vm.amount = amount }
    if let decimals = decimals { vm.decimals = decimals }
    if let recipientAddress = recipientAddress { vm.recipientAddress = recipientAddress }
    if let expiresAt = expiresAt { vm.expiresAt = expiresAt }
    if let signatureData = signatureData { vm.signatureData = signatureData }
    if let adminSalt = adminSalt { vm.adminSalt = adminSalt }
    if let adminSignature = adminSignature { vm.adminSignature = adminSignature }
    _viewModel = StateObject(wrappedValue: vm)
  }
  
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
      .navigationTitle("Build Withdraw Transaction")
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
      Image(systemName: "arrow.down.circle.fill")
        .font(.system(size: 50))
        .foregroundColor(.blue)
      
      Text("Withdraw Transaction Builder")
        .font(.title2)
        .fontWeight(.bold)
      
      Text("Generate transaction calldata for withdrawals")
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
        inputField(title: "Contract Address", text: $viewModel.contractAddress, placeholder: "0x...")
        inputField(title: "Proxy Address", text: $viewModel.proxyAddress, placeholder: "0x...")
        inputField(title: "Token Address", text: $viewModel.tokenAddress, placeholder: "0x...")
        inputField(title: "Amount", text: $viewModel.amount, placeholder: "e.g., 100.0")
        inputField(title: "Decimals", text: $viewModel.decimals, placeholder: "e.g., 18")
        inputField(title: "Recipient Address", text: $viewModel.recipientAddress, placeholder: "0x...")
        inputField(title: "Expires At", text: $viewModel.expiresAt, placeholder: "Unix timestamp or ISO8601")
        inputField(title: "Signature Data (Hex)", text: $viewModel.signatureData, placeholder: "0x...")
        inputField(title: "Admin Salt (Hex)", text: $viewModel.adminSalt, placeholder: "0x...")
        inputField(title: "Admin Signature (Hex)", text: $viewModel.adminSignature, placeholder: "0x...")
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
      Task {
        await viewModel.buildTransaction()
      }
    }) {
      HStack {
        if viewModel.isProcessing {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
        } else {
          Image(systemName: "play.circle.fill")
        }
        
        Text("Build Transaction")
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
  
  private func resultSection(result: String) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("Transaction Calldata")
          .font(.headline)
        
        Spacer()
        
        Button(action: {
          UIPasteboard.general.string = result
          viewModel.showCopyFeedback = true
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            viewModel.showCopyFeedback = false
          }
        }) {
          HStack(spacing: 4) {
            Image(systemName: "doc.on.doc")
            Text("Copy")
          }
          .font(.caption)
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(8)
        }
      }
      
      ScrollView {
        Text(result)
          .font(.system(.caption, design: .monospaced))
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding()
          .background(Color(.systemBackground))
          .cornerRadius(8)
          .textSelection(.enabled)
      }
      .frame(maxHeight: 200)
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

// MARK: - ViewModel

@MainActor
class BuildWithdrawTransactionDemoViewModel: ObservableObject {
  @Published var chainId: String = "43113"
  @Published var contractAddress: String = "0x1234567890123456789012345678901234567890"
  @Published var proxyAddress: String = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd"
  @Published var tokenAddress: String = "0x9876543210987654321098765432109876543210"
  @Published var amount: String = "100.0"
  @Published var decimals: String = "18"
  @Published var recipientAddress: String = "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc"
  @Published var expiresAt: String = "\(Int(Date().addingTimeInterval(86400).timeIntervalSince1970))"
  // Example 32-byte hex strings (64 hex characters)
  @Published var signatureData: String = "0xa1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef1234567890"
  @Published var adminSalt: String = "0x1a2b3c4d5e6f789012345678901234567890abcdef1234567890abcdef1234567890"
  @Published var adminSignature: String = "0xf1e2d3c4b5a6789012345678901234567890abcdef1234567890abcdef1234567890"
  
  @Published var isProcessing: Bool = false
  @Published var statusMessage: String = "Ready"
  @Published var error: Error?
  @Published var result: String?
  @Published var showCopyFeedback: Bool = false
  
  private let sdkService = RainSDKService.shared
  
  init() {
    // Observe service initialization state
    sdkService.$isInitialized
      .sink { [weak self] _ in
        self?.objectWillChange.send()
      }
      .store(in: &cancellables)
  }
  
  private var cancellables = Set<AnyCancellable>()
  
  var canBuild: Bool {
    !chainId.isEmpty
      && !contractAddress.isEmpty
      && !proxyAddress.isEmpty
      && !tokenAddress.isEmpty
      && !amount.isEmpty
      && !decimals.isEmpty
      && !recipientAddress.isEmpty
      && !expiresAt.isEmpty
      && !signatureData.isEmpty
      && !adminSalt.isEmpty
      && !adminSignature.isEmpty
      && Int(chainId) != nil
      && Double(amount) != nil
      && Int(decimals) != nil
      && sdkService.isInitialized
  }
  
  func buildTransaction() async {
    guard let chainIdInt = Int(chainId),
          let amountDouble = Double(amount),
          let decimalsInt = Int(decimals) else {
      return
    }
    
    // Convert hex strings to Data
    guard let signatureDataBytes = Data(hexString: signatureData),
          let adminSaltBytes = Data(hexString: adminSalt),
          let adminSignatureBytes = Data(hexString: adminSignature) else {
      error = NSError(domain: "Demo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid hex data"])
      return
    }
    
    isProcessing = true
    statusMessage = "Building transaction..."
    error = nil
    result = nil
    
    do {
      let calldata = try await sdkService.buildWithdrawTransactionData(
        chainId: chainIdInt,
        contractAddress: contractAddress,
        proxyAddress: proxyAddress,
        tokenAddress: tokenAddress,
        amount: amountDouble,
        decimals: decimalsInt,
        recipientAddress: recipientAddress,
        expiresAt: expiresAt,
        signatureData: signatureDataBytes,
        adminSalt: adminSaltBytes,
        adminSignature: adminSignatureBytes
      )
      
      result = calldata
      statusMessage = "Success! Transaction calldata generated."
      error = nil
    } catch {
      self.error = error
      statusMessage = "Failed to build transaction"
    }
    
    isProcessing = false
  }
}

// Helper extension for hex string to Data conversion
extension Data {
  init?(hexString: String) {
    let hex = hexString.hasPrefix("0x") ? String(hexString.dropFirst(2)) : hexString
    let len = hex.count / 2
    var data = Data(capacity: len)
    var i = hex.startIndex
    for _ in 0..<len {
      let j = hex.index(i, offsetBy: 2)
      let bytes = hex[i..<j]
      if var num = UInt8(bytes, radix: 16) {
        data.append(&num, count: 1)
      } else {
        return nil
      }
      i = j
    }
    self = data
  }
}

#Preview {
  BuildWithdrawTransactionDemoView()
}
