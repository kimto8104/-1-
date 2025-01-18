////
////  TimeSelectionView.swift
////  NowFocus
////
////  Created by Tomofumi Kimura on 2023/02/12.
////
//
//import SwiftUI
//
//struct TimeSelectionView: View {
//  @ObservedObject var presenter:TimeSelectionPresenter
//  @Binding var isTimerPageActive: Bool // タブ表示制御用のバインディング
//  var body: some View {
//    NavigationStack {
//      GeometryReader { geometry in
//        let hm = geometry.size.width / 375
//        let vm = geometry.size.height / 667
//        let multiplier = abs(hm - 1) < abs(vm - 1) ? hm : vm
//        GradientBackgroundUtil.gradientBackground(size: geometry.size, multiplier: multiplier)
//        
//        VStack() {
//          Spacer()
//            .frame(height: 160 * multiplier)
//          List {
//            ForEach (presenter.timeOptions, id: \.self) { time in
//              HStack {
//                Spacer()
//                TimeOptionCell(timeOption: time, multiplier: multiplier, isTimerPageActive: $isTimerPageActive)
//                  .padding(.vertical, 18 * multiplier) // セル間のスペース（46 / 2）
//                Spacer()
//              }
//              // Listの背景色を透明に
//              .listRowBackground(Color.clear)
//              .listRowSeparator(.hidden) // セル間の線を非表示
//            }
//          }
//          .scrollDisabled(true)
//          .listStyle(PlainListStyle()) // スタイルを明示的に設定
//          .padding(.top, 140 * multiplier)
//          .padding(.horizontal, 40 * multiplier)
//          .onAppear(perform: {
//            isTimerPageActive = false
//            presenter.setupTimeOptions()
//          })
//        }
//          
//      }
//    }
//  }
//}
//
//struct TimeOptionCell: View {
//  let baseColor = Color(hex: "#E3DDDD") ?? Color.clear
//  let timeOption: TimeOption
//  let multiplier: CGFloat
//  @State private var isPressed = false
//  @State private var navigate: Bool = false
//  @Binding var isTimerPageActive: Bool
//  var body: some View {
//    ZStack {
//      // NavigationLinkのvalueにOptional Intを使用
//      NavigationLink(destination:  TimerRouter.initializeTimerModule(with: timeOption.time, isTimerPageActive: $isTimerPageActive), isActive: $navigate, label: {
//        EmptyView()
//      })
//      .opacity(0)
//      
//      Text("+\(timeOption.time) 分")
//        .shadow(color: .black.opacity(0.2), radius: 2 * multiplier, x: 0, y: 4 * multiplier)
//        .frame(width: 176 * multiplier, height: 60 * multiplier)
//        .background(isPressed ? Color.gray : baseColor)
//        .cornerRadius(10 * multiplier)
//        .shadow(color: Color.black.opacity(0.2), radius: 4 * multiplier, x: 10 * multiplier, y: 10 * multiplier)
//        .font(.custom("IBM Plex Mono", size: 20 * multiplier))
//        .foregroundColor(timeOption.isEnabled ? .black : .black.opacity(0.2))
//        .multilineTextAlignment(.center)
//        .shadow(color: Color(hex: "#FDF3F3")?.opacity(0.25) ?? .clear, radius: 4 * multiplier, x: -4 * multiplier, y: -4 * multiplier)
//        .scaleEffect(isPressed ? 0.95 : 1.0)
//        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPressed)
//        .onTapGesture {
//          if timeOption.isEnabled {
//            isPressed = true
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//              isPressed = false
//              navigate = true // 遷移先の値を設定
//            }
//          }
//        }
//    }
//    .buttonStyle(PlainButtonStyle()) // 見た目をそのまま
//  }
//}
//
//struct TimeSelectionView_Previews: PreviewProvider {
//  static var previews: some View {
//    @Previewable @State var isTimerPageActive = true
//    TimeSelectionView(presenter: TimeSelectionPresenter(), isTimerPageActive: $isTimerPageActive)
//  }
//}
