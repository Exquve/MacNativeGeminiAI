import Foundation

enum GeminiModel: String, CaseIterable, Identifiable {
    case pro25       = "gemini-2.5-pro"
    case flash25     = "gemini-2.5-flash"
    case flashLite25 = "gemini-2.5-flash-lite"
    case pro31       = "gemini-3.1-pro-preview"
    case flash3      = "gemini-3-flash-preview"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pro25:       "Gemini 2.5 Pro"
        case .flash25:     "Gemini 2.5 Flash"
        case .flashLite25: "Gemini 2.5 Flash Lite"
        case .pro31:       "Gemini 3.1 Pro Preview"
        case .flash3:      "Gemini 3 Flash Preview"
        }
    }
}
