import Vapor
import Fluent
import VaporOAuth

struct CryptoKeysRepository {
    let database: Database
    
    func create(_ key: CryptoKey, operation: KeyOperation) async throws {
        try await key.save(on: database).get()
        // Log the key operation
        let logEntry = KeyOperationLog(keyID: key.id!, operation: operation, timestamp: Date())
        try await logEntry.save(on: database).get()
    }
    
    func find(identifier: String, keyType: String) async throws -> CryptoKey? {
        guard let uuid = UUID(uuidString: identifier),
              let enumKeyType = KeyType(rawValue: keyType) else { return nil } // Convert string to KeyType enum
        
        return try await CryptoKey.query(on: database)
            .filter(\.$id == uuid)
            .filter(\.$keyType == enumKeyType) // Compare with KeyType enum
            .first()
            .get()
    }
    
    func delete(identifier: String) async throws {
        guard let uuid = UUID(uuidString: identifier) else { return }
        try await CryptoKey.query(on: database)
            .filter(\.$id == uuid)
            .delete()
            .get()
    }
    
    func list() async throws -> [CryptoKey] {
        try await CryptoKey.query(on: database).all().get()
    }
    
    func findActiveKey(keyType: KeyType) async throws -> CryptoKey {
        try await CryptoKey.query(on: database)
            .filter(\.$keyType == keyType)
            .filter(\.$isActive == true)
            .first()
            .unwrap(or: Abort(.notFound))
            .get()
    }
    
    func findActiveKeys(keyType: KeyType) async throws -> [CryptoKey] {
        try await CryptoKey.query(on: database)
            .filter(\.$keyType == keyType)
            .filter(\.$isActive == true)
            .all()
            .get()
    }
}
