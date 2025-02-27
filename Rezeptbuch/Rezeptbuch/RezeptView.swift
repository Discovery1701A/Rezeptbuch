//
//  RezeptView.swift
//  Rezeptbuch
//https://medium.com/@rohit.jankar/using-swift-a-guide-to-adding-reminders-in-the-ios-reminder-app-with-the-eventkit-api-020b2e6b38bb
//  Created by Anna Rieckmann on 10.03.24.
//
import SwiftUI
import EventKit
import WebKit

struct RecipeView: View {
    var recipe: Recipe
    var modelView: ViewModel
        var originIngriedents: [FoodItemStruct]
        @State private var ingredients: [FoodItemStruct]
        @State private var shoppingList: [FoodItemStruct] = []
        @State private var isReminderAdded = false
        let eventStore = EKEventStore()
        @State private var portion: Double
    @State private var showingShareSheet = false
        
        // Für den Picker
    @State private var cakeFormSelection : Formen
    @State private var diameter : Double
    @State private var lenght : Double
    @State private var width : Double
    @State private var privDiameter : Double
    @State private var privLenght : Double
    @State private var privWidth : Double
    @State private var originDiameter : Double
    @State private var originLenght : Double
    @State private var originWidth : Double
    var summary = NutritionSummary()
    

        
    init(recipe: Recipe, modelView: ViewModel) {
        self.recipe = recipe
//        print("ffdfdvfbdfbfdbdfbdfb",recipe)
        self.modelView = modelView
        self.originIngriedents = recipe.ingredients
        self._ingredients = State(initialValue: originIngriedents)
       
        if case let .Portion(portionValue) = recipe.portion {
            self.portion = portionValue
        } else {
            self.portion = 0.0
        }
        self.privWidth = 0
        self.privLenght = 0
        self.privDiameter = 0
        if case let .cake(form: FormValu, size: SizeValue) = recipe.cake {
            self.cakeFormSelection = FormValu
           
            if case let .rectangular(length: lenght, width: width) = SizeValue {
                self.lenght = lenght
                self.width = width
                self.diameter = (sqrt((lenght*width) / Double.pi) * 2).rounded(toPlaces: 2)

                self.originLenght = lenght
                self.originWidth = width
                self.originDiameter = (sqrt((lenght*width) / Double.pi) * 2).rounded(toPlaces: 2)
               
            }
            else if case let .round(diameter: diameter) = SizeValue {
                self.diameter = diameter
                self.lenght = sqrt(pow((diameter/2),2) * Double.pi).rounded(toPlaces: 2)
                self.width  = sqrt(pow((diameter/2),2) * Double.pi).rounded(toPlaces: 2)
                self.originDiameter = diameter
                self.originLenght = sqrt(pow((diameter/2),2) * Double.pi).rounded(toPlaces: 2)
                self.originWidth  = sqrt(pow((diameter/2),2) * Double.pi).rounded(toPlaces: 2)
               
            } else {
                self.diameter = 0
                self.lenght = 0
                self.width  = 0
                self.originDiameter = 0
                self.originLenght = 0
                self.originWidth  = 0
            }
           
            
        } else {
            self.cakeFormSelection = .rund
            self.diameter = 0
            self.lenght = 0
            self.width  = 0
            self.originDiameter = 0
            self.originLenght = 0
            self.originWidth  = 0
         
        }
        self.privWidth = self.width
        self.privLenght = self.lenght
        self.privDiameter = self.diameter
        
        summary.calculate(from: ingredients)
     
    }
    func extractYouTubeID(from link: String) -> String? {
        if link.contains("youtube.com") {
            // Extrahiere die ID aus einem normalen YouTube-Link
            if let url = URL(string: link), let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems {
                for item in queryItems where item.name == "v" {
                    return item.value
                }
            }
        } else if link.contains("youtu.be") {
            // Extrahiere die ID aus einem verkürzten youtu.be Link
            return URL(string: link)?.lastPathComponent
        }
        return nil
    }
    
    var body: some View {
        GeometryReader { geometry in
           
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                           
                                    ShareSheetView(recipe: recipe)
                                
                            
                        }
                        NavigationLink(destination: RecipeCreationView(recipe: recipe, modelView: modelView)) {
                                                    Text("Bearbeiten")
                                                        .padding()
                                                        .foregroundColor(.white)
                                                        .background(Color.blue)
                                                        .cornerRadius(10)
                                                }
                        VStack(alignment: .center, spacing: 10) {
                            Text(recipe.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)

                            Divider().padding(.horizontal, 16)
                            RecipeImageView(imagePath: recipe.image)
                            if recipe.tags != nil {
                                if recipe.tags!.count > 0 {
                                    RecipeTagsView(tags: recipe.tags!)
                                }
                            }
                            Divider().padding(.horizontal, 16)
                    if recipe.portion != .notPortion && recipe.portion != nil
                    {
                        HStack{
                            portionScaleMinus()
                            Text(String(Int(portion)))
                            portionScalePlus()
                        }
                    }
                    if let cakeInfo = recipe.cake, case .cake = cakeInfo {
                                            Picker("Kuchenform", selection: $cakeFormSelection) {
                                                Text("Eckig").tag(Formen.eckig)
                                                Text("Rund").tag(Formen.rund)
                                            }
                                            .pickerStyle(SegmentedPickerStyle())
                                            .padding()
                                            .onChange(of: cakeFormSelection) { newValue in
                                                if newValue == Formen.rund{
                                                   
                                                    if privLenght != lenght || privWidth != width{
                                                        rectToRound()
                                                        privWidth = width
                                                        privLenght = lenght
                                                        privDiameter = diameter
                                                        scaleRoundIngredients()
                                                    }
                                                } else if newValue == Formen.eckig{
                                                   
                                                    if privDiameter != diameter{
                                                        roundToRect()
                                                        privDiameter = diameter
                                                        privWidth = width
                                                        privLenght = lenght
                                                        scaleRectIngredients()
                                                    }
                                                }
                                            }
                                        
                                            
                        HStack{
                            if cakeFormSelection == .rund{
                                Text("Durchmesser (cm):")
                                TextField("Durchmesser (cm)", text: Binding(
                                    get: { "\(diameter)" },
                                    set: {
                                        if let value = Double($0) {
                                            diameter = value
                                        }
                                    })
                                )
#if os(iOS)
                                .keyboardType(.decimalPad)
                                #endif
                                .onChange(of: diameter) { newValue in
                                    scaleRoundIngredients()}
                            }
                            
                            if cakeFormSelection == .eckig{
                                Text("Länge (cm):")
                                TextField("Länge (cm)", text: Binding(
                                    get: { "\(lenght)" },
                                    set: {
                                        if let value = Double($0) {
                                            lenght = value
                                        }
                                    })
                                )
                                
#if os(iOS)
                                .keyboardType(.decimalPad)
                                #endif
                                .onChange(of: width) { newValue in
                                    scaleRectIngredients()
                                
                            }
                                Text("Breite (cm):")
                                TextField("Breite (cm)", text: Binding(
                                    get: { "\(width)" },
                                    set: {
                                        if let value = Double($0) {
                                            width = value
                                        }
                                    })
                                )
#if os(iOS)
                                .keyboardType(.decimalPad)
                                #endif
                                .onChange(of: lenght) { newValue in
                                    scaleRectIngredients()
                                
                            }
                            }
                            
                            
                            
                        }
                                        }
                        
                            Divider().padding(.horizontal, 16)
                           
                                  NutritionSummaryView(summary: summary)
                            
                            Divider().padding(.horizontal, 16)
                    RecipeIngredientsView(ingredients: ingredients)
                                .onAppear {
                                           print("Angezeigte Zutatenin der View: \(ingredients)")
                                       }
                            
                            Divider().padding(.horizontal, 16)
                            RecipeInstructionsView(instructions: recipe.instructions)
                            Divider().padding(.horizontal, 16)
                            if recipe.videoLink != "" && recipe.videoLink != nil{
                                
                                
                                RecipeVideoView(videoLink: recipe.videoLink)
                                Divider().padding(.horizontal, 16)
                            }
                            Kochmodus()
                   
                    Button(action: {
                        createShoppingList()
                        addShoppingListToReminders()
                    }) {
                        Text("Einkaufsliste erstellen und zu Erinnerungen hinzufügen")
                    }
                }
                .padding()
                .background()
                .cornerRadius(15)
                .shadow(radius: 5)
            }
        }

    }
  
    
    @ViewBuilder
    func Kochmodus()-> some View{
        NavigationLink(destination: CookingModeView(recipe: recipe)) {
                                    Text("Zum Kochmodus")
                                        .padding()
                                        .foregroundColor(.white)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
    }
    
    func createShoppingList() {
           shoppingList.removeAll()
           for ingredient in ingredients {
               if !shoppingList.contains(where: { $0.food == ingredient.food }) {
                   shoppingList.append(ingredient)
               } else {
                   if let existingIndex = shoppingList.firstIndex(where: { $0.food == ingredient.food }) {
                       shoppingList[existingIndex].quantity += ingredient.quantity
                   }
               }
           }
       }
       
    func addShoppingListToReminders() {
       
        
        if #available(iOS 17.0, *),   #available(macOS 14.0, *){
            eventStore.requestFullAccessToReminders() { granted, error in
                if granted && error == nil {
                   let reminderList = findOrCreateReminderList(eventStore: eventStore, title: "Shopping List")
                            for item in shoppingList {
                                findRemindersForItem(item, in: reminderList) { existingReminders in
                                    if let existingReminders = existingReminders, !existingReminders.isEmpty {
                                        updateExistingReminders(existingReminders, with: item, in: eventStore)
                                    } else {
                                        let reminder = EKReminder(eventStore: eventStore)
                                        reminder.title = "\(item.quantity) " + item.unit.rawValue + " " + item.food.name
                                        reminder.calendar = reminderList
                                        
                                        do {
                                            try eventStore.save(reminder, commit: true)
//                                             print(item.food.name)
                                        } catch {
                                            print("Error saving reminder: \(error.localizedDescription)")
                                        }
                                    
                                
                            }
                            
                            print("Shopping list added to Reminders.")
                            isReminderAdded = true
                        }
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }

    
    func findOrCreateReminderList(eventStore: EKEventStore, title: String) -> EKCalendar? {
            let calendars = eventStore.calendars(for: .reminder)
            
            if let existingList = calendars.first(where: { $0.title == title }) {
                return existingList
            } else {
                let newList = EKCalendar(for: .reminder, eventStore: eventStore)
                newList.title = title
                newList.source = eventStore.defaultCalendarForNewReminders()?.source
                
                do {
                    try eventStore.saveCalendar(newList, commit: true)
                    print("New reminder list created: \(title)")
                    return newList
                } catch {
                    print("Error creating reminder list: \(error.localizedDescription)")
                    return nil
                }
            }
        }
       
    func findRemindersForItem(_ item: FoodItemStruct, in reminderList: EKCalendar?, completion: @escaping ([EKReminder]?) -> Void) {
        guard let reminderList = reminderList else { completion(nil); return }
       
        if #available(iOS 17.0, *),   #available(macOS 14.0, *){
            
            eventStore.requestFullAccessToReminders() { granted, error in
                if granted {
//                    print("ja")
                    let predicate = eventStore.predicateForReminders(in: [reminderList])
                    eventStore.fetchReminders(matching: predicate) { reminders in
                        let filteredReminders = reminders?.filter { $0.title?.contains(item.unit.rawValue + " " + item.food.name) ?? false }
                        completion(filteredReminders)
                    }
                } else {
                    print("Access to reminders denied.")
                    completion(nil)
                }
            }
        }
    }

    func updateExistingReminders(_ reminders: [EKReminder], with item: FoodItemStruct, in eventStore: EKEventStore) {
        
        for reminder in reminders {
            let newTitle = "\(item.quantity + Double(reminder.title.components(separatedBy: " ").first ?? "")!)" + " " + item.unit.rawValue + " " + item.food.name
            reminder.title = newTitle
            do {
                try eventStore.save(reminder, commit: true)
                print("Reminder updated: \(newTitle)")
            } catch {
                print("Error updating reminder: \(error.localizedDescription)")
            }
        }
    }
    @ViewBuilder
    func portionScalePlus() -> some View {
        Button(action: {
            if portion > 0 {
                portion = 1 + portion
                scaleIngredients(portion: portion)
            }
            
        }, label: {
            Image(systemName: "plus.circle.fill")
        })
    }

    @ViewBuilder
    func portionScaleMinus() -> some View {
        Button(action: {
            if portion > 1 {
                portion = portion - 1
                scaleIngredients(portion: portion)
            }
            
        }, label: {
            Image(systemName: "minus.circle.fill")
        })
    }


     
     private func scaleIngredients(portion: Double) {
         if case let .Portion(portionValue) = recipe.portion {
             ingredients = Model().portionScale(portionOrigin: portionValue, portionNew: portion, foodItems: originIngriedents)
         }
     }
    
    private func scaleRoundIngredients() {
       
            ingredients = Model().roundScale(diameterOrigin: originDiameter, diameterNew: diameter, foodItems: originIngriedents)
    }
    private func scaleRectIngredients(){
        ingredients = Model().rectScale(lengthOrigin: originLenght, widthOrigin: originWidth, lengthNew: lenght, widthNew: width, foodItems: originIngriedents)
    }
    
    private func rectToRound(){
        diameter = Model().rectToRound(length: lenght, width: width).rounded(toPlaces: 2)
    }
    
    private func roundToRect(){
        width = Model().roundToRect(diameter: diameter, length: lenght).rounded(toPlaces: 2)
    }
    
    private func itemScale(){
        ingredients = Model().itemScale(foodItemsOrigin: originIngriedents, foodItemsNew: ingredients)
    }
    
    

   }

struct RecipeImageView: View {
    var imagePath: String?
    
    var body: some View {
        if let path = imagePath, let image = Image.loadImageFromPath(path) {
            image
                .resizable()
                .scaledToFit()
                .cornerRadius(10)
                .padding(.top, 10)
                .frame(maxWidth: .infinity, maxHeight: 200)
        } else {
            if let imageName = imagePath {
                                  Image(imageName)
                                      .resizable()
                                      .scaledToFit()
                                      .cornerRadius(10)
                                      .padding(.top, 10)
                                      .frame(maxWidth: .infinity, maxHeight: 200)
            } else{
                Text("Bild nicht verfügbar")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
}

struct RecipeVideoView: View {
    var videoLink: String?
    
    func extractYouTubeID(from link: String) -> String? {
        if link.contains("youtube.com"), let url = URL(string: link), let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems {
            return queryItems.first(where: { $0.name == "v" })?.value
        } else if link.contains("youtu.be") {
            return URL(string: link)?.lastPathComponent
        }
        return nil
    }
    
    var body: some View {
        if let link = videoLink, let videoID = extractYouTubeID(from: link) {
            YouTubeView(videoID: videoID)
                
                .scaledToFit()
                
              
                .frame(maxWidth: .infinity, maxHeight: 300)
        } else {
            if videoLink != nil {
                Text("Kein gültiges Video gefunden.")
            }
        }
    }
}
struct RecipeTagsView: View {
    var tags: [TagStruct]
    var body: some View {
        ScrollView(.horizontal) {
            HStack{
                ForEach(tags, id: \.self) { tag in
                    Text(tag.name)
                        .font(.headline)
                        .padding()
                        
                }
            }
        }
    }
}

struct RecipeIngredientsView: View {
    @State var ingredients: [FoodItemStruct] // Zutaten als @State
    @State var orignIngredients: [FoodItemStruct]
    @State private var selectedIngredient: FoodItemStruct? = nil // Direkte Referenz zur bearbeiteten Zutat
    @State private var editedQuantity: String = "" // Temporär bearbeitete Menge
    @State private var selectedUnit: Unit = .gram // Temporär bearbeitete Einheit
    
    init(ingredients: [FoodItemStruct]) {
        self.ingredients = ingredients
        self.orignIngredients = ingredients
       
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Zutaten:")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            ForEach(ingredients.indices, id: \.self) { index in
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(ingredients[index].food.name)")
                            .font(.body)
                        
                        HStack {
                            Text("\(ingredients[index].quantity.rounded(toPlaces: 2).formatted(toPlaces: 2))")
                                .font(.subheadline)
                            
                            Text(ingredients[index].unit.rawValue)
                                .font(.subheadline)
                                .onLongPressGesture {
                                    preparePopup(for: index)
                                }
                        }
                        .padding(.bottom, 5)
                    }
                }
                .padding()
            }
        }
        .padding()
        .sheet(item: $selectedIngredient) { ingredient in
            EditIngredientPopup(
                ingredient: Binding(
                    get: { ingredient },
                    set: { updatedIngredient in
                        // Aktualisiere die Zutat im Array
                        if let index = ingredients.firstIndex(where: { $0.id == updatedIngredient.id }) {
                            ingredients[index] = updatedIngredient
                        }
                    }
                ),
                editedQuantity: $editedQuantity,
                selectedUnit: $selectedUnit,
                onSave: { newQuantity, newUnit in
                    if let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
                        ingredients[index].quantity = newQuantity
                        ingredients[index].unit = newUnit
                        print("Gespeicherte neue Menge in übergeordneter Ansicht: \(ingredients[index].quantity)")
                        adjustOtherIngredients(for: ingredient)
                    }
                },
                onClose: {
                    selectedIngredient = nil // Popup schließen
                }
            )
        }
    }

    private func preparePopup(for index: Int) {
        // Popup-Daten vorbereiten
        let ingredient = ingredients[index]
        selectedIngredient = ingredient // Wähle die Zutat direkt aus
        editedQuantity = String(ingredient.quantity)
        selectedUnit = ingredient.unit
    }

    private func adjustOtherIngredients(for ingredient: FoodItemStruct) {
        guard let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) else { return }
        
        let oldQuantity = orignIngredients[index].quantity
        let newQuantity = Unit.convert(value: ingredients[index].quantity, from: ingredients[index].unit, to: orignIngredients[index].unit, density: ingredients[index].food.density ?? 0) ?? ingredients[index].quantity
        let adjustmentFactor = newQuantity / oldQuantity

        // Passe die Mengen der anderen Zutaten an
        for i in ingredients.indices where i != index  {
            ingredients[i].quantity = adjustmentFactor * orignIngredients[i].quantity
        }
    }
}

struct EditIngredientPopup: View {
    @Binding var ingredient: FoodItemStruct
    @Binding var editedQuantity: String
    @Binding var selectedUnit: Unit
    @State private var temporaryUnit: Unit // Temporäre Einheit für Berechnungen
    var onClose: () -> Void // Callback zum Schließen des Popups
    var onSave: (Double, Unit) -> Void // Callback zum Speichern und Anpassen der anderen Zutaten
    
    init(
        ingredient: Binding<FoodItemStruct>,
        editedQuantity: Binding<String>,
        selectedUnit: Binding<Unit>,
        onSave: @escaping (Double, Unit) -> Void,
        onClose: @escaping () -> Void
        
    ) {
        self._ingredient = ingredient
        self._editedQuantity = editedQuantity
        self._selectedUnit = selectedUnit
        self.onClose = onClose
        self.onSave = onSave
        self._temporaryUnit = State(initialValue: selectedUnit.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Menge bearbeiten")
                .font(.headline)
            
            Text(ingredient.food.name)
                .font(.title2)
            
            if ingredient.food.density == nil || ingredient.food.density ?? 0 <= 0 {
                Text("Einheit kann nicht geändert werden, da keine Dichte vorhanden ist.")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            if ingredient.unit == .piece {
                Text("Einheit kann nicht geändert werden, da es sich um eine Stückanzahl handelt.")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            
            HStack {
                TextField("Menge", text: $editedQuantity)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
                
                Picker("Einheit", selection: $selectedUnit) {
                    ForEach(Unit.allCases.filter { $0 != .piece || $0 == selectedUnit }, id: \.self) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .disabled(ingredient.food.density == nil || ingredient.food.density ?? 0 <= 0 || ingredient.unit == .piece) // Deaktiviert den Picker
                .onChange(of: selectedUnit) { newUnit in
                    // Umrechnung der Menge beim Ändern der Einheit
                    if newUnit != .piece && ingredient.unit != .piece {
                        if let newQuantity = Unit.convert(
                            value: Double(editedQuantity) ?? 0,
                            from: temporaryUnit,
                            to: newUnit,
                            density: ingredient.food.density ?? 1.0 // Standarddichte
                        ) {
                            editedQuantity = String(newQuantity)
                        }
                        temporaryUnit = newUnit
                    }
                }
            }
            .padding()
            
            HStack {
                Button("Abbrechen") {
                    // Popup schließen ohne Änderungen
                    onClose() // Schließt das Popup
                }
                .padding()
                Button("Speichern") {
                    if let newQuantity = Double(editedQuantity) {
                        print("Converted Quantity: \(newQuantity)")
                        onSave(newQuantity, selectedUnit) // Rückgabe an die übergeordnete Ansicht
                    } else {
                        print("Ungültige Eingabe in Edited Quantity: \(editedQuantity)")
                    }
                    onClose() // Schließt das Popup
                }


                .padding()



            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}


struct RecipeInstructionsView: View {
    var instructions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Anleitung:")
                .font(.headline)
                .multilineTextAlignment(.center)
            ForEach(instructions, id: \.self) { instruction in
                Text(instruction)
//                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}




struct YouTubeView: UIViewRepresentable {
    var videoID: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: "https://www.youtube.com/embed/\(videoID)?playsinline=1") else { return }
        uiView.scrollView.isScrollEnabled = false
        uiView.load(URLRequest(url: url))
    }
}
extension Double {
    func formatted(toPlaces places: Int) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = places
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}



// Struktur zur Zusammenfassung der Nährwerte
struct NutritionSummary {
    var totalCalories: Int = 0
    var totalProtein: Double = 0.0
    var totalCarbohydrates: Double = 0.0
    var totalFat: Double = 0.0
    var missingStings:[String] = []

    mutating func calculate(from items: [FoodItemStruct]) {
        totalCalories = 0
        totalProtein = 0.0
        totalCarbohydrates = 0.0
        totalFat = 0.0
       
        for item in items {
            if item.food.density == nil || item.food.density ?? 0 <= 0 {
                missingStings.append("\(item.food.name) hat keine Dichte")
            }
            if item.food.nutritionFacts == nil || item.food.nutritionFacts?.calories == nil || item.food.nutritionFacts?.calories ?? 0 <= 0  || item.food.nutritionFacts?.protein == nil || item.food.nutritionFacts?.protein ?? 0 <= 0 || item.food.nutritionFacts?.carbohydrates == nil || item.food.nutritionFacts?.carbohydrates ?? 0 <= 0 || item.food.nutritionFacts?.fat == nil || item.food.nutritionFacts?.fat ?? 0 <= 0 {
                missingStings.append("\(item.food.name) hat fehlende Nährwerte")
                
            }
            
            if item.unit == .piece{
                missingStings.append("\(item.food.name) hat eine Stückmenge daher ist die Berechnung nicht vollständing")
            } else {
                
                if let nutrition = item.food.nutritionFacts {
                    print(nutrition)
                    totalCalories += Int(Double(nutrition.calories ?? 0) *  (Unit.convert(value: item.quantity, from: item.unit, to: .gram, density: item.food.density ?? 0) ?? 0) / 100)
                    totalProtein += (nutrition.protein ?? 0.0) *  (Unit.convert(value: item.quantity, from: item.unit, to: .gram, density: item.food.density ?? 0) ?? 0) / 100
                    totalCarbohydrates += (nutrition.carbohydrates ?? 0.0) *  (Unit.convert(value: item.quantity, from: item.unit, to: .gram, density: item.food.density ?? 0) ?? 0) / 100
                    
                    totalFat += (nutrition.fat ?? 0.0) *  (Unit.convert(value: item.quantity, from: item.unit, to: .gram, density: item.food.density ?? 0) ?? 0) / 100
                }
            }
        }
    
    }
}

struct NutritionSummaryView: View {
    let summary: NutritionSummary

    var body: some View {
        VStack {
            Text("Nährwerte")
                .font(.headline)
                .padding()
            if summary.missingStings.count > 0 {
                Text("Es wurden bei der Berechnung nicht alle Zutaten berücksichtigt.")
            }
            HStack {
                NutritionBar(value: summary.totalCalories, label: "Kalorien", color: .red)
                NutritionBar(value: Int(summary.totalProtein), label: "Protein", color: .blue)
                NutritionBar(value: Int(summary.totalCarbohydrates), label: "Kohlenhydrate", color: .green)
                NutritionBar(value: Int(summary.totalFat), label: "Fett", color: .yellow)
            }
            .padding()
        }
    }
}

// Hilfskomponente für Balkendiagramme
struct NutritionBar: View {
    var value: Int
    var label: String
    var color: Color

    var body: some View {
        VStack {
            
             Text(label)
                 .font(.caption)
                 .rotationEffect(.degrees(-45))
                 .padding(.vertical)
            Text("\(value)")
                .font(.caption)
                .padding(.vertical)
        
        }
    }
}

