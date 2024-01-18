//
//  QuestionsViewModel.swift
//  Survey
//
//  Created by Simon Kostenko on 17.01.2024.
//

import Combine
import Foundation

class QuestionsViewModel: ObservableObject {
    
    enum SubmitAnswerStatus {
        case normal
        case success
        case failure
    }
    
    private let service: QuestionsServiceable
    
    private var cancellableSet: Set<AnyCancellable> = []
    private var submitAnswerStatusCancellable: AnyCancellable?
    
    @Published var isQuestionsLoaded = false
    @Published var isQuestionsLoadingError = false
    
    @Published private var answeredQuestions: [AnsweredQuestion] = []
    @Published private var currentQuestionIndex = 0
    
    @Published var answeredQuestionsCount = ""
    @Published var currentQuestionNumber = ""
    @Published var currentQuestion: String = ""
    @Published var currentQuestionAnswer: String = ""
    @Published var isPreviousDisabled: Bool = true
    @Published var isNextDisabled: Bool = true
    @Published var isSubmitDisabled: Bool = true
    @Published var submitButtonTitle: String = ""
    @Published var isTextFieldDisabled: Bool = true
    
    @Published var submitAnswerStatus: SubmitAnswerStatus = .normal
    
    init(service: QuestionsServiceable = QuestionsService()) {
        self.service = service
        
        $currentQuestionIndex
            .removeDuplicates()
            .sink { [weak self] index in
                guard let self else { return }
                submitAnswerStatusCancellable?.cancel()
                self.submitAnswerStatus = .normal
            }
            .store(in: &cancellableSet)
    }
    
    func getQuestions() async {
        do {
            let questions = try await service.getQuestions()
            await MainActor.run {
                answeredQuestions = questions.map { AnsweredQuestion(question: $0, answer: "") }
                setupAssigns()
                isQuestionsLoaded = true
            }
        } catch {
            await MainActor.run {
                isQuestionsLoadingError = true
            }
        }
    }
    
    func submitAnswer() async {
        let answer = currentQuestionAnswer
        let questionID = answeredQuestions[currentQuestionIndex].question.id
        do {
            try await service.submitAnswer(currentQuestionAnswer, for: questionID)
            await MainActor.run {
                answeredQuestions[currentQuestionIndex] = AnsweredQuestion(question: answeredQuestions[currentQuestionIndex].question, answer: answer)
                submitAnswerStatus = .success
                updateToNormalStatus()
            }
        } catch {
            await MainActor.run {
                submitAnswerStatus = .failure
                updateToNormalStatus()
            }
        }
    }
    
    func openNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func openPreviousQuestion() {
        currentQuestionIndex -= 1
    }
    
    private func updateToNormalStatus() {
        submitAnswerStatusCancellable = $submitAnswerStatus
            .filter { $0 != .normal }
            .debounce(for: .seconds(3.0), scheduler: RunLoop.main)
            .sink { [weak self] status in
                self?.submitAnswerStatus = .normal
            }
    }
    
    private func setupAssigns() {
        $answeredQuestions
            .map {
                let answeredQuestionsCount = $0.reduce(0) { $0 + ($1.isAnswered ? 1 : 0) }
                return "Questions submitted: \(answeredQuestionsCount)"
            }
            .assign(to: &$answeredQuestionsCount)
        
        $currentQuestionIndex
            .map { [weak self] in
                guard let self else { return "" }
                return "Question \($0 + 1)/\(self.answeredQuestions.count)"
            }
            .assign(to: &$currentQuestionNumber)
        
        $currentQuestionIndex
            .map { [weak self] in
                guard let self else { return "" }
                return self.answeredQuestions[$0].question.question
            }
            .assign(to: &$currentQuestion)
        
        $currentQuestionIndex
            .map { [weak self] in
                guard let self else { return "" }
                return self.answeredQuestions[$0].answer
            }
            .assign(to: &$currentQuestionAnswer)
        
        $currentQuestionIndex
            .map {
                return $0 == 0
            }
            .assign(to: &$isPreviousDisabled)
        
        $currentQuestionIndex
            .map { [weak self] in
                guard let self else { return true }
                return $0 == self.answeredQuestions.count - 1
            }
            .assign(to: &$isNextDisabled)
        
        Publishers.CombineLatest3($currentQuestionIndex, $currentQuestionAnswer, $answeredQuestions)
            .map {
                return $0.2[$0.0].isAnswered || $0.1.isEmpty
            }
            .assign(to: &$isSubmitDisabled)
        
        Publishers.CombineLatest($currentQuestionIndex, $answeredQuestions)
            .map {
                $0.1[$0.0].isAnswered ? "Already submitted" : "Submit"
            }
            .assign(to: &$submitButtonTitle)
        
        Publishers.CombineLatest($currentQuestionIndex, $answeredQuestions)
            .map {
                $0.1[$0.0].isAnswered
            }
            .assign(to: &$isTextFieldDisabled)
    }
}
