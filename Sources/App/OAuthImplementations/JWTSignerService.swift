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
        let privateKeyData = try await keyManagementService.retrieveKey(identifier: privateKeyIdentifier, keyType: .private)
        
        // I'm lazy to import
        let privateKeyPEM = """
                -----BEGIN EC PRIVATE KEY-----
                MHcCAQEEIHQLM5lSuUr9EIprgwVh29waBk3kFxCZLCbsKwVSKE2JoAoGCCqGSM49
                AwEHoUQDQgAEUdXNDo0lZCE0+SQbBGeCW3/kjU2CF5aF6QsnDla9tRbfKaQ8Wbwi
                rdLU3s9xmhDAt1RzlV9bBPOHT781aI9GnA==
                -----END EC PRIVATE KEY-----
                """
        
        return JWTSigner.es256(key: try .private(pem: privateKeyPEM))
    }
}

extension String {
    func chunked(into size: Int) -> [String] {
        return stride(from: 0, to: self.count, by: size).map {
            let start = self.index(self.startIndex, offsetBy: $0)
            let end = self.index(start, offsetBy: size, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[start..<end])
        }
    }
}
