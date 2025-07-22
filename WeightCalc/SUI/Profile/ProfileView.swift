//
//  ProfileView.swift
//  WeightCalc
//
//  Created by D K on 21.07.2025.
//

// MARK: - ProfileView.swift
import SwiftUI
import PhotosUI

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedPhotoItem: PhotosPickerItem?
    
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
                VStack(spacing: 20) {
                    Text("My Profile")
                        .font(.largeTitle).bold()
                        .foregroundColor(.textPrimary)
                        .padding(.top, 0)
                    
                    ProfilePhotoPicker(
                        profileImage: viewModel.profileImage,
                        selectedPhotoItem: $selectedPhotoItem
                    )
                    
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            ProfileTextField(label: "HEIGHT (CM)", text: $viewModel.height)
                            ProfileTextField(label: "WEIGHT (KG)", text: $viewModel.weight)
                        }
                        ProfileTextField(label: "AGE", text: $viewModel.age)
                    }
                    
                    updateButton()
                    
                    
                    
                    KangarooTipView(tip: viewModel.currentTip)
                    
                    Spacer()
                }
                .padding()
                .padding(.bottom, 70)
            }
            
            // Показываем подтверждение поверх всего
            if viewModel.showSaveConfirmation {
                saveConfirmationView()
            }
        }
        .onChange(of: selectedPhotoItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    viewModel.setImage(from: data)
                }
            }
        }
    }
    
    @ViewBuilder
    private func updateButton() -> some View {
        Button(action: viewModel.saveProfile) {
            Text("Update")
                .font(.headline.bold())
                .foregroundColor(.themeBackgroundEnd)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.themeAccent)
                .cornerRadius(50)
                .shadow(color: .themeAccent.opacity(0.5), radius: 10, y: 5)
        }
        .padding(.top, 10)
    }

    @ViewBuilder
    private func saveConfirmationView() -> some View {
        Text("Profile Updated!")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.green.opacity(0.8))
            .cornerRadius(12)
            .transition(.opacity.combined(with: .move(edge: .top)))
            .onAppear {
                // Вибрация для обратной связи
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
    }
}

// MARK: - Reusable UI Components for Profile

private struct ProfilePhotoPicker: View {
    let profileImage: Image?
    @Binding var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 150, height: 150)
                    .overlay(
                        Circle().stroke(Color.themeAccent, lineWidth: 4)
                    )
                
                // Отображаем выбранное фото или плейсхолдер
                (profileImage ?? Image(systemName: "person.fill"))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 140)
                    .clipShape(Circle())
                    .foregroundColor(profileImage == nil ? .white.opacity(0.6) : .clear)
                
                // Кнопка "+"
                ZStack {
                    Circle().fill(Color.themeAccent)
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.themeBackgroundEnd)
                }
                .frame(width: 40, height: 40)
                .offset(x: 50, y: 50)
            }
        }
    }
}

private struct ProfileTextField: View {
    let label: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption.bold())
                .foregroundColor(.themeAccent)
            
            TextField("", text: $text)
                .font(.title3.bold())
                .foregroundColor(.black)
                .keyboardType(.decimalPad)
                .padding(12)
                .background(Color.white)
                .cornerRadius(50)
        }
    }
}


private struct KangarooTipView: View {
    let tip: String
    
    var body: some View {
        HStack(alignment: .bottom, spacing: -20) {
            Image("kangaroo_pointing_up") // Убедитесь, что эта картинка есть в Assets
                .resizable()
                .scaledToFit()
                .frame(width: 150)
            
            Spacer()
            
            VStack {
                Text(tip)
                    .font(.subheadline)
                    .padding()
                    .background(Color.white)
                    .clipShape(SpeechBubble())
                    .foregroundColor(.black)
                    .transition(.scale.combined(with: .opacity))
                    .id(tip) // .id() заставляет SwiftUI перерисовывать View и применять transition
                    .shadow(radius: 5)
             Spacer()
            }
        }
        .padding(.top, 20)
    }
}

// Кастомная форма для облачка с текстом
private struct SpeechBubble: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let cornerRadius: CGFloat = 16
        
        path.addRoundedRect(in: rect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
        
        // "Хвостик" облачка
        path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX - 15, y: rect.maxY + 15))
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius + 10, y: rect.maxY))
        
        return path
    }
}

#Preview {
    ProfileView()
}
