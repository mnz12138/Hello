
extension Request {
    func user() throws -> ExampleUser {
        return try auth.assertAuthenticated()
    }
}
