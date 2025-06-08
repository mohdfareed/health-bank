import HealthKit
import SwiftUI

struct AboutView: View {
    @Environment(\.healthKit) private var healthKit

    var body: some View {
        NavigationStack {
            Form {
                // Apple Health Integration
                Section {
                    // Apple Health Header
                    HStack(spacing: 16) {
                        Image.appleHealthLogo
                            .frame(height: 48)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Apple Health Integration")
                                .font(.headline)
                                .fontWeight(.medium)
                            Text(
                                """
                                This app integrates with Apple Health to track and manage your health data.
                                """
                            )
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        }
                    }

                    // Privacy Information
                    Text(
                        """
                        Health data is stored and managed by Apple Health.
                        This app does not collect or store personal health information.
                        You can manage app data and permissions in Apple Health:
                        Settings > Apps > Health > Data Access & Devices > \(AppName)
                        """
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }.listRowSeparator(.hidden)

                // Credits & Licenses Section
                Section {
                    CreditRow(
                        service: "SF Symbols",
                        description: "System icons by Apple",
                        url: "https://developer.apple.com/sf-symbols/"
                    )
                    CreditRow(
                        service: "Icons8",
                        description: "Custom app icons and symbols",
                        url: "https://icons8.com"
                    )
                } header: {
                    Text("Credits & Licenses")
                }

                // App Information Section
                Section {
                    AppInfoRow(
                        title: "Version",
                        value: appVersion,
                        systemImage: "app.badge"
                    )

                    AppInfoRow(
                        title: "Build",
                        value: buildNumber,
                        systemImage: "hammer"
                    )

                    AppInfoRow(
                        title: "Developer",
                        value: "Mohammed Fareed",
                        systemImage: "person.circle"
                    )
                } header: {
                    Text("App Information")
                }

                // Source Code Section
                Section {
                    Link(destination: URL(string: RepoURL)!) {
                        LabeledContent {
                            Image(systemName: "arrow.up.right")
                                .foregroundStyle(Color.accent)
                        } label: {
                            Label(
                                "Source Code",
                                systemImage: "chevron.left.slash.chevron.right"
                            )
                        }
                    }
                }
            }
            .navigationTitle("About")
        }
    }

    // MARK: - Helper Properties

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            ?? "Unknown"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String
            ?? "Unknown"
    }
}

// MARK: - Supporting Views

struct AppInfoRow: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        LabeledContent {
            Text(value)
        } label: {
            Label {
                Text(title)
            } icon: {
                Image(systemName: systemImage)
            }
        }
    }
}

struct CreditRow: View {
    let service: String
    let description: String?
    let url: String

    var body: some View {
        Link(destination: URL(string: url)!) {
            LabeledContent {
                Image(systemName: "arrow.up.right")
            } label: {
                Text(service)
                if let description = description {
                    Text(description)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct HealthPermissionsManager: View {
    let service: HealthKitService

    var body: some View {
        Button {
            service.requestAuthorization()
        } label: {
            Label {
                HStack {
                    Text("Permissions")
                        .foregroundStyle(Color.primary)
                    Spacer()
                    switch service.authorizationStatus() {
                    case .notReviewed:
                        Label {
                            Image(systemName: "lock.shield.fill")
                                .foregroundStyle(Color.accent)
                        } icon: {
                            Text("Request")
                                .foregroundStyle(Color.accent)
                        }
                    case .authorized:
                        Label {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundStyle(Color.green)
                        } icon: {
                            Text("Authorized")
                                .foregroundStyle(Color.secondary)
                        }
                    case .denied:
                        Label {
                            Image(systemName: "xmark.shield.fill")
                                .foregroundStyle(Color.red)
                        } icon: {
                            Text("Denied")
                                .foregroundStyle(Color.secondary)
                        }
                    case .partiallyAuthorized:
                        Label {
                            Image(systemName: "exclamationmark.shield.fill")
                                .foregroundStyle(Color.yellow)
                        } icon: {
                            Text("Partially Authorized")
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
            } icon: {
                Image.healthKit
                    .foregroundStyle(Color.healthKit)
            }
        }
    }
}
