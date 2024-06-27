// sourcery: AutoMockable
public protocol PendingTransactionParametersEntity {
  var transactionHash: String { get }
  var chainId: String { get }
  var fromAddress: String { get }
  var toAddress: String { get }
  var amount: Double { get }
  var currency: String { get }
  var status: String { get }
  var contractAddress: String? { get }
  var decimal: Int { get }
  var gasPrice: Double { get }
  var gasUsed: Double { get }
  var transactionFee: Double { get }
}
