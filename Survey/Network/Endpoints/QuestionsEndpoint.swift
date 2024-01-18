//
//  QuestionsEndpoint.swift
//  Survey
//
//  Created by Simon Kostenko on 16.01.2024.
//

enum QuestionsEndpoint {
    case questions
    case submitAnswer(id: Int, answer: String)
}

extension QuestionsEndpoint: Endpoint {
    var path: String {
        switch self {
        case .questions:
            return "/questions"
        case .submitAnswer:
            return "/question/submit"
        }
    }

    var method: RequestMethod {
        switch self {
        case .questions:
            return .get
        case .submitAnswer:
            return .post
        }
    }

    var header: [String: String]? {
        nil
    }
    
    var body: [String: Any]? {
        switch self {
        case .questions:
            return nil
        case .submitAnswer(let id, let answer):
            return [
                "id": id,
                "answer": answer
            ]
        }
    }
}
