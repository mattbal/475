//
//  AddRecipeView.swift
//  RecipeBox
//
//  Created by Matt on 10/25/22.
//

import SwiftUI
import PhotosUI

extension TextEditor {
    @ViewBuilder func hideBackground() -> some View {
        if #available(iOS 16, *) {
            self.scrollContentBackground(.hidden)
        } else {
            self
        }
    }
}

struct AddRecipeView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.presentationMode) var presentationMode

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
//                        Text("Drag to reorder")
//                            .foregroundColor(.secondary)
//                            .padding(.bottom, 10)
//                        Grid(alignment: .topLeading) {
//                            ForEach(steps.indices, id: \.self) { index in
//                                GridRow {
//                                    Text("\(index + 1).")
//                                        .font(.system(size: 20, weight: .regular, design: .default))

//                                        Text(steps[index])
                                        //                                        .font(.system(size: 20, weight: .regular, design: .serif))
//                                            .fontDesign(.serif)
//                                            .frame(maxWidth: .infinity, alignment: .leading)
//                                            .background(
//                                                draggedStep ==  RoundedRectangle(cornerRadius: 5)
//                                                    .fill(.black.opacity(0.1))
//                                                    .scaleEffect(1.05)
//                                            )
//                                }
//                                .onDrag {
//                                    draggedStep = steps[index]
//                                    return NSItemProvider(object: "\(draggedStep ?? "")" as NSString)
//                                }
//                                .onDrop(of: [.text], delegate: DropViewDelegate())
//                                .padding(.bottom, 6)
//                            }
//                        }
//                        Button("Add Step") {
//                            steps.append("New Step")
//                        }
                    }
                    .padding(.bottom, 20)
                    
//                    VStack(alignment: .leading) {
//                        HStack(spacing: 0) {
//                            Text("Time")
//                                .bold()
//                                .padding(.trailing, 4)
//                            Text("(optional)")
//                        }
//                        Text("Use minutes")
//                            .foregroundColor(.secondary)
//                        TextField("", text: $time)
//                            .cornerRadius(4)
//                            .padding(8)
//                            .background(Color(red: 242 / 255, green: 242 / 255, blue: 242 / 255))
//                    }
//                    .padding(.bottom, 20)
                    
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
                    let r = Recipe(context: managedObjectContext)
                    r.id = UUID()
                    r.title = title
                    r.ingredients = ingredientsArray
                    r.steps = stepsArray
                    
                    PersistenceController.shared.save()
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

struct AddRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        
        AddRecipeView(title: "Spaghetti Carbonara", ingredients: "1 lb of Spaghetti\n1/2 lb of bacon\n2 cloves of garlic\n1/4 cup of grated parmesan cheese\n2 eggs\nFresh parsley", steps: "Fill a pot of water and set it over high heat. Heat a medium pan over medium heat\nWhen the pan is hot, add bacon\nCook bacon until crispy, about 5 minutes\nWhen the water starts to boil add the pasta. Cook for 2 minutes less than the manufacturer's recommended time\nDrain the pasta\nAdd the garlic to the pan. Stir for 30 seconds\nAdd the strained pasta to the pan. Cook for 2 minutes, stirring ocassionally\nWhile pasta is cooking, whisk the 2 eggs and parmesan cheese together. Add freshly cracked black peper and salt to taste\nTake the pan off the heat and mix in the egg mixture\nTop with fresh parsley and serve")
    }
}
