import XCTest
import SwiftUI
@testable import LFUtilities

final class DIContainerAnyViewTests: XCTestCase {
  
  let container = DIContainerAnyView()
  
  /*** Test the DIContainer clear functional
   * Test case: after register a type of view with a name, then clear it, the instance should be nil
   * Input: Register a view, then use clear
   * Expectation: the instance of with correct key should be nil
   */
  func testClearFunction() throws {
    let name = "TestView"
    let key = "\(EmptyView.self)\(name)"
    container.register(type: EmptyView.self, name: name) { _ in
      AnyView(EmptyView())
    }
    container.clear(type: EmptyView.self, name: name)
    let service = container.services[key]
    assert(service?.instance == nil)
  }
  
}
