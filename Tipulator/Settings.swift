import Foundation
import SwiftUI

class Settings: ObservableObject {
    private static let appearanceModeKey = "AppearanceMode"

    @Published var appearanceMode: AppearanceMode {
        didSet {
            saveAppearanceMode()
        }
    }

    enum AppearanceMode: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"

        var colorScheme: ColorScheme? {
            switch self {
            case .light:
                return .light
            case .dark:
                return .dark
            case .system:
                return nil
            }
        }
    }

    init() {
        self.appearanceMode = Self.loadAppearanceMode()
    }

    private static func loadAppearanceMode() -> AppearanceMode {
        if let savedRawValue = UserDefaults.standard.string(forKey: appearanceModeKey),
           let mode = AppearanceMode(rawValue: savedRawValue) {
            return mode
        }
        return .system
    }

    private func saveAppearanceMode() {
        UserDefaults.standard.set(appearanceMode.rawValue, forKey: Self.appearanceModeKey)
    }
}
