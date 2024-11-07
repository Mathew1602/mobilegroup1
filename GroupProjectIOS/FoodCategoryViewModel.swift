//
//  FoodCategoryViewModel.swift
//  GroupProjectIOS
//
//  Created by Xiaoya Zou on 2024-11-06.
//

import Foundation
import FirebaseFirestore

class FoodCategoryViewModel: ObservableObject {
    // Firestore reference to the "FoodCategory" collection
    private var db = Firestore.firestore().collection("FoodCategory")
    
    @Published var categories: [FoodCategory] = []
    
    init() {
//        loadCategory()
    }
    
    // Load pre-build category
    func loadCategory() {

//        categories = [
//            FoodCategory(name: "Fruit"),
//            FoodCategory(name: "Vegetable"),
//            FoodCategory(name: "Dairy"),
//            FoodCategory(name: "Protein"),
//            FoodCategory(name: "Bakery"),
//            FoodCategory(name: "Frozen")
//        ]
//
//        for category in categories {
//             guard let id = category.id else { continue }
//
//             db.document(id).getDocument { (document, error) in
//                 if let document = document, document.exists {
//                     // Category already exists in Firestore, skip adding
//                     print("Category \(category.name) already exists in Firestore.")
//                 } else {
//                     // Add category to Firestore
//                     do {
//                         try self.db.document(id).setData(from: category)
//                         print("Category \(category.name) added to Firestore.")
//                     } catch let error {
//                         print("Error adding category \(category.name): \(error)")
//                     }
//                 }
//             }
//         }
    }
    
    // Read
    func fetchCategories() {
        db.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching categories: \(error)")
                return
            }
            
            self.categories = snapshot?.documents.compactMap { document in
                var category = try? document.data(as: FoodCategory.self)
                category?.id = document.documentID
                if category?.id == nil {
                    print("Warning: Category fetched without an id.")
                }
                return category
            } ?? []
        }
    }
    
    // Check duplicates
    func checkCategory(_ category: FoodCategory) {
        // Check if the category already exists in Firestore by its name
        db.whereField("name", isEqualTo: category.name).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking category existence: \(error)")
                return
            }
            
            if let snapshot = snapshot, snapshot.isEmpty {
                // Category does not exist, so add it
                self.addCategory(category)
            } else {
                // Category already exists
                print("Category \(category.name) already exists in Firestore.")
            }
        }
    }
    
    // Add
    func addCategory(_ category: FoodCategory) {
        do {
            _ = try db.addDocument(from: category)
        } catch let error {
            print("Error adding category: \(error)")
        }
    }
    
    // Update
    func updateCategory(_ category: FoodCategory) {
        guard let id = category.id else { return }
        
        do {
            try db.document(id).setData(from: category, merge: true)
        } catch let error {
            print("Error updating category: \(error)")
        }
    }
    
    // Delete
    func deleteCategory(_ category: FoodCategory) {
        guard let id = category.id else { return }
        
        db.document(id).delete { error in
            if let error = error {
                print("Error deleting category: \(error)")
            }
        }
    }
}

