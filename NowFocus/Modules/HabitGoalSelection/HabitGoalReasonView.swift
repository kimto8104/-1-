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
    @FocusState private var isTextFieldFocused: Bool
    
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
                    
                    // テキスト入力フィールド
                    TextField("例：知識を増やしたいから", text: $reasonText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isTextFieldFocused)
                        .lineLimit(1)
                        .font(.body)
                        .submitLabel(.done)
                        .onSubmit {
                            if !reasonText.isEmpty {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isPresented = false
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // 決定ボタン
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresented = false
                        }
                    }) {
                        Text("決定")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(reasonText.isEmpty ? Color.gray : Color.blue)
                            )
                    }
                    .disabled(reasonText.isEmpty)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.5)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                )
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .onAppear {
            // 表示時にテキストフィールドにフォーカス
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextFieldFocused = true
            }
        }
    }
}

#Preview {
    HabitGoalReasonView(isPresented: .constant(true), selectedHabit: "読書")
}
