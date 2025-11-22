//
//  NotificationHalfModalSettingView.swift
//  FaceDownFocusTimer
//
//  Created by iosDevelopers on 2025/11/21.
//

import SwiftUI

struct NotificationHalfModalSettingView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @Environment(\.dismiss) var dismiss
    
    // State for UI
    @State private var selectedDays: Set<Int> = [1, 2, 3, 4, 5] // Default Mon-Fri (1=Mon, 7=Sun)
    @State private var notificationTime: Date = Date()
    @State private var isNotificationEnabled: Bool = true
    
    let days = ["月", "火", "水", "木", "金", "土", "日"]
    
    var body: some View {
        ZStack {
            (Color(hex: "#EAF2F8") ?? .white)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                
                // Title
                Text("通知設定")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 24)
                    .padding(.bottom, 8)
                
                VStack(alignment: .leading, spacing: 16) {
                    // Day Selector
                    Text("曜日")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 12) {
                        ForEach(0..<7) { index in
                            ModalDayButton(
                                title: days[index],
                                isSelected: selectedDays.contains(index + 1),
                                action: {
                                    toggleDay(index + 1)
                                }
                            )
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Time Picker
                    Text("時間")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    DatePicker("", selection: $notificationTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .frame(width: 120, height: 50)
                        .background(Color(hex: "#EAF2F8") ?? .white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                        )
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Notification Toggle
                    HStack {
                        Text("通知")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Spacer()
                        Toggle("", isOn: $isNotificationEnabled)
                            .labelsHidden()
                    }
                }
                
                Spacer()
                
                // Save Button
                Button(action: saveSettings) {
                    Text("保存")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                }
                .buttonStyle(NeumorphicButtonStyle())
                .padding(.bottom, 20)
                
            }
            .padding(24)
            .background(Color(hex: "#EAF2F8") ?? .white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 10)
            .padding()
        }
        .navigationTitle("習慣設定編集画面")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSettings()
        }
    }
    
    private func toggleDay(_ dayIndex: Int) {
        if selectedDays.contains(dayIndex) {
            selectedDays.remove(dayIndex)
        } else {
            selectedDays.insert(dayIndex)
        }
    }
    
    private func loadSettings() {
        // Load saved settings here
        if let savedTime = UserDefaults.standard.object(forKey: "notificationTime") as? Double {
            notificationTime = Date(timeIntervalSince1970: savedTime)
        }
        isNotificationEnabled = UserDefaults.standard.bool(forKey: "isNotificationEnabled")
        
        // Load days if saved, otherwise default
        if let savedDays = UserDefaults.standard.array(forKey: "selectedDays") as? [Int] {
            selectedDays = Set(savedDays)
        }
    }
    
    private func saveSettings() {
        // Save to UserDefaults
        UserDefaults.standard.set(notificationTime.timeIntervalSince1970, forKey: "notificationTime")
        UserDefaults.standard.set(isNotificationEnabled, forKey: "isNotificationEnabled")
        UserDefaults.standard.set(Array(selectedDays), forKey: "selectedDays")
        
        // Update NotificationManager
        if isNotificationEnabled {
            notificationManager.scheduleDailyNotification(at: notificationTime)
        } else {
            notificationManager.cancelNotifications()
        }
        
        dismiss()
    }
}

private struct ModalDayButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .primary : .gray.opacity(0.5))
                .frame(width: 40, height: 40)
                .background(
                    Group {
                        if isSelected {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#EAF2F8") ?? .white)
                                Circle()
                                    .stroke(Color.gray.opacity(0.6), lineWidth: 4)
                                    .blur(radius: 4)
                                    .offset(x: 3, y: 3)
                                    .mask(Circle().fill(LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: .topLeading, endPoint: .bottomTrailing)))
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                                    .blur(radius: 4)
                                    .offset(x: -3, y: -3)
                                    .mask(Circle().fill(LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .topLeading, endPoint: .bottomTrailing)))
                            }
                        } else {
                            Circle()
                                .fill(Color(hex: "#EAF2F8") ?? .white)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 2, y: 2)
                                .shadow(color: Color.white, radius: 4, x: -2, y: -2)
                        }
                    }
                )
        }
    }
}

struct NeumorphicButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Group {
                    if configuration.isPressed {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "#EAF2F8") ?? .white)
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.6), lineWidth: 4)
                                .blur(radius: 4)
                                .offset(x: 3, y: 3)
                                .mask(RoundedRectangle(cornerRadius: 16).fill(LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: .topLeading, endPoint: .bottomTrailing)))
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white, lineWidth: 4)
                                .blur(radius: 4)
                                .offset(x: -3, y: -3)
                                .mask(RoundedRectangle(cornerRadius: 16).fill(LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .topLeading, endPoint: .bottomTrailing)))
                        }
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "#EAF2F8") ?? .white)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 2, y: 2)
                            .shadow(color: Color.white, radius: 4, x: -2, y: -2)
                    }
                }
            )
    }
}

#Preview {
    NotificationHalfModalSettingView()
}
