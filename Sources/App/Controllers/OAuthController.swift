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
        oauthRoutes.post("redirect", use: redirect)
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
        
        // Handle session cookie update
        guard let cookie = request.cookies["vapor-session"] else {
            // Handle error: session cookie not found
            throw Abort(.internalServerError, reason: "Session cookie not found")
        }
        
        // http://localhost:8090/oauth/redirect
        guard let redirectURI = Environment.get("REDIRECT_URL") else {
            throw Abort(.internalServerError, reason: "Missing REDIRECT_URL")
        }
        
        let redirectURL = redirectURI
        let response = try await request.redirect(to: redirectURL).encodeResponse(for: request)
        response.cookies["vapor-session"] = cookie
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
    
    /// Handles the redirect request for OAuth authentication.
    /// - Parameter request: The incoming Request instance.
    /// - Returns: The Response instance.
    func redirect(_ request: Request) async throws -> Response {
        guard let state = request.session.data["state"],
              let client_id = request.session.data["client_id"],
              let scope = request.session.data["scope"],
              let redirect_uri = request.session.data["redirect_uri"],
              let csrfToken = request.session.data["CSRFToken"],
              let code_challenge = request.session.data["code_challenge"],
              let code_challenge_method = request.session.data["code_challenge_method"],
              let nonce = request.session.data["nonce"] else {
            // Handle missing session data
            throw Abort(.badRequest, reason: "Required session data is missing")
        }
        
        struct Temp: Content {
            let applicationAuthorized: Bool
            let csrfToken: String
            let code_challenge: String
            let code_challenge_method: String
            let nonce: String
        }
        
        let content = Temp(
            applicationAuthorized: true,
            csrfToken: csrfToken,
            code_challenge: code_challenge,
            code_challenge_method: code_challenge_method,
            nonce: nonce
        )

        // http://localhost:8090/oauth/authorize
        guard let authorizeEndpoint = Environment.get("AUTHORIZATION_ENDPOINT") else {
            throw Abort(.internalServerError, reason: "Missing AUTHORIZATION_ENDPOINT")
        }
        
        // Use configurable URL
        let authorizeURL = authorizeEndpoint
        let authorizeURI = URI(string: "\(authorizeURL)?client_id=\(client_id)&redirect_uri=\(redirect_uri)&response_type=code&scope=\(scope)&state=\(state)&nonce=\(nonce)")
        
        guard let cookie = request.cookies["vapor-session"] else {
            // Handle missing session cookie
            throw Abort(.internalServerError, reason: "Session cookie not found")
        }
        
        let headers = HTTPHeaders(dictionaryLiteral: ("Cookie", "vapor-session=\(cookie.string)"))
        
        // Forwarding the session cookie
        let response = try await request.client.post(authorizeURI, headers: headers, content: content).encodeResponse(for: request)
        response.cookies["vapor-session"] = cookie
        
        return response
    }
    
}
