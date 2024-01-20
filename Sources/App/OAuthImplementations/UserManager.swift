import Vapor
import VaporOAuth
import Fluent
import JWTKit

final class UserManager: VaporOAuth.UserManager {
    
    let app: Application
    
    init(app: Application) {
        self.app = app
    }
    
    /// User login
    func authenticateUser(username: String, password: String) async throws -> String? {
        // Check if the username is valid
        guard !username.isEmpty else {
            // Optionally log this as a warning or throw an exception
            throw Abort(.badRequest, reason: "Username is empty")
        }
        
        // Check if the password is valid
        guard !password.isEmpty else {
            // Optionally log this as a warning or throw an exception
            throw Abort(.badRequest, reason: "Password is empty")
        }
        
        // Fetch the user from the database
        guard let user = try await UserModel
            .query(on: app.db)
            .filter(\.$username == username)
            .first() else {
            // Log the event of not finding the user or handle accordingly
            return nil
        }
        
        // Verify the password
        guard try user.verify(password: password) else {
            // Log the failed login attempt or handle accordingly
            return nil
        }
        
        // Return the user's UUID string
        return user.id?.uuidString
    }
    
    /// Retrieve username in Introspection
    func getUser(userID: String) async throws -> VaporOAuth.OAuthUser? {
        guard let uuid = UUID(uuidString: userID) else {
            throw Abort(.badRequest, reason: "userID not valid UUID")
        }
        
        guard let myUser = try await UserModel
            .query(on: app.db)
            .filter(\.$id == uuid)
            .first() else {
            // Optionally, log the event of not finding the user
            // Use a proper logging mechanism here
            return nil
        }
        
        // Construct OAuthUser without exposing sensitive data like password
        return OAuthUser(
            userID: myUser.id?.uuidString,
            username: myUser.username,
            emailAddress: myUser.emailAddress,
            password: "", // Exclude the password
            name: myUser.name,
            givenName: myUser.givenName,
            familyName: myUser.familyName,
            middleName: myUser.middleName,
            nickname: myUser.nickname,
            profile: myUser.profile,
            picture: myUser.picture,
            website: myUser.website,
            gender: myUser.gender,
            birthdate: myUser.birthdate,
            zoneinfo: myUser.zoneinfo,
            locale: myUser.locale,
            phoneNumber: myUser.phoneNumber,
            extend: ["cookiePreferences": myUser.cookiePreferences?.rawValue ?? ""],
            updatedAt: myUser.updatedAt
        )
    }
    
}
