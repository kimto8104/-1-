//
//  ConsecutiveDaysRecordManager.swift
//  FaceDown Focus Timer
//
//  Created by Tomofumi Kimura on 2025/06/13.
//

import Foundation
import SwiftData

class ConsecutiveDaysRecordManager {
  
  static let shared = ConsecutiveDaysRecordManager()
  
  private init() {} // シングルトンのため、外部からの初期化を防ぐ
  
  // 現在の連続日数を取得
  private var consecutiveDays: Int {
    UserDefaultManager.consecutiveDays
  }
  
  // 集中セッション完了時に呼び出す
  @MainActor
  func recordFocusSession() {
    // 連続日数を計算して更新
    calculateAndSaveCurrentFocusStreakToUserDefaults()
  }
  
  // 全カテゴリーの連続集中日数を取得
  @MainActor
  func getTotalConsecutiveFocusDays() -> Int {
    // 毎回最新のデータから計算
    calculateAndSaveCurrentFocusStreakToUserDefaults()
    return consecutiveDays
  }
  
  // 特定のカテゴリーの連続集中記録を取得
  @MainActor
  func getCurrentFocusStreakByCategory(_ category: String) -> Int {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today)!
    
    // 過去30日分の履歴を取得
    let descriptor = FetchDescriptor<FocusHistory>(
      predicate: #Predicate<FocusHistory> { history in
        history.startDate >= thirtyDaysAgo && history.category == category
      },
      sortBy: [SortDescriptor(\.startDate, order: .reverse)]
    )
    
    do {
      let histories = try ModelContainerManager.shared.container?.mainContext.fetch(descriptor) ?? []
      
      // 日付ごとにグループ化（同じ日の複数セッションは1日としてカウント）
      var uniqueDates = Set<Date>()
      for history in histories {
        let dayStart = calendar.startOfDay(for: history.startDate)
        uniqueDates.insert(dayStart)
      }
      
      // 連続日数を計算
      var currentStreak = 0
      var checkDate = today
      
      while true {
        if uniqueDates.contains(checkDate) {
          currentStreak += 1
          // 前日をチェック
          guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
          checkDate = previousDay
        } else {
          break
        }
      }
      
      return currentStreak
      
    } catch {
      print("ConsecutiveDaysRecordManager: カテゴリー別履歴の取得に失敗 - \(error)")
      return 0
    }
  }
  
  // 全カテゴリーを考慮した連続集中記録を計算してUserDefaultsに保存
  // 同じ日に複数のカテゴリーで集中しても1日としてカウント
  @MainActor
  private func calculateAndSaveCurrentFocusStreakToUserDefaults() {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today)!
    
    // 過去30日分の履歴を取得（連続日数の計算には十分な期間）
    let descriptor = FetchDescriptor<FocusHistory>(
      predicate: #Predicate<FocusHistory> { history in
        history.startDate >= thirtyDaysAgo
      },
      sortBy: [SortDescriptor(\.startDate, order: .reverse)]
    )
    
    do {
      let histories = try ModelContainerManager.shared.container?.mainContext.fetch(descriptor) ?? []
      
      // 日付ごとにグループ化（同じ日の複数セッションは1日としてカウント）
      var uniqueDates = Set<Date>()
      for history in histories {
        let dayStart = calendar.startOfDay(for: history.startDate)
        uniqueDates.insert(dayStart)
      }
      
      // 連続日数を計算
      var currentStreak = 0
      var checkDate = today
      
      while true {
        if uniqueDates.contains(checkDate) {
          currentStreak += 1
          // 前日をチェック
          guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
          checkDate = previousDay
        } else {
          break
        }
      }
      
      // 連続日数を更新
      UserDefaultManager.consecutiveDays = currentStreak
      
    } catch {
      print("ConsecutiveDaysRecordManager: 履歴の取得に失敗 - \(error)")
      // エラー時は現在の値を維持
    }
  }
  
  // 連続記録をリセット（テスト用）
  func resetRecord() {
    UserDefaultManager.consecutiveDays = 0
  }
}
