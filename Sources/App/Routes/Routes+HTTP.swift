import Vapor
import Foundation

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
            
            guard let field = multipartFormData["imgfile"],
                let count = field.bytes?.count else {
                throw Abort.badRequest
            }
            let data = NSData(bytes: field.bytes, length: count)
            let path = NSHomeDirectory()+"/Desktop/imgfile.png"
            data.write(toFile: path, atomically: true)
            
            let response = try Response(status: .ok, json: JSON("success"))
            //响应头加入自定义值
            response.headers.customKey = "123"
            return response
        }
    }
    
}
