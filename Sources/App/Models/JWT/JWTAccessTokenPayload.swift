import VaporOAuth
import JWTKit

/// Represents the payload of a JWT access token.
final class JWTAccessTokenPayload: VaporOAuth.AccessToken {

    /// The coding keys used for encoding and decoding the payload.
    enum CodingKeys: String, CodingKey {
        case jti
        case clientID = "aud"
        case userID = "sub"
        case scopes = "scope"
        case expiryTime = "exp"
        case issuer = "iss"
        case issuedAt = "iat"
        case notBefore = "nbf"  // Not Before Claim
        case authorizedParty = "azp"  // Authorized Party Claim
    }

    /// The unique identifier of the token.
    public var jti: String

    /// The client ID associated with the token.
    public var clientID: String

    /// The user ID associated with the token.
    public var userID: String?

    /// The scopes granted to the token.
    public var scopes: String?

    /// The expiry time of the token.
    public var expiryTime: Date

    /// The issuer of the token.
    public var issuer: String

    /// The time at which the token was issued.
    public var issuedAt: Date

    /// The time before which the token must not be accepted.
    public var notBefore: Date?

    /// The party the token is authorized for (typically, the client ID).
    public var authorizedParty: String?

    /// Initializes a new instance of the `JWTAccessTokenPayload` class.
    public init(jti: String,
                clientID: String,
                userID: String? = nil,
                scopes: String? = nil,
                expiryTime: Date,
                issuer: String,
                issuedAt: Date,
                notBefore: Date? = nil,
                authorizedParty: String? = nil
    ) {
        self.jti = jti
        self.clientID = clientID
        self.userID = userID
        self.scopes = scopes
        self.expiryTime = expiryTime
        self.issuer = issuer
        self.issuedAt = issuedAt
        self.notBefore = notBefore
        self.authorizedParty = authorizedParty
    }
}
