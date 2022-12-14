//
//  RecipeView.swift
//  RecipeBox
//
//  Created by Matt on 10/25/22.
//

import SwiftUI

struct RecipeDetail: View {
    var recipe: Recipe
    @State private var showEditRecipe = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(recipe.title!)
                        .font(.system(size: 30, weight: .heavy, design: .serif))
                        .padding(.bottom, 20)
                        .padding(.top, 24)
                    
                    VStack(alignment: .leading) {
                        Text("Ingredients")
                            .font(.system(size: 20, weight: .bold, design: .default))
                            .padding(.bottom, 2)
                        ForEach(recipe.ingredients!, id: \.self) { ingredient in
                            Text(ingredient)
                                .font(.system(size: 16, weight: .regular, design: .default))
                                .padding(.bottom, 8)
                        }
                    }
                    .padding(.bottom, 20)

                    VStack(alignment: .leading) {
                        // make steps numbers sans serif like Step 1, Step 2
                        Text("Steps")
                            .font(.system(size: 20, weight: .bold, design: .default))
                            .padding(.bottom, 2)
                        Grid(alignment: .topLeading) {
                            ForEach(recipe.steps!.indices, id: \.self) { index in
                                GridRow {
                                    Text("\(index + 1).")
                                        .font(.system(size: 16, weight: .regular, design: .default))
                                    Text(recipe.steps![index])
                                        .font(.system(size: 16, weight: .regular, design: .serif))
                                }
                                .padding(.bottom, 6)
                            }
                        }
                    }
                    .padding(.bottom, 10)
                    
                    Spacer()
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                .padding(.horizontal)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Edit") {
                            // TODO:
                        }
                    }
                }
            }
        }
        .navigationDestination(isPresented: $showEditRecipe) {
            EditRecipeView(recipe: recipe)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showEditRecipe = true
                }
            }
        }
    }
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeDetail(recipe: PersistenceController.preview.container.viewContext.registeredObjects.first(where: { $0 is Recipe }) as! Recipe)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
