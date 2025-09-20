//
//  RezeptView.swift
//  Rezeptbuch
// 
//  Created by Anna Rieckmann on 10.03.24.
//
import EventKit
import SwiftUI
import UIKit
import WebKit

/// Ansicht zur Anzeige eines Rezepts mit Zutaten, Portionsanpassung und Einkaufsliste.
struct RecipeView: View {
    var recipe: Recipe  // Das anzuzeigende Rezept
    var modelView: ViewModel  // Das ViewModel für die Verwaltung der Daten
    var originIngredients: [FoodItemStruct]  // Die ursprünglichen Zutaten des Rezepts
    
    // Zustände für die Zutaten- und Portionsanpassung
    @State private var info: String? = ""
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
    
    // Zustände für die Einkaufsliste und Erinnerungsfunktion
    @State private var shoppingList: [FoodItemStruct] = []
    @State private var isReminderAdded = false
    @State private var showingReminderSheet = false
    @State private var availableReminderLists: [EKCalendar] = []
    @State private var selectedReminderList: EKCalendar?
    @State private var newListName: String = ""
    
    // Zustände für die Teilen-Funktion und UI-Aktualisierungen
    @State private var showingShareSheet = false
    @State private var isFormUpdatingIngredients = false
    @State private var refreshID = UUID()  // Nutzt `UUID`, um die View zu erzwingen, sich neu zu laden
    
    let eventStore = EKEventStore()  // Zugriff auf das Erinnerungs-Framework
    @State private var summary = NutritionSummary()  // Berechnung der Nährwerte
    
    /// Initialisiert die Ansicht mit einem Rezept und dem zugehörigen ViewModel.
    init(recipe: Recipe, modelView: ViewModel) {
        self.recipe = recipe
        self.modelView = modelView
        self.originIngredients = recipe.ingredients.sorted{ $0.number ?? 0 < $1.number ?? 1 }
        _ingredients = State(initialValue: recipe.ingredients.sorted { $0.number ?? 0 < $1.number ?? 1 })
        loadRecipe(recipe)  // Lädt die Rezeptdaten direkt bei der Initialisierung
        summary.calculate(from: ingredients)  // Berechnet die Nährwerte basierend auf den Zutaten
    }
    
    /// Lädt das Rezept und setzt die Werte für Portionen und Kuchenformen.
    private func loadRecipe(_ recipe: Recipe) {
        DispatchQueue.main.async {
            self.ingredients = recipe.ingredients.sorted { $0.number ?? 0 < $1.number ?? 1 }  // Zutaten aktualisieren
            
            // Setzt die Portionsgröße, falls vorhanden
            if case let .Portion(portionValue) = recipe.portion {
                self.portion = portionValue
            } else {
                self.portion = 0.0
            }
            self.info = recipe.info
            // Falls das Rezept ein Kuchen ist, wird die Form und Größe angepasst
            if case let .cake(form, size) = recipe.cake {
                self.cakeFormSelection = form
                
                switch size {
                case let .rectangular(length, width):
                    self.length = length
                    self.width = width
                    self.diameter = (sqrt((length * width) / Double.pi) * 2).rounded(toPlaces: 2)
                    
                    // Speichert die Originalwerte für spätere Berechnungen
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
                    self.resetCakeValues()  // Falls keine Form erkannt wird, setze Standardwerte
                }
            } else {
                self.resetCakeValues()  // Falls das Rezept kein Kuchen ist, setze Standardwerte
            }
        }
    }
    
    /// Setzt die Werte für die Kuchenform auf Standardwerte zurück.
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
    /// Extrahiert die YouTube-Video-ID aus einem YouTube-Link.
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
                    
                    // Rezeptbild
                    RecipeImageView(imagePath: recipe.image)
                    
                    // Tags anzeigen, falls vorhanden
                    if let tags = recipe.tags, !tags.isEmpty {
                        RecipeTagsView(tags: tags)
                    }
                    Divider().padding(.horizontal, 16)
                    InfoView(info:info)
                    
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
                    
                    // Nährwerte des Rezepts
                    NutritionSummaryView(summary: summary)
                    
                    Divider().padding(.horizontal, 16)
                    
                    // Zutatenliste
                    RecipeIngredientsView(ingredients: $ingredients, modelView: modelView)
                        .onChange(of: ingredients) { newIngredients in
                            updateIngredients(newIngredients)
                        }
                    
                    Divider().padding(.horizontal, 16)
                    
                    // Anweisungen & Video
                    RecipeInstructionsView(instructions: recipe.instructions)
                    
                    // Falls ein Video-Link vorhanden ist, wird das Video angezeigt
                    if let videoLink = recipe.videoLink, !videoLink.isEmpty {
                        Divider().padding(.horizontal, 16)
                        RecipeVideoView(videoLink: videoLink)
                    }
                    
                    Divider().padding(.horizontal, 16)
                    
                    // Kochmodus & Einkaufsliste-Button
                    Kochmodus()
                    shoppingListButton
                }
                // Erinnerungen-Auswahl anzeigen
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
                    loadRecipe(recipe)  // Rezeptdaten beim Laden der Ansicht setzen
                    summary.calculate(from: ingredients)  // Nährwerte aktualisieren
                }
                .id(refreshID)  // Erzwingt UI-Updates bei Änderungen
                .onChange(of: recipe) { newRecipe in
                    loadRecipe(newRecipe)  // Aktualisiert das Rezept
                    summary.calculate(from: ingredients)  // Berechnet die Nährwerte erneut
                }
            }
        }
    }
    
    /// Der Header mit Rezepttitel und Teilen-Button.
    private var recipeHeader: some View {
        ZStack {
            // Rezept-Titel in der Mitte
            Text(recipe.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Teilen-Button am rechten Rand
            ShareSheetView(recipe: recipe)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 16)
    }
    /// Ansicht zur Anpassung der Portionsgröße.
    private func portionView(for width: CGFloat) -> some View {
        VStack {
            Text("Portionen:")
            
            HStack {
                Spacer()
                portionScaleMinus()  // Verringert die Portionsgröße
                Text(formatPortion(portion))  // Zeigt die aktuelle Portionsgröße an
                portionScalePlus()  // Erhöht die Portionsgröße
                Spacer()
            }
            
            HStack {
                recipeEditButton  // Button zum Bearbeiten des Rezepts
                resetScale()  // Setzt die Portionsgröße zurück
            }
        }
    }
    
    /// Aktualisiert die Zutaten basierend auf den Änderungen der Portionen oder der Kuchenform.
    private func updateIngredients(_ newIngredients: [FoodItemStruct]) {
        DispatchQueue.main.async {
            // Falls die Änderung durch die Kuchenform kommt, wird sie ignoriert
            guard !isFormUpdatingIngredients else {
                isFormUpdatingIngredients = false  // Status zurücksetzen
                return
            }
            
            print("Zutaten haben sich geändert: \(newIngredients)")
            
            // Skaliert die Zutaten basierend auf der Portionsgröße
            if recipe.portion != .notPortion {
                ingriedentsScalePortion()
            }
            
            // Skaliert die Zutaten basierend auf der Kuchenform
            if recipe.cake != .notCake {
                if cakeFormSelection == .rund {
                    ingriedentsScaleDia()  // Skaliert Zutaten für runde Kuchen
                } else if cakeFormSelection == .eckig {
                    ingriedentsScaleWL()  // Skaliert Zutaten für rechteckige Kuchen
                }
            }
            
            // Aktualisiert die Nährwertberechnung
            summary.calculate(from: ingredients)
        }
    }
    
    /// Aktualisiert die Kuchenform und passt die Zutaten entsprechend an.
    private func updateCakeForm(_ newValue: Formen) {
        DispatchQueue.main.async {
            if newValue == .rund {
                // Falls sich Länge oder Breite geändert hat, wird die Form von rechteckig zu rund umgerechnet
                if privLength != length || privWidth != width {
                    rectToRound()
                    privWidth = width
                    privLength = length
                    privDiameter = diameter
                    ratio = length / width
                    scaleRoundIngredients()  // Zutaten für runde Kuchenform anpassen
                }
            } else if newValue == .eckig {
                // Falls sich der Durchmesser geändert hat, wird die Form von rund zu rechteckig umgerechnet
                if privDiameter != diameter {
                    roundToRect()
                    privDiameter = diameter
                    privWidth = width
                    privLength = length
                    ratio = length / width
                    scaleRectIngredients()  // Zutaten für rechteckige Kuchenform anpassen
                }
            }
            
            // Markieren, dass die Zutaten durch die Kuchenform geändert wurden
            isFormUpdatingIngredients = true
            summary.calculate(from: ingredients)
        }
    }
    
    /// Ansicht zur Auswahl der Kuchenform und Größenanpassung.
    private func cakeSelectionView(for width: CGFloat) -> some View {
        VStack {
            // Auswahl der Kuchenform (rund oder rechteckig)
            Picker("Kuchenform", selection: $cakeFormSelection) {
                Text("Eckig").tag(Formen.eckig)
                Text("Rund").tag(Formen.rund)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: cakeFormSelection, perform: updateCakeForm)  // Aktualisiert die Kuchenform
            
            // Dynamische Anordnung der Eingabefelder je nach Bildschirmbreite
            if width > 600 {
                HStack {
                    cakeSizeInputFields  // Eingabefelder für Größe der Kuchenform
                    VStack {
                        recipeEditButton  // Button zum Bearbeiten des Rezepts
                        resetScale()  // Setzt die Skala zurück
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
    
    /// Eingabefelder für die Kuchenform-Abmessungen (rund oder rechteckig).
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
                        scaleRoundIngredients()  // Zutaten für runde Form skalieren
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
                        scaleRectIngredients()  // Zutaten für rechteckige Form skalieren
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
                        scaleRectIngredients()  // Zutaten für rechteckige Form skalieren
                        summary.calculate(from: ingredients)
                    }
                }
              
            }
        }
    }
    /// Button zum Bearbeiten eines Rezepts.
    private var recipeEditButton: some View {
        NavigationLink(destination: RecipeCreationView(recipe: recipe, modelView: modelView, onSave: {
            refreshID = UUID()  // Erzwingt ein UI-Update
            loadRecipe(recipe)  // Lädt das Rezept neu
            summary.calculate(from: ingredients)  // Aktualisiert die Nährwerte
        })) {
            CardView {
                Text("Rezept Bearbeiten")
            }
            .frame(maxWidth: 200)
        }
    }
    
    /// Button zum Hinzufügen der Einkaufsliste zur Erinnerungen-App.
    private var shoppingListButton: some View {
        Button(action: {
            createShoppingList()  // Erstellt die Einkaufsliste
            fetchReminderLists()  // Lädt die Erinnerungslisten
            showingReminderSheet = true  // Öffnet die Erinnerungs-Auswahl
        }) {
            Text("Einkaufsliste zu Erinnerungen hinzufügen")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding()
    }
    
    /// Button für den Kochmodus.
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
    
    /// Erstellt eine Einkaufsliste, indem gleiche Zutatenmengen summiert werden.
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
    
    /// Lädt die verfügbaren Erinnerungslisten vom Event Store.
    func fetchReminderLists() {
        eventStore.requestFullAccessToReminders { granted, _ in
            guard granted else { return }
            let calendars = eventStore.calendars(for: .reminder)
            DispatchQueue.main.async {
                self.availableReminderLists = calendars
            }
        }
    }
    
    /// Fügt die Einkaufsliste zu einer ausgewählten Erinnerungs-Liste hinzu.
    func addShoppingListToReminders() {
        guard let reminderList = selectedReminderList else { return }
        
        for item in shoppingList {
            findRemindersForItem(item, in: reminderList) { existingReminders in
                if let existingReminders = existingReminders, !existingReminders.isEmpty {
                    updateExistingReminders(existingReminders, with: item)
                } else {
                    createNewReminder(for: item)
                }
            }
        }
        
        isReminderAdded = true
        showingReminderSheet = false
        print("✅ Einkaufsliste zur Erinnerungen-App hinzugefügt.")
    }
    
    /// Sucht nach bestehenden Erinnerungen zu einem bestimmten Artikel.
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
                print("⚠️ Zugriff auf Erinnerungen verweigert.")
                completion(nil)
            }
        }
    }
    
    /// Aktualisiert eine vorhandene Erinnerung, falls dieselbe Zutat bereits existiert.
    func updateExistingReminders(_ reminders: [EKReminder], with item: FoodItemStruct) {
        var shouldCreateNewReminder = true  // Standardmäßig neue Erinnerung erstellen
        let targetUnit = item.unit
        let targetQuantity = item.quantity
        
        for reminder in reminders {
            if !reminder.isCompleted {
                shouldCreateNewReminder = false  // Falls eine offene Erinnerung existiert, diese aktualisieren
                
                // Zerlege den Titel der Erinnerung in Bestandteile (z. B. "100 g Zucker")
                let reminderParts = reminder.title.components(separatedBy: " ")
                guard reminderParts.count >= 3,  // Erwartetes Format: "Menge Einheit Name"
                      let existingQuantity = Double(reminderParts[0]),
                      let existingUnit = Unit.fromString(reminderParts[1])
                else {
                    print("⚠️ Fehler beim Lesen der offenen Erinnerung: \(reminder.title).")
                    continue
                }
                
                // Falls die Einheit unterschiedlich ist (außer "Stück"), versuche umzurechnen
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
                // Falls die Einheit identisch ist, Mengen addieren
                else if existingUnit == targetUnit {
                    let newQuantity = existingQuantity + targetQuantity
                    let newTitle = "\(newQuantity) \(targetUnit.rawValue) \(item.food.name)"
                    reminder.title = newTitle
                    print("✅ Erinnerung aktualisiert: \(newTitle)")
                }
                // Falls eine Mischung aus "Stück" und anderen Einheiten vorliegt, erstelle eine neue Erinnerung
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
    
    
    /// Erstellt eine neue Erinnerung für eine Zutat.
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
    
    /// Erhöht die Portionsgröße um 1 oder rundet auf die nächste ganze Zahl auf.
    @ViewBuilder
    func portionScalePlus() -> some View {
        Button(action: {
            if portion > 0 {
                if portion.truncatingRemainder(dividingBy: 1) == 0 {
                    portion += 1  // Falls ganze Zahl, normal erhöhen
                } else {
                    portion = ceil(portion)  // Falls Dezimalstelle, aufrunden
                }
                scaleIngredients(portion: portion)  // Zutaten anpassen
                summary.calculate(from: ingredients)  // Nährwerte neu berechnen
            }
        }, label: {
            Image(systemName: "plus.circle.fill")
        })
    }
    
    /// Verringert die Portionsgröße um 1 oder rundet auf die nächste ganze Zahl ab.
    @ViewBuilder
    func portionScaleMinus() -> some View {
        Button(action: {
            if portion > 1 {
                if portion.truncatingRemainder(dividingBy: 1) == 0 {
                    portion -= 1  // Falls ganze Zahl, normal verringern
                } else {
                    portion = floor(portion)  // Falls Dezimalstelle, abrunden
                }
                scaleIngredients(portion: portion)  // Zutaten anpassen
                summary.calculate(from: ingredients)  // Nährwerte neu berechnen
            }
        }, label: {
            Image(systemName: "minus.circle.fill")
        })
    }
    
    /// Setzt die Zutaten, Portionsgröße und Kuchenmaße auf ihre ursprünglichen Werte zurück.
    @ViewBuilder
    func resetScale() -> some View {
        Button(action: {
            resetAllScale()
        }, label: {
            HStack {
                Image(systemName: "arrow.uturn.backward.circle.fill")  // Symbol für "Zurücksetzen"
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
    
    /// Formatiert die Portionsgröße je nach Anzahl der Dezimalstellen.
    private func formatPortion(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))  // Ganze Zahl ohne Nachkommastellen
        } else if value * 10 == floor(value * 10) {  // Prüft, ob nur eine Dezimalstelle nötig ist
            return String(format: "%.1f", value)  // Eine Nachkommastelle
        } else {
            return String(format: "%.2f", value)  // Zwei Nachkommastellen
        }
    }
    
    /// Skaliert die Zutaten basierend auf der neuen Portionsgröße.
    private func scaleIngredients(portion: Double) {
        if case let .Portion(portionValue) = recipe.portion {
            isFormUpdatingIngredients = true
            ingredients = Model().portionScale(portionOrigin: portionValue, portionNew: portion, foodItems: originIngredients)
        }
    }
    
    /// Skaliert Zutaten, wenn der Durchmesser für runde Kuchen geändert wird.
    private func scaleRoundIngredients() {
        isFormUpdatingIngredients = true
        ingredients = Model().roundScale(diameterOrigin: originDiameter, diameterNew: diameter, foodItems: originIngredients)
    }
    
    /// Skaliert Zutaten, wenn die Länge und Breite für rechteckige Kuchen geändert werden.
    private func scaleRectIngredients() {
        isFormUpdatingIngredients = true
        ingredients = Model().rectScale(lengthOrigin: originLength, widthOrigin: originWidth, lengthNew: length, widthNew: width, foodItems: originIngredients)
    }
    
    /// Berechnet den Durchmesser für eine runde Kuchenform basierend auf einer rechteckigen Form.
    private func rectToRound() {
        isFormUpdatingIngredients = true
        diameter = Model().rectToRound(length: length, width: width).rounded(toPlaces: 2)
    }
    
    /// Berechnet die Breite für eine rechteckige Kuchenform basierend auf einer runden Form.
    private func roundToRect() {
        isFormUpdatingIngredients = true
        width = Model().roundToRect(diameter: diameter, length: length).rounded(toPlaces: 2)
    }
    
    /// Aktualisiert die Zutaten nach Skalierung.
    private func itemScale() {
        ingredients = Model().itemScale(foodItemsOrigin: originIngredients, foodItemsNew: ingredients)
    }
    
    /// Setzt die Zutaten auf ihre ursprünglichen Mengen zurück.
    private func resetScale() {
        ingredients = originIngredients
    }
    
    /// Setzt die gesamten Skalierungswerte (Portionen, Kuchenform, Zutaten) zurück.
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
    
    /// Skaliert die Zutaten für einen runden Kuchen basierend auf dem Durchmesser.
    private func ingriedentsScaleDia() {
        guard let firstIngredient = ingredients.first,
              let firstOriginIngredient = originIngredients.first else { return }
        
        let factor: Double
        if firstIngredient.unit == .piece {
            factor = firstIngredient.quantity / firstOriginIngredient.quantity
        } else {
            guard let convertedQuantity = Unit.convert(
                value: firstIngredient.quantity,
                from: firstIngredient.unit,
                to: firstOriginIngredient.unit
            ) else {
                print("⚠️ Fehler in ingriedentsScaleDia() - Ungültige Werte")
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
    
    /// Skaliert die Zutaten basierend auf der Länge und Breite eines rechteckigen Kuchens.
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
            ) else {
                print("⚠️ Fehler in ingriedentsScaleWL() - Ungültige Werte")
                return
            }
            
            factor = convertedQuantity / firstOriginIngredient.quantity
        }
        
        // Berechnung der ursprünglichen Fläche
        let originalArea = originLength * originWidth
        
        if ratio <= 0 {
            print("⚠️ Fehler: Ungültiges Seitenverhältnis")
            return
        }
        
        // Neue Breite berechnen
        let newWidth = sqrt((originalArea * factor) / ratio)
        let newLength = ratio * newWidth
        
        if newWidth.isNaN || newLength.isNaN {
            print("⚠️ Fehler: Berechnete Länge/Breite ist NaN")
            return
        }
        
        width = newWidth
        length = newLength
    }
    
    /// Skaliert die Zutaten basierend auf einer neuen Portionsgröße.
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
            ) else {
                print("⚠️ Fehler in ingriedentsScalePortion() - Ungültige Werte")
                return
            }
            
            factor = convertedQuantity / firstOriginIngredient.quantity
        }
        
        // Originalportion aus dem Rezept ermitteln
        let originalPortion: Double
        if case let .Portion(portionValue) = recipe.portion {
            originalPortion = portionValue
        } else {
            originalPortion = 1
        }
        
        // Neue Portion berechnen
        portion = factor * originalPortion
    }
    
}



extension Double {
    /// Formatiert eine Double-Zahl je nach Nachkommastellen:
    /// - entfernt Nachkommastellen, wenn .00
    /// - zeigt eine Stelle, wenn zweite eine 0 ist (z. B. 12.50 → 12.5)
    /// - zeigt zwei Stellen, wenn beide relevant sind
    func cleanFormatted() -> String {
        let rounded = self.rounded(toPlaces: 2)
        let intPart = Int(rounded)
        let firstDecimal = Int((rounded * 10).truncatingRemainder(dividingBy: 10))
        let secondDecimal = Int((rounded * 100).truncatingRemainder(dividingBy: 10))

        if rounded == Double(intPart) {
            return "\(intPart)"
        } else if secondDecimal == 0 {
            return String(format: "%.1f", rounded)
        } else {
            return String(format: "%.2f", rounded)
        }
    }
}
