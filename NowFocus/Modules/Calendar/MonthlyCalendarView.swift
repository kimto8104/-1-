//
//  MonthlyCalendarView.swift
//  FaceDownFocusTimer
//
//  Created by Tomofumi Kimura on 2025/07/22.
//

import SwiftUI
struct MonthlyCalendarView: View {
  let currentDate: Date
  let focusHistory: [FocusHistory]
  let multiplier: CGFloat
  let onPreviousMonth: () -> Void
  let onNextMonth: () -> Void
  
  private var calendar: Calendar {
    var calendar = Calendar.current
    calendar.locale = Locale.current
    return calendar
  }
  
  private var monthStartDate: Date {
    calendar.dateInterval(of: .month, for: currentDate)?.start ?? currentDate
  }
  
  private var monthEndDate: Date {
    calendar.dateInterval(of: .month, for: currentDate)?.end ?? currentDate
  }
  
  private var daysInMonth: [Date] {
    var days: [Date] = []
    var currentDate = monthStartDate
    
    while currentDate < monthEndDate {
      days.append(currentDate)
      currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
    }
    
    return days
  }
  
  private var calendarDays: [CalendarDay] {
    var calendarDays: [CalendarDay] = []
    
    // 月の最初の曜日を取得（日曜日=1, 月曜日=2, ...）
    let firstWeekday = calendar.component(.weekday, from: monthStartDate)
    
    // 前月の日付を追加
    let previousMonthDays = firstWeekday - 1
    for i in 0..<previousMonthDays {
      let previousDate = calendar.date(byAdding: .day, value: -(previousMonthDays - i), to: monthStartDate) ?? Date()
      calendarDays.append(CalendarDay(date: previousDate, isCurrentMonth: false, focusTime: 0))
    }
    
    // 今月の日付を追加
    for date in daysInMonth {
      let focusTime = getFocusTimeForDate(date)
      calendarDays.append(CalendarDay(date: date, isCurrentMonth: true, focusTime: focusTime))
    }
    
    return calendarDays
  }
  
  var body: some View {
    VStack(spacing: 16 * multiplier) {
      // 月のヘッダー
      monthHeader
      
      // 曜日ヘッダー
      weekdayHeader
      
      // カレンダーグリッド
      calendarGrid
    }
    .padding(.horizontal, 20 * multiplier)
    .padding(.vertical, 16 * multiplier)
    .background(
      RoundedRectangle(cornerRadius: 16 * multiplier)
        .fill(Color.white)
        .shadow(color: Color(hex: "#ADB5BD")!.opacity(0.15), radius: 8, x: 0, y: 4)
    )
  }
  

  
  private var monthHeader: some View {
    HStack {
      Text(monthYearString)
        .font(.system(size: 20 * multiplier, weight: .semibold))
        .foregroundColor(Color(hex: "#495057")!)
      
      Spacer()
      
      HStack(spacing: 12 * multiplier) {
        Button(action: previousMonth) {
          Image(systemName: "chevron.left")
            .font(.system(size: 16 * multiplier, weight: .medium))
            .foregroundColor(Color(hex: "#339AF0")!)
        }
        
        Button(action: nextMonth) {
          Image(systemName: "chevron.right")
            .font(.system(size: 16 * multiplier, weight: .medium))
            .foregroundColor(Color(hex: "#339AF0")!)
        }
      }
    }
  }
  
  private var weekdayHeader: some View {
    HStack(spacing: 0) {
      ForEach(weekdaySymbols, id: \.self) { weekday in
        Text(weekday)
          .font(.system(size: 12 * multiplier, weight: .medium))
          .foregroundColor(Color(hex: "#868E96")!)
          .frame(maxWidth: .infinity)
      }
    }
  }
  
  private var calendarGrid: some View {
    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8 * multiplier), count: 7), spacing: 8 * multiplier) {
      ForEach(calendarDays, id: \.id) { day in
        CalendarDayView(day: day, multiplier: multiplier, isSelected: false)
      }
    }
  }
  
  private var monthYearString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy年M月"
    formatter.locale = Locale(identifier: "ja_JP")
    return formatter.string(from: currentDate)
  }
  
  private var weekdaySymbols: [String] {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ja_JP")
    return formatter.shortWeekdaySymbols
  }
  
  private func getFocusTimeForDate(_ date: Date) -> TimeInterval {
    let startOfDay = calendar.startOfDay(for: date)
    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
    
    return focusHistory
      .filter { history in
        let historyDate = calendar.startOfDay(for: history.startDate)
        return historyDate >= startOfDay && historyDate < endOfDay
      }
      .reduce(0) { $0 + $1.duration }
  }
  
  private func previousMonth() {
    onPreviousMonth()
  }
  
  private func nextMonth() {
    onNextMonth()
  }
}

struct CalendarDay {
  let id = UUID()
  let date: Date
  let isCurrentMonth: Bool
  let focusTime: TimeInterval
}

struct CalendarDayView: View {
  let day: CalendarDay
  let multiplier: CGFloat
  let isSelected: Bool
  
  private var focusTimeColor: Color {
    if day.focusTime == 0 {
      return Color(hex: "#F1F3F5")!
    } else {
      return Color(hex: "#FA5252")!
    }
  }
  
  private var dayNumber: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "d"
    return formatter.string(from: day.date)
  }
  
  var body: some View {
    ZStack {
      Circle()
        .fill(focusTimeColor)
        .frame(width: 36 * multiplier, height: 36 * multiplier)
        .overlay(
          Circle()
            .stroke(isSelected ? Color(hex: "#339AF0")! : Color.clear, lineWidth: 2)
        )
      
      Text(dayNumber)
        .font(.system(size: 16 * multiplier, weight: .medium))
        .foregroundColor(day.isCurrentMonth ? Color(hex: "#495057")! : Color(hex: "#CED4DA")!)
    }
    .frame(width: 40 * multiplier, height: 40 * multiplier)
  }
}

#Preview {
  MonthlyCalendarView(
    currentDate: Date(),
    focusHistory: [],
    multiplier: 1.0,
    onPreviousMonth: {},
    onNextMonth: {}
  )
  .padding()
}
