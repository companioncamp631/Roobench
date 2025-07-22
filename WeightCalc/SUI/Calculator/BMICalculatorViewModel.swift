//
//  BMICalculatorViewModel.swift
//  WeightCalc
//
//  Created by D K on 21.07.2025.
//
import Foundation
import SwiftUI

// Единицы измерения веса
enum WeightUnit: String, CaseIterable, Identifiable {
    case kg, lbs
    var id: String { self.rawValue }
    var displayText: String { self.rawValue.uppercased() }
}

// Единицы измерения роста
enum HeightUnit: String, CaseIterable, Identifiable {
    case cm, ft
    var id: String { self.rawValue }
    var displayText: String { self.rawValue.uppercased() }
}

// Категории ИМТ с цветами и описаниями
enum BMICategory: CaseIterable {
    case severeThinness
    case moderateThinness
    case mildThinness
    case normal
    case overweight
    case obeseClass1
    case obeseClass2
    case obeseClass3
    
    var description: String {
        switch self {
        case .severeThinness: return "Severe Thinness"
        case .moderateThinness: return "Moderate Thinness"
        case .mildThinness: return "Mild Thinness"
        case .normal: return "Normal"
        case .overweight: return "Overweight"
        case .obeseClass1: return "Obese (Class I)"
        case .obeseClass2: return "Obese (Class II)"
        case .obeseClass3: return "Obese (Class III)"
        }
    }
    
    var range: String {
        switch self {
        case .severeThinness: return "< 16"
        case .moderateThinness: return "16 - 17"
        case .mildThinness: return "17 - 18.5"
        case .normal: return "18.5 - 25"
        case .overweight: return "25 - 30"
        case .obeseClass1: return "30 - 35"
        case .obeseClass2: return "35 - 40"
        case .obeseClass3: return "> 40"
        }
    }
    
    var color: Color {
        switch self {
        case .severeThinness, .moderateThinness, .mildThinness: return .blue
        case .normal: return .green
        case .overweight: return .orange
        case .obeseClass1, .obeseClass2, .obeseClass3: return .red
        }
    }
    
    // Функция для определения категории по значению ИМТ
    static func from(bmi: Double) -> BMICategory {
        switch bmi {
        case ..<16: return .severeThinness
        case 16..<17: return .moderateThinness
        case 17..<18.5: return .mildThinness
        case 18.5..<25: return .normal
        case 25..<30: return .overweight
        case 30..<35: return .obeseClass1
        case 35..<40: return .obeseClass2
        default: return .obeseClass3
        }
    }
}


class BMICalculatorViewModel: ObservableObject {
    
    // MARK: - Input Properties
    @Published var weightString: String = ""
    @Published var heightCmString: String = ""
    @Published var heightFtString: String = ""
    @Published var heightInString: String = ""
    
    // MARK: - Unit Selection
    @Published var weightUnit: WeightUnit = .kg
    @Published var heightUnit: HeightUnit = .cm
    
    // MARK: - Result Properties
    @Published var bmiResult: Double?
    @Published var bmiCategory: BMICategory?
    
    // MARK: - State Management
    @Published var isShowingResult: Bool = false
    
    var isFormValid: Bool {
        !weightString.isEmpty &&
        (heightUnit == .cm ? !heightCmString.isEmpty : (!heightFtString.isEmpty && !heightInString.isEmpty))
    }
    
    // MARK: - Calculation Logic
    func calculateBMI() {
        guard isFormValid else { return }
        
        // 1. Конвертируем вес в КГ
        let weightInKg: Double
        if weightUnit == .lbs {
            let weightInLbs = Double(weightString) ?? 0
            weightInKg = weightInLbs * 0.453592
        } else {
            weightInKg = Double(weightString) ?? 0
        }
        
        // 2. Конвертируем рост в МЕТРЫ
        let heightInMeters: Double
        if heightUnit == .ft {
            let feet = Double(heightFtString) ?? 0
            let inches = Double(heightInString) ?? 0
            heightInMeters = ((feet * 12) + inches) * 0.0254
        } else {
            let heightInCm = Double(heightCmString) ?? 0
            heightInMeters = heightInCm / 100
        }
        
        // 3. Проверяем на 0, чтобы избежать деления
        guard heightInMeters > 0 && weightInKg > 0 else {
            // Можно добавить обработку ошибки, если нужно
            return
        }
        
        // 4. Считаем ИМТ
        let result = weightInKg / (heightInMeters * heightInMeters)
        
        // 5. Сохраняем результат и категорию
        self.bmiResult = result
        self.bmiCategory = .from(bmi: result)
        
        // 6. Переключаем экран на результат
        self.isShowingResult = true
    }
    
    // MARK: - Reset
    func reset() {
        self.isShowingResult = false
        // Не сбрасываем поля ввода, чтобы пользователь мог их поправить
    }
}
