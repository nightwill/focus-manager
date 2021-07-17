import Combine
import Foundation
import SwiftUI

public typealias FocusHandler = (Bool) -> Void
public typealias ActionHandler = () -> Void

public struct FocusableView: ViewModifier {

    @State private var id = FocusID()
    @State private var isSelected: Bool = false

    @EnvironmentObject var focusManager: FocusManager

    let isDefault: Bool
    let onFocusChange: FocusHandler?
    let onAction: ActionHandler?
    let onContextMenu: ActionHandler?
    let title: String?

    public func body(content: Content) -> some View {
        content
            //.anchorPreference(key: BoundsPreferenceKey.self, value: .bounds) { $0 }
//            .backgroundPreferenceValue(BoundsPreferenceKey.self) { preferences in
//                GeometryReader { geometry in
//                    updateViewBounds(geometry: geometry)
//                }
//            }

            .onTapGesture {
                isSelected = true
            }
            .onTapGesture(count: 2) {
                onAction?()
            }
            .onChange(of: isSelected, perform: { value in
                onFocusChange?(isSelected)
            })
            .onAppear {
                focusManager.registerView(
                    context: .init(id: id, isDefault: isDefault, isSelected: $isSelected, onEvent: onEvent, title: title)
                )
            }
            .onDisappear {
                focusManager.unregisterView(id: id)
            }
            .background(
                GeometryReader { geometry in
                    updateViewBounds(geometry: geometry)
                }
            )
    }

    private func updateViewBounds(geometry: GeometryProxy) -> some View {
        focusManager.update(bounds: geometry.frame(in: .global), for: id)
        return Color.clear
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
