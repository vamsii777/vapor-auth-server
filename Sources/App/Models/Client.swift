import Fluent
import VaporOAuth
import Vapor

extension OAuthFlowType: Content {}
/// Clients
///
/// - Parameters:
///   - id: unique identifier (uuid) in the database
///   - client_id: unique identifier of the client. separate from the id as the requirement for the client_id is to be as string value
///   - redirect_uri: allowed redirect uris for this client
///   - client_secret: client secret
///   - scopes: allowed scopes for this client
///   - confidential_client: An application that can securely store confidential secrets with which to authenticate itself to an authorization server or use another secure authentication mechanism for that purpose. Confidential clients typically execute primarily on a protected server.
///   - first_party: First-party applications are those controlled by the same organization or person who owns this authorization provider.
///   - grant_type: authorization_code
///
/// Represents a client in the authentication system.
final class Client: Model, Content {
    
    static let schema = "clients"
    
    @ID(key: .id)
    var id: UUID?
    
    // Username must be unique
    @Field(key: "client_id")
    var clientId: String
    
    var redirectUris: [String]? {
        get {
            guard let redirectUris = _redirectUris else { return nil }
            let redirect_uris_Array = redirectUris.split(separator: ",")
            return redirect_uris_Array.map(String.init)
        }
        set {
            guard let newValue = newValue else {
                _redirectUris = nil
                return
            }
            _redirectUris = newValue.joined(separator: ",")
        }
    }
    
    @OptionalField(key: "redirect_uris")
    var _redirectUris: String?
    
    @OptionalField(key: "client_secret")
    var clientSecret: String?
    
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
    
    @OptionalField(key: "scopes")
    var _scopes: String?
    
    // Confidential clients are applications that are able to securely authenticate with the authorization server, for example being able to keep their registered client secret safe.
    // Public clients are unable to use registered client secrets, such as applications running in a browser or on a mobile device.
    @OptionalField(key: "confidential_client")
    var confidentialClient: Bool?
    
    // First-party applications are applications that the user recognizes as belonging to the same brand as the authorization server. For example, a bank publishing their own mobile application.
    @OptionalField(key: "first_party")
    var firstParty: Bool?
    
    @Enum(key: "grant_type")
    var grantType: OAuthFlowType
    
    init() {}
    
    init(
        id: UUID? = nil,
        clientId: String,
        redirectUris: [String]?,
        clientSecret: String?,
        scopes: [String]?,
        confidentialClient: Bool?,
        firstParty: Bool?,
        grantType: OAuthFlowType
    ) throws {
        self.id = id
        self.clientId = clientId
        self.clientSecret = try Bcrypt.hash(clientSecret!)
        self.redirectUris = redirectUris
        self.scopes = scopes
        self.confidentialClient = confidentialClient
        self.firstParty = firstParty
        self.grantType = grantType
    }
    
    /// Verifies the provided secret against the client's stored secret.
    /// - Parameter secret: The secret to verify.
    /// - Returns: `true` if the secret is valid, `false` otherwise.
    func verifySecret(_ secret: String) throws -> Bool {
        try Bcrypt.verify(secret, created: self.clientSecret!)
    }
}
