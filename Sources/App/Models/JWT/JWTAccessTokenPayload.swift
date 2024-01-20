import VaporOAuth
import JWTKit

/// Represents the payload of a JWT access token.
final class JWTAccessTokenPayload: VaporOAuth.AccessToken {
    
    /// The coding keys used for encoding and decoding the payload.
    enum CodingKeys: String, CodingKey {
        case jti = "jti"
        case clientID = "aud"
        case userID = "sub"
        case scopes = "scopes"
        case expiryTime = "exp"
        case issuer = "iss"
        case issuedAt = "iat"
    }
    
    /// The unique identifier of the token.
    public var jti: String
    
    /// The client ID associated with the token.
    public var clientID: String
    
    /// The user ID associated with the token.
    public var userID: String?
    
    /// The scopes granted to the token.
    public var scopes: [String]?
    
    /// The expiry time of the token.
    public var expiryTime: Date
    
    /// The issuer of the token.
    public var issuer: String
    
    /// The time at which the token was issued.
    public var issuedAt: Date
    
    /// Initializes a new instance of the `JWTAccessTokenPayload` struct.
    /// - Parameters:
    ///   - jti: The unique identifier of the token.
    ///   - clientID: The client ID associated with the token.
    ///   - userID: The user ID associated with the token.
    ///   - scopes: The scopes granted to the token.
    ///   - expiryTime: The expiry time of the token.
    ///   - issuer: The issuer of the token.
    ///   - issuedAt: The time at which the token was issued.
    public init(jti: String,
                clientID: String,
                userID: String? = nil,
                scopes: [String]? = nil,
                expiryTime: Date,
                issuer: String,
                issuedAt: Date
    ) {
        self.jti = jti
        self.clientID = clientID
        self.userID = userID
        self.scopes = scopes
        self.expiryTime = expiryTime
        self.issuer = issuer
        self.issuedAt = issuedAt
    }
    
}
