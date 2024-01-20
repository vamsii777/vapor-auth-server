import VaporOAuth
import JWTKit

/// Represents the payload of a JWT refresh token.
final class JWTRefreshTokenPayload: VaporOAuth.RefreshToken {
    
    /// The unique identifier of the token.
    public var jti: String
    
    /// The client ID associated with the token.
    public var clientID: String
    
    /// The user ID associated with the token.
    public var userID: String?
    
    /// The scopes granted to the token.
    public var scopes: [String]?
    
    /// The expiration date of the token.
    public var exp: Date
    
    /// The issuer of the token.
    public var issuer: String
    
    /// The date and time when the token was issued.
    public var issuedAt: Date
    
    /// The coding keys used for encoding and decoding the token payload.
    enum CodingKeys: String, CodingKey {
        case jti = "jti"
        case clientID = "aud"
        case userID = "sub"
        case scopes = "scopes"
        case exp = "exp"
        case issuer = "iss"
        case issuedAt = "iat"
    }
    
    /// Initializes a new instance of `JWTRefreshTokenPayload`.
    /// - Parameters:
    ///   - jti: The unique identifier of the token.
    ///   - clientID: The client ID associated with the token.
    ///   - userID: The user ID associated with the token.
    ///   - scopes: The scopes granted to the token.
    ///   - exp: The expiration date of the token.
    ///   - issuer: The issuer of the token.
    ///   - issuedAt: The date and time when the token was issued.
    init(
        jti: String,
        clientID: String,
        userID: String? = nil,
        scopes: [String]? = nil,
        exp: Date,
        issuer: String,
        issuedAt: Date
    ) {
        self.jti = jti
        self.clientID = clientID
        self.userID = userID
        self.scopes = scopes
        self.exp = exp
        self.issuer = issuer
        self.issuedAt = issuedAt
    }
    
}
