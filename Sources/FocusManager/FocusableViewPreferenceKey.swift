import SwiftUI

struct FocusableViewPreferenceKey: PreferenceKey {

    typealias Value = [FocusableViewContext]

    static var defaultValue: Value = []

    static func reduce(value: inout Value, nextValue: () -> Value) {
        let newValues = nextValue()
        for newValue in newValues {
            if value.contains(newValue) {
                //value.remove(newValue)
            }
            value.append(newValue)
        }
    }

}