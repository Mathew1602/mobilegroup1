//
//  CategoryDetailsView.swift
//  GroupProjectIOS
//
//  Created by Xiaoya Zou on 2024-11-07.
//

import SwiftUI

struct CategoryDetailsView: View {
    
    var category: FoodCategory
    @EnvironmentObject var foodViewModel: FoodViewModel
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        
        NavigationStack {
            VStack {
                let categoryFoods = foodViewModel.foods.filter { $0.category == category.name }
                
                if categoryFoods.isEmpty {
                    
                    Image("not-found")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.secondary)
                    
                    Text("0 items found.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List {
                        ForEach(categoryFoods, id: \.id) { food in
                            
                            NavigationLink(destination: UpdateFoodView(food: food)){
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        // Food name
                                        Text(food.name)
                                            .font(.headline)

                                        // Other details below the name
                                        Text("Quantity: \(food.quantity)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("Expiry: \(food.expirationDate, formatter: dateFormatter)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                let food = categoryFoods[index]
                                foodViewModel.deleteFood(food)
                            }
                        }
                    }
                }
            }
            .onAppear {
                foodViewModel.fetchFoods(forCategory: category.name) // Fetch foods from Firestore
            }
            .navigationTitle(category.name)
        }
    }
}

#Preview {
    CategoryDetailsView(category: FoodCategory(id: "sampleID", name: "Sample Category", imageName: "Sample Image"))
        .environmentObject(FoodViewModel())
        .environmentObject(FoodCategoryViewModel())
}
