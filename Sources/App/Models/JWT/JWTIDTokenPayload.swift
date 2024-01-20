import VaporOAuth
import JWTKit

/// Represents the payload of a JWT ID token.
final class  JWTIDTokenPayload: VaporOAuth.IDToken {
    
    /// The coding keys for the payload properties.
    enum CodingKeys: String, CodingKey {
        case sub = "sub"
        case aud = "aud"
        case exp = "exp"
        case nonce = "nonce"
        case authTime = "auth_time"
        case iss = "iss"
        case iat = "iat"
        case jti = "jti"
    }
    
    /// The subject of the ID token.
    public var sub: String
    
    /// The audience of the ID token.
    public var aud: [String]
    
    /// The expiration date of the ID token.
    public var exp: Date
    
    /// The nonce value used during authentication.
    public var nonce: String?
    
    /// The authentication time.
    public var authTime: Date?
    
    /// The issuer of the ID token.
    public var iss: String
    
    /// The issued at date of the ID token.
    public var iat: Date
    
    /// The unique identifier of the ID token.
    public var jti: String
    
    /// Initializes a new instance of the JWTIDTokenPayload struct.
    /// - Parameters:
    ///   - sub: The subject of the ID token.
    ///   - aud: The audience of the ID token.
    ///   - exp: The expiration date of the ID token.
    ///   - nonce: The nonce value used during authentication.
    ///   - authTime: The authentication time.
    ///   - iss: The issuer of the ID token.
    ///   - iat: The issued at date of the ID token.
    ///   - jti: The unique identifier of the ID token.
    public init(sub: String,
                aud: [String],
                exp: Date,
                nonce: String?,
                authTime: Date?,
                iss: String,
                iat: Date,
                jti: String
    ) {
        self.sub = sub
        self.aud = aud
        self.exp = exp
        self.nonce = nonce
        self.authTime = authTime
        self.iss = iss
        self.iat = iat
        self.jti = jti
    }
    
    /// Verifies the expiration date of the ID token using the specified signer.
    /// - Parameter signer: The JWT signer to use for verification.
    /// - Throws: An error if the ID token has expired.
    public func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
    
}
