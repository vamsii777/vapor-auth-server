import Vapor
import Fluent
import VaporOAuth

// OAuthRouteControllerCollection
// Path: Sources/App/Controllers/OAuthRouteControllerCollection.swift

/// A collection of routes related to OAuth authentication.
public struct OAuthRouteControllerCollection: RouteCollection {
    

    /// Boots the OAuthRouteControllerCollection by registering the routes.
    /// - Parameter routes: The RoutesBuilder instance used to register the routes.
    public func boot(routes: RoutesBuilder) throws {
        let passwordProtected = routes.grouped(UserModel.credentialsAuthenticator())
        let oauthRoutes = passwordProtected.grouped("oauth")
        oauthRoutes.post("login", use: login)
        oauthRoutes.get("logout", use: logout)
    }
    
    /// Handles the login request for OAuth authentication.
    /// - Parameter request: The incoming Request instance.
    /// - Returns: The Response instance.
    func login(_ request: Request) async throws -> Response {
        let user = try request.auth.require(UserModel.self)

        // Log in OAuth user with credentials
        let oauthUser = OAuthUser(
            userID: user.id?.uuidString,
            username: user.username,
            emailAddress: "", // Ensure this is handled appropriately
            password: user.password
        )
        
        request.auth.login(oauthUser)
        request.session.authenticate(oauthUser)
        
        // http://localhost:8090/oauth/redirect
        guard let redirectURI = Environment.get("REDIRECT_URL") else {
            throw Abort(.internalServerError, reason: "Missing REDIRECT_URL")
        }
        
        let redirectURL = redirectURI
        let response = try await request.redirect(to: redirectURL).encodeResponse(for: request)
        
        return response
    }
    
    /// Handles the logout request for OAuth authentication.
    /// - Parameter request: The incoming Request instance.
    /// - Returns: The HTTPStatus instance.
    func logout(_ request: Request) async throws -> HTTPStatus {
        // Optionally, check if the user is logged in before logging out
        if request.auth.has(OAuthUser.self) || request.auth.has(UserModel.self) {
            request.auth.logout(OAuthUser.self)
            request.auth.logout(UserModel.self)
            request.session.destroy()
        } else {
            // Handle the case where there is no user to log out
            // This could be a simple return or a specific handling if needed
        }
        
        // Consider redirecting the user after logout or sending a confirmation response
        return .ok
    }
    
    
    
}
