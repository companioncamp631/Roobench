//
//  ProgressViewModel.swift
//  WeightCalc
//
//  Created by D K on 20.07.2025.
//

// MARK: - ProgressViewModel.swift
import Foundation
import SwiftUI

// Структура для данных графика "Общий Тоннаж"
struct MonthlyVolume: Identifiable {
    let id = UUID()
    let month: String
    let date: Date
    let totalVolume: Double
}

// Модель для карточки "At a Glance"
struct SummaryStats: Equatable {
    let totalWorkouts: Int
    let totalVolume: Double
    let heaviestLift: WorkoutLog?
}

// Модель для одного личного рекорда
struct PersonalRecord: Identifiable {
    let id: UUID
    let exerciseName: String
    let recordLog: WorkoutLog
}

// MARK: - ProgressViewModel.swift

import Foundation
import SwiftUI

class ProgressViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    // Данные для новых карточек
    @Published var summaryStats: SummaryStats?
    @Published var personalRecords: [PersonalRecord] = []
    
    // Данные для старых графиков
    @Published var monthlyVolumeData: [MonthlyVolume] = []
    @Published var exerciseProgressionData: [WorkoutLog] = []
    
    // Управление пикером для графика прогрессии
    @Published var exercisesWithHistory: [String] = []
    @Published var selectedExercise: String = "" {
        didSet {
            // Пересчитываем график при смене упражнения в пикере
            updateExerciseProgressionChart(from: fullHistory)
        }
    }
    
    private var fullHistory: [String: [WorkoutLog]] = [:]
    
    // MARK: - Public Method for Data Refresh
    
    /// Этот метод будет вызываться из View при каждом появлении экрана.
    /// Он полностью пересчитывает всю статистику.
    func updateData(from history: [String: [WorkoutLog]]) {
        self.fullHistory = history
        
        // Получаем список упражнений, по которым есть история
        self.exercisesWithHistory = history.keys.sorted()
        
        // Если выбранное ранее упражнение исчезло, выбираем первое из списка
        if !exercisesWithHistory.contains(selectedExercise), let first = exercisesWithHistory.first {
            self.selectedExercise = first
        } else if exercisesWithHistory.isEmpty {
            self.selectedExercise = ""
        }
        
        // Вызываем все функции для расчета
        calculateSummaryStats(from: history)
        calculatePersonalRecords(from: history)
        calculateMonthlyVolume(from: history)
        updateExerciseProgressionChart(from: history)
    }
    
    // MARK: - Private Calculation Methods
    
    private func calculateSummaryStats(from history: [String: [WorkoutLog]]) {
        let allLogs = history.values.flatMap { $0 }
        
        guard !allLogs.isEmpty else {
            self.summaryStats = nil
            return
        }
        
        let totalWorkouts = Set(allLogs.map { Calendar.current.startOfDay(for: $0.date) }).count
        let totalVolume = allLogs.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
        let heaviestLift = allLogs.max(by: { $0.weight < $1.weight })
        
        self.summaryStats = SummaryStats(
            totalWorkouts: totalWorkouts,
            totalVolume: totalVolume,
            heaviestLift: heaviestLift
        )
    }
    
    private func calculatePersonalRecords(from history: [String: [WorkoutLog]]) {
        var records: [PersonalRecord] = []
        
        for (exerciseName, logs) in history {
            // Находим лог с максимальным весом для данного упражнения
            if let recordLog = logs.max(by: { $0.weight < $1.weight }) {
                records.append(
                    PersonalRecord(id: UUID(), exerciseName: exerciseName, recordLog: recordLog)
                )
            }
        }
        
        // Сортируем по имени упражнения для стабильного порядка
        self.personalRecords = records.sorted { $0.exerciseName < $1.exerciseName }
    }
    
    private func calculateMonthlyVolume(from history: [String: [WorkoutLog]]) {
        let allLogs = history.values.flatMap { $0 }
        
        let groupedByMonth = Dictionary(grouping: allLogs) { log -> Date in
            return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: log.date))!
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM" // "Jul"
        
        self.monthlyVolumeData = groupedByMonth.map { (monthDate, logs) in
            let totalVolume = logs.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
            let monthString = formatter.string(from: monthDate)
            return MonthlyVolume(month: monthString, date: monthDate, totalVolume: totalVolume)
        }.sorted { $0.date < $1.date }
    }
    
    private func updateExerciseProgressionChart(from history: [String: [WorkoutLog]]) {
        guard !selectedExercise.isEmpty else {
            self.exerciseProgressionData = []
            return
        }
        self.exerciseProgressionData = history[selectedExercise]?.sorted(by: { $0.date < $1.date }) ?? []
    }
}
