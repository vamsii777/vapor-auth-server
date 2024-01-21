import Fluent
import Foundation

struct SeedPrivateCryptoKey: AsyncMigration {
    func prepare(on database: Database) async throws {
        
        let cryptokey = CryptoKey(
            keyType: .private,
            keyValue:
                """
                -----BEGIN EC PRIVATE KEY-----
                MHcCAQEEIHQLM5lSuUr9EIprgwVh29waBk3kFxCZLCbsKwVSKE2JoAoGCCqGSM49
                AwEHoUQDQgAEUdXNDo0lZCE0+SQbBGeCW3/kjU2CF5aF6QsnDla9tRbfKaQ8Wbwi
                rdLU3s9xmhDAt1RzlV9bBPOHT781aI9GnA==
                -----END EC PRIVATE KEY-----
                """,
            description: "EC prime256v1 private key",
            validFrom: Date(),
            isActive: true
        )

        return try await cryptokey.save(on: database)
    }
    
    func revert(on database: Database) async throws {
        try await CryptoKey.query(on: database).delete()
    }
}
