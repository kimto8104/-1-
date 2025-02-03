//
//  TimerPresenter.swift
//  NowFocus
//
//  Created by Tomofumi Kimura on 2024/07/21.
//

import SwiftUI
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
  func updateShowAlertForPause(showAlert: Bool)
  func updateShowResultView(show: Bool)
  func updateTabBarVisibility(isVisible: Bool)
  func showTotalFocusTime(totalFocusTimeString: String)
  // SwiftDataに保存するためのメソッド
  func saveTotalFocusTimeInTimeInterval(extraFocusTime: TimeInterval)
  func saveStartDate(_ date: Date)
  // MotionManager
  func updateIsFaceDown(isFaceDown: Bool)
//  func startMonitoringDeviceMotion()
  func stopMonitoringDeviceMotion()
  
}

class TimerPresenter: NSObject, TimerPresenterProtocol {
  var originalTime: TimeInterval?
  var startDate: Date?
  var totalFocusTimeInTimeInterval: TimeInterval?
  // タブバー表示状態を保持
  var isTabBarVisible: Binding<Bool>?
  
  private(set) lazy var view = TimerPage().delegate(self)
  var interactor: TimerInteractorProtocol?
  var router: TimerRouterProtocol?
  
  // 00:50のフォーマットに変えてViewに渡す
  func updateRemainingTime(remainingTime: String) {
    view.model.updateRemainingTime(remainingTime: remainingTime)
  }
  
  func updateTimerState(timerState: TimerState) {
    view.model.updateTimerState(timerState: timerState)
  }
  
  func updateIsFaceDown(isFaceDown: Bool) {
    view.model.updateIsFaceDown(isFaceDown: isFaceDown)
  }
  
  func updateShowAlertForPause(showAlert: Bool) {
    view.model.updateShowAlertForPause(showAlert: showAlert)
  }
  
  func updateShowResultView(show: Bool) {
    view.model.updateShowResultView(show: show)
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
  
  func stopMonitoringDeviceMotion() {
    interactor?.stopMonitoringDeviceMotion()
  }
  
  func resetTimer() {
    interactor?.resetTimer()
    interactor?.updateTimerState(timerState: .start)
    startMonitoringDeviceMotion()
//    view.model.startProgressAnimation()
  }
  
  // タブバーの表示/非表示を制御
  func updateTabBarVisibility(isVisible: Bool) {
    withAnimation(.easeInOut(duration: 1.0)) {
      self.isTabBarVisible?.wrappedValue = isVisible
    }
  }
}

extension TimerPresenter: TimerPageDelegate {
  func tapCategorySelectionButton() {
    view.model.showCategoryPopup()
  }
  
  func tapResetAlertOKButton() {
    self.resetTimer()
  }
  
  func tapCompletedButton() {
    self.resetTimer()
  }
  
  func startMonitoringDeviceMotion() {
    interactor?.startMonitoringDeviceMotion()
  }
}
