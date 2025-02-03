//
//  CategoryPopupInteractor.swift
//  FaceDown Focus Timer
//
//  Created by Tomofumi Kimura on 2025/02/02.
//

protocol CategoryPopupInteractorProtocol {
  func fetchCategories() -> [String]
  func addCategory(name: String)
}

class CategoryPopupInteractor: CategoryPopupInteractorProtocol {
  private var categories: [String] = ["仕事", "勉強", "運動", "読書"]
  var presenter: CategoryPopupPresenterProtocol?
  func fetchCategories() -> [String] {
    return categories
  }
  
  func addCategory(name: String) {
    categories.append(name)
  }
}

