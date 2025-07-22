// MARK: - WorkoutsView.swift

import SwiftUI

struct WorkoutsView: View {
    
    @EnvironmentObject private var viewModel: WorkoutsViewModel
    @State private var isShowingAddExerciseAlert = false
    @State private var newExerciseName = ""
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            // MARK: - Main Content
            VStack(alignment: .leading, spacing: 0) {
                HeaderView()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.exercises) { exercise in
                            WorkoutCardView(
                                exercise: exercise,
                                log: viewModel.getLatestLog(for: exercise)
                            )
                            .onTapGesture {
                                viewModel.selectedExercise = exercise
                                withAnimation(.spring()) {
                                    viewModel.isShowingEntryView = true
                                }
                            }
                        }
                    }
                    .padding()
                    .padding(.bottom, 150)

                }
                .padding(.bottom, 50)

            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.themeBackgroundStart, .themeBackgroundEnd]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .disabled(viewModel.isShowingEntryView) // Блокируем фон при открытом pop-up
            
            // MARK: - Floating Add Button
            VStack {
                Spacer()
                AddWorkoutButton {
                    isShowingAddExerciseAlert = true
                }
            }
            
            // MARK: - Custom Pop-up View
            if viewModel.isShowingEntryView {
                WorkoutEntryView(viewModel: viewModel)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .alert("New Exercise", isPresented: $isShowingAddExerciseAlert) {
            TextField("Exercise Name (e.g., Leg Press)", text: $newExerciseName)
            Button("Add", action: addCustomExercise)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter the name for your new custom exercise.")
        }
        .tint(.themeAccent)
        
        .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
    }
    
    func addCustomExercise() {
        if !newExerciseName.trimmingCharacters(in: .whitespaces).isEmpty {
            viewModel.addCustomExercise(name: newExerciseName)
            newExerciseName = ""
        }
    }
}


// MARK: - Workout Entry Pop-up View
struct WorkoutEntryView: View {
    @ObservedObject var viewModel: WorkoutsViewModel
    
    // Локальное состояние для полей ввода
    @State private var date: Date
    @State private var weightString: String = ""
    @State private var repsString: String = ""
    
    init(viewModel: WorkoutsViewModel) {
        self.viewModel = viewModel
        
        // Инициализируем состояние на основе данных из ViewModel
        if let log = viewModel.getLatestLog(for: viewModel.selectedExercise!) {
            _date = State(initialValue: log.date)
            _weightString = State(initialValue: String(format: "%.1f", log.weight))
            _repsString = State(initialValue: "\(log.reps)")
        } else {
            // Если данных нет, ставим значения по умолчанию
            _date = State(initialValue: Date())
        }
    }
    
    var body: some View {
        ZStack {
            // Полупрозрачный фон
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { closeView() }
            
            VStack(spacing: 20) {
                Text(viewModel.selectedExercise?.name ?? "Add Workout")
                    .font(.title2).bold()
                    .foregroundColor(.textPrimary)
                
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .foregroundColor(.white)
                //                    .colorInvert()
                //  .colorMultiply(.themeAccent)
                    .tint(.themeAccent)
                
                
                VStack {
                    TextField("Weight (kg)", text: $weightString)
                        .keyboardType(.decimalPad)
                    Divider().background(Color.textSecondary)
                }
                
                VStack {
                    TextField("Reps", text: $repsString)
                        .keyboardType(.numberPad)
                    Divider().background(Color.textSecondary)
                }
                
                Button(action: saveAndClose) {
                    Text("Save")
                        .font(.headline).bold()
                        .foregroundColor(.themeBackgroundEnd)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.themeAccent)
                        .cornerRadius(12)
                }
                .padding(.top)
            }
            .padding(30)
            .background(Color.themeBackgroundEnd)
            .cornerRadius(25)
            .shadow(radius: 20)
            .padding(30)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .textFieldStyle(.plain)
            .foregroundColor(.white)
        }
    }
    
    private func saveAndClose() {
        guard let exercise = viewModel.selectedExercise else { return }
        let weight = Double(weightString) ?? 0.0
        let reps = Int(repsString) ?? 0
        
        viewModel.addLog(for: exercise, date: date, weight: weight, reps: reps)
        closeView()
    }
    
    private func closeView() {
        withAnimation(.spring()) {
            viewModel.isShowingEntryView = false
        }
        viewModel.selectedExercise = nil
    }
}

// MARK: - Updated Card View
struct WorkoutCardView: View {
    let exercise: Exercise
    let log: WorkoutLog?
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text(exercise.name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.themeAccent)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .frame(maxHeight: 100)
            
            Spacer()
            
            if let log = log {
                // Если есть данные
                VStack {
                    Text(log.dateString)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.2))
                        .clipShape(Capsule())
                    
                    Text(log.resultString)
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .overlay(
                            Capsule()
                                .stroke(Color.textSecondary, lineWidth: 1.5)
                        )
                }
            } else {
                // Заглушка, если данных нет
                Text("No data yet.\nTap to add.")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .italic()
            }
            Spacer()
        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 150)
        .background(Color.themeCard)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}


// Вспомогательные View (Header, AddWorkoutButton) можно оставить без изменений
// из предыдущего ответа. Я добавлю их сюда для полноты.

struct HeaderView: View {
    var body: some View {
        Text("My Workouts")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.textPrimary)
            .padding(.horizontal)
            .padding(.top, 50)
            .padding(.bottom, 10)
    }
}

struct AddWorkoutButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label("Add Workout", systemImage: "plus")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.themeBackgroundEnd)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.themeAccent)
                .clipShape(Capsule())
                .shadow(color: .themeAccent.opacity(0.5), radius: 10, y: 5)
        }
        .padding(.horizontal, 40)
        .padding(.bottom, size().height > 667 ? 100 : 80)
    }
}



extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
