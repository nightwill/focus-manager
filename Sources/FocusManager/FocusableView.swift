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
            .background(
                GeometryReader { geometry in
                    updateViewBounds(geometry: geometry)
                }
            )
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

    private func updateViewBounds(geometry: GeometryProxy) -> some View {
        let context = FocusableViewContext(
            id: id,
            isDefault: isDefault,
            bounds: geometry.frame(in: .global),
            isSelected: $isSelected,
            onEvent: onEvent,
            title: title
        )
        focusManager.update(context: context)
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
