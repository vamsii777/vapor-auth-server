import Vapor
import VaporOAuth
import JWTKit

/// JWT Signer Service
final class JWTSignerService: VaporOAuth.JWTSignerService {
    
    let keyManagementService: VaporOAuth.KeyManagementService
    
    private let cryptoKeysRepository: CryptoKeysRepository
    
    init(
        keyManagementService: VaporOAuth.KeyManagementService,
        cryptoKeysRepository: CryptoKeysRepository
    ) {
        self.keyManagementService = keyManagementService
        self.cryptoKeysRepository = cryptoKeysRepository
    }
    
    func makeJWTSigner() async throws -> JWTSigner {
        let privateKeyIdentifier = try await keyManagementService.privateKeyIdentifier()
        let privateKeyData = try await retrivePrivateKey(identifier: privateKeyIdentifier)
        return JWTSigner.es256(key: try .private(pem: privateKeyData))
    }
    
    public func retrivePrivateKey(identifier: String) async throws -> String {
        guard let keyRecord = try await cryptoKeysRepository.find(identifier: identifier, keyType: "private") else {
            throw Abort(.notFound)
        }
        return keyRecord.keyValue
    }
}
