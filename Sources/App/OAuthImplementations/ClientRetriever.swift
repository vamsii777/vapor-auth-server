import Vapor
import VaporOAuth
import Fluent


final class ClientRetriever: VaporOAuth.ClientRetriever {
    
    let app: Application
    
    init(app: Application) {
        self.app = app
    }
    
    func getClient(clientID: String) async throws -> VaporOAuth.OAuthClient? {
        
#if DEBUG
        print("\n-----------------------------")
        print("MyClientRetriever() \(#function)")
        print("-----------------------------")
        print("clientID: \(clientID)")
        print("-----------------------------")
#endif
        
        guard
            let client = try await Client
                .query(on: app.db)
                .filter(\.$clientId == clientID)
                .first()
        else {
            return nil
        }
        
#if DEBUG
        print("\n-----------------------------")
        print("MyClientRetriever() \(#function)")
        print("-----------------------------")
        print("Database query: \(client)")
        print("-----------------------------")
#endif
        
        let oauthClient = OAuthClient(
            clientID: client.clientId,
            redirectURIs: client.redirectUris,
            clientSecret: client.clientSecret,
            validScopes: client.scopes,
            confidential: client.confidentialClient,
            firstParty: client.firstParty ?? true,
            allowedGrantType: client.grantType
        )
        
#if DEBUG
        print("\n-----------------------------")
        print("MyClientRetriever() \(#function)")
        print("-----------------------------")
        print("OAuthClient redirect: \(oauthClient.redirectURIs)")
        print("-----------------------------")
#endif
        
        return oauthClient
        
    }
    
}
