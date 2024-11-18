//
//  FoodViewModel.swift
//  GroupProjectIOS
//
//  Created by Xiaoya Zou on 2024-11-06.
//
import Foundation
import Firebase
import FirebaseFirestore
import UserNotifications
import UIKit
import FirebaseStorage

class FoodViewModel: ObservableObject {
    
    @Published var foods: [Food] = []
    @Published var isNotificationEnabled: Bool = true
    
    private var db = Firestore.firestore().collection("Food")
    
    init() {}

    // Read
    func fetchFoods(forCategory categoryName: String) {
        db.whereField("category", isEqualTo: categoryName).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching foods for category \(categoryName): \(error)")
                return
            }
            
            self.foods = snapshot?.documents.compactMap { document in
                try? document.data(as: Food.self)
            } ?? []
        }
    }
    
    // Fetch food by name string
    func fetchFoodByName() {
        db.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching food by name: \(error)")
                return
            }
            
            self.foods = snapshot?.documents.compactMap { document in
                var name = try? document.data(as: Food.self)
                name?.id = document.documentID
                if name?.id == nil {
                    print("Warning: Food name fetched without an id.")
                }
                return name
            } ?? []
        }
    }
       
    // Create
    func addFood(_ food: Food) {
        do {
            _ = try db.addDocument(from: food)
            
            if isNotificationEnabled {
                scheduleExpiryNotification(for: food.name, expiryDate: food.expirationDate)
            }
        } catch let error {
            print("Error adding food: \(error)")
        }
    }
       
    // Update
    func updateFood(_ food: Food) {
        if let id = food.id {
            do {
                try db.document(id).setData(from: food)
                
                if isNotificationEnabled {
                    scheduleExpiryNotification(for: food.name, expiryDate: food.expirationDate)
                }
            } catch let error {
                print("Error updating food: \(error)")
            }
        }
    }
       
    // Delete
    func deleteFood(_ food: Food) {
        if let id = food.id {
            db.document(id).delete { error in
                if let error = error {
                    print("Error deleting food: \(error)")
                }
            }
        }
    }
    
    // Request user notification
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            }
            print("Notification permission granted: \(granted)")
        }
    }
    
    // Schedule a local notification
    func scheduleExpiryNotification(for foodName: String, expiryDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Food Expiry Reminder"
        content.body = "\(foodName) will expire tomorrow. Consider using it soon!"
        content.sound = .default
        
        // Optionally add an attachment for notification
        if let imageURL = Bundle.main.url(forResource: "AppIcon", withExtension: "png") {
            let attachment = try? UNNotificationAttachment(identifier: "image", url: imageURL, options: nil)
            if let attachment = attachment {
                content.attachments = [attachment]
            }
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "\(foodName)_testReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Test notification scheduled to trigger in 5 seconds.")
            }
        }
    }

    // Fetch image from Firebase Storage
    func fetchImage(for food: Food, completion: @escaping (UIImage?) -> Void) {
        guard let imageName = food.imageName else {
            completion(nil)
            return
        }
        
        let storageRef = Storage.storage().reference().child("food_images/\(imageName)")
        storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error fetching image: \(error)")
                completion(nil)
            } else if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
    }
    
    // Upload image to Firebase Storage
    func uploadImage(_ image: UIImage, for food: Food, completion: @escaping (String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("food_images/\(imageName)")
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error)")
                return
            }
            DispatchQueue.main.async {
                completion(imageName)  
            }
        }
    }

}
