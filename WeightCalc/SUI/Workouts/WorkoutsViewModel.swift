// MARK: - WorkoutsViewModel.swift

import Foundation
import SwiftUI

class WorkoutsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var exercises: [Exercise] = []
    
    // --- ИЗМЕНЕНИЕ ЛОГИКИ ХРАНЕНИЯ ---
    // Раньше: @Published var workoutLogs: [String: WorkoutLog] = [:]
    // Теперь: Храним полную историю для каждого упражнения
    @Published var workoutHistory: [String: [WorkoutLog]] = [:]

    // Управление состоянием кастомного модального окна
    @Published var isShowingEntryView = false
    @Published var selectedExercise: Exercise?
    
    // MARK: - UserDefaults Keys
    private let customExercisesKey = "customExercises"
    private let workoutHistoryKey = "workoutHistory" // Новое имя ключа
    
    // MARK: - Initialization
    init() {
        loadData()
    }
    
    // MARK: - Data Handling
    func loadData() {
        let baseExercises = getBaseExercises()
        let customExercises = loadCustomExercises()
        self.exercises = (baseExercises + customExercises).sorted { $0.name < $1.name }
        self.workoutHistory = loadWorkoutHistory()
    }
    
    private func saveData() {
        let customExercises = exercises.filter { $0.isCustom }
        
        if let encodedCustom = try? JSONEncoder().encode(customExercises) {
            UserDefaults.standard.set(encodedCustom, forKey: customExercisesKey)
        }
        
        if let encodedHistory = try? JSONEncoder().encode(workoutHistory) {
            UserDefaults.standard.set(encodedHistory, forKey: workoutHistoryKey)
        }
    }
    
    // MARK: - Public Methods
    
    /// --- ОБНОВЛЕННЫЙ МЕТОД ---
    /// Добавляет новый лог в историю упражнения, а не заменяет старый.
    func addLog(for exercise: Exercise, date: Date, weight: Double, reps: Int) {
        let newLog = WorkoutLog(id: UUID(), date: date, weight: weight, reps: reps)
        
        // Если для упражнения уже есть история, добавляем в нее
        if var history = workoutHistory[exercise.name] {
            history.append(newLog)
            // Сортируем, чтобы самые новые были в конце
            history.sort { $0.date < $1.date }
            workoutHistory[exercise.name] = history
        } else {
            // Иначе создаем новую историю
            workoutHistory[exercise.name] = [newLog]
        }
        saveData()
    }
    
    func addCustomExercise(name: String) {
        guard !exercises.contains(where: { $0.name.lowercased() == name.lowercased() }) else { return }
        let newExercise = Exercise(id: UUID(), name: name.uppercased(), isCustom: true)
        exercises.append(newExercise)
        exercises.sort { $0.name < $1.name }
        saveData()
    }
    
    /// --- ОБНОВЛЕННЫЙ МЕТОД ---
    /// Получает самый последний лог из массива истории.
    func getLatestLog(for exercise: Exercise) -> WorkoutLog? {
        // Сортируем по дате (от новой к старой) и берем первый элемент
        return workoutHistory[exercise.name]?.sorted(by: { $0.date > $1.date }).first
    }
    
    // MARK: - Helper Methods
    
    private func getBaseExercises() -> [Exercise] {
        return [
            "Bench Press", "Barbell Squat", "Deadlift", "Overhead Press",
            "Pull-Ups", "Bent-over Row", "Lat Pulldown", "Dumbbell Curl",
            "Triceps Extension", "Plank", "Push-Ups"
        ].map { Exercise(id: UUID(), name: $0.uppercased()) }
    }
    
    private func loadCustomExercises() -> [Exercise] {
        guard let data = UserDefaults.standard.data(forKey: customExercisesKey),
              let decoded = try? JSONDecoder().decode([Exercise].self, from: data) else {
            return []
        }
        return decoded
    }

    private func loadWorkoutHistory() -> [String: [WorkoutLog]] {
        guard let data = UserDefaults.standard.data(forKey: workoutHistoryKey),
              let decoded = try? JSONDecoder().decode([String: [WorkoutLog]].self, from: data) else {
            return generateMockHistory() // Если истории нет, генерируем для примера
        }
        return decoded
    }
    
    // Моковые данные, чтобы графики не были пустыми при первом запуске
    private func generateMockHistory() -> [String: [WorkoutLog]] {
        var mockHistory: [String: [WorkoutLog]] = [:]
//        let benchPressName = "BENCH PRESS"
//        mockHistory[benchPressName] = [
//            WorkoutLog(id: UUID(), date: Date().addingTimeInterval(-86400 * 30), weight: 90, reps: 5),
//            WorkoutLog(id: UUID(), date: Date().addingTimeInterval(-86400 * 15), weight: 95, reps: 5),
//            WorkoutLog(id: UUID(), date: Date().addingTimeInterval(-86400 * 2), weight: 100, reps: 5)
//        ]
//        
//        let squatName = "BARBELL SQUAT"
//        mockHistory[squatName] = [
//            WorkoutLog(id: UUID(), date: Date().addingTimeInterval(-86400 * 25), weight: 110, reps: 8),
//            WorkoutLog(id: UUID(), date: Date().addingTimeInterval(-86400 * 10), weight: 115, reps: 8),
//            WorkoutLog(id: UUID(), date: Date().addingTimeInterval(-86400 * 1), weight: 120, reps: 8)
//        ]
        return mockHistory
    }
}
