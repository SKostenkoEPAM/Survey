//
//  RequestError.swift
//  Survey
//
//  Created by Simon Kostenko on 16.01.2024.
//

enum RequestError: Error {
    case invalidURL
    case noResponse
    case decode
    case unauthorized
    case unexpectedStatusCode
    case unknown
}
