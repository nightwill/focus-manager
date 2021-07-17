import SwiftUI

struct FocusableViewContext: Equatable, Hashable {

    public static func == (lhs: FocusableViewContext, rhs: FocusableViewContext) -> Bool {
        (lhs.id == rhs.id)
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

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
