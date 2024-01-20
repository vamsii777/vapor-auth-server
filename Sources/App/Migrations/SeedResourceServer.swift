import Fluent
import Vapor

struct SeedResourceServer: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        
        let uuid = UUID()
        //let password = try Bcrypt.hash("resource-1-password")
        let password = "resource-1-password"
        
        let server = try ResourceServer(
            id: uuid,
            username: "resource-1",
            password: password, encryptionKey: "hello"
        )
        
        return try await server.save(on: database)
    }
    
    func revert(on database: Database) async throws {
        
        try await ResourceServer.query(on: database)
            .filter(\.$username == "resource-1")
            .delete()
    }
    
}



