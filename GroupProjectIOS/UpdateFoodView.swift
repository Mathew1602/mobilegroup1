//
//  UpdateFoodView.swift
//  GroupProjectIOS
//
//  Created by Xiaoya Zou on 2024-11-07.
//

import SwiftUI

struct UpdateFoodView: View {
    
    @EnvironmentObject var foodViewModel: FoodViewModel
    @EnvironmentObject var foodCategoryViewModel: FoodCategoryViewModel
    
    @State var food: Food
    @State var showAlert = false
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        
        NavigationStack{
            
            VStack{
                Form {
                        
                    TextField("Name", text: $food.name)
                    
                    Stepper(value: $food.quantity, in: 1...100) {
                        Text("Quantity: \(food.quantity)")
                    }
                                
                    DatePicker("Expiration Date", selection: $food.expirationDate, displayedComponents: .date)
                            
                    Picker("Category", selection: $food.category) {
                        ForEach(foodCategoryViewModel.categories, id: \.self) { category in
                            Text(category.name).tag(category.name)
                        }
                    }
                    
                    Toggle("Enable Expiration Notification", isOn: $foodViewModel.isNotificationEnabled)
                        .padding(.vertical)
                }
                
                Button("Save Changes"){
                    foodViewModel.updateFood(food)
                    showAlert = true
                }
                .frame(maxWidth: .infinity)
                .padding() // For button text
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal) // For button itself
                .alert("Successfully Updated.", isPresented: $showAlert) {
                    Button("OK", role: .cancel){}
                }
            }
            .navigationTitle("\(food.name)")
            .padding(.bottom, 20)
            Spacer()
            
        }
    }
}

#Preview {
    UpdateFoodView(food: Food(id: "sampleID", name: "Sample Food", quantity: 2, expirationDate: Date(), category: "Sample Category"))
        .environmentObject(FoodViewModel())
        .environmentObject(FoodCategoryViewModel())
}
