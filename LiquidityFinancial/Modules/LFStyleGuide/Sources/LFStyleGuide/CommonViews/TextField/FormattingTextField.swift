import SwiftUI
import LFUtilities

public struct FormattingTextField: View {
  var value: Binding<String>
  let formatters: [TextFormatter]
  let isSecure: Bool
  
  public init(
    value: Binding<String>,
    formatters: [TextFormatter],
    isSecure: Bool = false
  ) {
    self.formatters = formatters
    self.value = value
    self.isSecure = isSecure
  }

  public var body: some View {
    if isSecure {
      SecureField("", text: value)
        .onChange(of: value.wrappedValue) { newValue in
          value.wrappedValue = format(value: newValue)
        }
    } else {
      TextField("", text: value)
        .onChange(of: value.wrappedValue) { newValue in
          value.wrappedValue = format(value: newValue)
        }
    }
  }

  private func format(value: String) -> String {
    var formatted = value
    formatters.forEach { formatter in
      formatted = formatter.format(text: formatted)
    }
    return formatted
  }
}

// MARK: - TextFormatter

public protocol TextFormatter {
  func format(text: String) -> String
}

// MARK: - TextLimitFormatter
public struct TextLimitFormatter: TextFormatter {
  let limit: Int
  
  public init(limit: Int) {
    self.limit = limit
  }

  public func format(text: String) -> String {
    String(text.prefix(limit))
  }
}

// MARK: - CardFormatter
public struct CardFormatter: TextFormatter {
  public init() {}
  
  public func format(text: String) -> String {
    String(text.removeWhitespace().inserting(separator: " ", every: 4))
  }
}

// MARK: - ExpirationFormatter
public struct ExpirationFormatter: TextFormatter {
  public init() {}
  
  public func format(text: String) -> String {
    String(text.removeWhitespace().inserting(separator: " / ", every: 2))
  }
}

// MARK: - RestrictionFormatter
public struct RestrictionFormatter: TextFormatter {
  let restriction: TextRestriction

  public init(restriction: TextRestriction) {
    self.restriction = restriction
  }
  
  public func format(text: String) -> String {
    text.filter { restriction.allowedInput.contains($0) }
  }
}

// MARK: Regex
public struct DecimalFormatter: TextFormatter {
  public init() {}
  
  public func format(text: String) -> String {
    let filtered = text.filter { "0123456789.".contains($0) }
    
    if filtered.contains(".") {
      let splitted = filtered.split(separator: ".")
      if splitted.count >= 2 {
        let preDecimal = String(splitted[0])
        let afterDecimal = String(splitted[1])
        return "\(preDecimal).\(afterDecimal)"
      }
    }
    return filtered
  }
}
