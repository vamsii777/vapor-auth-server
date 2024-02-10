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
    static let schema: String = "access_tokens"
    
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
    
    /// The internal representation of the scopes as a string.
    @Field(key: "scopes")
    var scopes: String?
    
    /// The expiry time of the access token.
    @Field(key: "expiry_time")
    var expiryTime: Date
    
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
    
    // The 'jti' field is mapped to the model's 'id' to use it as the JWT's unique identifier.
    // This is a design decision to simplify the token handling and adhere to JWT best practices.
    var jti: String {
        id?.uuidString ?? ""
    }
    
    /// Initializes an access token from a decoder.
    /// - Parameters:
    ///   - decoder: The decoder to decode the access token from.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userID = try container.decodeIfPresent(String.self, forKey: .sub)
        expiryTime = try container.decodeIfPresent(Date.self, forKey: .exp) ?? Date()
        issuer = try container.decodeIfPresent(String.self, forKey: .iss) ?? ""
        clientID = try container.decodeIfPresent(String.self, forKey: .aud) ?? ""
        
        // Decode `iat` as a Date and then convert to String if needed.
        let iatDate = try container.decodeIfPresent(Date.self, forKey: .iat) ?? Date()
        // Format Date to String here, according to your preferred format.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // ISO 8601 format
        iat = dateFormatter.string(from: iatDate)
        
        // The 'jti' field is not directly stored as it's derived from the 'id' property.
        // Hence, it's not decoded here but will be handled as part of JWT payload encoding/decoding.
    }
    
    /// Encodes the access token to an encoder.
    /// - Parameters:
    ///   - encoder: The encoder to encode the access token to.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(userID, forKey: .sub)
        try container.encode(expiryTime, forKey: .exp)
        try container.encode(issuer, forKey: .iss)
        try container.encode(clientID, forKey: .aud)
        
        // Encode 'iat' as a Date.
        try container.encode(iat, forKey: .iat)
        
        // Encode 'jti' using 'id' property, assuming 'id' is available and is a UUID.
        if let id = id {
            try container.encode(id.uuidString, forKey: .jti)
        }
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
         scopes: String? = nil,
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
