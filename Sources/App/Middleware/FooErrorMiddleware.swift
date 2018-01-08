import HTTP

enum FooError: Error {
    case fooServiceUnavailable
}

final class FooErrorMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        do {
            return try next.respond(to: request)
        } catch FooError.fooServiceUnavailable {
            throw Abort(
                .badRequest,
                reason: "Sorry, we were unable to query the Foo service."
            )
        }
    }
    
}
