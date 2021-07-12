import SwiftUI

struct FocusableViewContext: Equatable {

    public static func == (lhs: FocusableViewContext, rhs: FocusableViewContext) -> Bool {
        (lhs.id == rhs.id) && (lhs.bounds == rhs.bounds)
    }

    let id: FocusID
    let isDefault: Bool
    let bounds: CGRect
    let isSelected: Binding<Bool>
    let onEvent: (FocusManagerEvent?) -> Void
    let title: String?

    var debugTitle: String {
        title ?? "\(id)"
    }

}
