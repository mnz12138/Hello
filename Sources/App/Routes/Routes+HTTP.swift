import Vapor

extension Droplet {
    
    func setupHTTPRoutes() throws {
        
        get("upload") { request in
            return try self.view.make("upload.html");
        }
        post("upload/image") { (request) -> ResponseRepresentable in
            // Node? from application/x-www-form-urlencoded
            let formData = request.formURLEncoded
            
            // [String:Field]? from multipart/form-data
            guard let multipartFormData = request.formData else {
                throw Abort.badRequest
            }
            
            // [Part]? from multipart/mixed
            let multipartMixedData = request.multipart
            
            let field = multipartFormData["imgfile"]
            
            let response = try Response(status: .ok, json: JSON("success"))
            //响应头加入自定义值
            response.headers.customKey = "123"
            return response
        }
        
    }
    
}
