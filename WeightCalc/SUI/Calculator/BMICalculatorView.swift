//
//  BMICalculatorView.swift
//  WeightCalc
//
//  Created by D K on 21.07.2025.
//

// MARK: - BMICalculatorView.swift

import SwiftUI

struct BMICalculatorView: View {
    @StateObject private var viewModel = BMICalculatorViewModel()
    @State private var isShowingInfoSheet = false
    
    var body: some View {
        ZStack {
            // Фон
            LinearGradient(
                gradient: Gradient(colors: [.themeBackgroundStart, .themeBackgroundEnd]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                // Основной контент
                VStack {
                    if viewModel.isShowingResult {
                        BMIResultView(viewModel: viewModel, isShowingInfoSheet: $isShowingInfoSheet)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        CalculatorInputView(viewModel: viewModel, isShowingInfoSheet: $isShowingInfoSheet)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.5), value: viewModel.isShowingResult)
            }
        }
        .sheet(isPresented: $isShowingInfoSheet) {
            BMITableInfoView()
        }
    }
}

// MARK: - Input Form View
private struct CalculatorInputView: View {
    @ObservedObject var viewModel: BMICalculatorViewModel
    @Binding var isShowingInfoSheet: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            Header(title: "CALCULATE YOUR BMI", showInfoButton: true, isShowingInfoSheet: $isShowingInfoSheet)
            
            // Weight Input
            UnitPicker(label: "WEIGHT", selection: $viewModel.weightUnit)
            BMITextField(placeholder: "e.g. 80", text: $viewModel.weightString)
            
            // Height Input
            UnitPicker(label: "HEIGHT", selection: $viewModel.heightUnit)
            if viewModel.heightUnit == .cm {
                BMITextField(placeholder: "e.g. 175", text: $viewModel.heightCmString)
            } else {
                HStack {
                    BMITextField(placeholder: "ft", text: $viewModel.heightFtString)
                    BMITextField(placeholder: "in", text: $viewModel.heightInString)
                }
            }
            
            
            // Kangaroo Image
            Image("kangaroo_thinking") // Убедитесь, что эта картинка есть в Assets
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .background {
                    VStack {
                        Rectangle()
                            .frame(width: 40, height: 10)
                            .foregroundStyle(.white)
                            .padding(.top, 40)
                        
                        Spacer()
                    }
                }

            // Calculate Button
            PrimaryButton(title: "Calculate", action: viewModel.calculateBMI)
                .disabled(!viewModel.isFormValid)
                .opacity(viewModel.isFormValid ? 1.0 : 0.6)
                .offset(y: -10)
            
        }
        .padding()
        .padding(.bottom, 100) // Отступ для таббара
        .padding(.top, -20)
    }
}


// MARK: - Result View
private struct BMIResultView: View {
    @ObservedObject var viewModel: BMICalculatorViewModel
    @Binding var isShowingInfoSheet: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Header(title: "YOUR BMI IS", showBackButton: true, isShowingInfoSheet: $isShowingInfoSheet) {
                viewModel.reset()
            }
            
            ResultCircle(result: viewModel.bmiResult ?? 0)
            
            CategoryIndicator(category: viewModel.bmiCategory)
            
            Spacer()
            
            Image("kangaroo_waving") // Убедитесь, что эта картинка есть в Assets
                .resizable()
                .scaledToFit()
                .frame(height: 250)
        }
        .padding()
        .padding(.bottom, 100) // Отступ для таббара
    }
}

// MARK: - Reusable UI Components

private struct Header: View {
    let title: String
    var showBackButton: Bool = false
    var showInfoButton: Bool = false
    @Binding var isShowingInfoSheet: Bool
    var backAction: (() -> Void)?
    
    init(title: String, showBackButton: Bool = false, showInfoButton: Bool = false, isShowingInfoSheet: Binding<Bool> = .constant(false), backAction: (() -> Void)? = nil) {
        self.title = title
        self.showBackButton = showBackButton
        self.showInfoButton = showInfoButton
        self._isShowingInfoSheet = isShowingInfoSheet
        self.backAction = backAction
    }

    var body: some View {
        HStack {
            if showBackButton {
                Button(action: { backAction?() }) {
                    Image(systemName: "arrow.left")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            Text(title)
                .font(.title2).bold().foregroundColor(.white)
            Spacer()
            
            if showInfoButton || showBackButton {
                 Button(action: { isShowingInfoSheet = true }) {
                    Image(systemName: "info.circle")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
                // Для выравнивания, если кнопки "назад" нет
                .opacity(showBackButton ? 1 : 0)
                .disabled(!showBackButton)
            }
        }
        .padding()
    }
}

private struct UnitPicker<T: RawRepresentable & CaseIterable & Identifiable & Hashable>: View where T.RawValue == String, T.AllCases: RandomAccessCollection {
    let label: String
    @Binding var selection: T
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.headline).foregroundColor(.white)
            Picker(label, selection: $selection) {
                ForEach(T.allCases) { unit in
                    Text(unit.rawValue.uppercased()).tag(unit)
                }
            }
            .pickerStyle(.segmented)
            .background(Color.black.opacity(0.2))
            .cornerRadius(8)
        }
    }
}

private struct BMITextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .font(.title.bold())
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
            .keyboardType(.decimalPad)
            .padding()
            .background(Color.white)
            .cornerRadius(16)
    }
}

private struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.bold())
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.themeCard)
                .cornerRadius(50)
                .shadow(color: .purple.opacity(0.5), radius: 10, y: 5)
        }
    }
}


private struct ResultCircle: View {
    let result: Double
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.2))
            Circle()
                .stroke(getColor(result: result), lineWidth: 5)
                .padding(5)
            
            Text(String(format: "%.1f", result))
                .font(.system(size: 70, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: 200, height: 200)
    }
    
    
    func getColor(result: Double) -> Color {
        switch result {
        case ..<18.5:
            return .blue
        case 18.5...25:
            return .green
        case 25.1...29.9:
            return .orange
        case 30...100:
            return .orange
        default:
            return .white
        }
    }
}

private struct CategoryIndicator: View {
    let category: BMICategory?
    private let categoriesToShow: [BMICategory] = [.mildThinness, .normal, .overweight, .obeseClass1]
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(categoriesToShow, id: \.self) { cat in
                VStack {
                    Circle()
                        .fill(cat.color)
                        .frame(width: 30, height: 30)
                        .animation(.spring(), value: category)
                    
                    Text(cat == .mildThinness ? "Underweight" : (cat == .obeseClass1 ? "Obese" : cat.description))
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(20)
    }
}

// MARK: - BMI Info Table View
struct BMITableInfoView: View {
    var body: some View {
        ZStack {
            Color.themeBackgroundEnd.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Text("BMI Categories")
                    .font(.title2).bold()
                    .foregroundColor(.white)
                    .padding()
                
                // Table Header
                HStack {
                    Text("Category").bold()
                    Spacer()
                    Text("BMI Range").bold()
                }
                .padding()
                .background(Color.white.opacity(0.2))
                
                // Table Rows
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(BMICategory.allCases, id: \.self) { category in
                            HStack {
                                Text(category.description)
                                Spacer()
                                Text(category.range)
                            }
                            .padding()
                            Divider().background(Color.white.opacity(0.2))
                        }
                    }
                }
            }
            .foregroundColor(.white)
        }
    }
}

#Preview {
    BMICalculatorView()
}
