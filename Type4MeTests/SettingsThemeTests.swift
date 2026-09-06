import AppKit
import SwiftUI
import XCTest
@testable import Type4Me

final class SettingsThemeTests: XCTestCase {
    func testDefaultAndUnknownPreferenceFollowSystem() {
        XCTAssertEqual(SettingsTheme.defaultValue, .system)
        XCTAssertEqual(SettingsTheme.resolve("future-value"), .system)
        XCTAssertNil(SettingsTheme.system.colorScheme)
        XCTAssertNil(SettingsTheme.system.appearance)
        XCTAssertNotEqual(SettingsTheme.storageKey, RecordingTheme.storageKey)
    }

    func testExplicitThemesOverrideAppearance() {
        XCTAssertEqual(SettingsTheme.light.colorScheme, .light)
        XCTAssertEqual(SettingsTheme.dark.colorScheme, .dark)
        XCTAssertEqual(SettingsTheme.light.appearance?.bestMatch(from: [.aqua, .darkAqua]), .aqua)
        XCTAssertEqual(SettingsTheme.dark.appearance?.bestMatch(from: [.aqua, .darkAqua]), .darkAqua)
    }

    func testLabelsCanSwitchLanguageWithoutChangingSavedValues() {
        let themes = SettingsTheme.allCases
        let savedValues = themes.map(\.rawValue)
        XCTAssertEqual(themes.map { $0.displayName(language: .zh) }, ["跟随系统", "浅色", "深色"])
        XCTAssertEqual(themes.map { $0.displayName(language: .en) }, ["Follow System", "Light", "Dark"])
        XCTAssertEqual(themes.map { $0.displayName(language: .zh) }, ["跟随系统", "浅色", "深色"])
        XCTAssertEqual(savedValues.map(SettingsTheme.resolve), themes)
    }

    func testSettingsTextAndSolidButtonContrastInBothAppearances() {
        let surfaces = [TF.settingsWindowBackground, TF.settingsBg, TF.settingsCard,
                        TF.settingsCardAlt, TF.settingsSidebar, TF.settingsControl]
        let textColors = [TF.settingsText, TF.settingsTextSecondary, TF.settingsTextTertiary,
                          TF.settingsAccentBlue, TF.settingsAccentGreen,
                          TF.settingsAccentAmber, TF.settingsAccentRed]
        for name in [NSAppearance.Name.aqua, .darkAqua] {
            let appearance = NSAppearance(named: name)!
            for surface in surfaces {
                for text in textColors {
                    XCTAssertGreaterThanOrEqual(contrast(text, surface, appearance), 4.5,
                                                "Text contrast under \(name)")
                }
            }
            for fill in [TF.settingsText, TF.settingsNavActive, TF.settingsAccentBlue,
                         TF.settingsAccentGreen, TF.settingsAccentAmber, TF.settingsAccentRed] {
                XCTAssertGreaterThanOrEqual(contrast(TF.settingsOnStrong, fill, appearance), 4.5,
                                            "Button contrast under \(name)")
            }
        }
    }

    private func contrast(_ first: Color, _ second: Color, _ appearance: NSAppearance) -> Double {
        func luminance(_ color: Color) -> Double {
            var result = 0.0
            appearance.performAsCurrentDrawingAppearance {
                let rgb = NSColor(color).usingColorSpace(.sRGB)!
                func linear(_ value: CGFloat) -> Double {
                    let value = Double(value)
                    return value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
                }
                result = 0.2126 * linear(rgb.redComponent)
                    + 0.7152 * linear(rgb.greenComponent) + 0.0722 * linear(rgb.blueComponent)
            }
            return result
        }
        let a = luminance(first), b = luminance(second)
        return (max(a, b) + 0.05) / (min(a, b) + 0.05)
    }
}
