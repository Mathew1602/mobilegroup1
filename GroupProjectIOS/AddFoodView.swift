//
//  AddFoodView.swift
//  GroupProjectIOS
//
//  Created by Xiaoya Zou on 2024-11-06.
//

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
    @State private var isPhotoPickerPresented = false
    @State private var useFoodPrediction: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                }
                
                
                HStack(spacing: 20) {
                    Button {
                        isCameraPresented = true
                    } label: {
                        Label("Camera", systemImage: "camera")
                    }
                    
                    Button {
                        isPhotoPickerPresented = true
                    } label: {
                        Label("Photos", systemImage: "photo")
                    }
                }
                
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
                    
                        Toggle("Use food prediction", isOn: $useFoodPrediction)
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
                        handlePrediction()
                    }
                }))
            }
            .sheet(isPresented: $isPhotoPickerPresented) {
                PhotoPickerView(imageData: $image, isPresented: $isPhotoPickerPresented)
            }
            Spacer()
        }.onChange(of: image) {
            handlePrediction()
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
                DispatchQueue.main.async {
                    resetFields()
                    alertMessage = "\(newFood.name) is saved successfully!"
                    showAlert = true
                    print("Saved food: \(newFood.name)")
                }
            }
        } else {
            foodViewModel.addFood(newFood)
            DispatchQueue.main.async {
                resetFields()
                alertMessage = "\(newFood.name) is saved successfully!"
                showAlert = true
                print("Saved food: \(newFood.name)")
            }
        }
    }

    
    func resetFields() {
        name = ""
        quantity = 1
        expirationDate = Date()
        image = nil
        useFoodPrediction = false
    }
    
    func handlePrediction() {
        guard useFoodPrediction, let image = image else { return }
        let predictor = CoreMLPrediction()
        predictor.predictFood(from: image) { predictedClass, confidence in
            self.name = predictedClass
            if(confidence >= 68)
            {
                self.alertMessage = "Succesfully predicted \(predictedClass) & \(confidence)"
            }else {
                self.alertMessage = "Unkown food \(confidence)"
            }
            self.showAlert = true
        }
    }

    

}

#Preview {
    AddFoodView()
        .environmentObject(FoodViewModel())
        .environmentObject(FoodCategoryViewModel())
}
