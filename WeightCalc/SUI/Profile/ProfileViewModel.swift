//
//  ProfileViewModel.swift
//  WeightCalc
//
//  Created by D K on 21.07.2025.
//

// MARK: - UserProfile.swift
import Foundation

struct UserProfile: Codable {
    var height: String = ""
    var weight: String = ""
    var age: String = ""
    
    // Храним изображение в виде Data, т.к. это легко кодируется в JSON
    var profileImageData: Data?
}

// MARK: - ProfileViewModel.swift
import Foundation
import SwiftUI
import Combine // Для таймера

class ProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties for UI
    @Published var height: String = ""
    @Published var weight: String = ""
    @Published var age: String = ""
    @Published var profileImage: Image?
    
    @Published var currentTip: String = ""
    @Published var showSaveConfirmation: Bool = false
    
    // MARK: - Private Properties
    private var userProfile = UserProfile()
    private let userDefaultsKey = "userProfileData"
    
    private var tipTimer: AnyCancellable?
    private var tipIndex = 0
    private let tips = [
        "Eat enough protein for muscle recovery.",
        "Stay hydrated throughout the day.",
        "Consistency is more important than intensity.",
        "Don't skip your warm-ups to prevent injuries.",
        "Listen to your body and rest when you need it.",
        "Progressive overload is the key to getting stronger.",
        "Aim for 7-9 hours of quality sleep per night.",
        "Compound lifts are highly effective for overall strength.",
        "Stretch after your workouts to improve flexibility.",
        "Track your progress to stay motivated and see results."
    ]

    // MARK: - Initialization
    init() {
        loadProfile()
        startTipCycle()
    }
    
    deinit {
        // Важно останавливать таймер, чтобы избежать утечек памяти
        tipTimer?.cancel()
    }
    
    // MARK: - Data Handling
    func loadProfile() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        
        if let decodedProfile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.userProfile = decodedProfile
            
            self.height = decodedProfile.height
            self.weight = decodedProfile.weight
            self.age = decodedProfile.age
            
            if let imageData = decodedProfile.profileImageData, let uiImage = UIImage(data: imageData) {
                self.profileImage = Image(uiImage: uiImage)
            }
        }
    }
    
    func saveProfile() {
        userProfile.height = height
        userProfile.weight = weight
        userProfile.age = age
        // userProfile.profileImageData уже обновлен при выборе фото
        
        if let encodedData = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
            
            // Показываем подтверждение сохранения
            showSaveConfirmation = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showSaveConfirmation = false
            }
        }
    }
    
    func setImage(from data: Data?) {
        guard let data = data, let uiImage = UIImage(data: data) else { return }
        self.profileImage = Image(uiImage: uiImage)
        self.userProfile.profileImageData = data // Сразу сохраняем данные для последующего сохранения
    }
    
    // MARK: - Tip Cycling Logic
    private func startTipCycle() {
        // Устанавливаем первый совет сразу
        self.currentTip = tips[0]
        
        tipTimer = Timer.publish(every: 6, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.tipIndex = (self.tipIndex + 1) % self.tips.count
                self.currentTip = self.tips[self.tipIndex]
            }
    }
}
