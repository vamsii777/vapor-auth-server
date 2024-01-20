import Vapor
import Fluent

// Function to configure databases
func configureDatabases(_ app: Application) throws {
    // Configure main database
    guard let mainDBURL = Environment.get("DATABASE_URL") else {
        app.logger.critical("Main database URL not found in environment variables.")
        throw Abort(.internalServerError, reason: "Main database configuration failed.")
    }
    try app.databases.use(.mongo(connectionString: mainDBURL), as: .main)

    // Configure key management database
    guard let keyDBURL = Environment.get("CRYPTO_DATABASE_URL") else {
        app.logger.warning("Key management database URL not found in environment variables.")
        // Continue without setting up key management database if it's optional
        return
    }
    try app.databases.use(.mongo(connectionString: keyDBURL), as: .keyManagement)
}

extension DatabaseID {
    static let main = DatabaseID(string: "main")
    static let keyManagement = DatabaseID(string: "keyManagement")
}
