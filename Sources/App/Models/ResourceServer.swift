import Fluent
import Vapor
import Crypto

/// Represents a resource server in the application.
final class ResourceServer: Model, Content {
    static let schema = "resource_servers"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "encrypted_password")
    var encryptedPassword: String
    
    /// Initializes a new instance of `ResourceServer`.
    init() {}
    
    /// Initializes a new instance of `ResourceServer` with the specified parameters.
    /// - Parameters:
    ///   - id: The ID of the resource server.
    ///   - username: The username of the resource server.
    ///   - password: The password of the resource server.
    ///   - encryptionKey: The encryption key used to encrypt the password.
    /// - Throws: An error if the encryption fails.
    init(
        id: UUID? = nil,
        username: String,
        password: String,
        encryptionKey: String
    ) throws {
        self.id = id
        self.username = username
        self.encryptedPassword = try ResourceServer.encrypt(password: password, withKey: encryptionKey)
    }
    
    /// Retrieves the decrypted password using the specified decryption key.
    /// - Parameter decryptionKey: The decryption key used to decrypt the password.
    /// - Returns: The decrypted password.
    /// - Throws: An error if the decryption fails.
    func getPassword(decryptionKey: String) throws -> String {
        try ResourceServer.decrypt(password: self.encryptedPassword, withKey: decryptionKey)
    }
    
    private static func symmetricKey(from base64Key: String) throws -> SymmetricKey {
        guard let keyData = Data(base64Encoded: base64Key) else {
            throw Abort(.internalServerError, reason: "Invalid encryption key format")
        }
        return SymmetricKey(data: keyData)
    }

    private static func encrypt(password: String, withKey base64Key: String) throws -> String {
        let keyBytes = try symmetricKey(from: base64Key)
        let sealedBox = try AES.GCM.seal(password.data(using: .utf8)!, using: keyBytes)
        return sealedBox.combined!.base64EncodedString()
    }

    private static func decrypt(password: String, withKey base64Key: String) throws -> String {
        let keyBytes = try symmetricKey(from: base64Key)
        guard let data = Data(base64Encoded: password),
              let sealedBox = try? AES.GCM.SealedBox(combined: data) else {
            throw Abort(.internalServerError, reason: "Failed to decode encrypted password")
        }
        let decryptedData = try AES.GCM.open(sealedBox, using: keyBytes)
        return String(data: decryptedData, encoding: .utf8)!
    }

}
