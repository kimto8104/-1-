//
//  MotionManagerService.swift
//  NowFocus
//
//  Created by Tomofumi Kimura on 2024/08/01.
//

import Foundation
import CoreMotion
import AudioToolbox
import AVFAudio
import AVFoundation

class MotionManagerService: ObservableObject {
  private let motionManager = CMMotionManager()
  @Published var isMonitoring = false
  @Published var isFaceDown = false
  @Published var faceUpCount: Int = 0
  
  private var initialAttitude: CMAttitude?
  private var audioPlayer: AVAudioPlayer?
  private var previousFaceDownState: Bool = false
  
  // 端末の動き検知を開始
  func startMonitoringDeviceMotion() {
    if motionManager.isDeviceMotionAvailable {
      // 検知間隔を1秒に設定
      motionManager.deviceMotionUpdateInterval = 1
      // 端末の動き検知開始
      motionManager.startDeviceMotionUpdates(to: .main) { [weak self] deviceMotion, error in
        guard let self else { return }
        self.isMonitoring = true
        // 角度や状態についてデータを持っているdeviceMotion
        guard let deviceMotion else { return }
        let gravityZ = deviceMotion.gravity.z
        // 下向きと判断するための閾値範囲
        let isFaceDownThreshold: ClosedRange<Double> = 0.7...1.0
        // 上向きと判断するための閾値範囲
        let isFaceUpThreshold: ClosedRange<Double> = -1.0...0.3
        let newIsFaceDown: Bool
        // 画面が下向きになっている
        if isFaceDownThreshold.contains(gravityZ) {
          newIsFaceDown = true
        } else if isFaceUpThreshold.contains(gravityZ) {
          // 画面が上向きになっている
          newIsFaceDown = false
        } else {
          // 範囲外の場合は状態を変えない
          return
        }
        
        // 状態が変わったときのみ更新
        if newIsFaceDown != self.isFaceDown {
          // 前回の状態が下向きで、今回上向きになった場合にカウントアップ
          if self.previousFaceDownState && !newIsFaceDown {
            self.faceUpCount += 1
            print("上向きになった回数: \(self.faceUpCount)")
          }
          
          self.previousFaceDownState = self.isFaceDown
          self.isFaceDown = newIsFaceDown
        }
      }
    }
  }
  
  private func playAlarmSound() {
    // Asset にあるWarning-Siren04-02(Low-Long)を鳴らす
    guard let url = Bundle.main.url(forResource: "Warning-Siren04-02(Low-Long)", withExtension: "mp3") else {
      print("Alarm sound file not found.")
      return
    }
    
    do {
      audioPlayer = try AVAudioPlayer(contentsOf: url)
      audioPlayer?.numberOfLoops = -1  // 無限にリピート
      audioPlayer?.prepareToPlay()
      audioPlayer?.play()
    } catch {
      print("Error playing alarm sound: \(error.localizedDescription)")
    }
  }
  
  func stopAlarm() {
    audioPlayer?.stop()
  }
  
  private func triggerAlerm() {
    playAlarmSound()
  }
  
  func stopMonitoring() {
    isMonitoring = false
    motionManager.stopDeviceMotionUpdates()
  }
  
  func reset() {
    initialAttitude = nil
    audioPlayer?.stop()
    isMonitoring = false
    // リセット時にはカウントをリセットしない（セッション中の合計を記録するため）
  }
  
  func resetFaceUpCount() {
    faceUpCount = 0
    previousFaceDownState = false
  }
}
