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
    var ingredients: [FoodItem]
    @State private var shoppingList: [FoodItem] = []
    @State private var isReminderAdded = false
    let eventStore = EKEventStore()
    init(recipe: Recipe) {
        self.recipe = recipe
        self.ingredients = recipe.ingredients
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
                    
                    VStack(alignment: .center, spacing: 5) {
                        Text("Zutaten:")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        Divider().padding(.horizontal, 16)
                        ForEach(ingredients, id: \.self) { ingredient in
                            Text("\(ingredient.quantity)" + ingredient.unit.rawValue + " " + ingredient.food.name)
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
           for ingredient in recipe.ingredients {
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

   }
