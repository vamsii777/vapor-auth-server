import Vapor
import VaporOAuth
import Fluent

final class ResourceServerRetriever: VaporOAuth.ResourceServerRetriever {
    let app: Application
    
    init(app: Application) {
        self.app = app
    }
    
    func getServer(_ username: String) async throws -> VaporOAuth.OAuthResourceServer? {
        // Validate the input
        guard !username.isEmpty else {
            // Optionally log this as a warning or throw an exception
            throw Abort(.badRequest, reason: "Username is empty")
        }
        
        // Fetch the server from the database
        guard let server = try await ResourceServer
            .query(on: app.db)
            .filter(\.$username == username)
            .first() else {
                // Log the event of not finding the server or handle accordingly
                return nil
        }
        
        // Create and return the OAuthResourceServer object
        return OAuthResourceServer(username: server.username, password: server.encryptedPassword)
    }
}
