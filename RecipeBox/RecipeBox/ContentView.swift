//
//  ContentView.swift
//  RecipeBox
//
//  Created by Matt on 10/21/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.title)]) var recipes: FetchedResults<Recipe>
    
    @State private var path: [Recipe] = []
    @State private var showAddRecipe = false
    @State private var searchText = ""
    private var query: Binding<String> {
        Binding {
            searchText
        } set: { newValue in
            searchText = newValue
            recipes.nsPredicate = newValue.isEmpty ? nil : NSPredicate(format: "title CONTAINS %@", newValue)
        }
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(recipes) { recipe in
                    NavigationLink(value: recipe) {
                        if let image = recipe.image {
                            UIImage(data: image).map { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                            }
                        } else {
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(Color("img-preview-stroke"), lineWidth: 1)
                                .background(
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color("img-preview"))
                                )
                                .frame(width: 30, height: 30)
                        }
                        Text(recipe.title!)
                            .padding(.leading, 6)
                    }
                }
                .onDelete(perform: removeRecipe)
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetail(recipe: recipe)
            }
            .navigationDestination(isPresented: $showAddRecipe) {
                AddRecipeView()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddRecipe = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "line.3.horizontal.decrease")
                    })
                }
            }
        }
        .searchable(text: query, prompt: "Search for a recipe by name")
    }
    
    private func removeRecipe(at offsets: IndexSet) {
        withAnimation {
            offsets.map { recipes[$0] }.forEach(managedObjectContext.delete)
            PersistenceController.shared.save()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
