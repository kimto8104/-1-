//
//  TimerInteractor.swift
//  NowFocus
//
//  Created by Tomofumi Kimura on 2024/07/21.
//

import Foundation
import Combine
import AudioToolbox

protocol TimerInteractorProtocol: AnyObject {
  var presenter: (any TimerPresenterProtocol)? { get set}
  func startTimer()
  func pauseTimer()
  func resetTimer()
  
  func updateTimerState(timerState: TimerState)
  // MotionManager
  func startMonitoringDeviceMotion()
  func stopMonitoringDeviceMotion()
  func resetMotionManager()
}

class TimerInteractor: TimerInteractorProtocol {
  // シングルトンインスタンスを保持する静的プロパティ
  static let shared: TimerInteractor = {
    let motionManagerService = MotionManagerService()
    return TimerInteractor(initialTime: 1, motionManagerService: motionManagerService)
  }()
  
  var presenter: (any TimerPresenterProtocol)?
  private var isFirstTimeActive = true
  private var motionManagerService: MotionManagerService
  private var cancellables = Set<AnyCancellable>()
  
  private var timer: Timer?
  private var remainingTime: TimeInterval
  private let initialTime: TimeInterval
  
  private var timerState: TimerState = .start
  
  
  private var extraFocusStartTime: Date? // タイマー完了後の計測開始時刻
  private var extraFocusTime: TimeInterval = 0 // 追加集中時間
  
  private init(initialTime: Int, motionManagerService: MotionManagerService) {
    self.remainingTime = TimeInterval(initialTime * 60)
    self.initialTime = TimeInterval(initialTime * 60)
    self.motionManagerService = motionManagerService
    setupBindings()
  }
  
  private func setupBindings() {
    // isFaceDownの監視、trueになるとタイマーを停止、falseになるとタイマーをスタートさせる
    motionManagerService.$isFaceDown.sink { [weak self] isFaceDown in
      guard let self else { return }
      self.presenter?.updateIsFaceDown(isFaceDown: isFaceDown)
      
      if self.isFirstTimeActive {
        self.isFirstTimeActive = false
        return
      }
      
      if isFaceDown && self.timerState != .completed {
        // 画面が下向きでタイマーが完了していない
        print("\(self.remainingTime.description)のタイマーを開始します")
        self.startTimer()
      } else if !isFaceDown && self.timerState != .completed {
        // 画面が上向きで、タイマーが完了していない
        self.showResetAlertForPause()
        self.pauseTimer()
      } else {
        // 画面が上向きでタイマーを完了した
        self.stopExtraFocusCalculation()
        self.presenter?.saveTotalFocusTimeInTimeInterval(extraFocusTime: self.extraFocusTime)
        
        self.stopMonitoringDeviceMotion()
        // 合計集中時間をPresenterに渡す
        self.presenter?.showTotalFocusTime(totalFocusTimeString: formatTotalFocusTimeForString())
        self.presenter?.updateShowResultView(show: true)
        self.pauseTimer()
      }
    }
    .store(in: &cancellables)
  }
  
  func startTimer() {
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
      guard let self else { return }
      self.presenter?.saveStartDate(Date())
      if self.remainingTime > 0 {
        self.remainingTime -= 1
      } else {
        // タイマー完了
        self.updateCompletedTimeStatus()
        self.startExtraFocusCalculation() // 追加集中時間計測を開始
        self.resetTimer()
        self.updateTimerState(timerState: .completed)
        return
      }
      self.updateFormattedRemainingTime()
    })
  }
  
  private func startExtraFocusCalculation() {
    extraFocusStartTime = Date()
  }
  
  private func stopExtraFocusCalculation() {
    guard let startTime = extraFocusStartTime else { return }
    extraFocusTime += Date().timeIntervalSince(startTime)
    extraFocusStartTime = nil
  }
  
  private func updateCompletedTimeStatus() {
    if initialTime == 60 {
      UserDefaultManager.oneMinuteDoneToday = true
    } else if initialTime == 600 {
      // 10分
      UserDefaultManager.tenMinuteDoneToday = true
    } else if initialTime == 900 {
      // 15分
      UserDefaultManager.fifteenMinuteDoneToday = true
    } else if initialTime == 1800 {
      // 30分
      UserDefaultManager.thirtyMinuteDoneToday = true
    } else if initialTime == 3000 {
      // 50分
      UserDefaultManager.fiftyMinuteDoneToday = true
    }
  }
  
  func updateTimerState(timerState: TimerState) {
    self.timerState = timerState
    self.presenter?.updateTimerState(timerState: timerState)
  }
  
  // 残り時間をフォーマットしてPresenterに渡す
  private func updateFormattedRemainingTime() {
      let minutes = Int(remainingTime) / 60
      let seconds = Int(remainingTime) % 60
      let formattedTime = String(format: "%02d:%02d", minutes, seconds)
    self.presenter?.updateRemainingTime(remainingTime: formattedTime)
      print("updateTime: \(formattedTime)") // デバッグ用
  }
  
  private func formatTotalFocusTimeForString() -> String {
    var totalFocusTimeString: String = ""
    var totalFocusTimeInSeconds = Int(initialTime) + Int(extraFocusTime)
    let hours = totalFocusTimeInSeconds / 3600
    let minutes = (totalFocusTimeInSeconds % 3600) / 60
    let seconds = totalFocusTimeInSeconds % 60
    
    if hours > 0 {
      totalFocusTimeString = "\(hours)時間\(minutes)分\(seconds)秒"
    } else if minutes > 0 {
      totalFocusTimeString = "\(minutes)分\(seconds)秒"
    } else {
      totalFocusTimeString = "\(seconds)秒"
    }
    
    return totalFocusTimeString
  }
  
  /// タイマー途中で画面を上向きにした場合に続けるかどうか？のアラートを出す
  private func showResetAlertForPause() {
    presenter?.updateShowAlertForPause(showAlert: true)
  }
  
  func pauseTimer() {
    self.timer?.invalidate()
  }
  
  func resetTimer() {
    timer?.invalidate()
    timer = nil
    remainingTime = initialTime
    self.updateFormattedRemainingTime()
  }
  
  func startMonitoringDeviceMotion() {
    motionManagerService.startMonitoringDeviceMotion()
  }
  
  func stopMonitoringDeviceMotion() {
    motionManagerService.stopMonitoring()
  }
  
  func resetMotionManager() {
    motionManagerService.reset()
  }
}
