import SwiftUI

@main
struct ClaudeBarApp: App {
    @StateObject private var model = UsageModel()

    var body: some Scene {
        MenuBarExtra {
            MenuContent(model: model)
        } label: {
            MenuBarLabel(title: model.menuBarTitle, level: model.level)
        }
    }
}
