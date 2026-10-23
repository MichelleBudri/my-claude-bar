import SwiftUI

enum UsageLevel {
    case normal, warning, critical

    init(percent: Int) {
        switch percent {
        case 81...: self = .critical
        case 51...: self = .warning
        default: self = .normal
        }
    }

    var color: Color? {
        switch self {
        case .normal: nil
        case .warning: .yellow
        case .critical: .red
        }
    }

    var indicator: String {
        switch self {
        case .normal: ""
        case .warning: "🟡 "
        case .critical: "🔴 "
        }
    }
}
