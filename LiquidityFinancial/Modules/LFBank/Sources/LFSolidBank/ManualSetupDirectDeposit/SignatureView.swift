import SwiftUI
import CoreGraphics
import UIKit
import LFLocalizable
import LFUtilities
import LFStyleGuide
import LFServices

struct SignatureView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject var viewModel: ManualSetupViewModel
  @State private var toastMessage: String?
  @State private var drawing = DrawingPath()
  @State private var isNavigateToSuccessView = false
  private let maxHeight: CGFloat = 240
  private let lineWidth: CGFloat = 5
  
  var body: some View {
    VStack(spacing: 10) {
      Spacer()
      SignatureDrawView(drawing: $drawing)
      HStack {
        FullSizeButton(title: LFLocalizable.Button.Back.title, isDisable: false, type: .secondary) {
          dismiss()
        }
        FullSizeButton(title: LFLocalizable.Button.Continue.title, isDisable: false) {
          extractImageAndHandle()
          if viewModel.signatureImage != nil {
            isNavigateToSuccessView = true
          } else {
            toastMessage = LFLocalizable.DirectDeposit.Signature.toastMessage
          }
        }
      }
      Spacer()
    }
    .popup(item: $toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .padding(.horizontal, 30)
    .background(Colors.background.swiftUIColor)
    .navigationLink(isActive: $isNavigateToSuccessView) {
      AddSignatureSuccessView(viewModel: viewModel)
    }
    .navigationBarHidden(true)
    .track(name: String(describing: type(of: self)))
  }
  
  private func extractImageAndHandle() {
    let image: UIImage
    let path = drawing.cgPath
    let maxX = drawing.points.map(\.x).max() ?? 0
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: maxX, height: maxHeight))
    let uiImage = renderer.image { ctx in
      ctx.cgContext.setStrokeColor(Colors.primary.color.cgColor)
      ctx.cgContext.setLineWidth(lineWidth)
      ctx.cgContext.beginPath()
      ctx.cgContext.addPath(path)
      ctx.cgContext.drawPath(using: .stroke)
    }
    
    image = uiImage
    if let data = image.pngData() {
      viewModel.signatureImage = data
    }
  }
}

struct SignatureDrawView: View {
  @Binding var drawing: DrawingPath
  @State private var drawingBounds: CGRect = .zero
  private let maxHeight: CGFloat = 240
  private let lineWidth: CGFloat = 5

  var body: some View {
    ZStack(alignment: .top) {
      Colors.background.swiftUIColor
        .background(
          GeometryReader { geometry in
            Color.clear.preference(
              key: FramePreferenceKey.self,
              value: geometry.frame(in: .local)
            )
          }
        )
        .onPreferenceChange(FramePreferenceKey.self) { bounds in
          drawingBounds = bounds
        }
      if drawing.isEmpty {
        Text(LFLocalizable.DirectDeposit.AddSignature.placeholder)
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
          .font(Fonts.regular.swiftUIFont(size: 44))
          .frame(maxWidth: .infinity, alignment: .center)
          .padding(.top, abs(maxHeight / 2))
      } else {
        DrawShape(drawingPath: drawing)
          .stroke(lineWidth: lineWidth)
          .foregroundColor(Colors.primary.swiftUIColor)
      }
      
      VStack {
        Button {
          clear()
        } label: {
          CircleButton(style: .xmark)
        }
        .frame(maxWidth: .infinity, alignment: .topTrailing)
        .padding(.top, 10)
        .padding(.trailing, 20)
      }
      .frame(maxWidth: .infinity, alignment: .topTrailing)
    }
    .frame(height: maxHeight)
    .gesture(DragGesture()
      .onChanged { value in
        if drawingBounds.contains(value.location) {
          drawing.addPoint(value.location)
        } else {
          drawing.addBreak()
        }
      }
      .onEnded { _ in
        drawing.addBreak()
      }
    )
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(
          Colors.label.swiftUIColor.opacity(0.25),
          style: StrokeStyle(lineWidth: 1, dash: [5])
        )
    )
  }
  
  private func clear() {
    drawing = DrawingPath()
  }
}

// MARK: - FramePreferenceKey

struct FramePreferenceKey: PreferenceKey {
  static var defaultValue: CGRect = .zero
  
  static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
    value = nextValue()
  }
}

// MARK: - DrawingPath

struct DrawingPath {
  private(set) var points = [CGPoint]()
  private var breaks = [Int]()
  
  var isEmpty: Bool {
    points.isEmpty
  }
  
  var cgPath: CGPath {
    let path = CGMutablePath()
    guard let firstPoint = points.first else { return path }
    path.move(to: firstPoint)
    (1 ..< points.count).forEach { index in
      if breaks.contains(index) {
        path.move(to: points[index])
      } else {
        path.addLine(to: points[index])
      }
    }
    return path
  }
  
  var path: Path {
    var path = Path()
    guard let firstPoint = points.first else { return path }
    path.move(to: firstPoint)
    (1 ..< points.count).forEach { index in
      if breaks.contains(index) {
        path.move(to: points[index])
      } else {
        path.addLine(to: points[index])
      }
    }
    return path
  }
  
  mutating func addPoint(_ point: CGPoint) {
    points.append(point)
  }
  
  mutating func addBreak() {
    breaks.append(points.count)
  }
}

struct DrawShape: Shape {
  let drawingPath: DrawingPath
  
  func path(in _: CGRect) -> Path {
    drawingPath.path
  }
}
