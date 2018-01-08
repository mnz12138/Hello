import Vapor
import RedisProvider

extension Droplet {
    
    func setupRedisRoutes() throws {
        
        post("redis/save") { request in
            guard let key = request.data["key"]?.string,
                let value = request.data["value"]?.string else{
                throw Abort.badRequest
            }
            try self.cache.set(key, value)
            return key
        }
        
        get("redis/get") { request in
            guard let key = request.data["key"]?.string else{
                throw Abort.badRequest
            }
            guard let node = try self.cache.get(key),
                let value = node.string else {
                return ""
            }
            return value
        }
        
    }
}
