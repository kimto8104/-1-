//
//  TimerInteractor.swift
//  NowFocus
//
//  Created by Tomofumi Kimura on 2024/07/21.
//

import Foundation
import Combine
import AudioToolbox

protocol TimerInteractorProtocol {
  var presenter: (any TimerPresenterProtocol)? { get set}
  func startTimer()
  func pauseTimer()
  func resetTimer()
  
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
  
  private var extraFocusStartTime: Date? // タイマー完了後の計測開始時刻
  private var extraFocusTime: TimeInterval = 0 // 追加集中時間
  
  
  private init(initialTime: Int, motionManagerService: MotionManagerService) {
//    self.remainingTime = TimeInterval(initialTime * 60)
//    self.initialTime = TimeInterval(initialTime * 60)
    self.remainingTime = TimeInterval(initialTime)
    self.initialTime = TimeInterval(initialTime)
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
      
      if isFaceDown && presenter?.timerState != .completed {
        // 画面が下向きでタイマーが完了していない
        print("\(self.remainingTime.description)のタイマーを開始します, presenterのiDは\(presenter?.id)")
        self.startTimer()
      } else if !isFaceDown && presenter?.timerState != .completed {
        // 画面が上向きで、タイマーが完了していない
        self.showResetAlertForPause()
        self.pauseTimer()
      } else {
        // 画面が上向きでタイマーを完了した
        self.stopExtraFocusCalculation()
        self.presenter?.saveTotalFocusTimeInTimeInterval(extraFocusTime: self.extraFocusTime)
        self.stopMonitoringDeviceMotion()
        self.presenter?.showTotalFocusTime(extraFocusTime: self.extraFocusTime)
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
        self.presenter?.updateTimerState(timerState: .completed)
        return
      }
      self.presenter?.updateTime(time: remainingTime)
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
  
  /// タイマー途中で画面を上向きにした場合に続けるかどうか？のアラートを出す
  private func showResetAlertForPause() {
    presenter?.showAlertForPause = true
  }
  
  func pauseTimer() {
    self.timer?.invalidate()
  }
  
  func resetTimer() {
    timer?.invalidate()
    timer = nil
    remainingTime = initialTime
    presenter?.updateTime(time: remainingTime)
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
