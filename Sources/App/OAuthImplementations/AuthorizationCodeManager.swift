import VaporOAuth
import Vapor
import Fluent

/// Manage authorization code
///
/// * generate authorization code
/// * get authorization code
/// * remove used authorization code
///
final class AuthorizationCodeManger: VaporOAuth.CodeManager {
    
    let app: Application
    
    init(app: Application) {
        self.app = app
    }
    
    // Generate a unique device code
    func generateDeviceCode(userID: String, clientID: String, scopes: [String]?) async throws -> String {
        let deviceCode = UUID().uuidString
        let userCode = UUID().uuidString.prefix(8)
        let expiryDate = Date().addingTimeInterval(60 * 30) // 30 minutes
        
        let oauthDeviceCode = OAuthDeviceCode(
            deviceCodeID: deviceCode,
            userCode: String(userCode),
            clientID: userID,
            userID: clientID,
            expiryDate: expiryDate,
            scopes: scopes
        )
        
        try await oauthDeviceCode.save(on: app.db)
        return deviceCode
    }
    
    // Retrieve a device code
    func getDeviceCode(_ deviceCode: String) async throws -> VaporOAuth.OAuthDeviceCode? {
        guard !deviceCode.isEmpty else {
            throw Abort(.badRequest, reason: "Device code is empty")
        }
        
        if let appDeviceCode = try await OAuthDeviceCode.query(on: app.db)
            .filter(\.$deviceCodeID == deviceCode)
            .first() {
            // Cast the appDeviceCode to the expected type
            return VaporOAuth.OAuthDeviceCode(
                deviceCodeID: appDeviceCode.deviceCodeID,
                userCode: appDeviceCode.userCode,
                clientID: appDeviceCode.clientID,
                userID: appDeviceCode.userID,
                expiryDate: appDeviceCode.expiryDate,
                scopes: appDeviceCode.scopes
            )
        } else {
            return nil
        }
    }
    
    
    // Mark a device code as used and remove it
    func deviceCodeUsed(_ deviceCode: VaporOAuth.OAuthDeviceCode) async throws {
        guard !deviceCode.deviceCodeID.isEmpty else {
            throw Abort(.badRequest, reason: "Device code is empty")
        }
        
        if let foundDeviceCode = try await OAuthDeviceCode.query(on: app.db)
            .filter(\.$deviceCodeID == deviceCode.deviceCodeID)
            .first() {
            try await foundDeviceCode.delete(on: app.db)
        } else {
            // Optionally handle the case where the device code is not found
        }
    }
    
    /// Retrieve Authorization code
    func getCode(_ code: String) async throws -> OAuthCode? {
        guard !code.isEmpty else {
            // Optionally log the error or handle the empty code case
            throw Abort(.badRequest, reason: "Authorization code is empty")
        }
        
        guard let authorizationCode = try await AuthorizationCode.query(on: app.db)
            .filter(\.$codeID == code)
            .first() else {
            // Log the event of not finding the code
            // You can use a logging framework here
            return nil
        }
        
        return OAuthCode(
            codeID: authorizationCode.codeID,
            clientID: authorizationCode.clientID,
            redirectURI: authorizationCode.redirectURI,
            userID: authorizationCode.userID,
            expiryDate: authorizationCode.expiryDate,
            scopes: authorizationCode.scopes,
            codeChallenge: authorizationCode.codeChallenge,
            codeChallengeMethod: authorizationCode.codeChallengeMethod,
            nonce: authorizationCode.nonce
        )
    }
    
    /// Generate Authorization Code
    func generateCode(userID: String, clientID: String, redirectURI: String, scopes: [String]?, codeChallenge: String?, codeChallengeMethod: String?, nonce: String?) throws -> String {
        
        let generatedCode = UUID().uuidString
        let expiryDate = Date().addingTimeInterval(60)
        
        let authorizationCode = AuthorizationCode(
            codeID: generatedCode,
            clientID: clientID,
            redirectURI: redirectURI,
            userID: userID,
            expiryDate: expiryDate,
            scopes: scopes,
            codeChallenge: codeChallenge,
            codeChallengeMethod: codeChallengeMethod,
            nonce: nonce
        )
        
        _ = authorizationCode.save(on: app.db)
        
        return generatedCode
    }
    
    /// Delete used Authorization Code
    func codeUsed(_ code: OAuthCode) async throws {
        guard !code.codeID.isEmpty else {
            // Handle the case where the codeID is empty
            // Log this as an error or throw an exception as needed
            throw Abort(.badRequest, reason: "Code ID is empty")
        }
        
        if let authorizationCode = try await AuthorizationCode.query(on: app.db)
            .filter(\.$codeID == code.codeID)
            .first() {
            do {
                try await authorizationCode.delete(on: app.db)
            } catch {
                // Log the error using a proper logging mechanism
                // Handle or throw the error as per your application's error handling strategy
                throw Abort(.internalServerError, reason: "Failed to delete authorization code")
            }
        } else {
            // Optionally handle the case where the authorization code is not found
            // This could be a simple return or specific error handling if needed
        }
    }
    
}
