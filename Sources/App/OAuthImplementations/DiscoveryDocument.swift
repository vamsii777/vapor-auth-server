import Vapor
import VaporOAuth

/// OpenID Connect Discovery Document
///
/// Specification: https://openid.net/specs/openid-connect-discovery-1_0.html
final class DiscoveryDocument: VaporOAuth.DiscoveryDocument {

    // Computed properties with hardcoded values
    var issuer: String? {
        return "OpenID Provider"
    }

    var authorizationEndpoint: String? {
        return "http://localhost:8090/oauth/authorize"
    }

    var tokenEndpoint: String? {
        return "http://localhost:8090/oauth/token"
    }

    var userInfoEndpoint: String? {
        return "http://localhost:8090/oauth/userinfo"
    }

    var revocationEndpoint: String? {
        return ""
    }

    var introspectionEndpoint: String? {
        return "http://localhost:8090/oauth/token_info"
    }

    var jwksURI: String? {
        return "http://localhost:8090/oauth/.well-known/jwks.json"
    }

    var registrationEndpoint: String? {
        return ""
    }

    var scopesSupported: [String]? {
        return ["code"]
    }

    var responseTypesSupported: [String]? {
        return ["query"]
    }

    var grantTypesSupported: [String]? {
        return ["authorization_code"]
    }

    var tokenEndpointAuthMethodsSupported: [String]? {
        return ["client_secret_basic"]
    }

    var tokenEndpointAuthSigningAlgValuesSupported: [String]? {
        return ["RS256"]
    }

    var serviceDocumentation: String? {
        return ""
    }

    var uiLocalesSupported: [String]? {
        return ["en-US"]
    }

    var opPolicyURI: String? {
        return ""
    }

    var opTosURI: String? {
        return ""
    }
    
    var claimsSupported: [String]? {
        return ["openid"]
    }
    
    var subjectTypesSupported: [String]? {
        return [""]
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
