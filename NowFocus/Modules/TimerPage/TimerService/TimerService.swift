//
//  TimerService.swift
//  FaceDown Focus Timer
//
//  Created by Tomofumi Kimura on 2025/05/21.
//

import Foundation
import SwiftUI
import Combine

// Time関連を管理するクラス
enum TimerState: String {
  case start
  case paused
  case completed
  case continueFocusing
}

class TimerService {
  private var timer: Timer?
  // タイマーの状態を管理
  @Published private(set) var timerState: TimerState = .start
  
  // 表示用の時間（通常モード：残り時間、追加集中モード：経過時間）
  @Published private(set) var displayTime: TimeInterval
  
  var timeDisplayPublisher: AnyPublisher<String, Never> {
    $displayTime
      .map { time -> String in
        if self.timerState == .continueFocusing {
          // 追加集中時間中は経過時間を表示
          return self.getElapsedTime().toFormattedString()
        }
        return time.toFormattedString()
      }
      .eraseToAnyPublisher()
  }
  
  private let initialTime: TimeInterval
  // タイマー開始時刻（通常のタイマーまたは追加集中時間の開始時）
  private var startDate: Date?
  // 通常モードでの実際の集中時間
  private var normalModeFocusTime: TimeInterval = 0
  
  private var totalFocusTimeInterval: TimeInterval = 0
  
  private var extraFocusStartTime: Date? // タイマー完了後の計測開始時刻
  private var extraFocusTime: TimeInterval = 0 // 追加集中時間
  
  private var selectedCategory: String?
  private var isFirstTimeActive = true
  
  init(initialTime: Int) {
//    self.remainingTime = TimeInterval(initialTime * 60)
//    self.initialTime = TimeInterval(initialTime * 60)
    // DEBUG 用に1秒に変更
    self.displayTime = TimeInterval(initialTime * 1)
    self.initialTime = TimeInterval(initialTime * 1)
  }
  
  // タイマーを開始する
  func startTimer() {
    if timer == nil {
      self.saveStartDate()
    }
    
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
      guard let self else { return }
      
      if self.timerState == .continueFocusing {
        // 追加集中時間モード中は経過時間を更新して表示
        self.displayTime = self.getElapsedTime()
        return
      }
      
      if self.displayTime > 0 {
        // 通常のタイマーモード中は残り時間をカウントダウン
        self.displayTime -= 1
        self.normalModeFocusTime = self.initialTime - self.displayTime
      } else {
        // 設定時間が終了したら追加集中時間モードへ移行
        self.timerState = .continueFocusing
        self.saveStartDate() // 追加集中時間の計測開始
      }
    })
  }
  
  // タイマーを一時停止
  func pauseTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  // タイマーをリセット（初期状態に戻す）
  func resetTimer() {
    timer?.invalidate()
    timer = nil
    displayTime = initialTime
    timerState = .start
    startDate = nil
    normalModeFocusTime = 0
  }
  
  // 開始時刻を保存
  private func saveStartDate() {
    self.startDate = Date()
  }
  
  private func saveStartDateOfExtraFocus() {
    self.extraFocusStartTime = Date()
  }
  
  func updateExtraFocusTime() {
    guard let startTime = extraFocusStartTime else { return }
    extraFocusTime = Date().timeIntervalSince(startTime)
  }
  
  // 開始時刻からの経過時間を計算
  private func getElapsedTime() -> TimeInterval {
    guard let startDate = startDate else { return 0 }
    return Date().timeIntervalSince(startDate)
  }
  
  // 総集中時間を取得（通常モードの集中時間 + 追加集中時間）
  func getTotalFocusTime() -> TimeInterval {
    let additionalTime = timerState == .continueFocusing ? getElapsedTime() : 0
    return normalModeFocusTime + additionalTime
  }
  
  func updateTimerState(timerState: TimerState) {
    self.timerState = timerState
  }
}
