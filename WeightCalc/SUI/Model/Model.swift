//
//  Model.swift
//  WeightCalc
//
//  Created by D K on 20.07.2025.
//


// MARK: - Models.swift

import Foundation

// Модель для ОДНОЙ записи о тренировке (вес, повторы, дата)
// Она осталась почти без изменений
struct WorkoutLog: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var weight: Double
    var reps: Int
    
    var resultString: String {
        "\(Int(weight)) KG × \(reps) REPS"
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date).uppercased()
    }
}

// НОВАЯ модель для самого УПРАЖНЕНИЯ
struct Exercise: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var isCustom: Bool = false
}
