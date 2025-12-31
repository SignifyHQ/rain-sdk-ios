import Foundation

extension CGFloat {
  public static func dropdownHeight(
    rowCount: Int,
    rowHeight: CGFloat,
    headerHeight: CGFloat = 0,
    footerHeight: CGFloat = 0,
    emptyViewHeight: CGFloat = 0,
    fallbackOveralHeight: CGFloat
  ) -> CGFloat {
    guard rowCount > 0
    else {
      return headerHeight + emptyViewHeight + footerHeight
    }
    
    let listHeight = CGFloat(rowCount) * rowHeight
    
    return Swift.min(listHeight + headerHeight + footerHeight, fallbackOveralHeight)
  }
}
