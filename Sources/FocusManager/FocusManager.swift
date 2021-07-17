import Combine
import SwiftUI

public struct FocusID: Hashable, Equatable {
    fileprivate let id = UUID()
}

public final class FocusManager: ObservableObject {

    private let isDebug: Bool
    private let id = UUID().uuidString.prefix(3)

    private var views: [FocusableViewContext] = []
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
    }

    func update(bounds: CGRect, for id: FocusID) {
        guard let index = views.firstIndex(where: { $0.id == id }) else {
            return
        }
        guard !bounds.isEmpty else {
            debugPrint("[\(views[index].debugTitle)] empty frame. Skipping.")
            return
        }
        views[index].bounds = bounds
        debugPrint("[\(views[index].debugTitle)] updated frame: \(views[index].bounds)")

        if activeIndex == nil, views[index].isDefault {
            select(views[index])
        }
    }

    func registerView(context: FocusableViewContext) {
        debugPrint("Registered view: \(context.debugTitle)")
        guard !views.contains(context) else {
            return
        }
        views.append(context)
    }

    func unregisterView(id: FocusID) {
        guard let index = views.firstIndex(where: { $0.id == id }) else {
            return
        }
        debugPrint("Unregistered view: \(views[index].debugTitle)")
        views.remove(at: index)
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

    private func applyNewSelectionIfNeeded(views: [FocusableViewContext]) {
        guard let activeIndex = activeIndex else {
            return
        }
        let allViews = self.views + views
        if let newSelectedView = allViews.first(where: { $0.isSelected.wrappedValue && $0.id != activeIndex }) {
            select(newSelectedView)
        }
    }

    private func replace(views: [FocusableViewContext]) {
        for view in views {
            self.views.removeAll(where: { $0.id == view.id })
            self.views.append(view)
        }
    }

    private func selectDefault() {
        guard let defaultView = self.views.first(where: { $0.isDefault }) else {
            return
        }
        select(defaultView)
    }

    private func view(withID id: FocusID) -> FocusableViewContext? {
        views.first(where: { $0.id == id })
    }

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
