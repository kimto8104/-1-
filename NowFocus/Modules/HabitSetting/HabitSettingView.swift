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
  var categoryName: String = "" {
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
  
  private func updateButtonState() {
    isButtonEnabled = !categoryName.isEmpty
  }
}

struct HabitSettingView: View {
  @State private var viewModel = HabitSettingViewModel()
  @FocusState private var categoryNameFocused: Bool
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
              
              TextField("ここに入力してください", text: $viewModel.categoryName)
                .font(.system(size: 16))
                .submitLabel(.done)
                .focused($categoryNameFocused)
              
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
                    .stroke(categoryNameFocused ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
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
        onComplete()
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
  }
}

#Preview {
  HabitSettingView {
    print("")
  }
}
