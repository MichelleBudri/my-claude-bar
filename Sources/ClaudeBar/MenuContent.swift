import ServiceManagement
import SwiftUI

struct MenuContent: View {
    @ObservedObject var model: UsageModel
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        if let error = model.errorMessage {
            Text("⚠️ \(error)")
        }
        if let usage = model.usage {
            usageRow("Sessão (5h)", usage.session)
            usageRow("Semanal (7 dias)", usage.weekly)
        }
        if let lastUpdated = model.lastUpdated {
            Text("Atualizado às \(lastUpdated.formatted(date: .omitted, time: .shortened))")
        }

        Divider()

        Button("Atualizar agora", action: model.refresh)
            .keyboardShortcut("r")
        Toggle("Abrir ao iniciar sessão", isOn: $launchAtLogin)
            .onChange(of: launchAtLogin, perform: setLaunchAtLogin)
        Button("Sair") { NSApplication.shared.terminate(nil) }
            .keyboardShortcut("q")
    }

    @ViewBuilder
    private func usageRow(_ title: String, _ window: UsageWindow?) -> some View {
        if let window {
            let indicator = UsageLevel(percent: window.percent).indicator
            let reset = window.resetsAt.map { " - renova \($0.formatted(.relative(presentation: .named)))" } ?? ""
            Text("\(indicator)\(title): \(window.percent)%\(reset)")
        }
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
}
