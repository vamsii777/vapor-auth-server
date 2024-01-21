import Fluent
import Foundation

struct SeedPublicCryptoKey: AsyncMigration {
    func prepare(on database: Database) async throws {
        
        let cryptokey = CryptoKey(
            keyType: .public,
            keyValue:
                """
                -----BEGIN PUBLIC KEY-----
                MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEUdXNDo0lZCE0+SQbBGeCW3/kjU2C
                F5aF6QsnDla9tRbfKaQ8WbwirdLU3s9xmhDAt1RzlV9bBPOHT781aI9GnA==
                -----END PUBLIC KEY-----
                """,
            description: "EC prime256v1 public key",
            validFrom: Date(),
            isActive: true
        )
        
        return try await cryptokey.save(on: database)
    }
    
    func revert(on database: Database) async throws {
        try await CryptoKey.query(on: database).delete()
    }
}
