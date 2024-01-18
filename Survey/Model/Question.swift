//
//  Question.swift
//  Survey
//
//  Created by Simon Kostenko on 18.01.2024.
//

struct Question: Codable {
    let id: Int
    let question: String
}

struct AnsweredQuestion {
    let question: Question
    let answer: String
    
    var isAnswered: Bool {
        !answer.isEmpty
    }
}
