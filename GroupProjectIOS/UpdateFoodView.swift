//
//  UpdateFoodView.swift
//  GroupProjectIOS
//
//  Created by Xiaoya Zou on 2024-11-07.
//

import SwiftUI
import FirebaseStorage

struct UpdateFoodView: View {
    
    @EnvironmentObject var foodViewModel: FoodViewModel
    @EnvironmentObject var foodCategoryViewModel: FoodCategoryViewModel
    
    @State var food: Food
    @State var showAlert = false
    @State var image: UIImage? = nil
    @State var isCameraPresented = false
    @State var isFetchingImage = true
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            VStack {
                if isFetchingImage {
                    ProgressView("Loading...")
                        .padding()
                } else {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                    } else {
                        Button("Take a Picture") {
                            isCameraPresented = true
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                
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
                
                Button(action: {
                    if let image = image {
                        foodViewModel.uploadImage(image, for: food) { imageName in
                           
                            food.imageName = imageName
                            foodViewModel.updateFood(food)
                            showAlert = true
                        }
                    } else {
                        foodViewModel.updateFood(food)
                        showAlert = true
                    }
                }) {
                    Text("Save Changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .alert("Successfully Updated.", isPresented: $showAlert) {
                    Button("OK", role: .cancel) {}
                }
            }
            .navigationTitle("\(food.name)")
            .padding(.bottom, 20)
            .onAppear {
                foodViewModel.fetchImage(for: food) { fetchedImage in
                    if let fetchedImage = fetchedImage {
                        self.image = fetchedImage
                    }
                    isFetchingImage = false
                }
            }
            .sheet(isPresented: $isCameraPresented) {
                CameraView(isPresented: $isCameraPresented, imageData: Binding(get: {
                    image?.jpegData(compressionQuality: 0.8)
                }, set: { newData in
                    if let newData = newData, let newImage = UIImage(data: newData) {
                        self.image = newImage
                    }
                }))
            }
        }
    }
}

#Preview {
    UpdateFoodView(food: Food(id: "sampleID", name: "Sample Food", quantity: 2, expirationDate: Date(), category: "Sample Category"))
        .environmentObject(FoodViewModel())
        .environmentObject(FoodCategoryViewModel())
}
