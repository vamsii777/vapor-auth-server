import Fluent
import VaporOAuth
import Vapor

/// Authorization Code
///
/// - Parameters:
///   - id: unique identifier in database (uuid)
///   - code_id: unique code identifier; separate from id as requirement is to have this value as string value and id is usually an uuid value
///   - client_id: client for whom this code was generated
///   - redirect_uri: client redirect uri
///   - user_id: user for whom this code was generated
///   - expiry_date: expiry data of the authorization code
///   - scopes: scopes requested by the client
///   - code_challenge: PKCE code challenge provided
///   - code_challenge_method: PKCE code challenge method
///
/// Represents an authorization code used in the authentication process.
final class AuthorizationCode: Model, Content {
    
    /// The database schema for the `MyAuthorizationCode` model.
    static let schema = "authorization_code"
    
    /// The unique identifier for the authorization code.
    @ID(key: .id)
    var id: UUID?
    
    /// The code ID associated with the authorization code.
    @Field(key: "code_id")
    var codeID: String
    
    /// The client ID associated with the authorization code.
    @Field(key: "client_id")
    var clientID: String
    
    /// The redirect URI associated with the authorization code.
    @Field(key: "redirect_uri")
    var redirectURI: String
    
    /// The user ID associated with the authorization code.
    @Field(key: "user_id")
    var userID: String
    
    /// The expiry date of the authorization code.
    @Field(key: "expiry_date")
    var expiryDate: Date
    
    /// The scopes associated with the authorization code.
    var scopes: [String]? {
        get {
            guard let scopes = _scopes else { return nil }
            let scopesArray = scopes.split(separator: ",")
            return scopesArray.map(String.init)
        }
        set {
            guard let newValue = newValue else {
                _scopes = nil
                return
            }
            _scopes = newValue.joined(separator: ",")
        }
    }
    
    /// The scopes as a comma-separated string.
    @Field(key: "scopes")
    var _scopes: String?
    
    /// The code challenge associated with the authorization code.
    @OptionalField(key: "code_challenge")
    var codeChallenge: String?
    
    /// The code challenge method associated with the authorization code.
    @OptionalField(key: "code_challenge_method")
    var codeChallengeMethod: String?
    
    /// The nonce associated with the authorization code.
    @OptionalField(key: "nonce")
    var nonce: String?
    
    /// Initializes a new instance of `MyAuthorizationCode`.
    init() {}
    
    /// Initializes a new instance of `MyAuthorizationCode` with the specified parameters.
    /// - Parameters:
    ///   - id: The unique identifier for the authorization code.
    ///   - codeID: The code ID associated with the authorization code.
    ///   - clientID: The client ID associated with the authorization code.
    ///   - redirectURI: The redirect URI associated with the authorization code.
    ///   - userID: The user ID associated with the authorization code.
    ///   - expiryDate: The expiry date of the authorization code.
    ///   - scopes: The scopes associated with the authorization code.
    ///   - codeChallenge: The code challenge associated with the authorization code.
    ///   - codeChallengeMethod: The code challenge method associated with the authorization code.
    ///   - nonce: The nonce associated with the authorization code.
    init(id: UUID? = nil,
         codeID: String,
         clientID: String,
         redirectURI: String,
         userID: String,
         expiryDate: Date,
         scopes: [String]?,
         codeChallenge: String?,
         codeChallengeMethod: String?,
         nonce: String?
    ) {
        self.id = id
        self.codeID = codeID
        self.clientID = clientID
        self.redirectURI = redirectURI
        self.userID = userID
        self.expiryDate = expiryDate
        self.scopes = scopes
        self.codeChallenge = codeChallenge
        self.codeChallengeMethod = codeChallengeMethod
        self.nonce = nonce
    }
}
