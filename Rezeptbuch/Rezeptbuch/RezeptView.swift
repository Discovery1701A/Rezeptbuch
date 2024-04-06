//
//  RezeptView.swift
//  Rezeptbuch
//https://medium.com/@rohit.jankar/using-swift-a-guide-to-adding-reminders-in-the-ios-reminder-app-with-the-eventkit-api-020b2e6b38bb
//  Created by Anna Rieckmann on 10.03.24.
//
import SwiftUI
import EventKit

struct RecipeView: View {
    var recipe: Recipe
        var originIngriedents: [FoodItem]
        @State private var ingredients: [FoodItem]
        @State private var shoppingList: [FoodItem] = []
        @State private var isReminderAdded = false
        let eventStore = EKEventStore()
        @State private var portion: Double
        
        // Für den Picker
    @State private var cakeFormSelection : Formen
    @State private var diameter : Double
    @State private var lenght : Double
    @State private var width : Double
    @State private var originDiameter : Double
    @State private var originLenght : Double
    @State private var originWidth : Double
        
    init(recipe: Recipe) {
        self.recipe = recipe
        self.originIngriedents = recipe.ingredients
        self._ingredients = State(initialValue: originIngriedents)
       
        if case let .Portion(portionValue) = recipe.portion {
            self.portion = portionValue
        } else {
            self.portion = 0.0
        }
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
     
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .center, spacing: 10) {
                    Text(recipe.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    Divider().padding(.horizontal, 16)
                    if let imageName = recipe.image {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                            .padding(.top, 10)
                            .frame(maxWidth: .infinity, maxHeight: 200)
                    }
                    
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
                                                Text("Rund").tag(Formen.rund)
                                                Text("Eckig").tag(Formen.eckig)
                                            }
                                            .pickerStyle(SegmentedPickerStyle())
                                            .padding()
                                            .onChange(of: cakeFormSelection) { newValue in
                                                if newValue == Formen.rund{
                                                    rectToRound()
                                                    scaleRoundIngredients()
                                                } else if newValue == Formen.eckig{
                                                    roundToRect()
                                                    scaleRectIngredients()
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
                                .keyboardType(.decimalPad)
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
                                
                                .keyboardType(.decimalPad)
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
                                .keyboardType(.decimalPad)
                                .onChange(of: lenght) { newValue in
                                    scaleRectIngredients()
                                
                            }
                            }
                            
                            
                            
                        }
                                        }
               
                    
                    VStack(alignment: .center, spacing: 5) {
                        Text("Zutaten:")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        Divider().padding(.horizontal, 16)
                        ForEach(ingredients, id: \.self) { ingredient in
                            Text("\(ingredient.quantity.rounded(toPlaces: 2))" + ingredient.unit.rawValue + " " + ingredient.food.name)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 10)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(minHeight: 30)
                                .frame(width : geometry.size.width*0.6)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                                .padding(.vertical, 5)
                                .onChange(of: ingredient) { newValue in
                                    itemScale()
                                
                            }
                            Divider().padding(.horizontal, 16)
                        }
                    }
                    
                    VStack(alignment: .center, spacing: 5) {
                        Text("Anleitung:")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        Divider().padding(.horizontal, 16)
                        ForEach(recipe.instructions, id: \.self) { instruction in
                            Text("\(instruction)")
                                .foregroundColor(.blue)
                                .padding(.horizontal)
                                .padding(.vertical,10)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(width : geometry.size.width*0.9)
                                .background(RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1))
                                .padding(.vertical, 5)
                            Divider().padding(.horizontal, 16)
                        }
                    }
                    NavigationLink(destination: CookingModeView(recipe: recipe)) {
                                                Text("Zum Kochmodus")
                                                    .padding()
                                                    .foregroundColor(.white)
                                                    .background(Color.blue)
                                                    .cornerRadius(10)
                                            }
                    Button(action: {
                        createShoppingList()
                        addShoppingListToReminders()
                    }) {
                        Text("Einkaufsliste erstellen und zu Erinnerungen hinzufügen")
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
            }
        }
        .alert(isPresented: $isReminderAdded) {
            Alert(
                title: Text("Erinnerungen hinzugefügt"),
                message: Text("Die Einkaufsliste wurde zu den Erinnerungen hinzugefügt."),
                primaryButton: .default(Text("Öffnen"), action: {
                    // Öffnen Sie die Erinnerungs-App
                    if let url = URL(string: "x-apple-reminderkit://") {
                        UIApplication.shared.open(url)
                    }
                }),
                secondaryButton: .cancel(Text("OK"))
            )
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
       
        
        if #available(iOS 17.0, *) {
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
                                            print(item.food.name)
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
       
    func findRemindersForItem(_ item: FoodItem, in reminderList: EKCalendar?, completion: @escaping ([EKReminder]?) -> Void) {
        guard let reminderList = reminderList else { completion(nil); return }
       
        if #available(iOS 17.0, *) {
            
            eventStore.requestFullAccessToReminders() { granted, error in
                if granted {
                    print("ja")
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

    func updateExistingReminders(_ reminders: [EKReminder], with item: FoodItem, in eventStore: EKEventStore) {
        
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
