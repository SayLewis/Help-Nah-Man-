import Observation
import SwiftUI

@MainActor
@Observable
final class AppTheme {
    let paper = Color(red: 0.969, green: 0.949, blue: 0.906)
    let cream = Color(red: 1.0, green: 0.98, blue: 0.945)
    let ink = Color(red: 0.09, green: 0.14, blue: 0.12)
    let muted = Color(red: 0.36, green: 0.42, blue: 0.39)
    let forest = Color(red: 0.082, green: 0.247, blue: 0.20)
    let forestSoft = Color(red: 0.14, green: 0.36, blue: 0.29)
    let coral = Color(red: 0.933, green: 0.408, blue: 0.31)
    let gold = Color(red: 0.941, green: 0.788, blue: 0.365)
    let mint = Color(red: 0.863, green: 0.922, blue: 0.867)

    func kindColor(_ kind: NoticeKind) -> Color {
        switch kind {
        case .volunteer: forestSoft
        case .event: gold
        case .donation: coral
        }
    }
}
