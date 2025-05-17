//
//  TabBar.swift
//  FaceDown Focus Timer
//
//  Created by Tomofumi Kimura on 2024/12/25.
//

import SwiftUI
import CoreHaptics // 触覚フィードバック用

struct TabBarView: View {
  @Binding var selectedTab: TabIcon
  @State var Xoffset = 0.0
  var multiplier: CGFloat
  @State private var hapticEngine: CHHapticEngine? // 触覚エンジン
  
  var body: some View {
    HStack(spacing: 0) {
      ForEach(Array(tabItems.enumerated()), id: \.element.id) { index, item in
        Button {
          if selectedTab != item.tab {
            // 振動フィードバック
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
            withAnimation(.spring()) {
              selectedTab = item.tab
              Xoffset = (CGFloat(index) * 70) * multiplier
            }
          }
        } label: {
          VStack(spacing: 6 * multiplier) {
            Image(systemName: item.iconname)
              .font(.system(size: 22 * multiplier, weight: .medium))
              .foregroundColor(selectedTab == item.tab ? 
                            Color(hex: "#339AF0")! : 
                            Color(hex: "#868E96")!)
            
            // 選択中のタブにインジケーターを表示
            if selectedTab == item.tab {
              Circle()
                .fill(Color(hex: "#339AF0")!)
                .frame(width: 5 * multiplier, height: 5 * multiplier)
            } else {
              Circle()
                .fill(Color.clear)
                .frame(width: 5 * multiplier, height: 5 * multiplier)
            }
          }
          .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
      }
    }
    .padding(.vertical, 12 * multiplier)
    .frame(height: 70 * multiplier)
    .background(
      RoundedRectangle(cornerRadius: 20 * multiplier)
        .fill(Color.white)
        .shadow(color: Color(hex: "#ADB5BD")!.opacity(0.15), radius: 8, x: 0, y: 4)
    )
    .padding(.horizontal, 30 * multiplier)
    .onAppear(perform: prepareHaptics)
  }
  
  // 触覚エンジンの準備
  private func prepareHaptics() {
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
    
    do {
      hapticEngine = try CHHapticEngine()
      try hapticEngine?.start()
    } catch {
      print("触覚エンジンの開始に失敗: \(error.localizedDescription)")
    }
  }
}

struct TabBar: Identifiable {
  var id = UUID()
  var iconname: String
  var tab: TabIcon
}

let tabItems = [
  TabBar(iconname: "house", tab: .Home),
  TabBar(iconname: "clock", tab: .Clock),
//  TabBar(iconname: "location", tab: .Location),
//  TabBar(iconname: "calendar", tab: .Purchases),
//  TabBar(iconname: "gear", tab: .Notification)
]
enum TabIcon: String {
  case Home
  case Clock
//  case Location
//  case Purchases
//  case Notification
}

#Preview {
  let selectedTab = Binding<TabIcon>.constant(.Home)
  TabBarView(selectedTab: selectedTab, multiplier: 1)
}
