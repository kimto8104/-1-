//
//  TimerManager.swift
//  NowFocus
//
//  Created by Tomofumi Kimura on 2024/07/01.
//

import Foundation

class TimerManager: ObservableObject {
  @Published var remainingTime: Int? {
    didSet {
      updateFormattedTime()
    }
  }
  @Published var formattedTime: String = ""
  private var timer: Timer?
  @Published var isPaused: Bool = true
  @Published var isFinished: Bool = false
  init(time: Int) {
    // 分数を秒に変える
    self.remainingTime = time * 60
    self.formattedTime = formatTime(seconds: self.remainingTime!)
  }
  
  func tapTimerButton() {
    // タイマー停止の状態で押下するとタイマー再開
    if isPaused {
      startTimer()
    } else {
      // タイマー動いてる状態で押下するとタイマー停止
      stopTimer()
    }
  }
  
  // 00:50のフォーマットに変える
  private func formatTime(seconds: Int) -> String {
    let minutes = seconds / 60
    let seconds = seconds % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }
  
  private func updateFormattedTime() {
    guard let remainingTime = self.remainingTime else { return }
    self.formattedTime = formatTime(seconds: remainingTime)
  }
  
  private func startTimer() {
    isPaused = false
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
      guard let self else { return }
      guard let remainingTime = self.remainingTime else {
        self.stopTimer()
        return
      }
      self.remainingTime! -= 1
      self.updateFormattedTime()
      if remainingTime <= 0 {
        // タイムアップ
        self.stopTimer()
        self.isFinished = true
      }
    })
  }
  
  private func stopTimer() {
    isPaused = true
    timer?.invalidate()
    timer = nil
  }
  
  func reset() {
    self.stopTimer()
    self.remainingTime = nil
  }
}
