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
  
  var startDate: Date? { get }
  var totalFocusTimeInTimeInterval: TimeInterval? { get }
  
  func resetTimer()
  func updateRemainingTime(remainingTime: String)
  func updateTimerState(timerState: TimerState)
  func showTotalFocusTime(totalFocusTimeString: String)
  // SwiftDataに保存するためのメソッド
  func saveTotalFocusTimeInTimeInterval(extraFocusTime: TimeInterval)
  func saveStartDate(_ date: Date)
  // MotionManager
  func updateIsFaceDown(isFaceDown: Bool)
  func startMonitoringDeviceMotion()
  func stopMonitoringDeviceMotion()
  
}

class TimerPresenter: NSObject, TimerPresenterProtocol {
//  @Published var time: String = "01:00"
//  @Published var totalFocusTime: String?
//  @Published var isFaceDown = false
//  @Published var timerState: TimerState = .start
//  @Published var showAlertForPause = false
  
  var originalTime: TimeInterval?
  var startDate: Date?
  var totalFocusTimeInTimeInterval: TimeInterval?
  
  private(set) lazy var view = TimerPage().delegate(self)
  var interactor: TimerInteractorProtocol?
  var router: TimerRouterProtocol?
  
  init(time: Int) {
    print("TimerPresenter initialized")
  }
  
  func resumeTimer() {
    interactor?.startTimer()
  }
  
  func resetTimer() {
    interactor?.resetTimer()
  }
  
  // 00:50のフォーマットに変える
  func updateRemainingTime(remainingTime: String) {
    view.model.updateRemainingTime(remainingTime: remainingTime)
  }
  
  func updateTimerState(timerState: TimerState) {
    view.model.updateTimerState(timerState: timerState)
  }
  
  func updateIsFaceDown(isFaceDown: Bool) {
    view.model.updateIsFaceDown(isFaceDown: isFaceDown)
  }
  
  func showTotalFocusTime(totalFocusTimeString: String) {
    view.model.updateTotalFocusTime(totalFocusTimeString: totalFocusTimeString)
    print("合計集中時間: \(totalFocusTimeString)")
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

extension TimerPresenter: TimerPageDelegate {
  func test() {
    print("test")
  }
}
