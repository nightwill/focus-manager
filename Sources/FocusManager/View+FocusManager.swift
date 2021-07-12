import SwiftUI

extension View {

    @ViewBuilder
    public func focusableControl(
        isDefault: Bool = false,
        onFocusChange: FocusHandler? = nil,
        onAction: ActionHandler? = nil,
        onContextMenu: ActionHandler? = nil,
        title: String? = nil
    ) -> some View {
        self.modifier(FocusableView(isDefault: isDefault, onFocusChange: onFocusChange, onAction: onAction, onContextMenu: onContextMenu, title: title))
    }

    public func attach(manager: FocusManager) -> some View {
        self.onPreferenceChange(FocusableViewPreferenceKey.self, perform: { value in
            manager.update(views: value)
        })
    }

}
