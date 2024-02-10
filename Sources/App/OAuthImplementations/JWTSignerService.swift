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
        let privateKeyData = try await keyManagementService.retrieveKey(identifier: privateKeyIdentifier, keyType: .private)
        return JWTSigner.es256(key: try .private(pem: privateKeyData))
    }
}
