import Vapor

/// An enumeration representing the different cookie preferences.
public enum CookiePreferences: String, Content {
    case ACCEPTED
    case DECLINED
    case NOT_SET
}
