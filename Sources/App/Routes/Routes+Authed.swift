import Vapor
import AuthProvider
import Sessions

extension Droplet {
    
    func setupAuthedRoutes() throws {
        //如果您的登录页面不是'/login'或者您希望重定向中间件重定向到不同类型的页面，只需使用完整的初始化程序即可。
        //RedirectMiddleware(path: "/login")
        //创建一个重定向中间件非常简单。我们将使用其中一个预设重定向用户/login
//        let redirect = RedirectMiddleware.login()
//        let tokenMiddleware = TokenAuthenticationMiddleware(ExampleUser.self)
//        //确保重定向中间件位于auth中间件之前。
//        let protected = grouped([redirect, tokenMiddleware])
//        protected.get("me") { req in
//            let user = try req.auth.assertAuthenticated(ExampleUser.self)
//            return "Welcome to the secure page, \(user.username)"
//        }
        
        //InverseRedirectMiddleware用来重定向认证的Users离开登录页面的例子。
//        let inverseRedirect = InverseRedirectMiddleware.home(ExampleUser.self)
        //如果你想要的页面不是'/'或者你想反向重定向中间件重定向到不同类型的页面，只需使用完整的初始化程序即可。
        let inverseRedirect = InverseRedirectMiddleware(ExampleUser.self, path: "/index")
        let group = grouped([inverseRedirect])
        group.get("login") { req in
            return "Please login"
        }
        
        let memory = MemorySessions()
        //会话认证
        let sessionsMiddleware = SessionsMiddleware(memory)
        //Username + Password (Basic) Auth
        let passwordMiddleware = PasswordAuthenticationMiddleware(ExampleUser.self)
        //Persisting Auth意味着用户不需要为每个请求提供他们的凭证
        let persistMiddleware = PersistMiddleware(ExampleUser.self)

        let authed = grouped([sessionsMiddleware, persistMiddleware, passwordMiddleware])
        /// use this route group for protected routes
        authed.get("me") { req in
            // return the authenticated user
            //调用req.user.authenticated(ExampleUser.self)访问已认证的用户。
            let user = try req.auth.assertAuthenticated(ExampleUser.self)
            return try user.makeJSON()
        }
        
        //在GET /remember，name从会话数据获取并返回它。
        get("remember") { req in
            let session = try req.assertSession()
            guard let name = session.data["name"]?.string else {
                throw Abort(.badRequest, reason: "Please POST the name first.")
            }
            return name
        }
        //在POST /remember，name从请求输入中获取一个，然后将这个名字存储到会话数据中。
        post("remember") { req in
            /*
             {
                 "metadata": "some metadata",
                 "artists" : {
                 "href": "http://someurl.com",
                 "items": [
                     {
                        "name": "Van Gogh",
                     },
                     {
                        "name": "Mozart"
                     }
                 ]
                 }
             }
             request.data["artists", "items", "name"] -> ["Van Gogh", "Mozart"]
             */
            guard let name = req.data["name"]?.string else {
                throw Abort(.badRequest)
            }
            let session = try req.assertSession()
            try session.data.set("name", name)
            return "Remebered name."
        }
        
        get("login") { req in
            return ""
        }
        
    }
}
