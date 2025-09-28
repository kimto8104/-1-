//
//  NowFocusApp.swift
//  NowFocus
//
//  Created by Tomofumi Kimura on 2023/02/12.
//

import SwiftUI
import UserNotifications
import SwiftData

@main
struct NowFocusApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  var body: some Scene {
    WindowGroup {
      RootView()
    }
  }
}

struct RootView: View {
  @AppStorage("HabitIsCreated") var isHabitCreated: Bool = false
  var body: some View {
      TimerPage()
        // プロジェクト共通のコンテナ（FocusHistory + Habit を含む）を提供
        .modelContainer(ModelContainerManager.shared.container)
        .onAppear {
          // アプリ起動時にリセットを確認
          UserDefaultManager.resetDailyDataIfDateChanged()
        }
    
  }
}
