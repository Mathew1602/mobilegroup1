//
//  AddFoodView.swift
//  GroupProjectIOS
//
//  Created by Xiaoya Zou on 2024-11-06.
//

import SwiftUI

struct AddFoodView: View {
    
    @EnvironmentObject var foodViewModel: FoodViewModel
    @EnvironmentObject var foodCategoryViewModel: FoodCategoryViewModel
    
    @State private var name: String = ""
    @State private var quantity: Int = 1
    @State private var expirationDate = Date()
    @State private var category: String = "Fruit"
    @State private var showAlert : Bool = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack{
            
            VStack{
                Form {
                        // Enter food name
                        TextField("Name", text: $name)
                        
                        // Choose quantity
                        Stepper(value: $quantity, in: 1...100) {
                            Text("Quantity: \(quantity)")
                        }
                        
                        // Select expiry date
                        DatePicker("Expiration Date", selection: $expirationDate, displayedComponents: .date)
                        
                        // Select food category
                        Picker("Category", selection: $category) {
                            ForEach(foodCategoryViewModel.categories, id: \.self) { category in
                                Text(category.name).tag(category.name)
                            }
                        }
                    
                    // Allow user enable notification
                    Toggle("Enable Expiration Notification", isOn: $foodViewModel.isNotificationEnabled)
                        .padding(.vertical)
                    }

                    Button("Add") {
                        saveFood()
                        showAlert = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding() // For button text
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal) // For button itself
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Add Food"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
            }
            .navigationTitle("Add")
            .padding(.bottom, 20)
            Spacer()
        }
    }
    
    func saveFood(){
        
        if name.isEmpty || category.isEmpty {
            alertMessage = "Please enter all required fields."
            showAlert = true
        } else {
            let newFood = Food(id: nil, name: name, quantity: quantity, expirationDate: expirationDate, category: category)
//            let newCategory = FoodCategory(name: category)
            foodViewModel.addFood(newFood)
//            foodCategoryViewModel.checkCategory(newCategory)
            alertMessage = "\(name) is saved successfully!"
            print("Food saved: \(name), \(quantity), \(expirationDate), \(category)")
            name = ""
        }
    }
}

#Preview {
    AddFoodView()
        .environmentObject(FoodViewModel())
        .environmentObject(FoodCategoryViewModel())
}
