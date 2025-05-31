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
  @Published private(set) var remainingTime: TimeInterval
  var remainingTimePublisher: AnyPublisher<String, Never> {
    $remainingTime
      .map { $0.toFormattedString() }
      .eraseToAnyPublisher()
  }
  @Published private(set) var timerState: TimerState = .start
  
  
  private let initialTime: TimeInterval
  private var totalFocusTimeInterval: TimeInterval = 0
  
  
  private var startDate: Date?
  
  private var extraFocusStartTime: Date? // タイマー完了後の計測開始時刻
  private var extraFocusTime: TimeInterval = 0 // 追加集中時間
  
  private var selectedCategory: String?
  private var isFirstTimeActive = true
  
  init(initialTime: Int) {
    self.remainingTime = TimeInterval(initialTime * 60)
    self.initialTime = TimeInterval(initialTime * 60)
  }
  
  
  func startTimer() {
//    self.saveStartDate()
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
      guard let self else { return }
      
      if self.remainingTime > 0 {
        self.remainingTime -= 1
      } else {
        // タイマー完了
//        self.updateCompletedTimeStatus()
//        self.saveStartDateOfExtraFocus() // 追加集中時間計測を開始
        self.resetTimer()
//        self.updateTimerState(timerState: .completed)
        return
      }
//      self.updateFormattedRemainingTime()
    })
  }
  
  func pauseTimer() {
    timer?.invalidate()
  }
  
  func resetTimer() {
    timer?.invalidate()
    timer = nil
    remainingTime = initialTime
//    self.updateFormattedRemainingTime()
//    self.presenter?.updateTabBarVisibility(isVisible: true)
  }
  
  private func saveStartDate() {
    self.startDate = Date()
  }
}
