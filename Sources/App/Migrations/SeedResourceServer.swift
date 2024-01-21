import Fluent
import Vapor

struct SeedResourceServer: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        
        let uuid = UUID()
        //let password = try Bcrypt.hash("resource-1-password")
        let password = "pass@d"
        
        let server = try ResourceServer(
            id: uuid,
            username: "dewonderstruck",
            password: password, encryptionKey: "i+/61SLnMj2A25nB6sVJnLtHkJQQNMDubwoCbx83bsk="
        )
        
        return try await server.save(on: database)
    }
    
    func revert(on database: Database) async throws {
        
        try await ResourceServer.query(on: database)
            .filter(\.$username == "dewonderstruck")
            .delete()
    }
    
}



