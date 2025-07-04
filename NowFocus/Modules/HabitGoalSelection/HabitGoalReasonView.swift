//
//  HabitGoalReasonView.swift
//  FaceDownFocusTimer
//
//  Created by Tomofumi Kimura on 2025/07/04.
//

import SwiftUI
import Speech

struct HabitGoalReasonView: View {
    @Binding var isPresented: Bool
    let selectedHabit: String
    @State private var reasonText: String = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var isRecording = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    
    var body: some View {
        ZStack {
            // 薄暗い背景
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    // ヘッダー
                    HStack {
                        Text("なぜ習慣化させたい？")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            isPresented = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // 選択された習慣の表示
                    Text("「\(selectedHabit)」を")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // 音声入力フィールド
                    HStack {
                        Text(reasonText.isEmpty ? "音声で入力してください" : reasonText)
                            .font(.body)
                            .foregroundColor(reasonText.isEmpty ? .secondary : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    .background(Color.gray.opacity(0.05))
                            )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // マイクボタンまたは決定ボタン
                    HStack(spacing: 20) {
                        // やり直しボタン（音声入力がある時のみ表示）
                        if !reasonText.isEmpty {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    reasonText = ""
                                    // 音声認識の状態もリセット
                                    resetSpeechRecognition()
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.gray)
                                        .frame(width: 60, height: 60)
                                        .shadow(color: Color.gray.opacity(0.3), radius: 8, x: 0, y: 4)
                                    
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(.white)
                                }
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        // メインボタン（マイクまたは決定）
                        Button(action: {
                            if reasonText.isEmpty {
                                // 音声入力開始
                                if isRecording {
                                    stopRecording()
                                } else {
                                    startRecording()
                                }
                            } else {
                                // 決定ボタンとして機能
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isPresented = false
                                }
                            }
                        }) {
                            ZStack {
                                // パルスエフェクト（録音中のみ表示）
                                if isRecording {
                                    Circle()
                                        .stroke(reasonText.isEmpty ? Color.red : Color.blue, lineWidth: 2)
                                        .frame(width: 80, height: 80)
                                        .scaleEffect(pulseScale)
                                        .opacity(2 - pulseScale)
                                        .animation(
                                            Animation.easeInOut(duration: 1.5)
                                                .repeatForever(autoreverses: false),
                                            value: pulseScale
                                        )
                                }
                                
                                Circle()
                                    .fill(reasonText.isEmpty ? (isRecording ? Color.red : Color.blue) : Color.green)
                                    .frame(width: 80, height: 80)
                                    .shadow(color: reasonText.isEmpty ? (isRecording ? Color.red.opacity(0.3) : Color.blue.opacity(0.3)) : Color.green.opacity(0.3), radius: 10, x: 0, y: 5)
                                
                                if reasonText.isEmpty {
                                    // マイクアイコン
                                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                                        .font(.system(size: 32, weight: .medium))
                                        .foregroundColor(.white)
                                        .scaleEffect(isRecording ? 0.8 : 1.0)
                                        .animation(.easeInOut(duration: 0.2), value: isRecording)
                                } else {
                                    // チェックマークアイコン
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .scaleEffect(reasonText.isEmpty ? 1.0 : 1.1)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: reasonText.isEmpty)
                        }
                        
                        // 右側のスペーサー（やり直しボタンがある時は非表示）
                        if !reasonText.isEmpty {
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 60, height: 60)
                        }
                    }
                    
                    Text(reasonText.isEmpty ? (isRecording ? "録音中..." : "タップして音声入力") : "タップして決定")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .animation(.easeInOut(duration: 0.3), value: reasonText.isEmpty)
                }
                .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.5)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                )
                .padding(.horizontal, 40)
                .padding(.bottom, keyboardHeight > 0 ? keyboardHeight - 100 : 0)
                
                Spacer()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation(.easeInOut(duration: 0.3)) {
                    keyboardHeight = keyboardFrame.height
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                keyboardHeight = 0
            }
        }
    }
    
    // 音声録音開始
    private func startRecording() {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            print("Speech recognizer is not available")
            return
        }
        
        // 音声エンジンを停止してから再開
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
            guard let recognitionRequest = recognitionRequest else {
                print("Unable to create recognition request")
                return
            }
            
            recognitionRequest.shouldReportPartialResults = true
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    DispatchQueue.main.async {
                        self.reasonText = result.bestTranscription.formattedString
                    }
                }
                
                if error != nil || result?.isFinal == true {
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    self.isRecording = false
                }
            }
            
            isRecording = true
            
            // パルスアニメーション開始
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                pulseScale = 2.0
            }
            
        } catch {
            print("Error starting speech recognition: \(error)")
        }
    }
    
    // 音声録音停止
    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        isRecording = false
        
        // パルスアニメーション停止
        pulseScale = 1.0
    }
    
    // 音声認識の状態をリセット
    private func resetSpeechRecognition() {
        // 録音中なら停止
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        
        // 認識リクエストを終了
        recognitionRequest?.endAudio()
        
        // 認識タスクをキャンセル
        recognitionTask?.cancel()
        
        // 状態をリセット
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
        
        // 音声セッションをリセット
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Error deactivating audio session: \(error)")
        }
    }
}

#Preview {
    HabitGoalReasonView(isPresented: .constant(true), selectedHabit: "読書")
}
