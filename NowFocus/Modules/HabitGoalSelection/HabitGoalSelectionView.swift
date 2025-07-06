//
//  HabitGoalSelectionView.swift
//  FaceDownFocusTimer
//
//  Created by Tomofumi Kimura on 2025/07/04.
//

import SwiftUI

struct HabitGoalSelectionView: View {
    @Binding var isPresented: Bool
    let onHabitSelected: (String) -> Void
    @State private var goalText: String = ""
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
                        Text("１つ習慣化するとしたら？")
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
                    
                    // テキスト入力フィールド
                    TextField("例：読書", text: $goalText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isTextFieldFocused)
                        .lineLimit(1)
                        .font(.body)
                        .submitLabel(.done)
                        .onSubmit {
                            if !goalText.isEmpty {
                                onHabitSelected(goalText)
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isPresented = false
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // 決定ボタン
                    Button(action: {
                        onHabitSelected(goalText)
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
                                    .fill(goalText.isEmpty ? Color.gray : Color.blue)
                            )
                    }
                    .disabled(goalText.isEmpty)
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
    HabitGoalSelectionView(isPresented: .constant(true), onHabitSelected: { _ in })
}
