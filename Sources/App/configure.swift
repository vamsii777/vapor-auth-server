import NIOSSL
import Fluent
import FluentMongoDriver
import Vapor
import VaporOAuth

// configures your application
public func configure(_ app: Application) async throws {
    app.logger.logLevel = .notice
    app.http.server.configuration.port = 8000
    try configureDatabases(app)
    app.databases.default(to: .main)
    
    @Sendable func isSecure(environment: Environment) -> Bool {
        return environment == .production
    }
    
    let corsOrigins = Environment.get("CORS_ORIGINS")?.split(separator: ",").map(String.init) ?? []
    
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .any(corsOrigins),
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin, .accessControlAllowHeaders, .init("X-CSRF-TOKEN")],
        allowCredentials: true
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(cors, at: .beginning)
    
    app.migrations.add(CreateAccessToken(), to: .main)
    app.migrations.add(CreateAuthorizationCode(), to: .main)
    app.migrations.add(CreateRefreshToken(), to: .main)
    app.migrations.add(CreateResourceServer(), to: .main)
    app.migrations.add(CreateIDToken(), to: .main)
    app.migrations.add(CreateClient(), to: .main)
    app.migrations.add(CreateUser(), to: .main)
    app.migrations.add(CreateCryptoKey(), to: .main)
    app.migrations.add(CreateKeyOperationLog(), to: .main)
    app.migrations.add(SeedClient(), to: .main)
    app.migrations.add(SeedUser(), to: .main)
    app.migrations.add(SeedResourceServer(), to: .main)
    app.migrations.add(SeedPrivateCryptoKey(), to: .main)
    app.migrations.add(SeedPublicCryptoKey(), to: .main)
    
    try await app.autoMigrate().get()
    
    // Correctly create a CryptoKeysRepository instance by passing the database.
    let cryptoKeysRepository = CryptoKeysRepository(database: app.db)
    
    let keyManagementService = MyKeyManagementService(app: app, cryptoKeysRepository: cryptoKeysRepository)
    
    // Change the cookie name to "foo".
    app.sessions.configuration.cookieName = "vapor-session"

    // Configures cookie value creation.
    app.sessions.configuration.cookieFactory = { sessionID in
            .init(string: sessionID.string, isSecure: isSecure(environment: Environment.development))
    }
    
    let sessionsMiddleware = app.sessions.middleware
    app.middleware.use(sessionsMiddleware, at: .beginning)
    app.middleware.use(OAuthUserSessionAuthenticator())
    app.middleware.use(UserModel.sessionAuthenticator())
    
    app.sessions.use(.fluent)
    
    app.migrations.add(SessionRecord.migration)
    
    app.lifecycle.use(
        OAuth2(
            codeManager: AuthorizationCodeManger(app: app),
            tokenManager: TokenManager(app: app),
            clientRetriever: ClientRetriever(app: app),
            authorizeHandler: AuthorizationHandler(),
            userManager: UserManager(app: app),
            validScopes: nil,
            resourceServerRetriever: ResourceServerRetriever(app: app),
            oAuthHelper: .remote(
                tokenIntrospectionEndpoint: "",
                client: app.client,
                resourceServerUsername: "",
                resourceServerPassword: ""
            ),
            jwtSignerService: JWTSignerService(keyManagementService: keyManagementService, cryptoKeysRepository: cryptoKeysRepository),
            discoveryDocument: DiscoveryDocument(),
            keyManagementService: keyManagementService
        )
    )
    
    try routes(app)
}
