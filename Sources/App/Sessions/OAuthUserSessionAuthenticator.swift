import Vapor
import Fluent
import VaporOAuth

public struct OAuthUserSessionAuthenticator: AsyncSessionAuthenticator {
    public typealias User = OAuthUser

    public func authenticate(sessionID: String, for request: Request) async throws {
        guard let uuid = UUID(uuidString: sessionID) else {
            // Optionally log an error or handle invalid session ID appropriately
            return
        }

        // Query database for user
        guard let user = try await UserModel.query(on: request.db)
            .filter(\.$id == uuid)
            .first() else {
            // Optionally handle the case where the user is not found
            return
        }

        // Construct OAuthUser from the found user
        let oauthUser = OAuthUser(
            userID: user.id?.uuidString,
            username: user.username,
            emailAddress: user.emailAddress,
            password: user.password,
            name: user.name,
            givenName: user.givenName,
            familyName: user.familyName,
            middleName: user.middleName,
            nickname: user.nickname,
            profile: user.profile,
            picture: user.picture,
            website: user.website,
            gender: user.gender,
            birthdate: user.birthdate,
            zoneinfo: user.zoneinfo,
            locale: user.locale,
            phoneNumber: user.phoneNumber,
            updatedAt: user.updatedAt
        )

        request.auth.login(oauthUser)
        request.session.authenticate(oauthUser)
    }
}
