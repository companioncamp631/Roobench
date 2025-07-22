//
//  Tab.swift
//  WeightCalc
//
//  Created by D K on 20.07.2025.
//

// MARK: - MainView.swift

import SwiftUI

// Перечисление для всех вкладок
enum Tab: Int, CaseIterable {
    case workouts, progress, calculator, profile
    
    var iconName: String {
        switch self {
        case .workouts: return "dumbbell.fill"
        case .progress: return "chart.bar.xaxis"
        case .calculator: return "scalemass.fill"
        case .profile: return "person.fill"
        }
    }
}

struct MainView: View {
    @State private var selectedTab: Tab = .workouts
    @State private var isOnboardingShown: Bool = false
    @StateObject private var workoutsViewModel = WorkoutsViewModel()
    
    
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack {
            switch selectedTab {
            case .workouts:
                WorkoutsView()
                    // Передаем ViewModel как EnvironmentObject, чтобы не создавать его снова
                    .environmentObject(workoutsViewModel)
            case .progress:
                ProgressView() // Он получит объект из окружения
                       .environmentObject(workoutsViewModel)
            case .calculator:
                BMICalculatorView()
            case .profile:
                ProfileView()
            
            }
            
            VStack {
                Spacer()
                
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .background(Color.themeBackgroundEnd.edgesIgnoringSafeArea(.all))
        .fullScreenCover(isPresented: $isOnboardingShown) {
            OnboardingView {
                
            }
        }
        .onAppear {
            if !UserDefaults.standard.bool(forKey: "onbo") {
                isOnboardingShown.toggle()
                UserDefaults.standard.set(true, forKey: "onbo")
            }
        }
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 22, weight: .regular))
                            .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                        
                        // Можно добавить название под иконкой
                        // Text(tab.rawValue.capitalized)
                        //     .font(.caption)
                    }
                }
                .foregroundColor(selectedTab == tab ? .themeAccent : .inactiveTab)
                .frame(maxWidth: .infinity)
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.themeBackgroundEnd.opacity(0.95))
        .cornerRadius(25)
        .shadow(color: .black.opacity(0.3), radius: 10, y: -5)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

#Preview {
    MainView()
}
