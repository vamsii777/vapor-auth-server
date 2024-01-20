import Vapor
import VaporOAuth

extension OAuthUser: SessionAuthenticatable {
    
    /// Conforms to the `SessionAuthenticatable` protocol.
    ///
    /// This extension allows the `OAuthUser` model to be used for session authentication.
    ///
    /// - Returns: The session ID as a string. If the `id` property is `nil`, an empty string is returned.
    public var sessionID: String { self.id ?? "" }
    
}




