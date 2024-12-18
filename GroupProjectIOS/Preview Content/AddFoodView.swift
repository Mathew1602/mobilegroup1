//
//  AddFoodView.swift
//  GroupProjectIOS
//
//  Created by Xiaoya Zou on 2024-11-06.
//

import SwiftUI
import FirebaseStorage

struct AddFoodView: View {
    
    @EnvironmentObject var foodViewModel: FoodViewModel
    @EnvironmentObject var foodCategoryViewModel: FoodCategoryViewModel
    
    @State private var name: String = ""
    @State private var quantity: Int = 1
    @State private var expirationDate = Date()
    @State private var category: String = "Fruit"
    @State private var showAlert: Bool = false
    @State private var alertMessage = ""
    @State private var image: UIImage? = nil
    @State private var isCameraPresented = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                }
                Button("Take a Picture") {
                    isCameraPresented = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Form {
                    TextField("Name", text: $name)
                    
                    Stepper(value: $quantity, in: 1...100) {
                        Text("Quantity: \(quantity)")
                    }
                    
                    DatePicker("Expiration Date", selection: $expirationDate, displayedComponents: .date)
                    
                    Picker("Category", selection: $category) {
                        ForEach(foodCategoryViewModel.categories, id: \.self) { category in
                            Text(category.name).tag(category.name)
                        }
                    }
                    
                    Toggle("Enable Expiration Notification", isOn: $foodViewModel.isNotificationEnabled)
                        .padding(.vertical)
                }
                
                Button(action: {
                    saveFood()
                }) {
                    Text("Add")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .alert(alertMessage, isPresented: $showAlert) {
                    Button("OK", role: .cancel) {}
                }
            }
            .navigationTitle("Add")
            .padding(.bottom, 20)
            .sheet(isPresented: $isCameraPresented) {
                CameraView(isPresented: $isCameraPresented, imageData: Binding(get: {
                    image?.jpegData(compressionQuality: 0.8)
                }, set: { newData in
                    if let newData = newData, let newImage = UIImage(data: newData) {
                        self.image = newImage
                    }
                }))
            }
            Spacer()
        }
    }
    
    func saveFood() {
        if name.isEmpty || category.isEmpty {
            alertMessage = "Please enter all required fields."
            showAlert = true
            return
        }
        
        var newFood = Food(id: nil, name: name, quantity: quantity, expirationDate: expirationDate, category: category, imageName: nil)
        
        if let image = image {
            foodViewModel.uploadImage(image, for: newFood) { imageName in
                newFood.imageName = imageName
                foodViewModel.addFood(newFood)
                resetFields()
                alertMessage = "\(name) is saved successfully!"
                showAlert = true
            }
        } else {
            resetFields()
            alertMessage = "\(name) is saved successfully!"
            showAlert = true
        }
    }
    
    func resetFields() {
        name = ""
        quantity = 1
        expirationDate = Date()
        image = nil 
    }
}

#Preview {
    AddFoodView()
        .environmentObject(FoodViewModel())
        .environmentObject(FoodCategoryViewModel())
}
