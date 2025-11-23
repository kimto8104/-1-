//
//  SettingsView.swift
//  NowFocus
//
//  Created by Tomofumi Kimura on 2025/11/20.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @Environment(\.dismiss) var dismiss
    
    // State for UI
    @State private var selectedDays: Set<Int> = [1, 2, 3, 4, 5] // Default Mon-Fri (1=Mon, 7=Sun)
    @State private var notificationTime: Date = Date()
    @State private var isNotificationEnabled: Bool = true
    
    let days = ["月", "火", "水", "木", "金", "土", "日"]
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                
                // Header (if needed, or just rely on navigation bar if presented in nav view)
                // The image shows "習慣設定編集画面" at the top, likely a navigation title.
                
                VStack(alignment: .leading, spacing: 16) {
                    // Day Selector
                    Text("曜日")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 12) {
                        ForEach(0..<7) { index in
                            DayButton(
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
                        .background(Color.white)
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
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.blue)
                        .cornerRadius(16)
                        .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.bottom, 20)
                
            }
            .padding(24)
            .background(Color.white)
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
        // For now, we just use the defaults or what's in NotificationManager if applicable
        // In a real app, we'd load 'selectedDays' from UserDefaults
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
            notificationManager.requestPermission { granted in
                if granted {
                    notificationManager.scheduleNotifications(at: notificationTime, on: Array(selectedDays))
                } else {
                    print("Notification permission denied")
                }
            }
        } else {
            notificationManager.cancelNotifications()
        }
        
        dismiss()
    }
}

struct DayButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .white : .gray)
                .frame(width: 40, height: 40)
                .background(
                    Group {
                        if isSelected {
                            Circle()
                                .fill(Color.blue)
                                .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
                        } else {
                            Circle()
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 2, y: 2)
                                .shadow(color: Color.white, radius: 4, x: -2, y: -2)
                        }
                    }
                )
        }
    }
}

#Preview {
    SettingsView()
}
