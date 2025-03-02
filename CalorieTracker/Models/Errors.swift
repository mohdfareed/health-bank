enum CalorieBudgetError: Error {
    case databaseError(dbError: Error)
}

enum CaloriesError: Error {
    case databaseError(dbError: Error)
}

enum AppSettingsError: Error {
    case databaseError(dbError: Error)
}

enum AppStateError: Error {
    case databaseError(dbError: Error)
}
