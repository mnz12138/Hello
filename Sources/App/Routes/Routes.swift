import Vapor
import MySQL
import ValidationProvider

extension Droplet {
    
    func setupRoutes() throws {
        let nameValidationSuite = NameValidationSuite()
        
        let userGroup = grouped("v1", User.parameter)
        
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }
        
        try resource("posts", PostController.self)
        
        get("error") { request in
            throw Abort(.badRequest, reason: "Sorry 😱")
        }
        
        //重定向到首页
//        get { request in
//            return Response(redirect: "index.html")
//        }
        
        get("index.html") { request in
            //直接返回html
//            return try self.view.make("index.html");
            //返回模板
            let dict: [String : Any] = ["greeting": "Hello, world!", "entering": true, "leaving": true]
            return try self.view.make("index.leaf", dict.makeNode(in: nil))
        }
        
        post("index.html") { request in
            return try self.view.make("index.html")
        }
        
        let hc = HelloController()
        get("hello", handler: hc.sayHello)
        get("sayHello", handler: hc.sayHelloAlternate)
        
        //允许您匹配多个嵌套斜杠层。
        /*
         /anything
         /anything/foo
         /anything/foo/bar
         /anything/foo/bar/baz
         */
        get("anything", "*") { request in
            return "Matches anything after /anything"
        }
        
        //用户列表 ../userlist
        get("userlist") { request in
            let users = try UserManager.queryAllUser()
            return try users.makeJSON()
        }
        // ../user/2
//        get("user", Int.parameter) { request in
//            let userId = try request.parameters.next(Int.self)
//            let user = try UserManager.queryUser(userid: userId)
//            return try user?.makeJSON() ?? ""
//        }
        //users/:id 类型安全(id就是key)
        //这将创建一个匹配的路径user/:id，其中:id的一个Int
//        get("user", ":id") { request in
//            guard let userId = request.parameters["id"]?.int else {
//                throw Abort.badRequest
//            }
//            let user = try UserManager.queryUser(userid: userId)
//            return try user?.makeJSON() ?? ""
//        }
        //Parameterizable
        //user/id
//        get("user", User.parameter) { request in
//            let user = try request.parameters.next(User.self)
//            if user.userid<=0 {
//                return ""
//            }
//            return try user.makeJSON()
//        }
        //user?user_id=3
        get("user") { request in
            guard let queryNode = request.query else {
                throw Abort.badRequest
            }
            let requestDict = JSON(queryNode.wrapped, queryNode.context)
            guard let user_id = requestDict["user_id"]?.int else {
                throw Abort.badRequest
            }
            let user = try UserManager.queryUser(userid: user_id)
            return try user?.makeJSON() ?? ""
        }
        //user_name=哈哈哈(保存并返回user_id)
        post("user/save") { request in
            guard let user_name = request.data["user_name"]?.string else{
                throw Abort.badRequest
            }
            //自定义验证
            try nameValidationSuite.validate(user_name)
            let userId = try UserManager.save(username: user_name)
            let dict = ["user_id": userId]
            let node = try dict.makeNode(in: nil)
            return JSON(node)
        }
        //保存用户
        post("temp/user/save") { (request) -> ResponseRepresentable in
            guard let user_name = request.data["user_name"]?.string else{
                throw Abort.badRequest
            }
            let user = UserTemp(username: user_name, age: 0)
            try user.save()
            return try user.makeJSON()
        }
        //获取所有用户
        get("temp/userlist") { (request) -> ResponseRepresentable in
            let users = try UserTemp.all()
            return try users.makeJSON()
        }
        //查询用户
        get("temp/user") { (request) -> ResponseRepresentable in
            guard let queryNode = request.query else {
                throw Abort.badRequest
            }
            let requestDict = JSON(queryNode.wrapped, queryNode.context)
            guard let user_id = requestDict["user_id"]?.int else {
                throw Abort.badRequest
            }
            guard let user = try UserTemp.find(user_id) else {
                return ""
            }
            return try user.makeJSON()
        }
        userGroup.grouped("users").get { request in
            let user = try request.parameters.next(User.self)
            return try user.makeJSON()
        }
        //缓存存
        post("cache/save") { (request) -> ResponseRepresentable in
            guard let key = request.data["key"]?.string,
                let value = request.data["value"]?.string else{
                throw Abort.badRequest
            }
            if value.passes(Count.min(1))==false {
                var json = JSON([:])
                try json.set("error", true)
                try json.set("message", "存储值长度最少1位")
                let response = Response(status: .badRequest)
                response.json = json
                return response
            }
            //30秒过期
//            self.cache.set(key, value, expiration: Date(timeIntervalSinceNow: 30))
            try self.cache.set(key, value)
            return key
        }
        //缓存取
        get("cache/get") { (request) -> ResponseRepresentable in
            guard let key = request.data["key"]?.string else{
                throw Abort.badRequest
            }
            guard let node = try self.cache.get(key) else {
                return ""
            }
            return JSON(node)
        }
        //缓存删
        get("cache/delete") { (request) -> ResponseRepresentable in
            guard let key = request.data["key"]?.string else{
                throw Abort.badRequest
            }
            try self.cache.delete(key)
            return key
        }
        
        get("foo") { req in
            let content = try getFooFromService()
            return content
        }
        
        func getFooFromService() throws -> String {
            throw FooError.fooServiceUnavailable
        }
        
        
    }
}
