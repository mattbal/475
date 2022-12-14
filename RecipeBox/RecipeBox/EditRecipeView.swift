//
//  AddRecipeView.swift
//  RecipeBox
//
//  Created by Matt on 10/25/22.
//

import SwiftUI
import PhotosUI

struct EditRecipeView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.presentationMode) var presentationMode

    var recipe: Recipe
    @State var title = ""
    @State var ingredients = ""
    @State var steps = ""
    
    // Render the string with localization, but no markdown, so it doesn't convert * * to italics
    // See https://stackoverflow.com/questions/69202170/opt-out-of-swiftui-text-markdown-support-in-ios-15 for more details
    let ingredientsHint = String(localized: "Separate by new lines. Use *section name* to denote a section")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("Title")
                            .bold()
                        TextField("", text: $title, axis: .vertical)
                            .cornerRadius(4)
                            .padding(8)
                            .background(Color(red: 242 / 255, green: 242 / 255, blue: 242 / 255))
                    }
                    .padding(.bottom, 20)
                    
                    VStack(alignment: .leading) {
                        Text("Ingredients")
                            .bold()
                            .padding(.bottom, 1)
                        Text(ingredientsHint)
                            .foregroundColor(.secondary)
                        TextEditor(text: $ingredients)
                            .hideBackground()
                            .frame(minHeight: 180)
                            .cornerRadius(4)
                            .padding(8)
                            .background(Color(red: 242 / 255, green: 242 / 255, blue: 242 / 255))
                            .lineSpacing(10)
                    }
                    .padding(.bottom, 20)
                    
                    VStack(alignment: .leading) {
                        Text("Steps")
                            .bold()
                            .padding(.bottom, 1)
                        TextEditor(text: $steps)
                            .hideBackground()
                            .frame(minHeight: 180)
                            .cornerRadius(4)
                            .padding(8)
                            .background(Color(red: 242 / 255, green: 242 / 255, blue: 242 / 255))
                            .lineSpacing(10)
                    }
                    .padding(.bottom, 20)
                    
                    VStack(alignment: .leading) {
                        HStack(spacing: 0) {
                            Text("Image")
                                .bold()
                                .padding(.trailing, 4)
                            Text("(optional)")
                        }
                        .padding(.bottom, 2)
                        Button("Select Image") {
                            print("")
//                            PhotosPicker(selection: <#T##SwiftUI.Binding<[_PhotosUI_SwiftUI.PhotosPickerItem]>#>, maxSelectionCount: <#T##Int?#>, selectionBehavior: <#T##_PhotosUI_SwiftUI.PhotosPickerSelectionBehavior#>, matching: <#T##PhotosUI.PHPickerFilter?#>, preferredItemEncoding: <#T##_PhotosUI_SwiftUI.PhotosPickerItem.EncodingDisambiguationPolicy#>, label: <#T##() -> Label#>)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Add recipe")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Save") {
                    let ingredientsArray = ingredients.components(separatedBy: "\n")
                    let stepsArray = steps.components(separatedBy: "\n")
                    
                    recipe.title = title
                    recipe.ingredients = ingredientsArray
                    recipe.steps = stepsArray
                    
                    PersistenceController.shared.save()
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                Button("Cancel") {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }

        }
        .scrollDismissesKeyboard(.interactively)
    }
}

struct EditRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        EditRecipeView(recipe: PersistenceController.preview.container.viewContext.registeredObjects.first(where: { $0 is Recipe }) as! Recipe)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
