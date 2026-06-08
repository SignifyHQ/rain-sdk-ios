import Testing
import Foundation
import Web3
@testable import RainSDK

@Suite("SolanaConverter")
struct SolanaConverterTests {
  @Test("solToLamports scales by 1e9")
  func scales() throws {
    #expect(try SolanaConverter.solToLamports(1.0) == 1_000_000_000)
    #expect(try SolanaConverter.solToLamports(0.5) == 500_000_000)
    #expect(try SolanaConverter.solToLamports(2.5) == 2_500_000_000)
    #expect(try SolanaConverter.solToLamports(0.0) == 0)
  }

  @Test("solToLamports handles the smallest unit without float drift")
  func noDrift() throws {
    #expect(try SolanaConverter.solToLamports(0.000000001) == 1)
    #expect(try SolanaConverter.solToLamports(0.1) == 100_000_000)
  }

  @Test("solToLamports truncates below one lamport")
  func truncates() throws {
    #expect(try SolanaConverter.solToLamports(0.0000000015) == 1)
  }

  @Test("solToLamports rejects negative amounts")
  func rejectsNegative() {
    #expect(throws: RainSDKError.self) { try SolanaConverter.solToLamports(-1.0) }
  }

  @Test("lamportsToSol divides by 1e9")
  func lamportsToSol() {
    // The Decimal form is exact; the Double form carries inherent floating-point drift.
    #expect(SolanaConverter.lamportsToSol(BigUInt(2_500_000_000)).description == "2.5")
    #expect(SolanaConverter.lamportsToSol(BigUInt(1)).description == "0.000000001")
    #expect(abs(SolanaConverter.lamportsToSolDouble(BigUInt(1)) - 0.000000001) < 1e-15)
  }
}
