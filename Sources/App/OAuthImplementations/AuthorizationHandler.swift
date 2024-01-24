import Vapor
import VaporOAuth

/// Manage authorization flow
struct AuthorizationHandler: AuthorizeHandler {
    
    /// Handle Authorization Request from the client
    func handleAuthorizationRequest(_ request: Request, authorizationRequestObject: AuthorizationRequestObject) async throws -> Response {
        // Validate the input request object if needed
        
        // Persist data in session on the server
        request.session.data["state"] = authorizationRequestObject.state
        request.session.data["client_id"] = authorizationRequestObject.clientID
        request.session.data["scope"] = authorizationRequestObject.scope.joined(separator: ",")
        request.session.data["redirect_uri"] = authorizationRequestObject.redirectURI.string
        request.session.data["code_challenge"] = authorizationRequestObject.codeChallenge ?? ""
        request.session.data["code_challenge_method"] = authorizationRequestObject.codeChallengeMethod ?? "S256"
        request.session.data["nonce"] = authorizationRequestObject.nonce
        
        // Construct the URL to the Nuxt 3 application login page with query parameters
        guard let nuxtLoginURL = Environment.get("LOGIN_URL") else {
            throw Abort(.internalServerError, reason: "Missing LOGIN_URL")
        }

        let nuxtLoginURLString = nuxtLoginURL
        var queryParams: [(String, String?)] = [
            ("state", authorizationRequestObject.state),
            ("client_id", authorizationRequestObject.clientID),
            ("scope", authorizationRequestObject.scope.joined(separator: ",")),
            ("redirect_uri", authorizationRequestObject.redirectURI.string),
            ("code_challenge", authorizationRequestObject.codeChallenge ?? ""),
            ("code_challenge_method", authorizationRequestObject.codeChallengeMethod ?? "S256"),
            ("nonce", authorizationRequestObject.nonce)
        ]
        
        // Append CSRF token
        queryParams.append(("csrf_token", authorizationRequestObject.csrfToken))
        
        // Construct the query string
        let queryString = queryParams.map { key, value in
            if let value = value {
                return "\(key)=\(value)"
            } else {
                return key
            }
        }.joined(separator: "&")
        
        // Combine the base URL and query string
        let redirectURLString = "\(nuxtLoginURLString)?\(queryString)"
        
        print(redirectURLString)
        
        // Create a URI from the combined URL string
        let redirectURI = redirectURLString
        
        // Redirect to the Nuxt 3 login page
        return request.redirect(to: redirectURI)
        
    }
    
    /// Handle Authorization Error
    func handleAuthorizationError(_ errorType: AuthorizationError) async throws -> Response {
        // Determine the appropriate HTTP status code based on the error type
        let statusCode: HTTPResponseStatus
        switch errorType {
        case .invalidClientID:
            statusCode = .badRequest
        case .confidentialClientTokenGrant:
            statusCode = .forbidden
        case .invalidRedirectURI, .httpRedirectURI:
            statusCode = .badRequest
        default:
            statusCode = .internalServerError
        }
        
        // Log the error using a proper logging mechanism
        // You can use a logging framework here

        
        // Construct a user-friendly error message
        // Be cautious about revealing too much information in the error message
        let errorMessage = "An error occurred during authorization. \(errorType)" // Generic message for production
        
        // Create and return the response
        return Response(status: statusCode, body: .init(string: errorMessage))
    }
}

