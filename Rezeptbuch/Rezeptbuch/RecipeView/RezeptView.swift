//
//  RezeptView.swift
//  Rezeptbuch
// https://medium.com/@rohit.jankar/using-swift-a-guide-to-adding-reminders-in-the-ios-reminder-app-with-the-eventkit-api-020b2e6b38bb
//  Created by Anna Rieckmann on 10.03.24.
//
import EventKit
import SwiftUI

import UIKit
import WebKit

struct RecipeView: View {
    var recipe: Recipe
    var modelView: ViewModel
    var originIngredients: [FoodItemStruct]

    @State private var ingredients: [FoodItemStruct] = []
    @State private var portion: Double = 0.0
    @State private var cakeFormSelection: Formen = .rund
    @State private var diameter: Double = 0
    @State private var length: Double = 0
    @State private var width: Double = 0
    @State private var privDiameter: Double = 0
    @State private var privLength: Double = 0
    @State private var privWidth: Double = 0
    @State private var originDiameter: Double = 0
    @State private var originLength: Double = 0
    @State private var originWidth: Double = 0
    @State private var ratio: Double = 1

    @State private var shoppingList: [FoodItemStruct] = []
    @State private var isReminderAdded = false
    @State private var showingReminderSheet = false
    @State private var availableReminderLists: [EKCalendar] = []
    @State private var selectedReminderList: EKCalendar?
    @State private var newListName: String = ""

    @State private var showingShareSheet = false
    @State private var isFormUpdatingIngredients = false
    @State private var refreshID = UUID() // 🔄 Nutzt `UUID`, um die View zu erzwingen, sich neu zu laden

    let eventStore = EKEventStore()
    @State private var summary = NutritionSummary()

    init(recipe: Recipe, modelView: ViewModel) {
        self.recipe = recipe
        self.modelView = modelView
        self.originIngredients = recipe.ingredients
        _ingredients = State(initialValue: recipe.ingredients)
        loadRecipe(recipe) // ⏳ Initialisierung direkt aufrufen
        summary.calculate(from: ingredients)
    }
    
    private func loadRecipe(_ recipe: Recipe) {
        DispatchQueue.main.async {
            self.ingredients = recipe.ingredients

            if case let .Portion(portionValue) = recipe.portion {
                self.portion = portionValue
            } else {
                self.portion = 0.0
            }

            if case let .cake(form, size) = recipe.cake {
                self.cakeFormSelection = form

                switch size {
                case let .rectangular(length, width):
                    self.length = length
                    self.width = width
                    self.diameter = (sqrt((length * width) / Double.pi) * 2).rounded(toPlaces: 2)

                    self.originLength = length
                    self.originWidth = width
                    self.originDiameter = self.diameter

                    self.privDiameter = self.diameter
                    self.privLength = length
                    self.privWidth = width

                    self.ratio = width != 0.0 ? length / width : 1

                case let .round(diameter):
                    self.diameter = diameter
                    self.length = sqrt(pow(diameter / 2, 2) * Double.pi).rounded(toPlaces: 2)
                    self.width = self.length

                    self.originDiameter = diameter
                    self.originLength = self.length
                    self.originWidth = self.width

                    self.privDiameter = diameter
                    self.privLength = self.length
                    self.privWidth = self.width

                    self.ratio = 1

                default:
                    self.resetCakeValues()
                }
            } else {
                self.resetCakeValues()
            }
        }
//        print("updddattttttteeeeeee")
    }

    /// Setzt Kuchenform-Werte auf Standardwerte zurück
    private func resetCakeValues() {
        cakeFormSelection = .rund
        diameter = 0
        length = 0
        width = 0
        originDiameter = 0
        originLength = 0
        originWidth = 0
        privDiameter = 0
        privLength = 0
        privWidth = 0
        ratio = 1
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
                VStack(alignment: .center, spacing: 10) {
                    // Titel & Share-Button
                    recipeHeader
                    
                    Divider().padding(.horizontal, 16)
                    
                    RecipeImageView(imagePath: recipe.image)
                    
                    // Tags anzeigen, falls vorhanden
                    if let tags = recipe.tags, !tags.isEmpty {
                        RecipeTagsView(tags: tags)
                    }
                    
                    Divider().padding(.horizontal, 16)
                    
                    // Portionierung & Rezeptbearbeitung
                    if let portion = recipe.portion, portion != .notPortion {
                        portionView(for: geometry.size.width)
                    }
                    
                    // Kuchenform-Auswahl
                    if recipe.cake != .notCake {
                        cakeSelectionView(for: geometry.size.width)
                    }
                    
                    Divider().padding(.horizontal, 16)
                    
                    // Nährwerte
                    NutritionSummaryView(summary: summary)
                    
                    Divider().padding(.horizontal, 16)
                    
                    // Zutatenliste
                    RecipeIngredientsView(ingredients: $ingredients, modelView: modelView)
//                        .onAppear { print("Angezeigte Zutaten: \(ingredients)") }
                        .onChange(of: ingredients) { newIngredients in
                            updateIngredients(newIngredients)
                        }
                    
                    Divider().padding(.horizontal, 16)
                    
                    // Anweisungen & Video
                    RecipeInstructionsView(instructions: recipe.instructions)
                    
                    if let videoLink = recipe.videoLink, !videoLink.isEmpty {
                        Divider().padding(.horizontal, 16)
                        RecipeVideoView(videoLink: videoLink)
                    }
                    
                    Divider().padding(.horizontal, 16)
                    
                    // Kochmodus & Einkaufsliste
                    Kochmodus()
                    shoppingListButton
                }
                .sheet(isPresented: $showingReminderSheet) {
                    ReminderListSelectionView(
                        availableLists: $availableReminderLists,
                        selectedList: $selectedReminderList,
                        newListName: $newListName,
                        eventStore: eventStore,
                        onConfirm: addShoppingListToReminders,
                        fetchReminderLists: fetchReminderLists
                    )
                }
                .padding()
                .background()
                .cornerRadius(15)
                .shadow(radius: 5)
                .onAppear {
                    loadRecipe(recipe)
                    summary.calculate(from: ingredients)
                }
                .id(refreshID)
                .onChange(of: recipe) { newRecipe in
                    loadRecipe(newRecipe)
                    summary.calculate(from: ingredients)
                }
            }
        }
    }
    
    private var recipeHeader: some View {
        ZStack {
            Text(recipe.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            ShareSheetView(recipe: recipe)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 16)
    }
    
    private func portionView(for width: CGFloat) -> some View {
        VStack {
            Text("Portionen:")
            
            HStack {
                Spacer()
                portionScaleMinus()
                Text(formatPortion(portion))
                portionScalePlus()
                Spacer()
            }
            HStack{
                recipeEditButton
                resetScale()
            }
            
        }
    }

    private func updateIngredients(_ newIngredients: [FoodItemStruct]) {
        DispatchQueue.main.async {
            // Falls die Änderung durch die Kuchenform kommt, ignorieren
            guard !isFormUpdatingIngredients else {
                isFormUpdatingIngredients = false // Status zurücksetzen
                return
            }
            
            print("Zutaten haben sich geändert: \(newIngredients)")
            
            // Portionierung anpassen
            if recipe.portion != .notPortion {
                ingriedentsScalePortion()
            }
            
            // Kuchenform anpassen
            if recipe.cake != .notCake {
                if cakeFormSelection == .rund {
                    ingriedentsScaleDia()
                } else if cakeFormSelection == .eckig {
                    ingriedentsScaleWL()
                }
            }
            
            // Nährwerte neu berechnen
            summary.calculate(from: ingredients)
        }
    }
    
    private func updateCakeForm(_ newValue: Formen) {
        DispatchQueue.main.async {
            if newValue == .rund {
                if privLength != length || privWidth != width {
                    rectToRound() // Umrechnung von rechteckig zu rund
                    privWidth = width
                    privLength = length
                    privDiameter = diameter
                    ratio = length / width
                    scaleRoundIngredients()
                }
            } else if newValue == .eckig {
                if privDiameter != diameter {
                    roundToRect() // Umrechnung von rund zu rechteckig
                    privDiameter = diameter
                    privWidth = width
                    privLength = length
                    ratio = length / width
                    scaleRectIngredients()
                }
            }
            
            // Markieren, dass die Zutaten durch die Kuchenform geändert wurden
            isFormUpdatingIngredients = true
            summary.calculate(from: ingredients)
        }
    }
    
    private func cakeSelectionView(for width: CGFloat) -> some View {
        VStack {
            Picker("Kuchenform", selection: $cakeFormSelection) {
                Text("Eckig").tag(Formen.eckig)
                Text("Rund").tag(Formen.rund)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: cakeFormSelection, perform: updateCakeForm)
            
            // Dynamische Anordnung je nach Bildschirmbreite
            if width > 600 {
                HStack {
                    cakeSizeInputFields
                    VStack {
                        recipeEditButton
                        resetScale()
                    }
                }
            } else {
                VStack {
                    cakeSizeInputFields
                    VStack {
                        recipeEditButton
                        resetScale()
                    }
                }
            }
        }
    }
    
    private var cakeSizeInputFields: some View {
        Group {
            if cakeFormSelection == .rund {
                HStack {
                    Text("Durchmesser (cm):")
                    TextField("Durchmesser", text: Binding(
                        get: { "\(diameter)" },
                        set: { if let value = Double($0) { diameter = value } }
                    ))
                    .keyboardType(.decimalPad)
                    .onSubmit {
                        scaleRoundIngredients()
                        summary.calculate(from: ingredients)
                    }
                }
            } else {
                HStack {
                    Text("Länge (cm):")
                    TextField("Länge", text: Binding(
                        get: { "\(length)" },
                        set: { if let value = Double($0) { length = value } }
                    ))
                    .keyboardType(.decimalPad)
                    .onSubmit {
                        ratio = length / width
                        scaleRectIngredients()
                        summary.calculate(from: ingredients)
                    }
                    
                    Text("Breite (cm):")
                    TextField("Breite", text: Binding(
                        get: { "\(width)" },
                        set: { if let value = Double($0) { width = value } }
                    ))
                    .keyboardType(.decimalPad)
                    .onSubmit {
                        ratio = length / width
                        scaleRectIngredients()
                        summary.calculate(from: ingredients)
                    }
                }
            }
        }
    }

    private var recipeEditButton: some View {
        NavigationLink(destination: RecipeCreationView(recipe: recipe, modelView: modelView, onSave: {
            refreshID = UUID()
            loadRecipe(recipe)
            summary.calculate(from: ingredients)
        })) {
            CardView {
                Text("Rezept Bearbeiten")
            }
            .frame(maxWidth: 200)
        }
    }
    
    private var shoppingListButton: some View {
        Button(action: {
            createShoppingList()
            fetchReminderLists()
            showingReminderSheet = true
        }) {
            Text("Einkaufsliste zu Erinnerungen hinzufügen")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding()
    }
  
    @ViewBuilder
    func Kochmodus() -> some View {
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
            if let index = shoppingList.firstIndex(where: { $0.food == ingredient.food }) {
                shoppingList[index].quantity += ingredient.quantity
            } else {
                shoppingList.append(ingredient)
            }
        }
    }

    func fetchReminderLists() {
        eventStore.requestFullAccessToReminders { granted, _ in
            guard granted else { return }
               
            let calendars = eventStore.calendars(for: .reminder)
            DispatchQueue.main.async {
                self.availableReminderLists = calendars
            }
        }
    }

    func addShoppingListToReminders() {
        guard let reminderList = selectedReminderList else { return }

        for item in shoppingList {
            findRemindersForItem(item, in: reminderList) { existingReminders in
                if let existingReminders = existingReminders, !existingReminders.isEmpty {
                    updateExistingReminders(existingReminders, with: item)
                } else {
                    let reminder = EKReminder(eventStore: eventStore)
                    reminder.title = "\(item.quantity) " + item.unit.rawValue + " " + item.food.name
                    reminder.calendar = reminderList
                       
                    do {
                        try eventStore.save(reminder, commit: true)
                    } catch {
                        print("Fehler beim Speichern der Erinnerung: \(error.localizedDescription)")
                    }
                }
            }
        }

        isReminderAdded = true
        showingReminderSheet = false
        print("Einkaufsliste zur Erinnerungen-App hinzugefügt.")
    }

    func findRemindersForItem(_ item: FoodItemStruct, in reminderList: EKCalendar?, completion: @escaping ([EKReminder]?) -> Void) {
        guard let reminderList = reminderList else { completion(nil); return }
           
        eventStore.requestFullAccessToReminders { granted, _ in
            if granted {
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

    func updateExistingReminders(_ reminders: [EKReminder], with item: FoodItemStruct) {
        var shouldCreateNewReminder = true // Standardmäßig annehmen, dass eine neue Erinnerung nötig ist
        let targetUnit = item.unit
        let targetQuantity = item.quantity

        for reminder in reminders {
            // Falls es eine offene Erinnerung gibt, aktualisieren wir diese statt eine neue zu erstellen
            if !reminder.isCompleted {
                shouldCreateNewReminder = false // Es gibt bereits eine noch nicht erledigte Erinnerung, also keine neue nötig
                
                // Versuche, die vorhandene Menge aus der Erinnerung zu extrahieren
                let reminderParts = reminder.title.components(separatedBy: " ")
                guard reminderParts.count >= 3, // Mindestens: "100 g Zucker"
                      let existingQuantity = Double(reminderParts[0]),
                      let existingUnit = Unit.fromString(reminderParts[1])
                else {
                    print("⚠️ Fehler beim Lesen der offenen Erinnerung: \(reminder.title).")
                    continue
                }

                // Wenn sich die Einheit geändert hat und nicht 'Stück' ist, umrechnen
                if existingUnit != targetUnit && existingUnit != .piece && targetUnit != .piece {
                    if let convertedQuantity = Unit.convert(value: existingQuantity, from: existingUnit, to: targetUnit, density: item.food.density ?? 1.0) {
                        let newQuantity = convertedQuantity + targetQuantity
                        let newTitle = "\(newQuantity) \(targetUnit.rawValue) \(item.food.name)"
                        reminder.title = newTitle
                        print("🔄 Erinnerung aktualisiert mit umgerechneter Einheit: \(newTitle)")
                    } else {
                        print("⚠️ Konnte Einheit nicht umrechnen: \(existingUnit) -> \(targetUnit).")
                        shouldCreateNewReminder = true
                        continue
                    }
                }
                // Falls die Einheit identisch ist, einfach zusammenrechnen
                else if existingUnit == targetUnit {
                    let newQuantity = existingQuantity + targetQuantity
                    let newTitle = "\(newQuantity) \(targetUnit.rawValue) \(item.food.name)"
                    reminder.title = newTitle
                    print("✅ Erinnerung aktualisiert: \(newTitle)")
                }
                // Falls eine Mischung aus "Stück" und anderen Einheiten vorliegt, neue Erinnerung erstellen
                else {
                    print("⚠️ Stückzahlen können nicht umgerechnet werden. Neue Erinnerung wird erstellt.")
                    shouldCreateNewReminder = true
                    continue
                }

                // Aktualisierte Erinnerung speichern
                do {
                    try eventStore.save(reminder, commit: true)
                    print("✅ Erinnerung gespeichert: \(reminder.title)")
                } catch {
                    print("❌ Fehler beim Speichern der aktualisierten Erinnerung: \(error.localizedDescription)")
                }
            }
        }

        // Falls keine offene Erinnerung existierte, neue erstellen
        if shouldCreateNewReminder {
            createNewReminder(for: item)
        }
    }

    /// Erstellt eine neue Erinnerung, falls keine offene existiert
    func createNewReminder(for item: FoodItemStruct) {
        guard let reminderList = selectedReminderList else {
            print("⚠️ Keine gültige Liste ausgewählt, neue Erinnerung konnte nicht erstellt werden.")
            return
        }

        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = "\(item.quantity) \(item.unit.rawValue) \(item.food.name)"
        reminder.calendar = reminderList

        do {
            try eventStore.save(reminder, commit: true)
            print("✅ Neue Erinnerung erstellt: \(reminder.title)")
        } catch {
            print("❌ Fehler beim Speichern der neuen Erinnerung: \(error.localizedDescription)")
        }
    }
    
    @ViewBuilder
    func portionScalePlus() -> some View {
        Button(action: {
            if portion > 0 {
                if portion.truncatingRemainder(dividingBy: 1) == 0 {
                    portion += 1 // Falls ganze Zahl, normal erhöhen
                } else {
                    portion = ceil(portion) // Falls Dezimalstelle, aufrunden
                }
                scaleIngredients(portion: portion)
                summary.calculate(from: ingredients)
            }
        }, label: {
            Image(systemName: "plus.circle.fill")
        })
    }

    @ViewBuilder
    func portionScaleMinus() -> some View {
        Button(action: {
            if portion > 1 {
                if portion.truncatingRemainder(dividingBy: 1) == 0 {
                    portion -= 1 // Falls ganze Zahl, normal verringern
                } else {
                    portion = floor(portion) // Falls Dezimalstelle, abrunden
                }
                scaleIngredients(portion: portion)
                summary.calculate(from: ingredients)
            }
        }, label: {
            Image(systemName: "minus.circle.fill")
        })
    }
    
    @ViewBuilder
    func resetScale() -> some View {
        Button(action: {
            resetAllScale()
        }, label: {
            HStack {
                Image(systemName: "arrow.uturn.backward.circle.fill") // Symbol für "Zurücksetzen"
                    .resizable()
                    .frame(width: 20, height: 20)
                Text("Zurücksetzen")
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.red)
            .cornerRadius(10)
            .shadow(radius: 3)
        })
    }
    
    private func formatPortion(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value)) // Ganzzahl ohne Nachkommastellen
        } else if value * 10 == floor(value * 10) { // Prüfen, ob nur eine Dezimalstelle notwendig ist
            return String(format: "%.1f", value) // Eine Dezimalstelle
        } else {
            return String(format: "%.2f", value) // Zwei Dezimalstellen
        }
    }

    private func scaleIngredients(portion: Double) {
        if case let .Portion(portionValue) = recipe.portion {
            isFormUpdatingIngredients = true
            ingredients = Model().portionScale(portionOrigin: portionValue, portionNew: portion, foodItems: originIngredients)
        }
    }
    
    private func scaleRoundIngredients() {
        isFormUpdatingIngredients = true
        ingredients = Model().roundScale(diameterOrigin: originDiameter, diameterNew: diameter, foodItems: originIngredients)
    }

    private func scaleRectIngredients() {
        isFormUpdatingIngredients = true
        ingredients = Model().rectScale(lengthOrigin: originLength, widthOrigin: originWidth, lengthNew: length, widthNew: width, foodItems: originIngredients)
    }
    
    private func rectToRound() {
        isFormUpdatingIngredients = true
        diameter = Model().rectToRound(length: length, width: width).rounded(toPlaces: 2)
    }
    
    private func roundToRect() {
        isFormUpdatingIngredients = true
        width = Model().roundToRect(diameter: diameter, length: length).rounded(toPlaces: 2)
    }
    
    private func itemScale() {
        ingredients = Model().itemScale(foodItemsOrigin: originIngredients, foodItemsNew: ingredients)
    }
    
    private func resetScale() {
        ingredients = originIngredients
    }
    
    private func resetAllScale() {
        ingredients = originIngredients
        diameter = originDiameter
        length = originLength
        width = originWidth
        let originalPortion: Double
        if case let .Portion(portionValue) = recipe.portion {
            originalPortion = portionValue
        } else {
            originalPortion = 1
        }
        portion = originalPortion
    }
    
    private func ingriedentsScaleDia() {
        guard let firstIngredient = ingredients.first,
              let firstOriginIngredient = originIngredients.first else { return }

        // Falls die Einheit "Stück" ist, keine Umrechnung durchführen, sondern 1 als Faktor setzen
        let factor: Double
        if firstIngredient.unit == .piece {
            factor = firstIngredient.quantity / firstOriginIngredient.quantity
        } else {
            guard let convertedQuantity = Unit.convert(
                value: firstIngredient.quantity,
                from: firstIngredient.unit,
                to: firstOriginIngredient.unit
            ) else { print("⚠️ Fehler in ingriedentsScaleDia() - Ungültige Werte")
                return
            }
            
            factor = convertedQuantity / firstOriginIngredient.quantity
        }
        let originalArea = Double.pi * pow(originDiameter / 2, 2)

        let newDiameter = sqrt((originalArea * factor) / Double.pi) * 2
        if newDiameter.isNaN {
            print("⚠️ Fehler: Berechneter Durchmesser ist NaN")
            return
        }

        diameter = newDiameter
    }

    private func ingriedentsScaleWL() {
        guard let firstIngredient = ingredients.first,
              let firstOriginIngredient = originIngredients.first else { return }

        // Falls die Einheit "Stück" ist, keine Umrechnung durchführen, sondern 1 als Faktor setzen
        let factor: Double
        if firstIngredient.unit == .piece {
            factor = firstIngredient.quantity / firstOriginIngredient.quantity
        } else {
            guard let convertedQuantity = Unit.convert(
                value: firstIngredient.quantity,
                from: firstIngredient.unit,
                to: firstOriginIngredient.unit
            ) else { print("⚠️ Fehler in ingriedentsScaleWL() - Ungültige Werte")
                return
            }
            
            factor = convertedQuantity / firstOriginIngredient.quantity
//            print ("Faktor: ", factor)
        }
        let originalArea = originLength * originWidth

        if ratio <= 0 {
            print("⚠️ Fehler: Ungültiges Seitenverhältnis")
            return
        }

        let newWidth = sqrt((originalArea * factor) / ratio)
        let newLength = ratio * newWidth

        if newWidth.isNaN || newLength.isNaN {
            print("⚠️ Fehler: Berechnete Länge/Breite ist NaN")
            return
        }
//        print("neeeuuuuuue: ", newWidth, newLength)
        width = newWidth
        length = newLength
    }
    
    private func ingriedentsScalePortion() {
        guard let firstIngredient = ingredients.first,
              let firstOriginIngredient = originIngredients.first else { return }

        // Falls die Einheit "Stück" ist, keine Umrechnung durchführen, sondern 1 als Faktor setzen
        let factor: Double
        if firstIngredient.unit == .piece {
            factor = firstIngredient.quantity / firstOriginIngredient.quantity
        } else {
            guard let convertedQuantity = Unit.convert(
                value: firstIngredient.quantity,
                from: firstIngredient.unit,
                to: firstOriginIngredient.unit
            ) else { print("⚠️ Fehler in ingriedentsScalePortion() - Ungültige Werte")
                return
            }
            
            factor = convertedQuantity / firstOriginIngredient.quantity
        }
        // Originalportion aus Rezept ermitteln
        let originalPortion: Double
        if case let .Portion(portionValue) = recipe.portion {
            originalPortion = portionValue
        } else {
            originalPortion = 1
        }

        // Neue Portion berechnen
        portion = factor * originalPortion
//        print("poooorrt ", portion)
    }
}

struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack {
            content
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 3)
        .padding(.horizontal)
    }
}

struct RecipeImageView: View {
    var imagePath: String?
    
    var body: some View {
//        Text(imagePath ?? "ccccccc")
        
        if let fileName = imagePath { // fileName ist die Rezept-ID
            let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let fileURL = applicationSupport.appendingPathComponent(fileName) // ✅ Nur Dateiname verwenden!

            if FileManager.default.fileExists(atPath: fileURL.path),
               let uiImage = UIImage(contentsOfFile: fileURL.path)
            {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .onAppear {
                        print("Bild geladen: \(fileURL.path)")
                    }
            } else {
                if let imageName = imagePath {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity, maxHeight: 200)
                } else {
                    Text("Bild nicht gefunden!")
                        .foregroundColor(.red)
                        .padding()
                        .onAppear {
                            print("Bild nicht gefunden: \(fileURL.path)")
                        }
                }
            }
        } else {
            Text("Bild nicht verfügbar")
                .foregroundColor(.secondary)
                .padding()
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
            HStack {
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
    @Binding var ingredients: [FoodItemStruct] // Zutaten als @State
    @State var orignIngredients: [FoodItemStruct]
    @State private var selectedIngredient: FoodItemStruct? = nil // Direkte Referenz zur bearbeiteten Zutat
    @State private var editedQuantity: String = "" // Temporär bearbeitete Menge
    @State private var selectedUnit: Unit = .gram // Temporär bearbeitete Einheit
    @State private var selectedFood: FoodStruct? = nil
    var modelView : ViewModel
   
    
    init(ingredients: Binding<[FoodItemStruct]>, modelView: ViewModel) {
        self._ingredients = ingredients
        self.orignIngredients = ingredients.wrappedValue
        self.modelView = modelView
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
                                       .onLongPressGesture {
                                           selectedFood = ingredients[index].food
//                                           print("iiiiii",ingredients[index].food.nutritionFacts?.protein)
                                       }
                               
                               .sheet(item: $selectedFood) { food in
                                   FoodDetailView(food: food, modelView: modelView)
                                  
                               }
                        
                        HStack {
                            Text("\(ingredients[index].quantity.rounded(toPlaces: 2).formatted(toPlaces: 2))")
                                .font(.subheadline)
                            
                            Text(ingredients[index].unit.rawValue)
                                .font(.subheadline)
                        }
                        .onLongPressGesture {
                            preparePopup(for: index)
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
        for i in ingredients.indices where i != index {
            if ingredients[i].unit != .piece{
                ingredients[i].quantity = Unit.convert(value: adjustmentFactor * orignIngredients[i].quantity, from: orignIngredients[i].unit, to: ingredients[i].unit, density: ingredients[i].food.density ?? 0) ?? ingredients[i].quantity
            } else {
                ingredients[i].quantity = adjustmentFactor * orignIngredients[i].quantity
            }
        }
    }
}

import SwiftUI

struct RecipeInstructionsView: View {
    var instructions: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Anleitung")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 5)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(instructions.enumerated()), id: \.element) { index, instruction in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1).")
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                        Text(instruction)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
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
