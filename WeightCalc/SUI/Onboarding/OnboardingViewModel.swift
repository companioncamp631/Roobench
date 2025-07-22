//
//  OnboardingViewModel.swift
//  WeightCalc
//
//  Created by D K on 21.07.2025.
//

// MARK: - OnboardingModels.swift
import Foundation

struct OnboardingPage: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
    let showsNameField: Bool
}

// MARK: - OnboardingViewModel.swift
import Foundation

class OnboardingViewModel: ObservableObject {
    @Published var pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "kangaroo_squat",
            title: "Welcome to Roobench!",
            description: "Your personal guide to building strength and tracking progress.",
            showsNameField: false
        ),
        OnboardingPage(
            imageName: "kangaroo_plank",
            title: "Track Everything",
            description: "Log your workouts, sets, and reps. See your total volume grow and hit new personal records.",
            showsNameField: false
        ),
        OnboardingPage(
            imageName: "kangaroo_pointing_up", // Возьмем кенгуру с экрана профиля
            title: "Let's Get Started",
            description: "What should we call you? Your name will be displayed in the profile.",
            showsNameField: true
        )
    ]
}
