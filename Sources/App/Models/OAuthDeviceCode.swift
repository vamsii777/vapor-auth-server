import Vapor
import Fluent
import VaporOAuth

final class OAuthDeviceCode: Model, Content {

    static let schema = "oauth_device_codes"

    @Field(key: "id")
    var id: UUID?

    @Field(key: "device_code_id")
    var deviceCodeID: String

    @Field(key: "user_code")
    var userCode: String

    @Field(key: "client_id")
    var clientID: String

    @Field(key: "user_id")
    var userID: String?

    @Field(key: "expiry_date")
    var expiryDate: Date

    @Field(key: "scopes")
    var scopes: [String]?

    public var extend: [String: Any] = [:]
    
    /// Initializes a new instance of `OAuthDeviceCode`.
    init() {}

    public init(
        deviceCodeID: String,
        userCode: String,
        clientID: String,
        userID: String?,
        expiryDate: Date,
        scopes: [String]?
    ) {
        self.deviceCodeID = deviceCodeID
        self.userCode = userCode
        self.clientID = clientID
        self.userID = userID
        self.expiryDate = expiryDate
        self.scopes = scopes
    }

    public var isExpired: Bool {
        return Date() > expiryDate
    }
}
