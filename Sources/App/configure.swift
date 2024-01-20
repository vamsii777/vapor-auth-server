import NIOSSL
import Fluent
import FluentMongoDriver
import Vapor
import VaporOAuth

// configures your application
public func configure(_ app: Application) async throws {
    app.logger.logLevel = .notice
    app.http.server.configuration.port = 8080
    try configureDatabases(app)
    app.databases.default(to: .main)
    try await app.autoMigrate().get()
    
    // Correctly create a CryptoKeysRepository instance by passing the database.
    let cryptoKeysRepository = CryptoKeysRepository(database: app.db)
    
    let keyManagementService = MyKeyManagementService(app: app, cryptoKeysRepository: cryptoKeysRepository)
    
    app.lifecycle.use(
        OAuth2(
            codeManager: AuthorizationCodeManger(app: app),
            tokenManager: TokenManager(app: app),
            clientRetriever: ClientRetriever(app: app),
            authorizeHandler: AuthorizationHandler(),
            userManager: UserManager(app: app),
            validScopes: nil, //["admin,openid"], value required if no clients defined
            resourceServerRetriever: ResourceServerRetriever(app: app),
            oAuthHelper: .remote(
                tokenIntrospectionEndpoint: "",
                client: app.client,
                resourceServerUsername: "",
                resourceServerPassword: ""
            ),
            jwtSignerService: JWTSignerService(keyManagementService: keyManagementService),
            discoveryDocument: DiscoveryDocument(),
            keyManagementService: keyManagementService
        )
    )
    
    try routes(app)
}
