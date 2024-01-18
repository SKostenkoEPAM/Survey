//
//  SurveyTests.swift
//  SurveyTests
//
//  Created by Simon Kostenko on 16.01.2024.
//

import XCTest
@testable import Survey
import Combine

final class SurveyTests: XCTestCase {
    
    private var subject: QuestionsViewModel!
    private var cancellables: Set<AnyCancellable> = []
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        subject = QuestionsViewModel(service: QuestionsServiceMock())
    }
    
    override func tearDownWithError() throws {
        cancellables.forEach { $0.cancel() }
        subject = nil
        
        try super.tearDownWithError()
    }
    
    func testSubmitButtonWithNotEmptyAnswer() async {
        await subject.getQuestions()
        subject.currentQuestionAnswer = "something"
        
        subject.$isSubmitDisabled.sink {
            XCTAssertFalse($0)
        }
        .store(in: &cancellables)
    }
    
    func testIsPreviousButtonDisabled1() async {
        await subject.getQuestions()
        
        subject.$isPreviousDisabled.sink {
            XCTAssertTrue($0)
        }
        .store(in: &cancellables)
    }
    
    func testIsPreviousButtonDisabled2() async {
        await subject.getQuestions()
        subject.openNextQuestion()
        
        subject.$isPreviousDisabled.sink {
            XCTAssertFalse($0)
        }
        .store(in: &cancellables)
    }
    
    func testQuestionsServiceMock() async {
        let serviceMock = QuestionsServiceMock()
        let result = try! await serviceMock.getQuestions()
        
        XCTAssertEqual(result[0].question, "What is your favourite colour?")
    }
    

}

class QuestionsServiceMock: Mockable, QuestionsServiceable {
    func getQuestions() async throws -> [Survey.Question] {
        return loadJSON(filename: "questions_response", type: [Question].self)
    }
    
    func submitAnswer(_ answer: String, for id: Int) async throws {
        return
    }
}
