//
//  CategoryPopupInteractor.swift
//  FaceDown Focus Timer
//
//  Created by Tomofumi Kimura on 2025/02/02.
//

//protocol CategoryPopupInteractorProtocol {
//  func fetchCategories() -> [String]
//  func addCategory(name: String)
//  @MainActor func removeCategoryFromHistory(category: String)
//}
//
//class CategoryPopupInteractor: CategoryPopupInteractorProtocol {
//  
//  @MainActor func removeCategoryFromHistory(category: String) {
//    ModelContainerManager.shared.removeCategoryFromHistory(category: category)
//  }
//  
//  private var categories: [String] = ["仕事", "勉強", "読書"]
//  var presenter: CategoryPopupPresenterDelegate?
//  func fetchCategories() -> [String] {
//    return categories
//  }
//  
//  func addCategory(name: String) {
//    categories.append(name)
//  }
//}
//
