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
    @State private var authStatus: HealthAuthorizationStatus = .denied

    let service: HealthKitService

    var body: some View {
        Button {
            service.requestAuthorization()
        } label: {
            Label {
                HStack {
                    Text("Health Permissions")
                        .foregroundStyle(Color.primary)
                    Spacer()
                    switch authStatus {
                    case .notReviewed:
                        Text("Request")
                            .foregroundStyle(Color.accent)
                        Image(systemName: "lock.shield.fill")
                            .imageScale(.large)
                            .foregroundStyle(Color.accent)
                    case .authorized:
                        Image(systemName: "checkmark.circle.fill")
                            .imageScale(.large)
                            .foregroundStyle(Color.green)
                    case .denied:
                        Image(systemName: "xmark.circle.fill")
                            .imageScale(.large)
                            .foregroundStyle(Color.red)
                    case .partiallyAuthorized:
                        Text("Partial")
                            .foregroundStyle(Color.secondary)
                        Image(systemName: "exclamationmark.circle.fill")
                            .imageScale(.large)
                            .foregroundStyle(Color.yellow)
                    }
                }
            } icon: {
                Image.healthKit
                    .foregroundStyle(Color.healthKit)
            }
        }
        .disabled(authStatus != .notReviewed)
        .animation(.default, value: authStatus)
        .onAppear {
            authStatus = service.authorizationStatus()
        }
    }
}
