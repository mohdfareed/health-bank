import HealthKit
import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
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

                // Health Data Section
                Section {
                    NavigationLink(destination: HealthKitLicenseView()) {
                        Label {
                            Text("Apple Health Integration")
                        } icon: {
                            Image.healthKit
                        }
                    }
                    .buttonStyle(.plain)
                } footer: {
                    Text(
                        "This app integrates with Apple Health to provide health data tracking."
                    )
                }

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

struct HealthKitLicenseView: View {
    @Environment(\.healthKit)
    private var healthKitService
    @State private var isManagingPermissions = false

    var body: some View {
        List {
            // Integration Overview
            Section {
                HStack(spacing: 16) {
                    Image.appleHealth
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 48)
                        .padding(1)  // Width of the border
                        .background(Color.secondary)  // Color of the border
                        .cornerRadius(12)  // Outer corner radius
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
            }

            Section {
                // Privacy Information
                Label {
                    Text("Data Privacy")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(
                        """
                        Health data is stored and managed by Apple Health.
                        This app does not collect or store personal health information.
                        """
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                } icon: {
                    Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                        .foregroundStyle(Color.green, Color.blue)
                        .symbolEffect(.pulse)
                }
                .healthKitAuthorizationSheet(
                    isPresented: $isManagingPermissions,
                    service: healthKitService
                )

                // Permissions Management
                Button {
                    isManagingPermissions = true
                } label: {
                    Label {
                        Text("Manage Permissions")
                    } icon: {
                        Image(systemName: "gear")
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(.primary)
            } footer: {
                Text("Configure which health data this app can use.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Apple Health Badge
            Section {
                HStack {
                    Spacer()
                    Image.appleHealthBadge
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 40)
                        .opacity(0.8)
                    Spacer()
                }
                .padding(.vertical, 12)
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("Apple Health")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
