//
//  RecordingTheme.swift
//  Type4Me
//

import Foundation
import SwiftUI

/// Appearance theme for the floating recording indicator and related overlays.
enum RecordingTheme: String, CaseIterable, Identifiable {
    case system
    case dark
    case light

    var id: String { rawValue }

    static let storageKey = "tf_recordingTheme"
    static let defaultValue = RecordingTheme.dark

    /// Resolve before passing a theme to rendering components. Never inherit the
    /// Settings window's overridden color scheme for the embedded preview.
    func resolved(systemIsDark: Bool) -> RecordingTheme {
        self == .system ? (systemIsDark ? .dark : .light) : self
    }

    var appearance: NSAppearance? {
        switch self {
        case .system: nil
        case .dark: NSAppearance(named: .darkAqua)
        case .light: NSAppearance(named: .aqua)
        }
    }

    var displayName: String { displayName(language: AppLanguage.current) }

    func displayName(language: AppLanguage) -> String {
        switch self {
        case .system: language == .zh ? "跟随系统" : "Follow System"
        case .dark: language == .zh ? "暗色" : "Dark"
        case .light: language == .zh ? "明亮" : "Light"
        }
    }
}

/// Observe app-level appearance rather than a window that may have a theme override.
@MainActor
final class RecordingSystemAppearance: ObservableObject {
    static let shared = RecordingSystemAppearance()
    @Published private(set) var isDark: Bool
    private var observation: NSKeyValueObservation?

    private init() {
        isDark = NSApplication.shared.effectiveAppearance.isDark
        observation = NSApplication.shared.observe(\.effectiveAppearance, options: [.new]) { [weak self] _, _ in
            Task { @MainActor [weak self] in
                self?.isDark = NSApplication.shared.effectiveAppearance.isDark
            }
        }
    }
}
