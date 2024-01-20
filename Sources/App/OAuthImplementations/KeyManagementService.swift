import Vapor
import FluentMongoDriver
import JWTKit
import VaporOAuth
import Crypto

final class MyKeyManagementService: VaporOAuth.KeyManagementService {
    
    private let app: Application
    private let cryptoKeysRepository: CryptoKeysRepository
    
    init(app: Application, cryptoKeysRepository: CryptoKeysRepository) {
        self.app = app
        self.cryptoKeysRepository = cryptoKeysRepository
    }
    
    func generateKey() async throws -> (privateKeyIdentifier: String, publicKeyIdentifier: String) {
        let privateKey = P256.KeyAgreement.PrivateKey()
        let publicKey = privateKey.publicKey
        
        let privateKeyPem = privateKey.pemRepresentation
        let publicKeyPem = publicKey.pemRepresentation
        
        let privateKeyRecord = CryptoKey(keyType: .private, keyValue: privateKeyPem, validFrom: Date(), validUntil: Date().addingTimeInterval(365*24*60*60), isActive: true)
        let publicKeyRecord = CryptoKey(keyType: .public, keyValue: publicKeyPem, validFrom: Date(), validUntil: Date().addingTimeInterval(365*24*60*60), isActive: true)
        
        try await cryptoKeysRepository.create(privateKeyRecord, operation: .create)
        try await cryptoKeysRepository.create(publicKeyRecord, operation: .create)
        
        // Assuming the ID is generated during the 'create' process and is available in the record
        guard let privateKeyId = privateKeyRecord.id?.uuidString, let publicKeyId = publicKeyRecord.id?.uuidString else {
            throw Abort(.internalServerError)
        }
        
        return (privateKeyId, publicKeyId)
    }
    
    func storeKey(_ key: String, keyType: VaporOAuth.KeyType) async throws {
        let keyRecord = CryptoKey(keyType: keyType, keyValue: key, validFrom: Date(), isActive: true)
        try await cryptoKeysRepository.create(keyRecord, operation: .create)
    }
    
    func retrieveKey(identifier: String, keyType: VaporOAuth.KeyType) async throws -> Data {
        guard let keyRecord = try await cryptoKeysRepository.find(identifier: identifier, keyType: keyType.rawValue) else {
            throw Abort(.notFound)
        }
        
        // Ensure that the key type is "private" because P-256 keys don't have a public/private distinction like RSA
        guard keyType == .private else {
            throw Abort(.badRequest, reason: "Invalid key type for P-256 key")
        }
        
        // Parse the PEM representation of the private key
        let privateKeyPem = keyRecord.keyValue
        guard let privateKey = try? P256.Signing.PrivateKey(pemRepresentation: privateKeyPem) else {
            throw Abort(.internalServerError, reason: "Failed to parse P-256 private key")
        }
        
        return privateKey.rawRepresentation
    }
    
    func listKeys() async throws -> [String] {
        let keys = try await cryptoKeysRepository.list()
        return keys.map { $0.keyValue }
    }
    
    func deleteKey(identifier: String) async throws {
        return try await cryptoKeysRepository.delete(identifier: identifier)
    }
    
    func publicKeyIdentifier() async throws -> String {
        let keyRecord = try await cryptoKeysRepository.findActiveKey(keyType: .public)
        // Assuming `keyRecord` has a property named `keyIdentifier` which is a String
        return keyRecord.id!.uuidString
    }
    
    func rotateKey(deprecateOld: Bool) async throws {
        let oldPrivateKey = try await cryptoKeysRepository.findActiveKey(keyType: .private)
        let newPrivateKey = P256.KeyAgreement.PrivateKey()
        let newPublicKey = newPrivateKey.publicKey
        
        let privateKeyPem = newPrivateKey.pemRepresentation
        let publicKeyPem = newPublicKey.pemRepresentation
        
        let newPrivateKeyRecord = CryptoKey(keyType: .private, keyValue: privateKeyPem, validFrom: Date(), validUntil: Date().addingTimeInterval(365*24*60*60), isActive: true)
        let newPublicKeyRecord = CryptoKey(keyType: .public, keyValue: publicKeyPem, validFrom: Date(), validUntil: Date().addingTimeInterval(365*24*60*60), isActive: true)
        
        
        try await cryptoKeysRepository.create(newPrivateKeyRecord, operation: .rotate)
        try await cryptoKeysRepository.create(newPublicKeyRecord, operation: .rotate)
        
        
        if deprecateOld {
            oldPrivateKey.isActive = false
            try await cryptoKeysRepository.create(oldPrivateKey, operation: .deprecate)
            // Also handle the deprecation of the old public key if necessary
            let oldPublicKey = try await cryptoKeysRepository.findActiveKey(keyType: .public)
            oldPublicKey.isActive = false
            try await cryptoKeysRepository.create(oldPublicKey, operation: .deprecate)
        }
    }
    
    func privateKeyIdentifier() async throws -> String {
        let keyRecord = try await cryptoKeysRepository.findActiveKey(keyType: .private)
//        for key in keyRecord {
//            if key.isActive {
//                return key.keyValue
//            }
//        }
        return keyRecord.id!.uuidString
    }
    
    func calculateKid(_ publicKey: Data) -> JWKIdentifier {
        // Create a SHA-256 hash of the public key data
        let sha256 = SHA256.hash(data: publicKey)
        
        // Convert the hash to a Base64URL encoded string
        let base64URL = Data(sha256).base64URLEncodedString()
        
        return JWKIdentifier(stringLiteral: base64URL)
    }
    
    func convertToJWK(_ publicKey: Data) throws -> [JWK] {
        // Since P-256 keys are 64 bytes in length (32 bytes for X and 32 bytes for Y),
        // split the raw bytes into X and Y components.
        // Note: This might vary for different key types.
        guard publicKey.count == 64 else {
            throw NSError(domain: "InvalidKeyLength", code: -1, userInfo: nil)
        }
        
        let xBytes = publicKey.prefix(32)
        let yBytes = publicKey.suffix(32)
        
        // Convert the X and Y bytes to Base64URL encoded strings
        let xBase64 = xBytes.base64EncodedString()
        let yBase64 = yBytes.base64EncodedString()
        
        // Calculate the "kid" (Key ID)
        let kid = calculateKid(publicKey)
        
        // Construct the JWK dictionary
        let jwk: JWK = .ecdsa(.es256, identifier: kid, x: xBase64, y: yBase64, curve: .p256)
        
        return [jwk]
    }
}


// Utility function to Base64URL encode Data
extension Data {
    func base64URLEncodedString() -> String {
        var base64 = self.base64EncodedString()
        base64 = base64.replacingOccurrences(of: "+", with: "-")
        base64 = base64.replacingOccurrences(of: "/", with: "_")
        base64 = base64.trimmingCharacters(in: CharacterSet(["="]))
        return base64
    }
}
