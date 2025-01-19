//
//  TimerPresenter.swift
//  NowFocus
//
//  Created by Tomofumi Kimura on 2024/07/21.
//

import Foundation
enum TimerState: String {
  case start
  case paused
  case completed
  case continueFocusing
}

// MARK: Protocol
protocol TimerPresenterProtocol: ObservableObject {
  var interactor: TimerInteractorProtocol? { get set }
  var router: TimerRouterProtocol? { get set }
  
  var time: String { get }
  var totalFocusTime: String? { get }
  var isFaceDown: Bool { get }
  var timerState: TimerState { get }
  var showAlertForPause: Bool { get set }
  var startDate: Date? { get }
  var totalFocusTimeInTimeInterval: TimeInterval? { get }
  var id: UUID { get }
  func resetTimer()
  func updateTime(time: TimeInterval)
  func updateTimerState(timerState: TimerState)
  func showTotalFocusTime(extraFocusTime: TimeInterval)
  // SwiftDataに保存するためのメソッド
  func saveTotalFocusTimeInTimeInterval(extraFocusTime: TimeInterval)
  func saveStartDate(_ date: Date)
  // MotionManager
  func updateIsFaceDown(isFaceDown: Bool)
  func startMonitoringDeviceMotion()
  func stopMonitoringDeviceMotion()
  
}

class TimerPresenter: TimerPresenterProtocol {
  @Published var time: String = "01:00"
  @Published var totalFocusTime: String?
  @Published var isFaceDown = false
  @Published var timerState: TimerState = .start
  @Published var showAlertForPause = false
  
  var originalTime: TimeInterval?
  var startDate: Date?
  var totalFocusTimeInTimeInterval: TimeInterval?
  
  var interactor: TimerInteractorProtocol?
  var router: TimerRouterProtocol?
  
  
  var id: UUID = UUID()
  init(time: Int) {
    print("TimerPresenter initialized")
    print("UUID: \(id)")
//    updateTime(time: TimeInterval(time * 60))
    updateTime(time: TimeInterval(time))
  }
  
  func resumeTimer() {
    interactor?.startTimer()
  }
  
  func resetTimer() {
    interactor?.resetTimer()
  }
  
  // 00:50のフォーマットに変える
  func updateTime(time: TimeInterval) {
    self.originalTime = time
    let minutes = Int(time) / 60
    let seconds = Int(time) % 60
    self.time =  String(format: "%02d:%02d", minutes, seconds)
    print("updateTime: \(self.time)")
  }
  
  func updateTimerState(timerState: TimerState) {
    self.timerState = timerState
  }
  
  func updateIsFaceDown(isFaceDown: Bool) {
    self.isFaceDown = isFaceDown
  }
  
  func showTotalFocusTime(extraFocusTime: TimeInterval) {
    // 現在の time を TimeInterval に変換
    let timeComponents = self.time.split(separator: ":").map { Int($0) ?? 0 }
    let currentTimeInSeconds = (timeComponents[0] * 60) + timeComponents[1]
    
    // 合計時間を計算
    let totalTimeInSeconds = currentTimeInSeconds + Int(extraFocusTime)
    
    // 合計時間をフォーマット
    let hours = totalTimeInSeconds / 3600
    let minutes = (totalTimeInSeconds % 3600) / 60
    let seconds = totalTimeInSeconds % 60
    
    if hours > 0 {
      self.totalFocusTime = "\(hours)時間\(minutes)分\(seconds)秒"
    } else if minutes > 0 {
      self.totalFocusTime = "\(minutes)分\(seconds)秒"
    } else {
      self.totalFocusTime = "\(seconds)秒"
    }
    
    print("合計集中時間: \(self.totalFocusTime!)")
  }
  
  func saveTotalFocusTimeInTimeInterval(extraFocusTime: TimeInterval) {
    if let originalTime = originalTime {
      self.totalFocusTimeInTimeInterval = extraFocusTime + originalTime
    } else {
      print("failed to calculate total focus time in TimeInterval so failed to save SwiftData")
    }
  }
  
  func saveStartDate(_ date: Date) {
    self.startDate = date
  }
  
  
  func startMonitoringDeviceMotion() {
    interactor?.startMonitoringDeviceMotion()
  }
  
  func stopMonitoringDeviceMotion() {
    interactor?.stopMonitoringDeviceMotion()
  }
}
