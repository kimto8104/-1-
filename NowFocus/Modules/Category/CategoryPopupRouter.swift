//
//  CategoryPopupRouter.swift
//  FaceDown Focus Timer
//
//  Created by Tomofumi Kimura on 2025/02/02.
//

import SwiftUI

protocol CategoryPopupRouterProtocol {
  static func createModule() -> CategoryPopup
}

class CategoryPopupRouter: CategoryPopupRouterProtocol {
  static func createModule() -> CategoryPopup {
    let router = CategoryPopupRouter()
    let interactor = CategoryPopupInteractor()
    let presenter = CategoryPopupPresenter()
    interactor.presenter = presenter
    presenter.interactor = interactor
    
    return presenter.view
  }
}

