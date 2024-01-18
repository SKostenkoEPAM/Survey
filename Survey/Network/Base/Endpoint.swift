//
//  Endpoint.swift
//  Survey
//
//  Created by Simon Kostenko on 16.01.2024.
//

protocol Endpoint {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var method: RequestMethod { get }
    var header: [String: String]? { get }
    var body: [String: Any]? { get }
}

extension Endpoint {
    var scheme: String {
        "https"
    }

    var host: String {
        "xm-assignment.web.app"
    }
}
