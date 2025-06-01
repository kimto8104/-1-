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
  
  private let initialTime: TimeInterval
  
  // 表示用の時間（初期値は設定時間）
  @Published private(set) var displayTime: TimeInterval
  
  var timeDisplayPublisher: AnyPublisher<String, Never> {
    $displayTime.map { $0.toFormattedString() }.eraseToAnyPublisher()
  }
  
  private var normalTimerStartDate: Date?  // 通常タイマーの開始時刻
  private var additionalFocusStartDate: Date?  // 追加集中の開始時刻
  private var elapsedSeconds: Int = 0  // 経過秒数
  
  init(initialTime: Int) {
    // DEBUG 用に3秒に変更
    self.initialTime = TimeInterval(initialTime * 3)
    self.displayTime = self.initialTime
  }
  
  // タイマーを開始する
  func startTimer() {
    if timer == nil {
      if timerState == .start {
        normalTimerStartDate = Date()
        elapsedSeconds = 0
      } else if timerState == .continueFocusing {
        additionalFocusStartDate = Date()
        elapsedSeconds = 0
      }
    }
    
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
      guard let self else { return }
      
      switch self.timerState {
      case .start:
        self.handleNormalTimer()
      case .continueFocusing:
        self.handleAdditionalFocusTimer()
      default:
        break
      }
    })
  }
  
  // 通常のタイマー処理
  private func handleNormalTimer() {
    elapsedSeconds += 1
    
    if elapsedSeconds >= Int(initialTime) {
      // タイマー完了時
      displayTime = 0
      timerState = .continueFocusing
      additionalFocusStartDate = Date()
      elapsedSeconds = 0
    } else {
      // 残り時間を更新
      displayTime = initialTime - TimeInterval(elapsedSeconds)
    }
  }
  
  // 追加集中時間の処理
  private func handleAdditionalFocusTimer() {
    elapsedSeconds += 1
    // 初期時間 + 追加経過時間
    displayTime = initialTime + TimeInterval(elapsedSeconds)
  }
  
  // タイマーを一時停止
  func pauseTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  // タイマーをリセット
  func resetTimer() {
    timer?.invalidate()
    timer = nil
    displayTime = initialTime
    timerState = .start
    normalTimerStartDate = nil
    additionalFocusStartDate = nil
    elapsedSeconds = 0
  }
  
  // 総集中時間を取得
  func getTotalFocusTime() -> TimeInterval {
    switch timerState {
    case .continueFocusing:
      // 通常の集中時間 + 追加集中時間
      return initialTime + TimeInterval(elapsedSeconds)
    default:
      // 通常モード中は経過時間を返す
      return TimeInterval(elapsedSeconds)
    }
  }
}
