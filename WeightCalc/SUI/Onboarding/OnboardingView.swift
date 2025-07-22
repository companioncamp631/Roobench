//
//  OnboardingView.swift
//  WeightCalc
//
//  Created by D K on 21.07.2025.
//

import Foundation
// MARK: - OnboardingView.swift
import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var currentPageIndex = 0
    @State private var userName: String = ""
    
    // Этот closure будет вызван для закрытия онбординга
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            // Фон, как и в остальном приложении
            LinearGradient(
                gradient: Gradient(colors: [.themeBackgroundStart, .themeBackgroundEnd]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Paged TabView для страниц
                TabView(selection: $currentPageIndex) {
                    ForEach(viewModel.pages.indices, id: \.self) { index in
                        OnboardingPageView(page: viewModel.pages[index], userName: $userName)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never)) // Скрываем стандартные точки
                
                // Кастомные точки-индикаторы
                PageIndicatorView(pageCount: viewModel.pages.count, currentIndex: $currentPageIndex)
                
                // Кнопка "Далее" / "Начать"
                OnboardingButton(
                    isLastPage: currentPageIndex == viewModel.pages.count - 1,
                    userName: userName
                ) {
                    handleButtonTap()
                }
            }
            .padding(.bottom)
        }
        .animation(.easeInOut, value: currentPageIndex)
        .onAppear {
            // Загружаем имя, если оно уже было сохранено ранее
            self.userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        }
    }
    
    private func handleButtonTap() {
        if currentPageIndex == viewModel.pages.count - 1 {
            // Последняя страница
            if !userName.isEmpty {
                UserDefaults.standard.set(userName, forKey: "userName")
                dismiss()
            }
        } else {
            // Переход на следующую страницу
            currentPageIndex += 1
        }
    }
}

// MARK: - Subviews for Onboarding

private struct OnboardingPageView: View {
    let page: OnboardingPage
    @Binding var userName: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: page.imageName == "kangaroo_pointing_up" ? 200 : 250)
                .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
            
            Text(page.title)
                .font(.largeTitle).bold()
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(page.description)
                .font(.title3)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            if page.showsNameField {
                TextField("Your Name", text: $userName)
                    .font(.title2)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.top)
            }
            
            Spacer()
        }
        .padding(30)
    }
}

private struct PageIndicatorView: View {
    let pageCount: Int
    @Binding var currentIndex: Int
    
    var body: some View {
        HStack {
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.themeAccent : Color.gray)
                    .frame(width: 10, height: 10)
                    .scaleEffect(index == currentIndex ? 1.2 : 1.0)
            }
        }
    }
}

private struct OnboardingButton: View {
    let isLastPage: Bool
    let userName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(isLastPage ? "Start Training!" : "Next")
                .font(.headline.bold())
                .foregroundColor(.themeBackgroundEnd)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.themeAccent)
                .cornerRadius(50)
                .shadow(color: .themeAccent.opacity(0.5), radius: 10, y: 5)
        }
        .padding(.horizontal, 40)
        .padding(.top, 30)
        .disabled(isLastPage && userName.isEmpty)
        .opacity((isLastPage && userName.isEmpty) ? 0.6 : 1.0)
    }
}

#Preview {
    OnboardingView() {
        
    }
}
