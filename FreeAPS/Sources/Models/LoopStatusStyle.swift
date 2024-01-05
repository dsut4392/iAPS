import Foundation

enum LoopStatusStyle: String, JSON, CaseIterable, Identifiable, Codable {
    var id: String { rawValue }
    case circle
    case bar
    

    var displayName: String {
        switch self {
        case .circle:
            return NSLocalizedString("Circle", comment: "")
        case .bar:
            return NSLocalizedString("Bar", comment: "")
        }
    }
}
