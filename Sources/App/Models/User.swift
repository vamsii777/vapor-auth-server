import Vapor
import Fluent

/// User Model
///
/// Customized:
/// - newsletter: Bool to indicate if a newsletter is requested
/// - blocked: Bool to indicate if a user is blocked
/// - number_of_logins: Counter to see how often the user logged in
/// - cookie_preferences: Cookie preferences
/// - oauth_provider: Authentication Provider used
/// - federated: Bool to indicate a user was not authenticated via this service
///
/// Entitlements:
///
/// - scopes: The scopes this user is entitled for. You might also create roles and attach entitlements to roles. In this example the scope is used for entitlements
///
/// OpenID Connect (https://openid.net/specs/openid-connect-core-1_0.html#UserInfo)
///
/// - sub: Subject - Identifier for the End-User at the Issuer. (= id)
/// - name: End-User's full name in displayable form including all name parts, possibly including titles and suffixes, ordered according to the End-User's locale and preferences.
/// - email: End-User's preferred e-mail address. Its value MUST conform to the RFC 5322 [RFC5322] addr-spec syntax. The RP MUST NOT rely upon this value being unique, as discussed in Section 5.7.
/// - email_verified: True if the End-User's e-mail address has been verified; otherwise false. When this Claim Value is true, this means that the OP took affirmative steps to ensure that this e-mail address was controlled by the End-User at the time the verification was performed. The means by which an e-mail address is verified is context specific, and dependent upon the trust framework or contractual agreements within which the parties are operating.
/// - given_name: Given name(s) or first name(s) of the End-User. Note that in some cultures, people can have multiple given names; all can be present, with the names being separated by space characters.
/// - family_name: Surname(s) or last name(s) of the End-User. Note that in some cultures, people can have multiple family names or no family name; all can be present, with the names being separated by space characters.
/// - nickname: Casual name of the End-User that may or may not be the same as the given_name. For instance, a nickname value of Mike might be returned alongside a given_name value of Michael.
/// – profile: URL of the End-User's profile page. The contents of this Web page SHOULD be about the End-User.
/// - picture: URL of the End-User's profile picture. This URL MUST refer to an image file (for example, a PNG, JPEG, or GIF image file), rather than to a Web page containing an image. Note that this URL SHOULD specifically reference a profile photo of the End-User suitable for displaying when describing the End-User, rather than an arbitrary photo taken by the End-User.
/// - website: URL of the End-User's Web page or blog. This Web page SHOULD contain information published by the End-User or an organization that the End-User is affiliated with.
/// - gender: End-User's gender. Values defined by this specification are female and male. Other values MAY be used when neither of the defined values are applicable.
/// - birthdate: End-User's birthday, represented as an ISO 8601-1 [ISO8601‑1] YYYY-MM-DD format. The year MAY be 0000, indicating that it is omitted. To represent only the year, YYYY format is allowed. Note that depending on the underlying platform's date related function, providing just year can result in varying month and day, so the implementers need to take this factor into account to correctly process the dates.
/// - zoneinfo: String from IANA Time Zone Database [IANA.time‑zones] representing the End-User's time zone. For example, Europe/Paris or America/Los_Angeles.
/// - locale: End-User's locale, represented as a BCP47 [RFC5646] language tag. This is typically an ISO 639 Alpha-2 [ISO639] language code in lowercase and an ISO 3166-1 Alpha-2 [ISO3166‑1] country code in uppercase, separated by a dash. For example, en-US or fr-CA. As a compatibility note, some implementations have used an underscore as the separator rather than a dash, for example, en_US; Relying Parties MAY choose to accept this locale syntax as well.
/// - phone_number: End-User's preferred telephone number. E.164 [E.164] is RECOMMENDED as the format of this Claim, for example, +1 (425) 555-1212 or +56 (2) 687 2400. If the phone number contains an extension, it is RECOMMENDED that the extension be represented using the RFC 3966 [RFC3966] extension syntax, for example, +1 (604) 555-1234;ext=5678.
/// - phone_number_verified: The means by which a phone number is verified is context specific, and dependent upon the trust framework or contractual agreements within which the parties are operating. When true, the phone_number Claim MUST be in E.164 format and any extensions MUST be represented in RFC 3966 format.
///
/// User activities
///
/// - updated_at: Time the End-User's information was last updated. Its value is a JSON number representing the number of seconds from 1970-01-01T00:00:00Z as measured in UTC until the date/time.
/// - created_at: Time the End-Users information was created.
/// - validated_at: Time the End-user was validated
/// - last_login: Time the user logged in the last time
///
final class UserModel: Model, Content {
    
    static let schema = "user"
    
    // Primary key must be named id (Fluent requirement)
    @ID(key: .id) var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password")
    var password: String
    
    @OptionalField(key: "email")
    var emailAddress: String?
    
    @OptionalBoolean(key: "email_verified")
    var emailAddressVerified: Bool?
    
    @OptionalField(key: "given_name") // first name
    var givenName: String?
    
    @OptionalField(key: "family_name") // last name
    var familyName: String?
    
    @OptionalField(key: "middle_name")
    var middleName: String?
    
    @OptionalField(key: "nickname")
    var nickname: String?
    
    @OptionalField(key: "profile")
    var profile: String?
    
    @OptionalField(key: "picture")
    var picture: String?
    
    @OptionalField(key: "website")
    var website: String?
    
    @OptionalField(key: "gender")
    var gender: String?
    
    @OptionalField(key: "birthdate")
    var birthdate: String?
    
    @OptionalField(key: "zoneinfo")
    var zoneinfo: String?
    
    @OptionalField(key: "locale")
    var locale: String?
    
    @OptionalField(key: "phone_number")
    var phoneNumber: String?
    
    @OptionalBoolean(key: "phone_number_verified")
    var phoneNumberVerified: Bool?
    
    @Timestamp(key: "created_at", on: .create, format: .default)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update, format: .default)
    var updatedAt: Date?
    
    @Timestamp(key: "last_login", on: .none, format: .default)
    var lastLogin: Date?
    
    @Timestamp(key: "validated_at", on: .none, format: .default)
    var validatedAt: Date?
    
    @Field(key: "number_of_logins")
    var numberOfLogins: Int
    
    var roles: [String] {
        get {
            let rolesArray = _roles.split(separator: ",")
            return rolesArray.map(String.init)
        }
        set {
            _roles = newValue.joined(separator: ",")
        }
    }
    
    @Field(key: "roles")
    var _roles: String
    
    @Field(key: "cookie_preferences")
    var cookiePreferences: CookiePreferences?
    
    @Boolean(key: "newsletter")
    var newsletter: Bool
    
    @Boolean(key: "blocked")
    var blocked: Bool
    
    @OptionalBoolean(key: "federated")
    var federated: Bool?
    
    @Field(key: "oauth_provider")
    var oauthProvider: OAuthProvider?
    
    var sub: String? {
        return id?.uuidString
    }
    
    var name: String? {
        var result: String = ""
        if let givenName { result += "\(givenName) " }
        if let middleName { result += "\(middleName) " }
        if let familyName { result += "\(familyName)" }
        return result
    }
    
    init() { }
    
    init(
        id: UUID? = nil,
        username: String,
        password: String,
        emailAddress: String?,
        emailAddressVerified: Bool?,
        givenName: String?,
        familyName: String?,
        middleName: String?,
        nickname: String?,
        profile: String?,
        picture: String?,
        website: String?,
        gender: String?,
        birthdate: String?,
        zoneinfo: String?,
        locale: String?,
        phoneNumber: String?,
        phoneNumberVerified: Bool?,
        roles: [String],
        newsletter: Bool = true,
        blocked: Bool = false,
        lastLogin: Date? = nil,
        numberOfLogins: Int = 0,
        validatedAt: Date? = nil,
        cookiePreferences: CookiePreferences? = .NOT_SET,
        federated: Bool = false,
        oauthProvider: OAuthProvider? = .SELF
    ) {
        self.id = id
        self.username = username
        self.password = password
        self.emailAddress = emailAddress
        self.emailAddressVerified = emailAddressVerified
        self.givenName = givenName
        self.familyName = familyName
        self.middleName = middleName
        self.nickname = nickname
        self.profile = profile
        self.picture = picture
        self.website = website
        self.gender = gender
        self.birthdate = birthdate
        self.zoneinfo = zoneinfo
        self.locale = locale
        self.phoneNumber = phoneNumber
        self.phoneNumberVerified = phoneNumberVerified
        self.roles = roles
        self.newsletter = newsletter
        self.blocked = blocked
        self.lastLogin = lastLogin
        self.numberOfLogins = numberOfLogins
        self.validatedAt = validatedAt
        self.cookiePreferences = cookiePreferences
        self.federated = federated
        self.oauthProvider = oauthProvider
    }
    
}

// WEB AUTHENTICATION ------------------------------------------

// Save and retrieve user as part of a session
extension UserModel: ModelSessionAuthenticatable {}

// Authenticate users with username and password when they log in
extension UserModel: ModelCredentialsAuthenticatable {}

extension UserModel: ModelAuthenticatable {
    
    static let usernameKey = \UserModel.$username
    static let passwordHashKey = \UserModel.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}


