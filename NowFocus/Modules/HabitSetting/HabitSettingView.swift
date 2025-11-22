//
//  HabitSettingView.swift
//  FaceDownFocusTimer
//
//  Created by Tomofumi Kimura on 2025/08/17.
//

import SwiftUI
import Combine
import Observation

@Observable
class HabitSettingViewModel {
    var habitName: String = "" {
        didSet {
            updateButtonState()
        }
    }
    var reason: String = "" {
        didSet {
            updateButtonState()
        }
    }
    var isButtonEnabled: Bool = false
    
    // エラー表示用
    var saveError: HabitSaveError? = nil
    var isShowingErrorAlert: Bool = false
    
    // UI向けのエラーメッセージ
    var errorMessage: String {
        guard let saveError else { return "" }
        switch saveError {
        case .duplicateHabitName(let name):
            return "「\(name)」はすでに登録されています。別の名前を入力してください。"
        case .unknown(let underlying):
            // 必要に応じて underlying.localizedDescription を出さない（一般ユーザー向け）運用も可
            return "保存中に不明なエラーが発生しました。時間をおいて再度お試しください。\n(\(underlying.localizedDescription))"
        }
    }
    
    private func updateButtonState() {
        isButtonEnabled = !habitName.isEmpty
    }
    
    @MainActor
    fileprivate func getAllHabits() {
        let allHabits = ModelContainerManager.shared.fetchAllHabits()
        print("ALL Habits Count: \(allHabits.count)")
        for habit in allHabits {
            print("Habit Name: \(habit.name)")
        }
    }
    
    @MainActor
    @discardableResult
    fileprivate func addHabit(name: String, reason: String?) -> Bool {
        ModelContainerManager.shared.debugPrintAllData()
        do {
            try ModelContainerManager.shared.saveHabit(habit: Habit(habitName: name, reason: reason))
            // 成功時はエラーをクリア
            saveError = nil
            isShowingErrorAlert = false
            return true
        } catch let e as HabitSaveError {
            // 期待通りのドメインエラー
            saveError = e
            isShowingErrorAlert = true
            return false
        } catch {
            // 念のためのフォールバック（通常は到達しない想定）
            saveError = .unknown(underlying: error)
            isShowingErrorAlert = true
            return false
        }
    }
}

struct HabitSettingView: View {
    @State private var viewModel = HabitSettingViewModel()
    @FocusState private var habitNameFocused: Bool
    @FocusState private var reasonFocused: Bool
    let onComplete: () -> Void // Created Habit
    
    var body: some View {
        VStack(spacing: 0) {
            // Header section
            VStack(spacing: 15) {
                HStack(spacing: 0) {
                    Text("1分")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    Text("ならできるはず")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                }
                .multilineTextAlignment(.center)
                .padding(.top, 20)
                
                // Form section
                VStack(spacing: 20) {
                    // Category Name Input
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("カテゴリー名")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            
                            Text("必須")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                        
                        HStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                            
                            TextField("ここに入力してください", text: $viewModel.habitName)
                                .font(.system(size: 16))
                                .submitLabel(.done)
                                .focused($habitNameFocused)
                            
                            Image(systemName: "pencil")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(habitNameFocused ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                                )
                        )
                    }
                    
                    // Reason Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("習慣化させる理由 (任意)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                        
                        TextField("例: キャリアアップのため...", text: $viewModel.reason)
                            .font(.system(size: 16))
                            .submitLabel(.done)
                            .focused($reasonFocused)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(reasonFocused ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
            .padding(.bottom, 20)
            
            // Register Button
            Button {
                // Save Habit
                let success = viewModel.addHabit(
                    name: viewModel.habitName.trimmingCharacters(in: .whitespacesAndNewlines),
                    reason: viewModel.reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? nil
                        : viewModel.reason.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                
                if success {
                    viewModel.getAllHabits()
                    onComplete()
                }
            } label: {
                HStack {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                    
                    Text("登録")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(viewModel.isButtonEnabled ? Color.blue : Color.gray.opacity(0.5))
            .cornerRadius(28)
            .disabled(!viewModel.isButtonEnabled)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.background)
        }
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 20)
        // エラーアラート
        .alert("登録できません", isPresented: $viewModel.isShowingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

#Preview {
    HabitSettingView {
        print("")
    }
}
