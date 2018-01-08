//
//  HelloController.swift
//  HelloPackageDescription
//
//  Created by 王全金 on 2017/12/28.
//

import Vapor
import HTTP

final class HelloController {
    func sayHello(_ req: Request) throws -> ResponseRepresentable {
        guard let name = req.data["name"]?.string else {
            throw Abort(.badRequest)
        }
        return "Hello, \(name)"
    }
    func sayHelloAlternate(_ req: Request) throws -> ResponseRepresentable {
        let name = try req.parameters.next(String.self)
        return "Hello, \(name)"
    }
}
