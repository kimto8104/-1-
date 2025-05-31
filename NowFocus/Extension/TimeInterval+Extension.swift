//
//  TimeInterval+Extension.swift
//  FaceDown Focus Timer
//
//  Created by Tomofumi Kimura on 2025/05/30.
//

import Foundation

extension TimeInterval {
  func toFormattedString() -> String {
    let minutes = Int(self) / 60
    let seconds = Int(self) % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }
}
