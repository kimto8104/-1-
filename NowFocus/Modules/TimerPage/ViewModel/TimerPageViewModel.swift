//
//  TimerPageViewModel.swift
//  FaceDown Focus Timer
//
//  Created by Tomofumi Kimura on 2025/05/21.
//

import SwiftUI
import Combine

// MARK: ViewModel
@MainActor
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
  @Published var isPulsating: Bool = false
  @Published var isResultViewAnimating: Bool = false
  @Published var isInstructionTextPulsing: Bool = false // instructionText用の点滅アニメーション
  // Category
  @Published var isCategoryPopupPresented = false
  var categoryPopup: CategoryPopup?  // モジュールをここで保持
  @Published var selectedCategory: String = UserDefaultManager.savedCategories.first ?? "reading"
  
  // HabitSetting
  @Published var isHabitSettingPresented = false
  
  // お祝いポップアップ関連のプロパティ
  @Published var showCelebrationPopup = false
  @Published var consecutiveDays = 0
  
  init(motionManagerService: MotionManagerService, timerService: TimerService) {
    self.motionManagerService = motionManagerService
    self.timerService = timerService
    print("TimerPageViewModel init - savedCategories: \(UserDefaultManager.savedCategories)")
    print("TimerPageViewModel init - selectedCategory: \(selectedCategory)")
    startObserving()
  }
  
  private func startObserving() {
    observeTimerState()
    observeDisplayTime()
    observeFaceDownState()
    observeSelectedTab()
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
  
  private func observeSelectedTab() {
    // selectedTabの変更を監視
    $selectedTab.sink { [weak self] newTab in
      guard let self else { return }
      self.handleTabChange(newTab: newTab)
    }
    .store(in: &cancellables)
  }
  
  private func handleTabChange(newTab: TabIcon) {
    print("Tab changed to: \(newTab)")
    
    switch newTab {
    case .Home:
      // Homeタブに切り替わった時はMotionManagerを開始
      print("Starting motion monitoring for Home tab")
      motionManagerService.startMonitoringDeviceMotion()
      
    case .Clock:
      // HistoryPageに切り替わった時はMotionManagerを停止
      print("Stopping motion monitoring for HistoryPage")
      motionManagerService.stopMonitoring()
      
      // タイマーが実行中だった場合はリセット
      if timerService.timerState == .focusing || timerService.timerState == .continueFocusing {
        print("Resetting timer when switching to HistoryPage")
        timerService.resetTimer()
        UIApplication.shared.isIdleTimerDisabled = false
      }
    }
  }
  
  private func handleDeviceOrientationChange(isFaceDown: Bool) {
    if isFaceDown {
      timerService.startTimer()
      AnalyticsManager.shared.logTimerStart(category: selectedCategory)
      if timerService.timerState == .focusing || timerService.timerState == .continueFocusing {
        UIApplication.shared.isIdleTimerDisabled = true
      }
    } else {
      // 画面を上向きにした時
      switch timerService.timerState {
      case .focusing:
        // 集中中に画面が上向きになった
        print("Failed")
        self.showFailedView = true
        // 失敗画面を出す
        // 集中失敗時にAnalyticsイベントを送信
        let remainingTime = timerService.getTotalFocusTime()
        AnalyticsManager.shared.logTimerCancel(duration: remainingTime, category: selectedCategory)
      case .continueFocusing:
        // 追加集中時間中に上向きになった場合&タイマー完了した時は結果を表示
        let totalTime = timerService.getTotalFocusTime()
        updateTotalFocusTime(totalFocusTimeString: totalTime.toFormattedString())
        saveFocusHistory() // 集中履歴を保存
        // 連続記録を更新
        ConsecutiveDaysRecordManager.shared.recordFocusSession()
        updateShowCelebrationPopup(show: true)
        
        // 集中完了時にAnalyticsイベントを送信
        AnalyticsManager.shared.logFocusSessionComplete(duration: totalTime, category: selectedCategory)
      default: break
      }
      // MotionMangerの判定を止める
      motionManagerService.stopMonitoring()
      // タイマーを止める
      timerService.resetTimer()
      if timerService.timerState == .ready {
        UIApplication.shared.isIdleTimerDisabled = false
      }
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
    }
  }
  
  func startProgressAnimation() {
    print("instruction pulse: \(self.isInstructionTextPulsing)")
    // パルスアニメーションを開始
    self.isPulsating = true
  }
  
  func updateSelectedCategory(_ category: String) {
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
  
  func updateShowAlertForPause(showAlert: Bool) {
    self.showAlertForPause = showAlert
  }
  
  func updateShowCelebrationPopup(show: Bool) {
    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
      showCelebrationPopup = show
      
      // 連続日数達成時にAnalyticsイベントを送信
      if show && consecutiveDays > 0 {
        AnalyticsManager.shared.logConsecutiveDaysAchieved(consecutiveDays: consecutiveDays)
      }
    }
  }
  
  
  func updateShowResultView(show: Bool) {
    withAnimation(.easeInOut(duration: 1.0)) {
      self.showResultView = show
      if show {
        // 結果画面を表示する時にアニメーションを開始
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
          self.isResultViewAnimating = true
        }
      } else {
        self.isResultViewAnimating = false
      }
    }
  }
  
  func handleCompletionButtonTap() {
    timerService.resetTimer()
    self.showResultView = false
    self.showFailedView = false
    self.continueFocusingMode = false
    motionManagerService.startMonitoringDeviceMotion()
  }
}

// MARK: Category
extension TimerPageViewModel {
  func tapCategorySelectionButton() {
    print("tapCategorySelectionButton - current categories: \(UserDefaultManager.savedCategories)")
    print("tapCategorySelectionButton - selectedCategory: \(selectedCategory)")
    showCategoryPopup()
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
}

// MARK: - FocusHistoryDataManager
extension TimerPageViewModel {
  // 集中できた記録を保存
  func saveFocusHistory() {
    guard let startDate = timerService.normalTimerStartDate else { return }
    let duration = timerService.getTotalFocusTime()
    FocusHistoryDataManager.shared.saveFocusHistoryData(
      startDate: startDate,
      duration: duration,
      habit: Habit(habitName: "Test")
    )
  }
}
