@_exported import Vapor
import AuthProvider

extension Droplet {
    public func setup() throws {
        try setupRoutes()
        try setupMySQLRoutes()
        try setupRedisRoutes()
        try setupAuthedRoutes()
        try setupHTTPRoutes()
        // Do any additional droplet setup
    }
}

