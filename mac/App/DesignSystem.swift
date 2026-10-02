import AppKit
import CoreText
import SwiftUI

enum AppStyle {
    static let canvas = Color("Canvas")
    static let panel = Color("Panel")
    static let ink = Color("Ink")
    static let secondary = Color("Secondary")
    static let accent = Color("AccentColor")
    static let onAccent = Color("OnAccent")
    static let gold = Color("Gold")
    static let rule = Color.primary.opacity(0.10)
    static func tamil(_ size: CGFloat) -> Font { .custom("NotoSerifTamil-Regular", size: size) }

    static func registerFonts() {
        guard let url = Bundle.main.url(forResource: "NotoSerifTamil-Regular", withExtension: "ttf") else { return }
        // Process-local registration; no installation into the user's font library.
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }
}

extension Appearance {
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct GarlandMark: View {
    var body: some View {
        Canvas { context, size in
            let scale = min(size.width / 40, size.height / 44)
            var outer = Path()
            outer.move(to: CGPoint(x: 9, y: 5))
            outer.addLine(to: CGPoint(x: 9, y: 24))
            outer.addCurve(to: CGPoint(x: 31, y: 24),
                           control1: CGPoint(x: 9, y: 44), control2: CGPoint(x: 31, y: 44))
            outer.addLine(to: CGPoint(x: 31, y: 5))
            var inner = Path()
            inner.move(to: CGPoint(x: 14, y: 8))
            inner.addLine(to: CGPoint(x: 14, y: 24))
            inner.addCurve(to: CGPoint(x: 26, y: 24),
                           control1: CGPoint(x: 14, y: 37), control2: CGPoint(x: 26, y: 37))
            inner.addLine(to: CGPoint(x: 26, y: 8))
            var stem = Path()
            stem.move(to: CGPoint(x: 20, y: 4))
            stem.addLine(to: CGPoint(x: 20, y: 26))
            let transform = CGAffineTransform(scaleX: scale, y: scale)
            context.stroke(outer.applying(transform), with: .color(AppStyle.gold), lineWidth: 1.4 * scale)
            context.stroke(inner.applying(transform), with: .color(AppStyle.gold), lineWidth: 1.4 * scale)
            context.stroke(stem.applying(transform), with: .color(AppStyle.gold), lineWidth: 2.2 * scale)
        }
        .accessibilityHidden(true)
    }
}

struct Eyebrow: View {
    let text: String
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .semibold))
            .tracking(1.4)
            .foregroundStyle(AppStyle.gold)
    }
}

struct FilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .padding(.horizontal, 18).padding(.vertical, 11)
            .foregroundStyle(AppStyle.onAccent)
            .background(AppStyle.accent.opacity(configuration.isPressed ? 0.8 : 1), in: RoundedRectangle(cornerRadius: 7))
    }
}

struct EmptyLibraryView: View {
    let title: String
    let description: String
    let action: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed").font(.system(size: 30, weight: .light)).foregroundStyle(AppStyle.gold)
            Text(title).font(.system(size: 23, design: .serif))
            Text(description).foregroundStyle(AppStyle.secondary).multilineTextAlignment(.center)
            Button("Show all verses", action: action).buttonStyle(.bordered)
        }
        .padding(40).frame(maxWidth: .infinity)
    }
}
