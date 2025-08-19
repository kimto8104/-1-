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
  var inputText: String = "" {
    didSet {
      isButtonEnabled = !inputText.isEmpty
    }
  }
  var isButtonEnabled: Bool = false
}

struct HabitSettingView: View {
  @State private var viewModel = HabitSettingViewModel()
  @FocusState private var textFieldFocused: Bool
  
  var body: some View {
    
    GeometryReader { gp in
      let hm = gp.size.width / 375
      let vm = gp.size.height / 667
      let multiplier = abs(hm - 1) < abs(vm - 1) ? hm : vm
      
      ZStack {
        VStack {
          Text("1分")
            .font(.system(size: 48 * multiplier))
            .fontWeight(.bold)
            .frame(width: 154 * multiplier, height: 100 * multiplier)
          
          Text("ならできるはず")
            .font(.title3)
            .fontWeight(.medium)
            .frame(width: 165 * multiplier, height: 20 * multiplier)
          Spacer()
            .frame(height: 20 * multiplier)
          
          TextField("", text: $viewModel.inputText, prompt: Text("1分ならできる習慣を入力").foregroundStyle(.gray))
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .submitLabel(.done)
            .background(
              RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                .shadow(color: Color.white.opacity(0.7), radius: 5, x: 0, y: -2)
            )
            .padding()
            .scaleEffect(textFieldFocused ? 1.06 : 1.0)
            .animation(.easeInOut(duration: 0.18), value: textFieldFocused)
            .focused($textFieldFocused)
          
          Spacer()
            .frame(height: 40 * multiplier)
          
          Button {
            // 挑戦するAction here
          } label: {
            Text("挑戦する")
              .foregroundStyle(.white)
              .font(.title3)
              .fontWeight(.medium)
          }
          .frame(width: 174 * multiplier, height: 56 * multiplier)
          .background(viewModel.isButtonEnabled ? Color(hex: "#F65050") : Color.gray.opacity(0.5))
          .cornerRadius(40 * multiplier)
          .disabled(!viewModel.isButtonEnabled)
        }
        .frame(width: gp.size.width, height: gp.size.height)
      }
    }
  }
}

#Preview {
  HabitSettingView()
}
