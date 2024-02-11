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
    
    func retrieveKey(identifier: String, keyType: VaporOAuth.KeyType) async throws -> String {
        guard let keyRecord = try await cryptoKeysRepository.find(identifier: identifier, keyType: keyType.rawValue) else {
            throw Abort(.notFound)
        }
        return keyRecord.keyValue
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
    
    func convertToJWK(_ publicKey: String) throws -> [JWK] {
        // Assuming publicKey is a PEM-encoded EC public key
        guard let ecPublicKey = try? P256.KeyAgreement.PublicKey(pemRepresentation: publicKey) else {
            throw NSError(domain: "PublicKeyError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to initialize EC public key from PEM"])
        }
        
        // Extract X and Y coordinates from the public key
        let x = ecPublicKey.x963Representation[1..<33].base64URLEncodedString()
        let y = ecPublicKey.x963Representation[33..<65].base64URLEncodedString()
        
        // Calculate the "kid" (Key ID) using a hash function on the X and Y coordinates for simplicity
        // In practice, this might involve more specific requirements for ID generation
        let publicKeyData = Data(ecPublicKey.x963Representation)
        let sha256 = SHA256.hash(data: publicKeyData)
        let kid = JWKIdentifier(stringLiteral: Data(sha256).base64URLEncodedString())
        
        // Construct the JWK
        let jwk: JWK = .ecdsa(.es256, identifier: kid, x: x, y: y, curve: .p256)
        
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
