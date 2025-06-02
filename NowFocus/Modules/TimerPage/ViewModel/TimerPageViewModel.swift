//
//  TimerPageViewModel.swift
//  FaceDown Focus Timer
//
//  Created by Tomofumi Kimura on 2025/05/21.
//

import SwiftUI
import Combine

// MARK: ViewModel
class TimerPageViewModel: ObservableObject {

  // Services
  private let motionManagerService: MotionManagerService
  private let timerService: TimerService
  private var cancellables = Set<AnyCancellable>()
  
  @Published var selectedTab: TabIcon = .Home
  // 合計集中時間文字列
  @Published var totalFocusTime: String?
  @Published var displayTime: String = "00:00"
  @Published var showAlertForPause = false
  @Published var showResultView: Bool = false
  // Failed Page
  @Published var showFailedView: Bool = false
  @Published var continueFocusingMode: Bool = false
  @Published var progress: CGFloat = 0
  @Published var isPulsating: Bool = false // パルスアニメーション用
  @Published var faceUpCount: Int = 0 // 上向きになった回数(内部保持用)
  // Category
  @Published var isCategoryPopupPresented = false
  var categoryPopup: CategoryPopup?  // モジュールをここで保持
  @Published var selectedCategory: String?
  
  init(motionManagerService: MotionManagerService, timerService: TimerService) {
    self.motionManagerService = motionManagerService
    self.timerService = timerService
    startObserving()
  }
  
  private func startObserving() {
    observeTimerState()
    observeDisplayTime()
    observeFaceDownState()
  }
  
  
  private func observeFaceDownState() {
    motionManagerService.$isFaceDown.sink { [weak self] isFaceDown in
      guard let self else { return }
      self.handleDeviceOrientationChange(isFaceDown: isFaceDown)
    }
    .store(in: &cancellables)
  }
  
  private func observeTimerState() {
    timerService.$timerState.sink { [weak self] timerState in
      guard let self else { return }
      self.handleTimerStateChange(timerState: timerState)
    }
    .store(in: &cancellables)
  }
  
  private func observeDisplayTime() {
    timerService.timeDisplayPublisher.sink { [weak self] formattedTime in
      guard let self else { return }
      self.displayTime = formattedTime
    }
    .store(in: &cancellables)
  }
  
  private func handleDeviceOrientationChange(isFaceDown: Bool) {
    if isFaceDown {
      timerService.startTimer()
    } else {
      // 画面を上向きにした時
      switch timerService.timerState {
      case .focusing:
        // 集中中に画面が上向きになった
        print("Failed")
        self.showFailedView = true
        // 失敗画面を出す
      case .completed, .continueFocusing:
        // 追加集中時間中に上向きになった場合&タイマー完了した時は結果を表示
        let totalTime = timerService.getTotalFocusTime()
        updateTotalFocusTime(totalFocusTimeString: totalTime.toFormattedString())
        self.showResultView = true
      default: break
      }
      // MotionMangerの判定を止める
      motionManagerService.stopMonitoring()
      // タイマーを止める
      timerService.resetTimer()
      
    }
  }
  
  private func handleTimerStateChange(timerState: TimerState) {
    switch timerState {
    case .focusing:
      print("start")
    case .ready:
      print("ready")
    case .continueFocusing:
      print("continuFocusing")
      self.continueFocusingMode = true
    case .completed:
      print("completed")
      self.showResultView = true
    }
  }
  
  
  
  func showCategoryPopup() {
    withAnimation(.easeInOut(duration: 0.2)) {
      self.isCategoryPopupPresented = true
    }
  }
  
  func hideCategoryPopup() {
    print("hideCategoryPopup呼び出し")
    withAnimation(.easeInOut(duration: 0.2)) {
      self.isCategoryPopupPresented = false
      print("isCategoryPopupPresented解除: \(self.isCategoryPopupPresented)")
    }
  }
  
  func startProgressAnimation() {
    progress = 0
    
    // パルスアニメーションを開始
    self.isPulsating = true
  }
  
  func updateSelectedCategory(_ category: String?) {
    self.selectedCategory = category
    hideCategoryPopup()
  }
}

// MARK: - MotionManagerService
extension TimerPageViewModel {
  func startMonitoringDeviceMotion() {
    motionManagerService.startMonitoringDeviceMotion()
  }
  
  func stopMonitoringDeviceMotion() {
    motionManagerService.stopMonitoring()
  }
}

// ViewModel Method
extension TimerPageViewModel {
  
  func updateTotalFocusTime(totalFocusTimeString: String) {
    self.totalFocusTime = totalFocusTimeString
  }
  
  func updateFaceUpCount(count: Int) {
    self.faceUpCount = count
  }
  
  func updateShowAlertForPause(showAlert: Bool) {
    self.showAlertForPause = showAlert
  }
  
  func updateShowResultView(show: Bool) {
    withAnimation(.easeInOut(duration: 1.0)) {
      self.showResultView = show
    }
  }
  
  func handleCompletionButtonTap() {
    timerService.resetTimer()
    self.showResultView = false
    self.showFailedView = false
    self.continueFocusingMode = false
  }
}
