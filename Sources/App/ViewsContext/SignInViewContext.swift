import Vapor

/// A context struct used for rendering the sign-in view.
public struct SignInViewContext: Encodable {
    /// The CSRF token used for form submission.
    public let csrfToken: String
    
    /// Initializes a new instance of `SignInViewContext`.
    /// - Parameter csrfToken: The CSRF token used for form submission.
    init(
        csrfToken: String
    ) {
        self.csrfToken = csrfToken
    }
}
