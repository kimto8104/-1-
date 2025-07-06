//
//  HabitGoalReasonView.swift
//  FaceDownFocusTimer
//
//  Created by Tomofumi Kimura on 2025/07/04.
//

import SwiftUI

struct HabitGoalReasonView: View {
    @Binding var isPresented: Bool
    let selectedHabit: String
    @State private var reasonText: String = ""
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isFocused: Bool
    @State private var celebrationScale: CGFloat = 1.0
    @State private var celebrationRotation: Double = 0.0
    @State private var showCelebration = false
    
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
                    
                    TextField("理由を入力してください", text: $reasonText)
                        .font(.body)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 20)
                        .submitLabel(.done)
                        .focused($isFocused)
                        .onSubmit {
                            if !reasonText.isEmpty {
                                triggerCelebrationAndClose()
                            }
                        }
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        // やり直しボタン（テキスト入力がある時のみ表示）
                        if !reasonText.isEmpty {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    reasonText = ""
                                    isFocused = true
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
                        
                        Button(action: {
                            if !reasonText.isEmpty {
                                triggerCelebrationAndClose()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(reasonText.isEmpty ? Color.gray : Color.green)
                                    .frame(width: 80, height: 80)
                                    .shadow(color: reasonText.isEmpty ? Color.gray.opacity(0.3) : Color.green.opacity(0.3), radius: 10, x: 0, y: 5)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .scaleEffect(celebrationScale)
                            .rotationEffect(.degrees(celebrationRotation))
                        }
                        .disabled(reasonText.isEmpty)
                        
                        // 右側のスペーサー（やり直しボタンがある時は非表示）
                        if !reasonText.isEmpty {
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 60, height: 60)
                        }
                    }
                    
                    Text(reasonText.isEmpty ? "理由を入力してください" : "タップして決定")
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
        .onAppear {
            isFocused = true
        }
    }
    
    private func triggerCelebrationAndClose() {
        isFocused = false
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            celebrationScale = 1.3
            celebrationRotation = 360
            showCelebration = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isPresented = false
            }
        }
    }
}

#Preview {
    HabitGoalReasonView(isPresented: .constant(true), selectedHabit: "読書")
}
