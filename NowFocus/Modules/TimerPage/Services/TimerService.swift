import Foundation
import Combine
import SwiftData

protocol TimerServiceProtocol {
    var remainingTime: TimeInterval { get }
    var timerState: TimerState { get }
    var isFirstTimeActive: Bool { get }
    
    var remainingTimePublisher: AnyPublisher<String, Never> { get }
    var timerStatePublisher: AnyPublisher<TimerState, Never> { get }
    
    func startTimer()
    func pauseTimer()
    func resetTimer()
    func updateTimerState(_ state: TimerState)
    func saveStartDate()
    func saveFocusHistory(category: String?, faceUpCount: Int)
}

class TimerService: TimerServiceProtocol {
    // MARK: - Published Properties
    @Published private(set) var remainingTime: TimeInterval
    @Published private(set) var timerState: TimerState = .start
    @Published private(set) var isFirstTimeActive = true
    
    // MARK: - Publishers
    var remainingTimePublisher: AnyPublisher<String, Never> {
        $remainingTime
            .map { time in
                let minutes = Int(time) / 60
                let seconds = Int(time) % 60
                return String(format: "%02d:%02d", minutes, seconds)
            }
            .eraseToAnyPublisher()
    }
    
    var timerStatePublisher: AnyPublisher<TimerState, Never> {
        $timerState.eraseToAnyPublisher()
    }
    
    // MARK: - Private Properties
    private let initialTime: TimeInterval
    private var timer: Timer?
    private var startDate: Date?
    private var extraFocusStartTime: Date?
    private var extraFocusTime: TimeInterval = 0
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(initialTimeInMinutes: Int) {
        self.initialTime = TimeInterval(initialTimeInMinutes * 60)
        self.remainingTime = self.initialTime
    }
    
    // MARK: - Public Methods
    func startTimer() {
        saveStartDate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                self.handleTimerCompletion()
                return
            }
        }
    }
    
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        pauseTimer()
        remainingTime = initialTime
        isFirstTimeActive = true
    }
    
    func updateTimerState(_ state: TimerState) {
        timerState = state
    }
    
    func saveStartDate() {
        startDate = Date()
    }
    
    func saveFocusHistory(category: String?, faceUpCount: Int) {
        guard let startDate = startDate else { return }
        
        let focusHistory = FocusHistory(
            startDate: startDate,
            duration: (initialTime + extraFocusTime),
            category: category,
            faceUpCount: faceUpCount
        )
        
        ModelContainerManager.shared.saveFocusHistory(history: focusHistory)
    }
    
    // MARK: - Private Methods
    private func handleTimerCompletion() {
        updateCompletedTimeStatus()
        startExtraFocusCalculation()
        resetTimer()
        updateTimerState(.completed)
    }
    
    private func startExtraFocusCalculation() {
        extraFocusStartTime = Date()
    }
    
    private func stopExtraFocusCalculation() {
        guard let extraFocusStartTime = extraFocusStartTime else { return }
        let additionalTime = Date().timeIntervalSince(extraFocusStartTime)
        extraFocusTime += additionalTime
        self.extraFocusStartTime = nil
    }
    
    private func updateCompletedTimeStatus() {
        switch initialTime {
        case 60:
            UserDefaultManager.oneMinuteDoneToday = true
        case 600:
            UserDefaultManager.tenMinuteDoneToday = true
        case 900:
            UserDefaultManager.fifteenMinuteDoneToday = true
        case 1800:
            UserDefaultManager.thirtyMinuteDoneToday = true
        case 3000:
            UserDefaultManager.fiftyMinuteDoneToday = true
        default:
            break
        }
    }
} 