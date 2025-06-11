import SwiftData
import SwiftUI

// TODO: Add dashboard view to track goals and progress
// TODO: Add haptics and animations
// TODO: Add welcome screen for new users

struct AppView: View {
    @AppStorage(.theme)
    internal var theme: AppTheme
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @AppLocale private var locale

    @State private var activeDataModel: HealthDataModel? = nil

    var body: some View {
        TabView {
            Tab("Dashboard", systemImage: "chart.xyaxis.line") {
                DashboardView()
            }
            Tab("Data", systemImage: "heart.text.clipboard.fill") {
                HealthDataView()
            }
            Tab("Settings", systemImage: "gear") {
                SettingsView()
            }
        }
        .environment(\.locale, self.locale)
        .preferredColorScheme(self.theme.colorScheme)

        .animation(.default, value: self.theme)
        .animation(.default, value: self.colorScheme)
        .animation(.default, value: self.locale)

        .contentTransition(.symbolEffect(.replace))
        .contentTransition(.numericText())
        .contentTransition(.opacity)

        #if os(iOS)
            .transform {
                if #available(iOS 26, macOS 26, watchOS 26, *) {
                    $0.tabViewBottomAccessory {
                        HStack(spacing: 16) {
                            AddButtons { dataModel in
                                activeDataModel = dataModel
                            }
                            .labelStyle(.titleAndIcon)
                            .buttonStyle(.glass)
                        }
                    }
                } else {
                    $0.overlay(alignment: .bottom) {
                        AddMenu { dataModel in
                            activeDataModel = dataModel
                        }
                        .buttonStyle(.borderless)
                        .padding(.bottom, 64)
                    }
                }
            }
        #endif

        .sheet(item: $activeDataModel) { dataModel in
            NavigationStack {
                dataModel.createNewRecordForm()
            }
        }
    }
}

struct AddButtons: View {
    let action: (HealthDataModel) -> Void
    var body: some View {
        ForEach(
            HealthDataModel.allCases, id: \.self
        ) { dataModel in
            Button(action: { action(dataModel) }) {
                Label {
                    Text(String(localized: dataModel.uiDefinition.title))
                } icon: {
                    dataModel.uiDefinition.icon
                }
            }
            .transform {
                if #available(iOS 26, macOS 26, watchOS 26, *) {
                    $0.glassEffect(
                        .regular.tint(dataModel.uiDefinition.color)
                    )
                } else {
                    $0.foregroundStyle(dataModel.uiDefinition.color)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct AddMenu: View {
    let action: (HealthDataModel) -> Void
    init(_ action: @escaping (HealthDataModel) -> Void) {
        self.action = action
    }

    var body: some View {
        Menu {
            ForEach(
                HealthDataModel.allCases, id: \.self
            ) { dataModel in
                Button(action: { action(dataModel) }) {
                    Label {
                        Text(
                            String(
                                localized: dataModel.uiDefinition.title
                            )
                        )
                    } icon: {
                        dataModel.uiDefinition.icon
                    }
                }
            }
        } label: {
            Button {
            } label: {
                Label("Add Data", systemImage: "plus.circle.fill")
                    .labelStyle(.iconOnly)
                    .font(.system(size: 48))
            }
        }
        .buttonBorderShape(.circle)
    }
}
