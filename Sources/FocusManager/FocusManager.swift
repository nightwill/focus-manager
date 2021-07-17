import Combine
import SwiftUI

public struct FocusID: Hashable, Equatable {
    fileprivate let id = UUID()
}

public final class FocusManager: ObservableObject {

    private let isDebug: Bool
    private let id = UUID().uuidString.prefix(3)

    private var views: Set<FocusableViewContext> = []
    private var activeIndex: FocusID?

    private var selectedView: FocusableViewContext? {
        guard let activeIndex = activeIndex else {
            return nil
        }
        return views.first(where: { $0.id == activeIndex })
    }

    public init(isDebug: Bool = false) {
        self.isDebug = isDebug
    }

    public func reset() {
        activeIndex = nil
        views.removeAll()
    }

    func update(context: FocusableViewContext) {
        guard !context.bounds.isEmpty else {
            debugPrint("[\(context.debugTitle)] empty frame. Skipping.")
            return
        }

        views.remove(context)
        views.insert(context)

        debugPrint("[\(context.debugTitle)] updated frame: \(context.bounds)")

        if activeIndex == nil, context.isDefault {
            select(context)
        }
    }

    public func selectNextTop() {
        guard let rect = selectedView?.bounds else { return }
        let availableViews = views.filter { rect.minY > $0.bounds.minY  }
        guard let nextRowMinY = availableViews.map(\.bounds.minY).max() else { return }
        let nextRowViews = availableViews.filter { $0.bounds.maxY > nextRowMinY }
        let sortedByDistanceRowViews = nextRowViews.sorted(by: { lhs, rhs in abs(lhs.bounds.midX - rect.midX) < abs(rhs.bounds.midX - rect.midX) })
        guard let nextView = sortedByDistanceRowViews.first else { return }
        select(nextView)
    }

    public func selectNextBottom() {
        guard let rect = selectedView?.bounds else { return }
        let availableViews = views.filter { rect.minY < $0.bounds.minY }
        guard let nextRowMaxY = availableViews.map(\.bounds.maxY).min() else { return }
        let nextRowViews = availableViews.filter { $0.bounds.minY < nextRowMaxY }
        let sortedByDistanceRowViews = nextRowViews.sorted(by: { lhs, rhs in abs(lhs.bounds.midX - rect.midX) < abs(rhs.bounds.midX - rect.midX) })
        guard let nextView = sortedByDistanceRowViews.first else { return }
        select(nextView)
    }

    public func selectNextLeft() {
        guard let rect = selectedView?.bounds else { return }
        let availableViews = views.filter { rect.minX > $0.bounds.minX  }
        guard let nextRowMinX = availableViews.map(\.bounds.minX).max() else { return }
        let nextRowViews = availableViews.filter { $0.bounds.maxX > nextRowMinX }
        let sortedByDistanceRowViews = nextRowViews.sorted(by: { lhs, rhs in abs(lhs.bounds.midY - rect.midY) < abs(rhs.bounds.midY - rect.midY) })
        guard let nextView = sortedByDistanceRowViews.first else { return }
        select(nextView)
    }

    public func selectNextRight() {
        guard let rect = selectedView?.bounds else { return }
        let availableViews = views.filter { rect.minX < $0.bounds.minX  }
        guard let nextRowMaxX = availableViews.map(\.bounds.maxX).max() else { return }
        let nextRowViews = availableViews.filter { $0.bounds.minX < nextRowMaxX }
        let sortedByDistanceRowViews = nextRowViews.sorted(by: { lhs, rhs in abs(lhs.bounds.midY - rect.midY) < abs(rhs.bounds.midY - rect.midY) })
        guard let nextView = sortedByDistanceRowViews.first else { return }
        select(nextView)
    }

    public func action() {
        selectedView?.onEvent(.action)
    }

    public func contextMenu() {
        selectedView?.onEvent(.contextMenu)
    }

}

// MARK: - Private Methods
extension FocusManager {

    private func select(_ nextView: FocusableViewContext) {
        if let selectedView = selectedView {
            debugPrint("[\(selectedView.debugTitle)] will be unselected")
            selectedView.isSelected.wrappedValue = false
        }

        debugPrint("[\(nextView.debugTitle)] will be selected")
        self.activeIndex = nextView.id
        DispatchQueue.main.async {
            nextView.isSelected.wrappedValue = true
        }
    }

    private func debugPrint(_ message: String) {
        guard isDebug else {
            return
        }
        print(id, message)
    }

}
