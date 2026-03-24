import SwiftUI
import RainSDK

struct GetTransactionsDemoView: View {
  @StateObject private var viewModel = GetTransactionsDemoViewModel()
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        headerSection
        statusSection
        inputSection
        fetchSection
        if !viewModel.transactions.isEmpty {
          transactionsSection
        } else if viewModel.hasFetched {
          emptySection
        }
      }
      .padding()
    }
    .navigationTitle("Get Transactions")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("Done") {
          dismiss()
        }
      }
    }
  }

  // MARK: - Header

  private var headerSection: some View {
    VStack(spacing: 8) {
      Image(systemName: "list.bullet.rectangle.fill")
        .font(.system(size: 50))
        .foregroundColor(.blue)

      Text("Get Transactions")
        .font(.title2)
        .fontWeight(.bold)

      Text("Fetch transaction history for the current wallet")
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding(.vertical)
  }

  // MARK: - Status

  private var statusSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Circle()
          .fill(
            viewModel.isLoading
              ? Color.orange
              : (viewModel.transactions.isEmpty ? Color.gray : Color.green)
          )
          .frame(width: 12, height: 12)

        Text(viewModel.statusMessage)
          .font(.body)
      }

      if let error = viewModel.error {
        Text("Error: \(error.localizedDescription)")
          .font(.caption)
          .foregroundColor(.red)
          .padding(8)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(Color.red.opacity(0.1))
          .cornerRadius(8)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  // MARK: - Input

  private var inputSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      VStack(alignment: .leading, spacing: 8) {
        Text("Chain ID")
          .font(.subheadline)
          .foregroundColor(.secondary)
        TextField("e.g. 43113, 1", text: $viewModel.chainId)
          .textFieldStyle(.roundedBorder)
          .keyboardType(.numberPad)
      }

      VStack(alignment: .leading, spacing: 8) {
        Text("Limit")
          .font(.subheadline)
          .foregroundColor(.secondary)
        TextField("e.g. 20", text: $viewModel.limit)
          .textFieldStyle(.roundedBorder)
          .keyboardType(.numberPad)
      }

      VStack(alignment: .leading, spacing: 8) {
        Text("Order")
          .font(.subheadline)
          .foregroundColor(.secondary)
        Picker("Order", selection: $viewModel.orderOption) {
          Text("Newest first").tag(WalletTransactionOrder.DESC)
          Text("Oldest first").tag(WalletTransactionOrder.ASC)
        }
        .pickerStyle(.menu)
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  // MARK: - Fetch

  private var fetchSection: some View {
    Button(action: {
      Task { await viewModel.fetchTransactions() }
    }) {
      HStack {
        if viewModel.isLoading {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
        } else {
          Image(systemName: "arrow.clockwise.circle.fill")
        }
        Text("Get Transactions")
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(viewModel.canFetch ? Color.blue : Color.gray)
      .foregroundColor(.white)
      .cornerRadius(12)
    }
    .disabled(!viewModel.canFetch || viewModel.isLoading)
  }

  // MARK: - Empty State

  private var emptySection: some View {
    VStack(spacing: 12) {
      Image(systemName: "tray")
        .font(.system(size: 36))
        .foregroundColor(.secondary)
      Text("No transactions found")
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity)
    .padding(32)
    .background(Color(.systemGray6))
    .cornerRadius(12)
  }

  // MARK: - Transactions list

  private var transactionsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("Transactions")
          .font(.headline)
        Spacer()
        Text("\(viewModel.transactions.count)")
          .font(.caption)
          .fontWeight(.semibold)
          .foregroundColor(.white)
          .padding(.horizontal, 8)
          .padding(.vertical, 3)
          .background(Color.blue)
          .clipShape(Capsule())
      }

      LazyVStack(spacing: 10) {
        ForEach(viewModel.transactions, id: \.uniqueId) { tx in
          TransactionCardView(tx: tx)
        }
      }
    }
  }
}

// MARK: - Transaction Card

private struct TransactionCardView: View {
  let tx: WalletTransaction

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // Top row: icon + hash + value
      HStack(alignment: .center, spacing: 10) {
        categoryIcon
        VStack(alignment: .leading, spacing: 2) {
          Text(shortHash(tx.hash))
            .font(.system(.subheadline, design: .monospaced))
            .fontWeight(.medium)
        }
        Spacer()
        if let value = tx.value {
          VStack(alignment: .trailing, spacing: 2) {
            Text(formattedValue(value))
              .font(.subheadline)
              .fontWeight(.semibold)
              .foregroundColor(valueColor(value))
            if let asset = tx.asset, !asset.isEmpty {
              Text(asset)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.blue.opacity(0.8))
                .clipShape(Capsule())
            }
          }
        }
      }

      Divider()
        .padding(.vertical, 8)

      // Details grid
      VStack(spacing: 6) {
        detailRow(label: "From", value: shortAddress(tx.from))
        detailRow(label: "To", value: shortAddress(tx.to))
        detailRow(label: "Block", value: "#\(tx.blockNum)")
        detailRow(label: "Time", value: formattedTimestamp(tx.metadata.blockTimestamp))
      }

      // Bottom row: category + chain
      HStack(spacing: 6) {
        categoryBadge
        Spacer()
        Text("Chain \(tx.chainId)")
          .font(.caption2)
          .foregroundColor(.secondary)
      }
      .padding(.top, 8)
    }
    .padding(14)
    .background(Color(.systemBackground))
    .cornerRadius(12)
    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
  }

  // MARK: - Sub-views

  private var categoryIcon: some View {
    let (iconName, color) = categoryIconInfo
    return ZStack {
      Circle()
        .fill(color.opacity(0.15))
        .frame(width: 38, height: 38)
      Image(systemName: iconName)
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(color)
    }
  }

  private var categoryBadge: some View {
    Text(tx.category.capitalized)
      .font(.caption2)
      .fontWeight(.medium)
      .foregroundColor(categoryIconInfo.1)
      .padding(.horizontal, 8)
      .padding(.vertical, 3)
      .background(categoryIconInfo.1.opacity(0.12))
      .clipShape(Capsule())
  }

  private func detailRow(label: String, value: String) -> some View {
    HStack(alignment: .top) {
      Text(label)
        .font(.caption)
        .foregroundColor(.secondary)
        .frame(width: 40, alignment: .leading)
      Text(value)
        .font(.system(.caption, design: .monospaced))
        .foregroundColor(.primary)
        .lineLimit(1)
        .truncationMode(.middle)
    }
  }

  // MARK: - Helpers

  private var categoryIconInfo: (String, Color) {
    switch tx.category.lowercased() {
    case "external":
      return ("arrow.up.right", .blue)
    case "internal":
      return ("arrow.triangle.2.circlepath", .purple)
    case "erc20":
      return ("dollarsign.circle", .orange)
    case "erc721", "erc1155":
      return ("photo.on.rectangle", .pink)
    case "receive":
      return ("arrow.down.left", .green)
    case "send":
      return ("arrow.up.right", .red)
    default:
      return ("circle.fill", .gray)
    }
  }

  private func shortHash(_ hash: String) -> String {
    guard hash.count > 12 else { return hash }
    return "\(hash.prefix(8))...\(hash.suffix(6))"
  }

  private func shortAddress(_ address: String) -> String {
    guard address.count > 12 else { return address }
    return "\(address.prefix(6))...\(address.suffix(4))"
  }

  private func formattedValue(_ value: Float) -> String {
    if value == 0 { return "0" }
    if value < 0.0001 { return String(format: "%.8f", value) }
    return String(format: "%.4f", value)
  }

  private func valueColor(_ value: Float) -> Color {
    if value > 0 { return .green }
    if value < 0 { return .red }
    return .primary
  }

  private func formattedTimestamp(_ raw: String) -> String {
    let iso = ISO8601DateFormatter()
    iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let date = iso.date(from: raw) {
      return DateFormatter.txDisplay.string(from: date)
    }
    // Fallback without fractional seconds
    let iso2 = ISO8601DateFormatter()
    if let date = iso2.date(from: raw) {
      return DateFormatter.txDisplay.string(from: date)
    }
    return raw
  }
}

// MARK: - DateFormatter

private extension DateFormatter {
  static let txDisplay: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .medium
    f.timeStyle = .short
    return f
  }()
}

#Preview {
  NavigationStack {
    GetTransactionsDemoView()
  }
}
