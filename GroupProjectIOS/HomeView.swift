//
//  HomeView.swift
//  GroupProjectIOS
//
//  Created by Xiaoya Zou on 2024-11-06.
//

import SwiftUI

struct HomeView: View {
    
    // Initialize Food Categoruy ViewModel
    @EnvironmentObject private var foodCategoryViewModel : FoodCategoryViewModel
    @EnvironmentObject private var foodViewModel : FoodViewModel
    @State private var searchText: String = ""
    @State private var searchRes : [Food] = []
    
    // carousel images
    let foodImages = ["food1", "food2", "food3"]
    
    private var filteredCategories: [FoodCategory] {
        if searchText.isEmpty {
            return foodCategoryViewModel.categories
        } else {
            return foodCategoryViewModel.categories.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // For grid layout
    let columns = [
        GridItem(.fixed(170), spacing: 16),
        GridItem(.fixed(170), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                
                // carousel
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(foodImages, id: \.self) { imageName in
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 250, height: 150) // Adjust width/height as needed
                                .clipped()
                                .cornerRadius(10)
                                .shadow(radius: 4)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                
                // Grid layout
                ScrollView {
                    Spacer()
                    LazyVGrid(columns: columns, spacing: 18) {
                        ForEach(filteredCategories, id: \.id) { category in
                            NavigationLink(destination: CategoryDetailsView(category: category)) {
                                CategoryCardView(category: category)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("What's In My Fridge")
            .onAppear {
                foodCategoryViewModel.fetchCategories() // Fetch categories when HomeView appears
                foodViewModel.requestNotificationPermission()
            }
        }
        .searchable(text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .always)) // MUST have the placement attribute, or else the searchbar will disappear after navigation back from CategoryDetailsView!!!😠
    }
}

#Preview {
    HomeView()
        .environmentObject(FoodCategoryViewModel())
        .environmentObject(FoodViewModel())
}
