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
  @Published var progress: CGFloat = 0
  @Published var isPulsating: Bool = false // パルスアニメーション用
  @Published var isResultViewAnimating: Bool = false // 結果画面のアニメーション用
  // Category
  @Published var isCategoryPopupPresented = false
  var categoryPopup: CategoryPopup?  // モジュールをここで保持
  @Published var selectedCategory: String = UserDefaultManager.savedCategories.first ?? "reading"
  
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
        saveFocusHistory() // 集中履歴を保存
        // 連続記録を更新
        ConsecutiveDaysRecordManager.shared.recordFocusSession()
        updateShowCelebrationPopup(show: true)
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
    }
  }
  
  func startProgressAnimation() {
    progress = 0
    
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
      // 選択されているカテゴリーの連続集中日数を取得
      consecutiveDays = ConsecutiveDaysRecordManager.shared.getCurrentFocusStreakByCategory(selectedCategory)
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
      category: selectedCategory
    )
  }
  
  // モックデータを生成して保存するメソッド
  func saveMockDataHistory() {
    // 過去30日分のランダムなデータを生成
    let numberOfRecords = Int.random(in: 5...15) // 5〜15件のレコードを生成
    let categories = ["勉強", "読書", "プログラミング", "運動", "瞑想", "作業", "趣味"]
    
    for _ in 0..<numberOfRecords {
      // 過去30日以内のランダムな日時を生成
      let randomDaysAgo = Int.random(in: 0...30)
      let randomHoursAgo = Int.random(in: 0...23)
      let randomMinutesAgo = Int.random(in: 0...59)
      
      let startDate = Calendar.current.date(
        byAdding: .day,
        value: -randomDaysAgo,
        to: Date()
      )?.addingTimeInterval(
        TimeInterval(-(randomHoursAgo * 3600 + randomMinutesAgo * 60))
      ) ?? Date()
      
      // 1分〜60分のランダムな集中時間を生成
      let duration = TimeInterval(Int.random(in: 60...3600))
      
      // ランダムなカテゴリーを選択（30%の確率でnil）
      let category = Double.random(in: 0...1) < 0.3 ? nil : categories.randomElement()
      
      // データを保存
      FocusHistoryDataManager.shared.saveFocusHistoryData(
        startDate: startDate,
        duration: duration,
        category: category
      )
    }
  }
}
