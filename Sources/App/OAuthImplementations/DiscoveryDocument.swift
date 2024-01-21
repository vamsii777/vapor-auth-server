import Vapor
import VaporOAuth

/// OpenID Connect Discovery Document
///
/// Specification: https://openid.net/specs/openid-connect-discovery-1_0.html
final class DiscoveryDocument: VaporOAuth.DiscoveryDocument {

    // Computed properties with hardcoded values
    var issuer: String? {
        return Environment.get("ISSUER")
    }

    var authorizationEndpoint: String? {
        return Environment.get("AUTHORIZATION_ENDPOINT")
    }

    var tokenEndpoint: String? {
        return Environment.get("TOKEN_ENDPOINT")
    }

    var userInfoEndpoint: String? {
        return Environment.get("USERINFO_ENDPOINT")
    }

    var revocationEndpoint: String? {
        return Environment.get("REVOCATION_ENDPOINT")
    }

    var introspectionEndpoint: String? {
        return Environment.get("INTROSPECTION_ENDPOINT")
    }

    var jwksURI: String? {
        return Environment.get("JWKS_URI")
    }

    var registrationEndpoint: String? {
        return Environment.get("REGISTRATION_ENDPOINT")
    }

    var scopesSupported: [String]? {
        return Environment.get("SCOPES_SUPPORTED")?.split(separator: ",").map { String($0) }
    }

    var responseTypesSupported: [String]? {
        return Environment.get("RESPONSE_TYPES_SUPPORTED")?.split(separator: ",").map { String($0) }
    }

    var grantTypesSupported: [String]? {
        return Environment.get("GRANT_TYPES_SUPPORTED")?.split(separator: ",").map { String($0) }
    }

    var tokenEndpointAuthMethodsSupported: [String]? {
        return Environment.get("TOKEN_ENDPOINT_AUTH_METHODS_SUPPORTED")?.split(separator: ",").map { String($0) }
    }

    var tokenEndpointAuthSigningAlgValuesSupported: [String]? {
        return Environment.get("TOKEN_ENDPOINT_AUTH_SIGNING_ALG_VALUES_SUPPORTED")?.split(separator: ",").map { String($0) }
    }

    var serviceDocumentation: String? {
        return Environment.get("SERVICE_DOCUMENTATION")
    }

    var uiLocalesSupported: [String]? {
        return Environment.get("UI_LOCALES_SUPPORTED")?.split(separator: ",").map { String($0) }
    }

    var opPolicyURI: String? {
        return Environment.get("OP_POLICY_URI")
    }

    var opTosURI: String? {
        return Environment.get("OP_TOS_URI")
    }
    
    var claimsSupported: [String]? {
        return Environment.get("CLAIMS_SUPPORTED")?.split(separator: ",").map { String($0) }
    }
    
    var subjectTypesSupported: [String]? {
        return Environment.get("SUBJECT_TYPES_SUPPORTED")?.split(separator: ",").map { String($0) }
    }


    // Dummy code for 'extend' property
    var extend: [String: Any] {
        get { return ["": ""] }
        set { }
    }

    // Optional properties not redefined as computed properties
    var responseModesSupported: [String]?
    var acrValuesSupported: [String]?
    var idTokenEncryptionAlgValuesSupported: [String]?
    var idTokenEncryptionEncValuesSupported: [String]?
    var userinfoSigningAlgValuesSupported: [String]?
    var userinfoEncryptionAlgValuesSupported: [String]?
    var userinfoEncryptionEncValuesSupported: [String]?
    var requestObjectSigningAlgValuesSupported: [String]?
    var requestObjectEncryptionAlgValuesSupported: [String]?
    var requestObjectEncryptionEncValuesSupported: [String]?
    var displayValuesSupported: [String]?
    var claimTypesSupported: [String]?
    var claimsLocalesSupported: [String]?
    var claimsParameterSupported: Bool?
    var requestParameterSupported: Bool?
    var requestUriParameterSupported: Bool?
    var requireRequestUriRegistration: Bool?
    
    var resourceServerRetriever: VaporOAuth.ResourceServerRetriever? {
        return nil
    }
}
