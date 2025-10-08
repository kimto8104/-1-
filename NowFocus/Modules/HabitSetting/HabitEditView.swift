//
//  HabitEditView.swift
//  FaceDownFocusTimer
//
//  Created by iosDevelopers on 2025/10/08.
//

import SwiftUI

@Observable
class HabitEditViewModel {
    var habits: [Habit] = []
    var isShowingAddView = false
    var isShowingDeleteAlert = false
    var habitToDelete: Habit?
    var mustAddHabit = false
    var newHabitName: String = ""
    var newHabitReason: String = ""
    var saveError: HabitSaveError?
    var isShowingErrorAlert = false
    
    @MainActor
    func loadHabits() {
        habits = ModelContainerManager.shared.fetchAllHabits()
        // 習慣がない場合は追加を強要
        if habits.isEmpty {
            mustAddHabit = true
            isShowingAddView = true
        }
    }
    
    @MainActor
    func deleteHabit(_ habit: Habit) {
        do {
            let context = ModelContainerManager.shared.container.mainContext
            context.delete(habit)
            try context.save()
            loadHabits()
        } catch {
            print("Habit削除エラー: \(error)")
        }
    }
    
    @MainActor
    func saveNewHabit() -> Bool {
        let trimmedName = newHabitName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedReason = newHabitReason.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else { return false }
        
        do {
            let newHabit = Habit(habitName: trimmedName, reason: trimmedReason.isEmpty ? nil : trimmedReason)
            try ModelContainerManager.shared.saveHabit(habit: newHabit)
            newHabitName = ""
            newHabitReason = ""
            loadHabits()
            isShowingAddView = false
            mustAddHabit = false
            return true
        } catch let error as HabitSaveError {
            saveError = error
            isShowingErrorAlert = true
            return false
        } catch {
            saveError = .unknown(underlying: error)
            isShowingErrorAlert = true
            return false
        }
    }
    
    func cancelAddHabit() {
        if !mustAddHabit {
            newHabitName = ""
            newHabitReason = ""
            isShowingAddView = false
        }
    }
}

struct HabitEditView: View {
    @State private var viewModel = HabitEditViewModel()
    @Environment(\.dismiss) var dismiss
    @FocusState private var habitNameFocused: Bool
    @FocusState private var reasonFocused: Bool
    
    var body: some View {
        ZStack {
            // 背景グラデーション
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#667EEA")!,
                    Color(hex: "#764BA2")!
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ヘッダー
                headerView
                
                // メインコンテンツ
                ScrollView {
                    VStack(spacing: 24) {
                        if viewModel.isShowingAddView {
                            addHabitView
                        }
                        
                        if !viewModel.habits.isEmpty {
                            habitGridView
                        } else if !viewModel.isShowingAddView {
                            emptyView
                        }
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            viewModel.loadHabits()
        }
        .alert("習慣を削除", isPresented: $viewModel.isShowingDeleteAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("削除", role: .destructive) {
                if let habit = viewModel.habitToDelete {
                    viewModel.deleteHabit(habit)
                }
            }
        } message: {
            if let habit = viewModel.habitToDelete {
                Text("「\(habit.name)」を削除しますか？関連する履歴も削除されます。")
            }
        }
        .alert("エラー", isPresented: $viewModel.isShowingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            if let error = viewModel.saveError {
                switch error {
                case .duplicateHabitName(let name):
                    Text("「\(name)」はすでに登録されています。別の名前を入力してください。")
                case .unknown(let underlying):
                    Text("保存中にエラーが発生しました。\n(\(underlying.localizedDescription))")
                }
            }
        }
    }
    
    // ヘッダー
    private var headerView: some View {
        HStack {
            Button {
                if !viewModel.habits.isEmpty {
                    dismiss()
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(viewModel.habits.isEmpty ? .white.opacity(0.3) : .white)
            }
            .disabled(viewModel.habits.isEmpty)
            
            Spacer()
            
            Text("習慣管理")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button {
                withAnimation(.spring(response: 0.3)) {
                    viewModel.isShowingAddView.toggle()
                }
            } label: {
                Image(systemName: viewModel.isShowingAddView ? "minus.circle.fill" : "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }
            .disabled(viewModel.mustAddHabit)
            .opacity(viewModel.mustAddHabit ? 0.3 : 1)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 20)
    }
    
    // 空の状態
    private var emptyView: some View {
        VStack(spacing: 24) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.9))
            
            VStack(spacing: 12) {
                Text("習慣を追加しましょう")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                
                Text("右上の + ボタンをタップして\n新しい習慣を登録してください")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
    
    // 習慣追加ビュー
    private var addHabitView: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                TextField("習慣名", text: $viewModel.newHabitName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .focused($habitNameFocused)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(habitNameFocused ? Color.white : Color.white.opacity(0.4), lineWidth: 2)
                            )
                    )
                    .placeholder(when: viewModel.newHabitName.isEmpty) {
                        Text("例: 勉強、運動、読書")
                            .foregroundColor(.white.opacity(0.5))
                    }
                
                TextField("理由（任意）", text: $viewModel.newHabitReason)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .focused($reasonFocused)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(reasonFocused ? Color.white : Color.white.opacity(0.4), lineWidth: 2)
                            )
                    )
                    .placeholder(when: viewModel.newHabitReason.isEmpty) {
                        Text("例: キャリアアップのため")
                            .foregroundColor(.white.opacity(0.5))
                    }
            }
            
            HStack(spacing: 12) {
                if !viewModel.mustAddHabit {
                    Button {
                        withAnimation {
                            viewModel.cancelAddHabit()
                        }
                    } label: {
                        Text("キャンセル")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white.opacity(0.2))
                            )
                    }
                }
                
                Button {
                    viewModel.saveNewHabit()
                } label: {
                    Text("保存")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "#667EEA"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                        )
                }
                .disabled(viewModel.newHabitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(viewModel.newHabitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
                .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
        )
        .transition(.scale.combined(with: .opacity))
    }
    
    // 習慣グリッド
    private var habitGridView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("登録済みの習慣")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.habits, id: \.id) { habit in
                    HabitEditCard(
                        habit: habit,
                        onDelete: {
                            viewModel.habitToDelete = habit
                            viewModel.isShowingDeleteAlert = true
                        }
                    )
                }
            }
        }
    }
}

// カスタムPlaceholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct HabitEditCard: View {
    let habit: Habit
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Spacer()
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 6) {
                Text(habit.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                if let reason = habit.reason, !reason.isEmpty {
                    Text(reason)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
                
                // 統計
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 10))
                    Text("\(habit.focusHistories.count)回")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.8))
                .padding(.top, 4)
            }
        }
        .frame(height: 140)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.25),
                            Color.white.opacity(0.15)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 8, y: 4)
        )
    }
}

#Preview {
    HabitEditView()
}
