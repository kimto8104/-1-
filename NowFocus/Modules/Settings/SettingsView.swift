//
//  SettingsView.swift
//  NowFocus
//
//  Created by Tomofumi Kimura on 2025/11/20.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @AppStorage("isNotificationEnabled") private var isNotificationEnabled: Bool = false
    @AppStorage("notificationTime") private var notificationTime: Double = Date().timeIntervalSince1970
    @Environment(\.dismiss) var dismiss
    
    @State private var showPermissionAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("通知設定")) {
                    Toggle("毎日通知を受け取る", isOn: $isNotificationEnabled)
                        .onChange(of: isNotificationEnabled) { newValue in
                            if newValue {
                                notificationManager.requestPermission { granted in
                                    if !granted {
                                        isNotificationEnabled = false
                                        showPermissionAlert = true
                                    } else {
                                        scheduleNotification()
                                    }
                                }
                            } else {
                                notificationManager.cancelNotifications()
                            }
                        }
                    
                    if isNotificationEnabled {
                        DatePicker("通知時間", selection: Binding(
                            get: { Date(timeIntervalSince1970: notificationTime) },
                            set: { newDate in
                                notificationTime = newDate.timeIntervalSince1970
                                scheduleNotification()
                            }
                        ), displayedComponents: .hourAndMinute)
                    }
                }
                
                Section(header: Text("アプリについて")) {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
            .alert("通知が許可されていません", isPresented: $showPermissionAlert) {
                Button("設定を開く") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("キャンセル", role: .cancel) { }
            } message: {
                Text("通知を受け取るには、設定アプリから通知を許可してください。")
            }
            .onAppear {
                // 画面表示時に権限状態を確認して同期
                notificationManager.checkPermissionStatus()
            }
        }
    }
    
    private func scheduleNotification() {
        let date = Date(timeIntervalSince1970: notificationTime)
        notificationManager.scheduleDailyNotification(at: date)
    }
}

#Preview {
    SettingsView()
}
