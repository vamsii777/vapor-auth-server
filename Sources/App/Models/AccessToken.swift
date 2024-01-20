import Fluent
import VaporOAuth
import Vapor
import JWTKit

/// Access Token
/// - Parameters:
///  - id: unique identifier in database (uuid)
/// - token: token value
/// - client_id: client for whom this token was generated
/// - user_id: user for whom this token was generated
/// - scopes: scopes requested by the client
/// - expiry_time: expiry time of the access token
/// - iat: issued at time
/// - jti: unique identifier of the access token
/// - iss: issuer of the access token
/// - aud: audience of the access token
/// - exp: expiry date of the access token
/// - sub: subject of the access token
/// - iat: issued at time
///
/// Represents an access token used for authentication and authorization.
/// Access Token
final class AccessToken: Model, Content, VaporOAuth.AccessToken, JWTPayload {
    
    /// The database collection name for the access token.
    static let schema: String = "access_token"
    
    /// The unique identifier of the access token.
    @ID(key: .id)
    var id: UUID?
    
    /// The token of the access token.
    @Field(key: "token")
    var token: String
    
    /// The client ID associated with the access token.
    @Field(key: "client_id")
    var clientID: String
    
    /// The user ID associated with the access token.
    @Field(key: "user_id")
    var userID: String?
    
    /// The scopes associated with the access token.
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
    
    /// The internal representation of the scopes as a string.
    @Field(key: "scopes")
    var _scopes: String?
    
    /// The expiry time of the access token.
    @Field(key: "expiry_time")
    var expiryTime: Date
    
    
    // Additional properties for the token generation
    
    /// The issuer of the access token.
    @Field(key: "issuer")
    var issuer: String
    
    
    @Field(key: "iat")
    var iat: String
    
    /// The available coding keys for encoding and decoding the access token.
    enum CodingKeys: CodingKey {
        case sub
        case exp
        case jti
        case iss
        case aud
        case iat
    }
    
    
    /// The unique identifier of the access token.
    var jti = String()
    
    /// Initializes an access token from a decoder.
    /// - Parameters:
    ///   - decoder: The decoder to decode the access token from.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userID = try container.decode(String.self, forKey: .sub)
        expiryTime = try container.decode(Date.self, forKey: .exp)
        if let token = try container.decodeIfPresent(String.self, forKey: .jti) {
            self.jti = token
        }
        issuer = try container.decode(String.self, forKey: .iss)
        clientID = try container.decode(String.self, forKey: .aud)
    }
    
    /// Encodes the access token to an encoder.
    /// - Parameters:
    ///   - encoder: The encoder to encode the access token to.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userID, forKey: .sub)
        try container.encode(expiryTime, forKey: .exp)
        try container.encode(token, forKey: .jti)
        try container.encode(issuer, forKey: .iss)
        try container.encode(clientID, forKey: .aud)
        try container.encode(iat, forKey: .iat)
    }
    
    /// Initializes an empty access token.
    init() {}
    
    /// Initializes an access token with the specified properties.
    /// - Parameters:
    ///   - id: The unique identifier of the access token.
    ///   - token: The token of the access token.
    ///   - clientID: The client ID associated with the access token.
    ///   - userID: The user ID associated with the access token.
    ///   - scopes: The scopes associated with the access token.
    ///   - expiryTime: The expiry time of the access token.
    init(id: UUID? = nil,
         token: String,
         clientID: String,
         userID: String? = nil,
         scopes: [String]? = nil,
         expiryTime: Date
    ) {
        self.id = id
        self.token = token
        self.clientID = clientID
        self.userID = userID
        self.scopes = scopes
        self.expiryTime = expiryTime
    }
}
