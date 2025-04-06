# App Settings

I'm working on an iOS app in swift, my stack is SwiftUI, SwiftData and UserDefault/AppStorage for this problem.

I am trying to abstract my settings to decouple what I want to access vs what's stored in the UserDefaults database. So I want to define certain protocols and types that will allow me to define a settings interface that is agnostic of the underlying storage.
I want to define a protocol that will be implemented *internally* by the types I want to support, such as:

extension String: SettingsValue {}
extension Bool: SettingsValue {}
extension Int: SettingsValue {}
extension Double: SettingsValue {}
extension URL: SettingsValue {}
extension Date: SettingsValue {}
extension Data: SettingsValue {}
extension PersistentIdentifier: SettingsValue {}

This will be what is actually stored in the user defaults.

Then I want to define another type that is essentially a RawRepresentable where its RawValue is one of the `SettingsValue` implementations.
This way I will use RawRepresentable to map the user-facing type to the underlying type. This will allow me to define a settings interface that is agnostic of the underlying storage.

I have the following problems with my typing system tho: optionals and using SettingsValue directly.
The underlying SettingsValue will always be stored as an optional, since I want to distinguish between unset and default.
But the user-facing type, the RawRepresentable, can be either. If it's optional, a default value is optional, if it isn't then the user must provide a default value.
The problem is allowing the user-facing type to be either while the underlying type to be always optional.
And the other problem is that I still want to use my underlying types directly; like, ofc the user can always just use String directly.
This then gets tricky since by the above, String? is not a SettingsValue, but is also supported since it's user-facing.

How can I define my interface? (no need for any implementations of the service itself, just the type handling)

Here's some usages that I was imagining:

I wanna define a new setting in my app:

```swift
enum FeatureSettings {
    case enableFeatureX(Bool=false)
    case activeConfig(PersistentIdentifier?)
    case activeConfig(PersistentIdentifier?)
}
```

Then I want to use it in my app:

```swift
struct SomeView: View {
    @AppStorage(FeatureSettings.enableFeatureX) var enableFeatureX: Bool
    @AppStorage(FeatureSettings.activeConfig) var activeConfig: PersistentIdentifier?

    var body: some View {
        Toggle("Enable Feature X", isOn: $enableFeatureX)
        if let config = activeConfig {
            Text("Active Config: \(config)")
        } else {
            Text("No Active Config")
        }
    }
}
