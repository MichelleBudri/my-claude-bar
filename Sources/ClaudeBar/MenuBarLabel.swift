import SwiftUI

struct MenuBarLabel: View {
    let title: String
    let level: UsageLevel

    var body: some View {
        if let color = level.color, let image = coloredImage(color) {
            Image(nsImage: image)
        } else {
            content
        }
    }

    private var content: some View {
        HStack(spacing: 3) {
            Image(nsImage: ClaudeIcon.image())
                .renderingMode(.template)
            Text(title)
                .monospacedDigit()
        }
    }

    // The menu bar ignores colors in labels, so colored states are drawn into a
    // non-template image.
    @MainActor
    private func coloredImage(_ color: Color) -> NSImage? {
        let renderer = ImageRenderer(content: content
            .font(.system(size: NSFont.systemFontSize, weight: .medium))
            .foregroundStyle(color))
        renderer.scale = NSScreen.main?.backingScaleFactor ?? 2

        let image = renderer.nsImage
        image?.isTemplate = false
        return image
    }
}
