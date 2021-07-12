import Combine
import Foundation
import SwiftUI

public typealias FocusHandler = (Bool) -> Void
public typealias ActionHandler = () -> Void

public struct FocusableView: ViewModifier {

    @State private var id = FocusID()
    @State private var isSelected: Bool = false

    let isDefault: Bool
    let onFocusChange: FocusHandler?
    let onAction: ActionHandler?
    let onContextMenu: ActionHandler?
    let title: String?

    public func body(content: Content) -> some View {
        content
            .border(isSelected ? Color.blue : Color.clear)
            .scaleEffect(isSelected ? 1.1 : 1)
            .anchorPreference(key: BoundsPreferenceKey.self, value: .bounds) { $0 }
            .backgroundPreferenceValue(BoundsPreferenceKey.self) { preferences in
                makePreference()
            }
            .onTapGesture {
                isSelected = true
            }
            .onTapGesture(count: 2) {
                onAction?()
            }
            .onChange(of: isSelected, perform: { value in
                onFocusChange?(isSelected)
            })
    }

    private func makePreference() -> some View {
        GeometryReader { geometry in
            Color.clear.preference(
                key: FocusableViewPreferenceKey.self,
                value: [
                    .init(id: id, isDefault: isDefault, bounds: geometry.frame(in: .global), isSelected: $isSelected, onEvent: onEvent, title: title)
                ]
            )
        }
    }

    private func onEvent(_ event: FocusManagerEvent?) {
        switch event {
        case .action:
            onAction?()
        case .contextMenu:
            onContextMenu?()
        default:
            break
        }
    }

}

private struct BoundsPreferenceKey: PreferenceKey {

    typealias Value = Anchor<CGRect>?

    static var defaultValue: Value = nil

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }

}
