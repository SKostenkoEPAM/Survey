//
//  WelcomeView.swift
//  Survey
//
//  Created by Simon Kostenko on 16.01.2024.
//

import SwiftUI

struct WelcomeView: View {
    
    @State private var showQuestions = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.gray.opacity(0.5)
                    .ignoresSafeArea()
                Button {
                    showQuestions.toggle()
                } label: {
                    Text("Start survey")
                        .frame(width: UIScreen.main.bounds.width * 0.7)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                
            }
            .navigationTitle("Welcome")
            .sheet(isPresented: $showQuestions, content: {
                QuestionsView(viewModel: QuestionsViewModel(), isShowing: $showQuestions)
            })
        }
    }
}

#Preview {
    WelcomeView()
}
