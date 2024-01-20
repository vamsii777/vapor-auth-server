import Vapor

/// A protocol representing a claim that indicates the time at which the JWT was issued.
public protocol IssuedAtClaim: Codable { }

public extension IssuedAtClaim {
    
    /// The date and time at which the JWT was created.
    ///
    /// The `iat` property is automatically populated with the current date when the JWT is created.
    var iat: Date {
        return Date()
    }
    
}