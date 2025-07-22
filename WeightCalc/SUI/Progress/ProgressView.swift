//
//  ProgressView.swift
//  WeightCalc
//
//  Created by D K on 20.07.2025.
//

// MARK: - ProgressView.swift

import SwiftUI
import Charts

struct ProgressView: View {
    
    // ViewModel для этого экрана
    @StateObject private var viewModel = ProgressViewModel()
    
    // Получаем доступ к главному ViewModel через окружение
    @EnvironmentObject private var workoutsViewModel: WorkoutsViewModel
    
    var body: some View {
        ZStack {
            // Фон
            LinearGradient(
                gradient: Gradient(colors: [.themeBackgroundStart, .themeBackgroundEnd]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // Основной контент
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Progress")
                        .font(.largeTitle).bold()
                        .foregroundColor(.textPrimary)
                        .padding([.horizontal, .top])
                        .padding(.top, 40)
                    
                    // Проверяем, есть ли хоть какие-то данные для отображения
                    if viewModel.summaryStats == nil && viewModel.personalRecords.isEmpty {
                        EmptyStateView()
                    } else {
                        // Отображаем все карточки со статистикой
                        SummaryStatsCard(stats: viewModel.summaryStats)
                        TotalVolumeCard(data: viewModel.monthlyVolumeData)
                        ExerciseProgressionCard(
                            data: viewModel.exerciseProgressionData,
                            availableExercises: viewModel.exercisesWithHistory,
                            selectedExercise: $viewModel.selectedExercise
                        )
                        PersonalRecordsCard(records: viewModel.personalRecords)
                    }
                }
                .padding(.bottom, 120)
            }
            .padding(.bottom, 50)

        }
        .onAppear {
            // Каждый раз при появлении экрана, обновляем данные в ProgressViewModel
            // из главного источника правды - workoutsViewModel
            viewModel.updateData(from: workoutsViewModel.workoutHistory)
        }
    }
}

// MARK: - New Subviews for ProgressView

struct SummaryStatsCard: View {
    let stats: SummaryStats?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("At a Glance")
                .font(.title2).bold()
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                StatItem(value: "\(stats?.totalWorkouts ?? 0)", label: "Workouts")
                Divider().background(Color.white.opacity(0.3))
                StatItem(value: "\(Int(stats?.totalVolume ?? 0)) kg", label: "Total Volume")
                Divider().background(Color.white.opacity(0.3))
                StatItem(value: "\(Int(stats?.heaviestLift?.weight ?? 0)) kg", label: "Heaviest Lift")
            }
            .frame(height: 50)
        }
        .cardStyle()
    }
}

struct StatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.headline).bold()
                .foregroundColor(.themeAccent)
            Text(label)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PersonalRecordsCard: View {
    let records: [PersonalRecord]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Records (Max Weight)")
                .font(.title2).bold()
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(records) { record in
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.themeAccent)
                        Text(record.exerciseName)
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(Int(record.recordLog.weight)) kg × \(record.recordLog.reps) reps")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                    if record.id != records.last?.id {
                        Divider().background(Color.white.opacity(0.2))
                    }
                }
            }
        }
        .cardStyle()
    }
}


// MARK: - Existing Subviews (with minor updates)

struct TotalVolumeCard: View {
    let data: [MonthlyVolume]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Total Volume")
                .font(.title2).bold().foregroundColor(.white)
            Text("Sum of weight × reps across all workouts").font(.footnote).foregroundColor(.textSecondary)
            
            if data.isEmpty {
                PlaceholderChartView(message: "Not enough data to show the chart.")
            } else {
                Chart(data) { item in
                    BarMark(x: .value("Month", item.month), y: .value("Volume (kg)", item.totalVolume))
                        .foregroundStyle(Color.themeAccent.gradient)
                        .cornerRadius(8)
                }
                .chartStyle()
            }
        }
        .cardStyle()
    }
}


struct ExerciseProgressionCard: View {
    let data: [WorkoutLog]
    let availableExercises: [String]
    @Binding var selectedExercise: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Exercise Progression").font(.title2).bold().foregroundColor(.white)
            
            if availableExercises.isEmpty {
                Text("Track a workout to see progression.").font(.footnote).foregroundColor(.textSecondary)
            } else {
                Picker("Select Exercise", selection: $selectedExercise) {
                    ForEach(availableExercises, id: \.self) { name in Text(name).tag(name) }
                }
                .pickerStyle(.menu)
                .accentColor(.themeAccent)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
            }
            
            if data.isEmpty {
                PlaceholderChartView(message: "No history for this exercise.")
            } else {
                Chart(data) { log in
                    LineMark(x: .value("Date", log.date), y: .value("Weight", log.weight))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color.themeAccent)
                        .symbol(Circle().strokeBorder(lineWidth: 2))
                    
                    PointMark(x: .value("Date", log.date), y: .value("Weight", log.weight))
                        .foregroundStyle(Color.themeAccent)
                }
                .chartStyle()
            }
        }
        .cardStyle()
    }
}

// MARK: - Helper Views and Modifiers

// Общий стиль для всех карточек
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.themeCard)
            .cornerRadius(20)
            .padding(.horizontal)
    }
}

extension View {
    func cardStyle() -> some View {
        self.modifier(CardStyle())
    }
}

// Общий стиль для графиков
extension Chart {
    func chartStyle() -> some View {
        self.frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine().foregroundStyle(Color.white.opacity(0.2))
                    AxisValueLabel().foregroundStyle(Color.themeAccent)
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine().foregroundStyle(Color.clear)
                    AxisValueLabel().foregroundStyle(Color.themeAccent)
                }
            }
    }
}

// Заглушка для пустого графика
struct PlaceholderChartView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.caption)
            .foregroundColor(.textSecondary)
            .frame(maxWidth: .infinity, minHeight: 200, alignment: .center)
    }
}

// Заглушка для всего экрана
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 60))
                .foregroundColor(.themeAccent.opacity(0.8))
            
            Text("No Data Yet")
                .font(.title2).bold()
                .foregroundColor(.white)
            
            Text("Track your workouts to unlock amazing progress charts and stats!")
                .font(.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
        .frame(height: 400)
    }
}
