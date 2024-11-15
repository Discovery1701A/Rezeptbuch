import sqlite3
import uuid

# Verbindung zur SQLite-Datenbank herstellen (erstellt die Datei, falls nicht vorhanden)
conn = sqlite3.connect('/Users/annarieckmann/Documents/GitHub/Rezeptbuch/Rezeptbuch.sqlite')
cursor = conn.cursor()

# Tabellen erstellen, falls sie noch nicht existieren
cursor.execute('''
    CREATE TABLE IF NOT EXISTS Food (
        id TEXT PRIMARY KEY,
        name TEXT,
        category TEXT,
        info TEXT
               
    )
''')

cursor.execute('''
    CREATE TABLE IF NOT EXISTS NutritionFacts (
        id TEXT PRIMARY KEY,
        calories INTEGER,
        protein REAL,
        carbohydrates REAL,
        fat REAL,
        food_id TEXT,
        FOREIGN KEY (food_id) REFERENCES Food(id)
    )
''')

cursor.execute('''
    CREATE TABLE IF NOT EXISTS Tag (
        id TEXT PRIMARY KEY,
        name TEXT
    )
''')

cursor.execute('''
    CREATE TABLE IF NOT EXISTS FoodTag (
        foodId TEXT,
        tagId TEXT,
        FOREIGN KEY (foodId) REFERENCES Food(id),
        FOREIGN KEY (tagId) REFERENCES Tag(id)
    )
''')

# Daten: Zutaten, Nährwerte und Tags
foods = [
    ("Zwiebel, frisch", "Gemüse", "Frische Zwiebel"),
    ("Tomaten, frisch", "Gemüse", "Frische Tomate"),
    ("Rote Paprika", "Gemüse", "Frische rote Paprika"),
    ("Karotten", "Gemüse", "Frische Karotte"),
    ("Brokkoli", "Gemüse", "Frischer Brokkoli"),
    ("Blumenkohl", "Gemüse", "Frischer Blumenkohl"),
    ("Spinat", "Gemüse", "Frischer Spinat"),
    ("Gurke", "Gemüse", "Frische Gurke"),
    ("Aubergine", "Gemüse", "Frische Aubergine"),
    ("Zucchini", "Gemüse", "Frische Zucchini"),
    ("Kartoffeln", "Gemüse", "Frische Kartoffeln"),
    ("Kürbis", "Gemüse", "Frischer Kürbis"),
    ("Knoblauch", "Gemüse", "Frischer Knoblauch"),
    ("Eisbergsalat", "Gemüse", "Frischer Eisbergsalat"),
    ("Spargel", "Gemüse", "Frischer Spargel"),
    ("Rosenkohl", "Gemüse", "Frischer Rosenkohl"),
    ("Rettich", "Gemüse", "Frischer Rettich"),
    ("Radieschen", "Gemüse", "Frische Radieschen"),
    ("Kohlrabi", "Gemüse", "Frischer Kohlrabi"),
    ("Sellerie", "Gemüse", "Frischer Sellerie")
]


nutrition_facts = [
    (31, 1.2, 4.9, 0.2),   # Zwiebel, frisch
    (20, 0.9, 3.9, 0.2),   # Tomaten, frisch
    (43, 1.3, 6.0, 0.3),   # Rote Paprika
    (41, 0.9, 9.6, 0.2),   # Karotten
    (34, 2.8, 6.6, 0.4),   # Brokkoli
    (25, 1.9, 4.9, 0.3),   # Blumenkohl
    (23, 2.9, 3.6, 0.4),   # Spinat
    (12, 0.6, 2.2, 0.1),   # Gurke
    (24, 1.0, 5.7, 0.2),   # Aubergine
    (17, 1.2, 3.1, 0.3),   # Zucchini
    (77, 2.0, 17.6, 0.1),  # Kartoffeln
    (26, 1.0, 6.5, 0.1),   # Kürbis
    (149, 6.4, 33.1, 0.5), # Knoblauch
    (14, 0.9, 2.0, 0.2),   # Eisbergsalat
    (20, 2.2, 3.9, 0.1),   # Spargel
    (43, 3.4, 9.0, 0.3),   # Rosenkohl
    (16, 0.7, 3.4, 0.1),   # Rettich
    (16, 0.7, 2.0, 0.1),   # Radieschen
    (27, 1.7, 6.2, 0.1),   # Kohlrabi
    (16, 0.7, 3.0, 0.2)    # Sellerie
]


tags = [
    ("Gemüse",),
    ("Gesund",),
    ("Kalorienarm",),
    ("Low-Carb",)
]

food_tags = [
    (0, [0, 1, 2]),    # Zwiebel
    (1, [0, 1, 3]),    # Tomaten
    (2, [0, 1]),       # Paprika
    (3, [0, 1, 2]),    # Karotten
    (4, [0, 1]),       # Brokkoli
    (5, [0, 1, 2]),    # Blumenkohl
    (6, [0, 1]),       # Spinat
    (7, [0, 2]),       # Gurke
    (8, [0, 2]),       # Aubergine
    (9, [0, 1]),       # Zucchini
    (10, [0, 1]),      # Kartoffeln
    (11, [0, 2]),      # Kürbis
    (12, [0, 1, 3]),   # Knoblauch
    (13, [0, 2]),      # Eisbergsalat
    (14, [0, 1, 2]),   # Spargel
    (15, [0, 1]),      # Rosenkohl
    (16, [0, 1]),      # Rettich
    (17, [0, 2]),      # Radieschen
    (18, [0, 1]),      # Kohlrabi
    (19, [0, 1, 2])    # Sellerie
]


# Tags in Datenbank einfügen
tag_ids = {}
for tag in tags:
    tag_id = str(uuid.uuid4())
    cursor.execute('INSERT INTO Tag (id, name) VALUES (?, ?)', (tag_id, tag[0]))
    tag_ids[tag[0]] = tag_id

# Lebensmittel und Nährwerte einfügen
for i, (food, nutrition) in enumerate(zip(foods, nutrition_facts)):
    food_id = str(uuid.uuid4())
    cursor.execute('INSERT INTO Food (id, name, category, info) VALUES (?, ?, ?, ?)', (food_id, food[0], food[1], food[2]))
    cursor.execute('INSERT INTO NutritionFacts (id, calories, protein, carbohydrates, fat, food_id) VALUES (?, ?, ?, ?, ?, ?)',
                   (str(uuid.uuid4()), nutrition[0], nutrition[1], nutrition[2], nutrition[3], food_id))
    
    # Tags zuweisen
    for tag_index in food_tags[i][1]:
        cursor.execute('INSERT INTO FoodTag (foodId, tagId) VALUES (?, ?)', (food_id, list(tag_ids.values())[tag_index]))

# Änderungen speichern und Verbindung schließen
conn.commit()
conn.close()

print("Daten wurden erfolgreich in die Datenbank eingefügt.")
