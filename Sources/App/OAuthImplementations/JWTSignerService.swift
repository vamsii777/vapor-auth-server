import Vapor
import VaporOAuth
import JWTKit

/// JWT Signer Service
final class JWTSignerService: VaporOAuth.JWTSignerService {
    
    let keyManagementService: VaporOAuth.KeyManagementService
    
    init(
        keyManagementService: VaporOAuth.KeyManagementService
    ) {
        self.keyManagementService = keyManagementService
    }
    
    func makeJWTSigner() async throws -> JWTSigner {
        let privateKeyIdentifier = try await keyManagementService.privateKeyIdentifier()
        let privateKey = try await keyManagementService.retrieveKey(identifier: privateKeyIdentifier, keyType: .private)
        return JWTSigner.es256(key: try .private(pem: privateKey))
    }
}
