import SwiftData
import SwiftUI

// TODO: Add dashboard view to track goals and progress
// TODO: Add haptics and animations
// TODO: Add welcome screen for new users

// FIXME: Debug warning:
// containerToPush is nil, will not push anything to candidate receiver for request token: BF2ABD30

// FIXME: Debug info:
// void * _Nullable NSMapGet(NSMapTable * _Nonnull, const void * _Nullable): map table argument is NULL

struct AppView: View {
    @AppStorage(.theme)
    internal var theme: AppTheme
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @AppLocale private var locale

    @Environment(\.healthKit)
    private var healthKitService

    @State private var activeDataModel: HealthDataModel? = nil

    var body: some View {
        TabView {
            Tab("Dashboard", systemImage: "chart.bar.xaxis") {
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

        .onAppear {
            healthKitService.requestAuthorization()
        }

        .transform {
            if #available(iOS 26, macOS 26, watchOS 26, *) {
                #if os(iOS)
                    $0.tabViewBottomAccessory {
                        HStack(alignment: .bottom, spacing: 0) {
                            AddButton(HealthDataModel.calorie.definition) {
                                activeDataModel = .calorie
                            }
                            AddButton(HealthDataModel.weight.definition) {
                                activeDataModel = .weight
                            }
                        }
                    }
                    .tabBarMinimizeBehavior(.onScrollDown)
                #endif
            } else {
                $0.overlay(alignment: .bottomTrailing) {
                    AddMenu { dataModel in
                        activeDataModel = dataModel
                    }
                    .padding(.bottom, 64)
                }
            }
        }

        .sheet(item: $activeDataModel) { dataModel in
            NavigationStack {
                dataModel.createForm(formType: .create)
            }
        }
    }
}
