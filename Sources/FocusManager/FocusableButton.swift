import SwiftUI

public struct FocusableButton<Content: View>: View {

    public let action: () -> Void
    public var title: String? = nil

    @ViewBuilder
    public let content: () -> Content

    public var body: some View {
        content()
            .focusableControl(onAction: action, title: title)
    }

    public init(action: @escaping () -> Void, title: String? = nil, content: @escaping () -> Content) {
        self.action = action
        self.title = title
        self.content = content
    }

}
