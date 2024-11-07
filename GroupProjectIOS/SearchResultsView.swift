//
//  SearchResultsView.swift
//  GroupProjectIOS
//
//  Created by Xiaoya Zou on 2024-11-06.
//

import SwiftUI

// Food item search
struct SearchResultsView: View {

    @EnvironmentObject private var foodCategoryViewModel : FoodCategoryViewModel
    @EnvironmentObject private var foodViewModel : FoodViewModel
    @State private var searchText: String = ""
    @State private var searchRes : [Food] = []
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private var filteredFoodItems: [Food] {
        if searchText.isEmpty {
            return foodViewModel.foods
        } else {
            return foodViewModel.foods.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    var body: some View {
        
        NavigationStack{
            
            VStack {
                List {
                    ForEach(filteredFoodItems, id: \.id) { food in
                        
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
                            let food = filteredFoodItems[index]
                            foodViewModel.deleteFood(food)
                        }
                    }
                }

            }
            .onAppear {
                foodViewModel.fetchFoodByName()
            }
            .navigationTitle("Search Food Item")
        }
        .searchable(text:$searchText)
    }
}


#Preview {
    SearchResultsView()
        .environmentObject(FoodCategoryViewModel())
        .environmentObject(FoodViewModel())
}
