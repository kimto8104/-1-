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
    print("ConsecutiveDaysRecordManager: getTotalConsecutiveFocusDays開始")
    // 毎回最新のデータから計算
    calculateAndSaveCurrentFocusStreakToUserDefaults()
    let result = consecutiveDays
    print("ConsecutiveDaysRecordManager: getTotalConsecutiveFocusDays結果: \(result)")
    return result
  }
  
  // 特定のカテゴリーの連続集中記録を取得
  @MainActor
  func getCurrentFocusStreakByCategory(_ category: String) -> Int {
    // 現在のタイムゾーンを明示的に指定してカレンダーを作成
    var calendar = Calendar.current
    calendar.timeZone = TimeZone.current
    
    let today = calendar.startOfDay(for: Date())
    let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today)!
    
    print("ConsecutiveDaysRecordManager: カテゴリー別連続日数計算開始")
    print("ConsecutiveDaysRecordManager: 対象カテゴリー: \(category)")
    print("ConsecutiveDaysRecordManager: 今日: \(today)")
    print("ConsecutiveDaysRecordManager: 30日前: \(thirtyDaysAgo)")
    print("ConsecutiveDaysRecordManager: 使用タイムゾーン: \(TimeZone.current.identifier)")
    
    // 過去30日分の履歴を取得
    let descriptor = FetchDescriptor<FocusHistory>(
      predicate: #Predicate<FocusHistory> { history in
        history.startDate >= thirtyDaysAgo && history.category == category
      },
      sortBy: [SortDescriptor(\.startDate, order: .reverse)]
    )
    
    do {
        let histories = try ModelContainerManager.shared.container.mainContext.fetch(descriptor)
      
      print("ConsecutiveDaysRecordManager: 取得した履歴数: \(histories.count)")
      for (index, history) in histories.enumerated() {
        print("ConsecutiveDaysRecordManager: 履歴\(index + 1) - 日付: \(history.startDate), カテゴリー: \(history.category ?? "nil"), 時間: \(history.duration)")
      }
      
      // 日付ごとにグループ化（同じ日の複数セッションは1日としてカウント）
      var uniqueDates = Set<Date>()
      for history in histories {
        let dayStart = calendar.startOfDay(for: history.startDate)
        uniqueDates.insert(dayStart)
        print("ConsecutiveDaysRecordManager: カテゴリー別履歴日付 \(history.startDate) -> 日付開始時刻 \(dayStart)")
      }
      
      print("ConsecutiveDaysRecordManager: ユニークな日付数: \(uniqueDates.count)")
      for date in uniqueDates.sorted() {
        print("ConsecutiveDaysRecordManager: ユニーク日付: \(date)")
      }
      
      // 連続日数を計算
      var currentStreak = 0
      var checkDate = today
      
      // 今日の記録があるかチェック
      let hasTodayRecord = uniqueDates.contains(checkDate)
      print("ConsecutiveDaysRecordManager: カテゴリー別今日の記録あり: \(hasTodayRecord)")
      
      if hasTodayRecord {
        // 今日の記録がある場合、今日から過去に向かって計算
        while true {
          if uniqueDates.contains(checkDate) {
            currentStreak += 1
            print("ConsecutiveDaysRecordManager: \(checkDate) に記録あり - 連続日数: \(currentStreak)")
            // 前日をチェック
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
          } else {
            print("ConsecutiveDaysRecordManager: \(checkDate) に記録なし - 連続終了")
            break
          }
        }
      } else {
        // 今日の記録がない場合、昨日から過去に向かって計算
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { 
          print("ConsecutiveDaysRecordManager: 昨日の日付計算に失敗")
          return 0
        }
        checkDate = yesterday
        
        while true {
          if uniqueDates.contains(checkDate) {
            currentStreak += 1
            print("ConsecutiveDaysRecordManager: \(checkDate) に記録あり - 連続日数: \(currentStreak)")
            // 前日をチェック
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
          } else {
            print("ConsecutiveDaysRecordManager: \(checkDate) に記録なし - 連続終了")
            break
          }
        }
      }
      
      print("ConsecutiveDaysRecordManager: 最終連続日数: \(currentStreak)")
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
    print("ConsecutiveDaysRecordManager: calculateAndSaveCurrentFocusStreakToUserDefaults開始")
    
    // 現在のタイムゾーンを明示的に指定してカレンダーを作成
    var calendar = Calendar.current
    calendar.timeZone = TimeZone.current
    
    let today = calendar.startOfDay(for: Date())
    let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today)!
    
    print("ConsecutiveDaysRecordManager: 全カテゴリー連続日数計算 - 今日: \(today), 30日前: \(thirtyDaysAgo)")
    print("ConsecutiveDaysRecordManager: 使用タイムゾーン: \(TimeZone.current.identifier)")
    
    // 過去30日分の履歴を取得（連続日数の計算には十分な期間）
    let descriptor = FetchDescriptor<FocusHistory>(
      predicate: #Predicate<FocusHistory> { history in
        history.startDate >= thirtyDaysAgo
      },
      sortBy: [SortDescriptor(\.startDate, order: .reverse)]
    )
    
    do {
      let histories = try ModelContainerManager.shared.container.mainContext.fetch(descriptor)
      
      print("ConsecutiveDaysRecordManager: 全カテゴリー履歴取得数: \(histories.count)")
      for (index, history) in histories.enumerated() {
        print("ConsecutiveDaysRecordManager: 全カテゴリー履歴\(index + 1) - 日付: \(history.startDate), カテゴリー: \(history.category ?? "nil"), 時間: \(history.duration)")
      }
      
      // 日付ごとにグループ化（同じ日の複数セッションは1日としてカウント）
      var uniqueDates = Set<Date>()
      for history in histories {
        // タイムゾーンを明示的に指定して日付の開始時刻を取得
        let dayStart = calendar.startOfDay(for: history.startDate)
        uniqueDates.insert(dayStart)
        print("ConsecutiveDaysRecordManager: 履歴日付 \(history.startDate) -> 日付開始時刻 \(dayStart)")
      }
      
      print("ConsecutiveDaysRecordManager: 全カテゴリーユニーク日付数: \(uniqueDates.count)")
      for date in uniqueDates.sorted() {
        print("ConsecutiveDaysRecordManager: 全カテゴリーユニーク日付: \(date)")
      }
      
      // 連続日数を計算
      var currentStreak = 0
      var checkDate = today
      
      // 今日の記録があるかチェック
      let hasTodayRecord = uniqueDates.contains(checkDate)
      print("ConsecutiveDaysRecordManager: 今日の記録あり: \(hasTodayRecord)")
      
      if hasTodayRecord {
        // 今日の記録がある場合、今日から過去に向かって計算
        while true {
          if uniqueDates.contains(checkDate) {
            currentStreak += 1
            print("ConsecutiveDaysRecordManager: 全カテゴリー \(checkDate) に記録あり - 連続日数: \(currentStreak)")
            // 前日をチェック
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
          } else {
            print("ConsecutiveDaysRecordManager: 全カテゴリー \(checkDate) に記録なし - 連続終了")
            break
          }
        }
      } else {
        // 今日の記録がない場合、昨日から過去に向かって計算
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { 
          print("ConsecutiveDaysRecordManager: 昨日の日付計算に失敗")
          return 
        }
        checkDate = yesterday
        
        while true {
          if uniqueDates.contains(checkDate) {
            currentStreak += 1
            print("ConsecutiveDaysRecordManager: 全カテゴリー \(checkDate) に記録あり - 連続日数: \(currentStreak)")
            // 前日をチェック
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
          } else {
            print("ConsecutiveDaysRecordManager: 全カテゴリー \(checkDate) に記録なし - 連続終了")
            break
          }
        }
      }
      // 連続日数を更新
      UserDefaultManager.consecutiveDays = currentStreak
      print("ConsecutiveDaysRecordManager: 全カテゴリー最終連続日数: \(currentStreak)")
      
    } catch {
      print("ConsecutiveDaysRecordManager: 全カテゴリー履歴の取得に失敗 - \(error)")
      // エラー時は現在の値を維持
    }
  }
  
  // 連続記録をリセット（テスト用）
  func resetRecord() {
    UserDefaultManager.consecutiveDays = 0
  }
}
