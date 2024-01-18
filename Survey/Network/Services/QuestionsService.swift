//
//  QuestionsService.swift
//  Survey
//
//  Created by Simon Kostenko on 16.01.2024.
//

import Foundation

protocol QuestionsServiceable {
    func getQuestions() async throws -> [Question]
    func submitAnswer(_ answer: String, for id: Int) async throws
}

struct QuestionsService: HTTPClient, QuestionsServiceable {
    func submitAnswer(_ answer: String, for id: Int) async throws {
        try await sendRequest(endpoint: QuestionsEndpoint.submitAnswer(id: id, answer: answer))
    }
    
    func getQuestions() async throws -> [Question] {
        try await sendRequest(endpoint: QuestionsEndpoint.questions, responseModel: [Question].self)
    }
}
