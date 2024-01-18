//
//  QuestionsView.swift
//  Survey
//
//  Created by Simon Kostenko on 17.01.2024.
//

import SwiftUI

struct QuestionsView: View {
    
    @ObservedObject var viewModel: QuestionsViewModel
    @Binding var isShowing: Bool
    @FocusState private var answerIsFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.gray.opacity(0.5)
                    .ignoresSafeArea()
                if viewModel.isQuestionsLoaded {
                    ScrollView {
                        VStack(spacing: 0) {
                            StatusView(viewModel: viewModel)
                            VStack(alignment: .leading) {
                                Text(viewModel.answeredQuestionsCount)
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray)
                                Text(viewModel.currentQuestion)
                                    .font(.title)
                                    .padding()
                                TextField("Type here for an answer", text: $viewModel.currentQuestionAnswer)
                                    .focused($answerIsFocused)
                                    .padding()
                                    .disabled(viewModel.isTextFieldDisabled)
                            }
                            Button {
                                answerIsFocused = false
                                Task {
                                    await viewModel.submitAnswer()
                                }
                            } label: {
                                Text(viewModel.submitButtonTitle)
                                    .frame(width: UIScreen.main.bounds.width * 0.7)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                            .disabled(viewModel.isSubmitDisabled)
                        }
                    }
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(2.0, anchor: .center)
                }
            }
            .navigationTitle(viewModel.isQuestionsLoaded ? viewModel.currentQuestionNumber : "Questions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.isQuestionsLoaded {
                    Button("Previous") {
                        viewModel.openPreviousQuestion()
                    }
                    .disabled(viewModel.isPreviousDisabled)
                    
                    Button("Next") {
                        viewModel.openNextQuestion()
                    }
                    .disabled(viewModel.isNextDisabled)
                }
            }
        }
        .task {
            await viewModel.getQuestions()
        }
        .alert("Error", isPresented: $viewModel.isQuestionsLoadingError, actions: {
            Button("OK", role: .cancel) {
                isShowing.toggle()
            }
        }, message: {
            Text("Questions loading failed. Please try again later")
        })
    }
}

struct StatusView: View {
    @ObservedObject var viewModel: QuestionsViewModel
    
    var body: some View {
        switch viewModel.submitAnswerStatus {
        case .normal:
            EmptyView()
        case .success:
            SuccessStatusView()
        case .failure:
            FailureStatusView(viewModel: viewModel)
        }
    }
}

struct SuccessStatusView: View {
    var body: some View {
        HStack {
            Text("Success")
                .font(.largeTitle)
                .padding(.leading)
            Spacer()
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .background(.green)
            
    }
}

struct FailureStatusView: View {
    @ObservedObject var viewModel: QuestionsViewModel
    
    var body: some View {
        HStack {
            Text("Failure!")
                .font(.largeTitle)
                .padding(.leading)
            Spacer()
            Button("RETRY") {
                Task {
                    await viewModel.submitAnswer()
                }
            }
            .padding(.trailing)
            .buttonStyle(.bordered)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .background(.red)
    }
}
    
#Preview {
    QuestionsView(viewModel: QuestionsViewModel(service: QuestionsService()), isShowing: .constant(true))
}
