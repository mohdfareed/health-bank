import AppIntents
import HealthVaultsShared
import WidgetKit

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    // static var description: IntentDescription { "This is an example widget." }

    // // An example configurable parameter.
    // @Parameter(title: "Favorite Emoji", default: "😃")
    // var favoriteEmoji: String
}

extension ConfigurationAppIntent {
    // fileprivate static var smiley: ConfigurationAppIntent {
    //     let intent = ConfigurationAppIntent()
    //     intent.favoriteEmoji = "😀"
    //     return intent
    // }
}
