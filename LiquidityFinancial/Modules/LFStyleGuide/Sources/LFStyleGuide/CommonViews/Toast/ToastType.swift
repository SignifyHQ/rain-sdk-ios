import SwiftUI

public enum ToastType {
  case error
  case success
  case warning
  
  var defaultTitle: String {
    switch self {
    case .error:
      "Error"
    case .success:
      "Success"
    case .warning:
      "Warning"
    }
  }
  
  var icon: Image {
    switch self {
    case .error:
      GenImages.Images.icoToastError.swiftUIImage
    case .success:
      GenImages.Images.icoToastSuccess.swiftUIImage
    case .warning:
      GenImages.Images.icoToastWarning.swiftUIImage
    }
  }
  
  var tintColor: Color {
    switch self {
    case .error:
      Colors.toastErrorTint.swiftUIColor
    case .success:
      Colors.toastSuccessTint.swiftUIColor
    case .warning:
      Colors.toastWarningTint.swiftUIColor
    }
  }
  
  var backgroundColor: Color {
    switch self {
    case .error:
      Colors.toastErrorBackground.swiftUIColor
    case .success:
      Colors.toastSuccessBackground.swiftUIColor
    case .warning:
      Colors.toastWarningBackground.swiftUIColor
    }
  }
}
