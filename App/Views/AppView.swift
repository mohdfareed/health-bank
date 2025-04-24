import SVGView
import SwiftData
import SwiftUI

struct AppView: View {
    @AppStorage(.theme)
    internal var theme: AppTheme
    @AppLocale()
    internal var locale: Locale

    // func test() -> some View {
    //     let color = SVGColor.
    // }

    var body: some View {
        //        Image(systemName: "AddChart")
        AppIcons.logoImage
        Image.init("AddChart").resizable().aspectRatio(contentMode: .fit)
        //        Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
        //        Image(UIImage(named: "AppIcon"))
        //        Image("Test").resizable().aspectRatio(contentMode: .fit)
        //        SVGView(contentsOf: Bundle.main.url(forResource: "AppIcon", withExtension: "svg")!)

        // SVGView(contentsOf: Bundle.main.url(forResource: "example", withExtension: "svg")!)
        TabView {
            Tab(
                String(localized: "Dashboard"),
                systemImage: "square.grid.2x2"
            ) { SettingsView() }
            Tab(
                String(localized: "Data"), systemImage: "list.clipboard"
            ) { SettingsView() }
            Tab(
                String(localized: "Settings"), systemImage: "gear"
            ) { SettingsView() }
        }
        .environment(\.locale, self.locale)
        .preferredColorScheme(self.theme.colorScheme)
    }
}

#Preview {
    AppView()
}
