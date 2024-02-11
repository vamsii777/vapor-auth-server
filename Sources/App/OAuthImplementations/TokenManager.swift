import Vapor
import VaporOAuth
import Fluent
import JWTKit

/// Manage Token handling
///
/// * generate access_token, refresh_token, id_token
/// * retrieve tokens
/// * update tokens
///
final class TokenManager: VaporOAuth.TokenManager {
    
    let app: Application
    let keyManagementService: KeyManagementService
    
    init(app: Application) {
        self.app = app
        self.keyManagementService = MyKeyManagementService(app: app, cryptoKeysRepository: CryptoKeysRepository(database: app.db))
    }
    
    /// Get Access Token for the token introspection
    // Get Access Token for the token introspection
    func getAccessToken(_ accessToken: String) async throws -> VaporOAuth.AccessToken? {
        // Remove debug statements
        
        let token: String?
        do {
            let publicKeyIdentifier = try await keyManagementService.publicKeyIdentifier()
            let publicKey = try await keyManagementService.retrieveKey(identifier: publicKeyIdentifier, keyType: .public)
            let signer = JWTSigner.es256(key: try .public(pem: publicKey))
            let jwt = try signer.verify(accessToken, as: JWTAccessTokenPayload.self)
            token = jwt.jti
        } catch {
            token = accessToken
        }
        
        // Check in database if the access_token exists
        guard let token,
              let accessToken = try await AccessToken.query(on: app.db)
            .filter(\.$token == token)
            .first() else {
            return nil
        }
        
        // Delete expired access tokens for this user
        if let id = accessToken.id {
            let expiredTokens = try await AccessToken
                .query(on: app.db)
                .filter(\.$userID == accessToken.userID)
                .filter(\.$expiryTime < accessToken.expiryTime)
                .filter(\.$id != id)
                .all()
            
            try await expiredTokens.delete(on: app.db)
        }
        
        // Construct the payload
        let payload = JWTAccessTokenPayload(
            jti: accessToken.jti,
            clientID: accessToken.clientID,
            userID: accessToken.userID,
            scopes: accessToken.scopes,
            expiryTime: accessToken.expiryTime,
            issuer: accessToken.issuer,
            issuedAt: Date()
        )
        
        return payload
    }
    
    
    /// Update Refresh Token scope
    func updateRefreshToken(_ refreshToken: VaporOAuth.RefreshToken, scopes: [String]) async throws {

        if let token = try await RefreshToken
            .query(on: app.db)
            .filter(\.$jti == refreshToken.jti)
            .first() {
            
            token.scopes = scopes.joined(separator: " ")
            
            try await token.save(on: app.db)
            
        }
    }
    
    /// Get Refresh Token
    func getRefreshToken(_ refreshToken: String) async throws -> VaporOAuth.RefreshToken? {
        
        let publicKeyIdentifier = try await keyManagementService.publicKeyIdentifier()
        let publicKey = try await keyManagementService.retrieveKey(identifier: publicKeyIdentifier, keyType: .public)
        let signer = JWTSigner.es256(key: try .public(pem: publicKey))
        let jwt = try signer.verify(refreshToken, as: JWTRefreshTokenPayload.self)
        
        guard
            let refreshToken = try await RefreshToken
                .query(on: app.db)
                .filter(\.$jti == jwt.jti)
                .first()
        else {
            return nil
        }
        
        // Important: vapor/oauth does not invalidate refresh tokens
        // Therefore, expired refresh tokens are only removed when a new
        // refresh token for this user has been issued. There is no
        // revoke feature.
        if let id = refreshToken.id {
            let otherActiveRefreshTokens = try await RefreshToken
                .query(on: app.db)
                .filter(\.$userID == refreshToken.userID)
                .filter(\.$exp < refreshToken.exp)
                .filter(\.$id != id)
                .all()

            try await otherActiveRefreshTokens.delete(on: app.db)
            
        }
        
        let payload = JWTRefreshTokenPayload(
            jti: refreshToken.jti,
            clientID: refreshToken.clientID,
            userID: refreshToken.userID,
            scopes: refreshToken.scopes,
            exp: refreshToken.exp,
            issuer: "https://securetoken.dewonderstruck.com",
            issuedAt: Date()
        )
        
        return payload
        
    }
    
    func generateTokens(clientID: String, userID: String?, scopes: [String]?, accessTokenExpiryTime: Int, idTokenExpiryTime: Int, nonce: String?) async throws -> (VaporOAuth.AccessToken, VaporOAuth.RefreshToken, VaporOAuth.IDToken) {
        
        app.logger.info("Starting generateTokens")
        
        let accessToken = try await generateAccessToken(clientID: clientID, userID: userID, scopes: scopes, expiryTime: accessTokenExpiryTime)
        
        let refreshToken = try await generateRefreshToken(clientID: clientID, userID: userID, scopes: scopes)
        
        let idToken = try await generateIDToken(clientID: clientID, userID: userID ?? "", scopes: scopes, expiryTime: idTokenExpiryTime, nonce: nonce)
        
        return (accessToken, refreshToken, idToken)
        
    }
    
    
    func generateRefreshToken(clientID: String, userID: String?, scopes: [String]?) async throws -> VaporOAuth.RefreshToken {
        
        let entitlements = try await isUserEntitled(user: userID, scopes: scopes)
        
        guard
            entitlements.entitled == true
        else {
            throw Abort(.unauthorized, reason: "User is not entitled for this scope.")
        }
        
        let refreshToken = try createRefreshToken(
            clientID: clientID,
            userID: userID,
            scopes: entitlements.scopes
        )
        
        try await refreshToken.save(on: app.db)
        
        let payload = JWTRefreshTokenPayload(
            jti: refreshToken.jti,
            clientID: refreshToken.clientID,
            userID: refreshToken.userID,
            scopes: refreshToken.scopes,
            exp: refreshToken.exp,
            issuer: "https://securetoken.dewonderstruck.com",
            issuedAt: Date()
        )
        
        return payload
    }
    
    
    
    func generateIDToken(clientID: String, userID: String, scopes: [String]?, expiryTime: Int, nonce: String?) async throws -> VaporOAuth.IDToken {
        
        let entitlements = try await isUserEntitled(user: userID, scopes: scopes)
        
        guard
            entitlements.entitled == true
        else {
            throw Abort(.unauthorized, reason: "User is not entitled for this scope.")
        }
        
        var subject: String = ""
        var authTime: Date =  Date()
        if let uuid = UUID(uuidString: userID) {
            
            // Query database for user
            if let author = try await UserModel
                .query(on: app.db)
                .filter(\.$id == uuid)
                .first() {
                
                if let id = author.id {
                    subject = "\(id)"
                }
                
                if let created_at = author.createdAt {
                    authTime = created_at
                }
                
            }
        }
        
        let idToken = try createIDToken(
            subject: subject,
            audience: ["\(clientID)"],
            nonce: nonce,
            authTime: authTime
        )
        
        try await idToken.save(on: app.db)
        
        // Delete expired id_tokens for this user
        if let id = idToken.id {
            let expiredTokens = try await IDToken
                .query(on: app.db)
                .filter(\.$exp < idToken.exp)
                .filter(\.$id != id)
                .all()
            
            try await expiredTokens.delete(on: app.db)
            
        }
        
        let payload = JWTIDTokenPayload(
            sub: idToken.sub,
            aud: idToken.aud,
            exp: idToken.exp,
            nonce: idToken.nonce,
            authTime: idToken.authTime,
            iss: idToken.iss,
            iat: idToken.iat,
            jti: idToken.jti
        )
        
        return payload
        
    }
    
    /// Generate new Access Token in exchange for the Refresh Token
    func generateAccessToken(clientID: String, userID: String?, scopes: [String]?, expiryTime: Int) async throws -> VaporOAuth.AccessToken {

        let entitlements = try await isUserEntitled(user: userID, scopes: scopes)
        
        guard
            entitlements.entitled == true
        else {
            throw Abort(.unauthorized, reason: "User is not entitled for this scope.")
        }
        
        let accessTokenUniqueId = UUID().uuidString
        
        // Expiry time 1 minutes for testing purposes
        let expiryTimeAccessToken = Date(timeIntervalSinceNow: TimeInterval(Environment.get("OAUTH_ACCESS_TOKEN_MAX_AGE").flatMap(Int.init) ?? 60 * 60 * 24 * 7))
        
        // Access Token for Database
        let accessToken = try createAccessToken(
            tokenString: accessTokenUniqueId,
            clientID: clientID,
            userID: userID,
            scopes: entitlements.scopes,
            expiryTime: expiryTimeAccessToken
        )
        
        try await accessToken.save(on: app.db)
        
        let payload = JWTAccessTokenPayload(
            jti: accessToken.jti,
            clientID: accessToken.clientID,
            userID: accessToken.userID,
            scopes: accessToken.scopes,
            expiryTime: accessToken.expiryTime,
            issuer: "https://securetoken.dewonderstruck.com",
            issuedAt: Date()
        )
        
        return payload
        
    }
    
    /// Generate Access and Refresh Token in exchange for the Authorization Code
    func generateAccessRefreshTokens(clientID: String, userID: String?, scopes: [String]?, accessTokenExpiryTime: Int) async throws -> (VaporOAuth.AccessToken, VaporOAuth.RefreshToken) {
        
        let accessToken = try await generateAccessToken(clientID: clientID, userID: userID, scopes: scopes, expiryTime: accessTokenExpiryTime)
        
        let refreshToken = try await generateRefreshToken(clientID: clientID, userID: userID, scopes: scopes)
        
        return (accessToken, refreshToken)
    }
    
    
    /// Create Access Token
    func createAccessToken(tokenString: String, clientID: String, userID: String?, scopes: [String]?, expiryTime: Date) throws -> AccessToken {
        
        return AccessToken(
            jti: [UInt8].random(count: 32).hex,
            token: tokenString,
            clientID: clientID,
            userID: userID,
            scope: scopes?.joined(separator: " "),
            expiryTime: expiryTime
        )
        
    }
    
    func createRefreshToken(clientID: String, userID: String?, scopes: [String]?) throws -> RefreshToken {
        // Expiry time: 30 days
        let expiryTimeRefreshToken = Date(timeIntervalSinceNow: TimeInterval(Environment.get("OAUTH_REFRESH_TOKEN_MAX_AGE").flatMap(Int.init) ?? 60 * 60 * 24 * 30))
        
        // Convert the array of scopes to a space-separated string
        let scopesString = scopes?.joined(separator: " ")
        
        return RefreshToken(
            jti: [UInt8].random(count: 32).hex,
            clientID: clientID,
            userID: userID,
            scopes: scopesString, // Now correctly passing a String?
            exp: expiryTimeRefreshToken
        )
    }
    
    /// Create IDToken
    func createIDToken(subject: String, audience: [String], nonce: String?, authTime: Date?) throws -> IDToken {
        
        // Expiry time: 30 days
        let expiryTimeIDToken = Date(timeIntervalSinceNow: TimeInterval(Environment.get("OAUTH_ID_TOKEN_MAX_AGE").flatMap(Int.init) ?? 60 * 60))
        
        return IDToken(
            jti: [UInt8].random(count: 32).hex,
            iss: "https://securetoken.dewonderstruck.com",
            sub: subject,
            aud: audience,
            exp: expiryTimeIDToken,
            iat: Date(),
            nonce: nonce,
            authTime: nil
        )
        
    }
    
    func isUserEntitled(user userID: String?, scopes: [String]?) async throws -> (entitled: Bool, scopes: [String]) {
        
        // Get user
        guard
            let userID,
            let uuid = UUID(uuidString: userID),
            let scopes,
            scopes.count > 0,
            let author = try await UserModel
                .query(on: app.db)
                .filter(\.$id == uuid)
                .first()
        else {
            throw Abort(.badRequest, reason: "No user specified or no scopes requested.")
        }
        
        // Get unique sets of all scopes
        let userScopes = Set(author.roles)
        let requestedScopes = Set(scopes)
        
        // Return true if all requestedScopes are part of the user scopes
        let entitled =  requestedScopes.isSubset(of: userScopes)
        
        return (entitled: entitled, scopes: Array(userScopes))
        
    }
    
}
