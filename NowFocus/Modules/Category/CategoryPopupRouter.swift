//
//  CategoryPopupRouter.swift
//  FaceDown Focus Timer
//
//  Created by Tomofumi Kimura on 2025/02/02.
//

import SwiftUI

protocol CategoryPopupRouterProtocol {
  func dismissCategoryPopup()
}

class CategoryPopupRouter: CategoryPopupRouterProtocol {
  var view: CategoryPopup?
  var parentView: TimerPage? // TimerPageへの参照を保持
  
  init(view: CategoryPopup, parentView: TimerPage) {
    self.view = view
    self.parentView = parentView
  }
  
  func dismissCategoryPopup() {
    parentView?.model.hideCategoryPopup()
  }
}

