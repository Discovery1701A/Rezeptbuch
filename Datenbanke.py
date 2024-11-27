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



# Daten: Zutaten, Nährwerte und Tags
foods = [
    ("Zwiebel, frisch", "Gemüse", "Frische Zwiebel mit scharfen Geschmack, reich an Antioxidantien und wichtigen Nährstoffen, die für das Immunsystem förderlich sind."),
    ("Tomaten, frisch", "Gemüse", "Frische Tomate, reich an Lycopin, Vitamin C und Antioxidantien, ideal für Salate und Saucen."),
    ("Rote Paprika", "Gemüse", "Frische rote Paprika, reich an Vitamin C und Beta-Carotin, gut für das Immunsystem und die Augen."),
    ("Karotten", "Gemüse", "Frische Karotte, reich an Beta-Carotin und Ballaststoffen, unterstützt die Augengesundheit und die Verdauung."),
    ("Brokkoli", "Gemüse", "Frischer Brokkoli, voller Vitamine und Mineralstoffe, insbesondere Vitamin K und C, gut für die Knochengesundheit."),
    ("Blumenkohl", "Gemüse", "Frischer Blumenkohl, vielseitig verwendbar, reich an Ballaststoffen und Vitamin C, fördert die Verdauung."),
    ("Spinat", "Gemüse", "Frischer Spinat, reich an Eisen, Magnesium und Vitamin K, unterstützt die Blutbildung und Muskelfunktion."),
    ("Gurke", "Gemüse", "Frische Gurke, sehr wasserhaltig, kalorienarm und ideal zur Hydrierung und als Snack für zwischendurch."),
    ("Aubergine", "Gemüse", "Frische Aubergine, reich an Ballaststoffen und Antioxidantien, gut für das Herz und die Verdauung."),
    ("Zucchini", "Gemüse", "Frische Zucchini, kalorienarm und reich an Vitamin C und Kalium, gut für die Herzgesundheit."),
    ("Kartoffeln", "Gemüse", "Frische Kartoffeln, reich an komplexen Kohlenhydraten und Kalium, liefern langanhaltende Energie."),
    ("Kürbis", "Gemüse", "Frischer Kürbis, reich an Beta-Carotin, Vitamin A und Ballaststoffen, gut für die Augengesundheit."),
    ("Knoblauch", "Gemüse", "Frischer Knoblauch, bekannt für seine antibakteriellen Eigenschaften, gut für das Immunsystem."),
    ("Eisbergsalat", "Gemüse", "Frischer Eisbergsalat, kalorienarm und reich an Wasser, ideal für Salate und zum Hydrieren."),
    ("Spargel", "Gemüse", "Frischer Spargel, reich an Folsäure und Vitaminen, unterstützt die Entgiftung des Körpers."),
    ("Rosenkohl", "Gemüse", "Frischer Rosenkohl, reich an Ballaststoffen und Vitamin K, gut für die Verdauung und Knochengesundheit."),
    ("Rettich", "Gemüse", "Frischer Rettich, reich an Vitamin C und Senfölen, unterstützt die Verdauung und das Immunsystem."),
    ("Radieschen", "Gemüse", "Frische Radieschen, reich an Senfölen und Vitamin C, ideal für Salate und zur Verdauungsförderung."),
    ("Kohlrabi", "Gemüse", "Frischer Kohlrabi, reich an Vitamin C und Ballaststoffen, unterstützt die Verdauung und das Immunsystem."),
    ("Sellerie", "Gemüse", "Frischer Sellerie, reich an Ballaststoffen und Kalium, gut für die Verdauung und Herzgesundheit."),
    ("Lauch", "Gemüse", "Frischer Lauch, reich an Vitamin K und Folsäure, unterstützt die Knochengesundheit und die Blutbildung."),
    ("Rucola", "Gemüse", "Frischer Rucola, reich an Vitamin K und Antioxidantien, gut für die Blutgerinnung und das Immunsystem."),
    ("Fenchel", "Gemüse", "Frischer Fenchel, reich an Ballaststoffen und Vitamin C, unterstützt die Verdauung und das Immunsystem."),
    ("Grüner Paprika", "Gemüse", "Frischer grüner Paprika, reich an Vitamin C und Antioxidantien, gut für das Immunsystem."),
    ("Weißkohl", "Gemüse", "Frischer Weißkohl, reich an Vitamin C und Ballaststoffen, gut für die Verdauung und das Immunsystem."),
    ("Rotkohl", "Gemüse", "Frischer Rotkohl, reich an Vitamin C und Anthocyanen, gut für die Herzgesundheit und das Immunsystem."),
    ("Mangold", "Gemüse", "Frischer Mangold, reich an Vitamin A, C und K, unterstützt die Augengesundheit und die Blutgerinnung."),
    ("Kohlrübe", "Gemüse", "Frische Kohlrübe, reich an Ballaststoffen und Vitamin C, unterstützt die Verdauung und das Immunsystem."),
    ("Bohnen, grün", "Gemüse", "Frische grüne Bohnen, reich an Ballaststoffen und Eiweiß, gut für die Verdauung und Muskelaufbau."),
    ("Erbsen", "Gemüse", "Frische grüne Erbsen, reich an Protein und Ballaststoffen, gut für die Muskeln und die Verdauung."),
    ("Mais", "Gemüse", "Frischer Mais, reich an Ballaststoffen und Kohlenhydraten, ideal als Energielieferant."),
    ("Okra", "Gemüse", "Frische Okra, reich an Ballaststoffen und Vitamin C, unterstützt die Verdauung und das Immunsystem."),
    ("Artischocken", "Gemüse", "Frische Artischocken, reich an Ballaststoffen und Antioxidantien, fördern die Verdauung und Lebergesundheit."),
    ("Süßkartoffeln", "Gemüse", "Frische Süßkartoffeln, reich an Beta-Carotin und Ballaststoffen, gut für die Augengesundheit und das Immunsystem."),
    ("Chinakohl", "Gemüse", "Frischer Chinakohl, reich an Vitamin C und Ballaststoffen, gut für die Verdauung und das Immunsystem."),
    ("Bok Choy", "Gemüse", "Frischer Bok Choy, reich an Vitamin A, C und K, gut für die Knochengesundheit und das Immunsystem."),
    ("Kresse", "Gemüse", "Frische Kresse, reich an Vitamin C und K, ideal für Salate und gut für das Immunsystem."),
    ("Rettich, rot", "Gemüse", "Frischer roter Rettich, reich an Senfölen und Vitamin C, fördert die Verdauung und das Immunsystem."),
    ("Schwarzwurzeln", "Gemüse", "Frische Schwarzwurzeln, reich an Ballaststoffen und Vitamin E, unterstützt die Verdauung und Hautgesundheit."),
    ("Wirsing", "Gemüse", "Frischer Wirsing, reich an Vitamin K und Ballaststoffen, gut für die Blutgerinnung und Verdauung."),
    ("Endivien", "Gemüse", "Frische Endivien, reich an Folsäure und Vitamin A, gut für die Zellbildung und Augengesundheit."),
    ("Pak Choi", "Gemüse", "Frischer Pak Choi, reich an Vitamin K und C, gut für die Blutgerinnung und das Immunsystem."),
    ("Batavia-Salat", "Gemüse", "Frischer Batavia-Salat, kalorienarm und reich an Ballaststoffen, ideal für Salate und fördert die Verdauung."),
    ("Grünkohl", "Gemüse", "Frischer Grünkohl, sehr nährstoffreich, reich an Vitamin K, C und A, gut für das Immunsystem und die Knochengesundheit."),
    ("Topinambur", "Gemüse", "Frischer Topinambur, reich an Ballaststoffen und Inulin, fördert die Verdauung und unterstützt eine gesunde Darmflora."),
    ("Pastinaken", "Gemüse", "Frische Pastinaken, reich an Ballaststoffen, Vitamin C und Folsäure, unterstützen die Verdauung und das Immunsystem."),
    ("Mairübe", "Gemüse", "Frische Mairübe, kalorienarm und reich an Vitamin C, unterstützt das Immunsystem und die Verdauung."),
    ("Löwenzahnblätter", "Gemüse", "Frische Löwenzahnblätter, reich an Vitamin A, C und K, fördern die Lebergesundheit und wirken entzündungshemmend."),
    ("Portulak", "Gemüse", "Frischer Portulak, reich an Omega-3-Fettsäuren, Vitamin A und C, unterstützt die Herzgesundheit und hat antioxidative Eigenschaften."),
    ("Gartenkresse", "Gemüse", "Frische Gartenkresse, reich an Vitamin C, A und K, ideal für Salate und fördert das Immunsystem."),
    ("Radicchio", "Gemüse", "Frischer Radicchio, reich an Ballaststoffen, Vitamin K und Antioxidantien, fördert die Verdauung und unterstützt die Knochengesundheit."),
    ("Chicorée", "Gemüse", "Frischer Chicorée, reich an Ballaststoffen und Folsäure, unterstützt die Verdauung und hilft bei der Entgiftung des Körpers."),
    ("Sauerampfer", "Gemüse", "Frischer Sauerampfer, reich an Vitamin C und Antioxidantien, unterstützt das Immunsystem und wirkt antioxidativ."),
    ("Brunnenkresse", "Gemüse", "Frische Brunnenkresse, reich an Vitamin K, C und A, wirkt antioxidativ und fördert die Blutgerinnung."),
    ("Bambussprossen", "Gemüse", "Frische Bambussprossen, kalorienarm, reich an Ballaststoffen und fördern die Verdauung."),
    ("Zuckerschoten", "Gemüse", "Frische Zuckerschoten, reich an Ballaststoffen und Vitamin C, ideal als Snack und gut für das Immunsystem."),
    ("Schalotten", "Gemüse", "Frische Schalotten, mild im Geschmack, reich an Antioxidantien und gut für das Immunsystem."),
    ("Knollensellerie", "Gemüse", "Frischer Knollensellerie, reich an Ballaststoffen, Vitamin K und C, unterstützt die Verdauung und fördert die Herzgesundheit."),
    ("Romanesco", "Gemüse", "Frischer Romanesco, reich an Vitamin C, K und Ballaststoffen, unterstützt die Verdauung und das Immunsystem."),
    ("Meerrettich", "Gemüse", "Frischer Meerrettich, reich an Vitamin C und Senfölen, wirkt antibakteriell und unterstützt das Immunsystem.")
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
    (16, 0.7, 3.0, 0.2),   # Sellerie
    (31, 2.1, 6.1, 0.3),   # Lauch
    (25, 2.6, 3.7, 0.7),   # Rucola
    (31, 1.2, 7.3, 0.2),   # Fenchel
    (20, 0.9, 4.6, 0.1),   # Grüner Paprika
    (25, 1.3, 5.8, 0.1),   # Weißkohl
    (29, 1.4, 6.7, 0.2),   # Rotkohl
    (19, 1.8, 3.7, 0.2),   # Mangold
    (37, 1.1, 8.6, 0.3),   # Kohlrübe
    (31, 1.8, 7.0, 0.1),   # Bohnen, grün
    (81, 5.4, 14.5, 0.4),  # Erbsen
    (86, 3.3, 19.0, 1.2),  # Mais
    (33, 2.0, 7.0, 0.1),   # Okra
    (47, 3.3, 10.5, 0.2),  # Artischocken
    (86, 1.6, 20.0, 0.1),  # Süßkartoffeln
    (13, 1.1, 2.2, 0.1),   # Chinakohl
    (13, 1.5, 2.2, 0.2),   # Bok Choy
    (32, 2.6, 4.4, 0.7),   # Kresse
    (15, 0.7, 3.4, 0.1),   # Rettich, rot
    (82, 3.0, 18.0, 0.3),  # Schwarzwurzeln
    (27, 2.1, 5.5, 0.2),   # Wirsing
    (17, 1.2, 3.4, 0.2),   # Endivien
    (13, 1.5, 2.2, 0.2),   # Pak Choi
    (16, 1.2, 2.7, 0.2),   # Batavia-Salat
    (49, 4.3, 8.7, 0.9),   # Grünkohl
    (73, 2.0, 17.4, 0.1),  # Topinambur
    (75, 1.2, 18.0, 0.3),  # Pastinaken
    (28, 0.9, 6.5, 0.1),   # Mairübe
    (45, 2.7, 9.2, 0.6),   # Löwenzahnblätter
    (20, 1.3, 3.8, 0.1),   # Portulak
    (32, 2.5, 4.4, 0.6),   # Gartenkresse
    (23, 1.4, 4.5, 0.2),   # Radicchio
    (17, 0.9, 3.3, 0.1),   # Chicorée
    (22, 2.0, 3.2, 0.7),   # Sauerampfer
    (11, 0.8, 1.5, 0.2),   # Brunnenkresse
    (27, 2.6, 5.2, 0.3),   # Bambussprossen
    (42, 2.8, 7.6, 0.1),   # Zuckerschoten
    (72, 2.5, 16.8, 0.1),  # Schalotten
    (42, 1.4, 9.2, 0.3),   # Knollensellerie
    (25, 2.0, 4.6, 0.3),   # Romanesco
    (48, 1.5, 11.5, 0.1)   # Meerrettich
]

tags = [
    ("Gemüse",),
    ("Gesund",),
    ("Kalorienarm",),
    ("Low-Carb",),
    ("Ballaststoffreich",),
    ("Vitaminreich",),
    ("Antioxidantien",),
    ("Vegan",),
    ("Glutenfrei",),
    ("Roh verzehrbar",),
    ("Saisonales Gemüse",)
]

food_tags = [
    (0, [0, 1, 2, 4, 5, 7]),    # Zwiebel
    (1, [0, 1, 3, 5, 7, 9]),    # Tomaten
    (2, [0, 1, 5, 6, 7]),       # Paprika
    (3, [0, 1, 2, 5, 7]),       # Karotten
    (4, [0, 1, 5, 6, 7]),       # Brokkoli
    (5, [0, 1, 2, 5, 7]),       # Blumenkohl
    (6, [0, 1, 5, 6, 7]),       # Spinat
    (7, [0, 2, 7, 9]),          # Gurke
    (8, [0, 2, 7]),             # Aubergine
    (9, [0, 1, 7, 9]),          # Zucchini
    (10, [0, 1, 8]),            # Kartoffeln
    (11, [0, 2, 7]),            # Kürbis
    (12, [0, 1, 3, 5, 7]),      # Knoblauch
    (13, [0, 2, 7, 9]),         # Eisbergsalat
    (14, [0, 1, 2, 5, 7]),      # Spargel
    (15, [0, 1, 5, 7]),         # Rosenkohl
    (16, [0, 1, 7]),            # Rettich
    (17, [0, 2, 7, 9]),         # Radieschen
    (18, [0, 1, 5, 7]),         # Kohlrabi
    (19, [0, 1, 2, 5, 7]),      # Sellerie
    (20, [0, 1, 5, 7]),         # Lauch
    (21, [0, 1, 2, 5, 7]),      # Rucola
    (22, [0, 1, 2, 5, 7]),      # Fenchel
    (23, [0, 1, 5, 7]),         # Grüner Paprika
    (24, [0, 1, 2, 5, 7]),      # Weißkohl
    (25, [0, 1, 5, 7]),         # Rotkohl
    (26, [0, 1, 5, 7]),         # Mangold
    (27, [0, 1, 2, 5, 7]),      # Kohlrübe
    (28, [0, 1, 5, 7]),         # Bohnen, grün
    (29, [0, 1, 2, 5, 7]),      # Erbsen
    (30, [0, 1, 5, 7]),         # Mais
    (31, [0, 1, 5, 7]),         # Okra
    (32, [0, 1, 5, 7]),         # Artischocken
    (33, [0, 1, 5, 7]),         # Süßkartoffeln
    (34, [0, 1, 5, 7]),         # Chinakohl
    (35, [0, 1, 5, 7]),         # Bok Choy
    (36, [0, 1, 2, 5, 7]),      # Kresse
    (37, [0, 1, 5, 7]),         # Rettich, rot
    (38, [0, 1, 5, 7]),         # Schwarzwurzeln
    (39, [0, 1, 2, 5, 7]),      # Wirsing
    (40, [0, 1, 5, 7]),         # Endivien
    (41, [0, 1, 5, 7]),         # Pak Choi
    (42, [0, 1, 5, 7]),         # Batavia-Salat
    (43, [0, 1, 5, 7]),         # Grünkohl
    (44, [0, 1, 2, 5, 7]),      # Topinambur
    (45, [0, 1, 2, 5, 7]),      # Pastinaken
    (46, [0, 1, 2, 5, 7]),      # Mairübe
    (47, [0, 1, 5, 7]),         # Löwenzahnblätter
    (48, [0, 1, 2, 5, 7]),      # Portulak
    (49, [0, 1, 2, 5, 7]),      # Gartenkresse
    (50, [0, 1, 5, 7]),         # Radicchio
    (51, [0, 1, 5, 7]),         # Chicorée
    (52, [0, 1, 5, 7]),         # Sauerampfer
    (53, [0, 1, 5, 7]),         # Brunnenkresse
    (54, [0, 1, 5, 7]),         # Bambussprossen
    (55, [0, 1, 5, 7]),         # Zuckerschoten
    (56, [0, 1, 5, 7]),         # Schalotten
    (57, [0, 1, 5, 7]),         # Knollensellerie
    (58, [0, 1, 5, 7]),         # Romanesco
    (59, [0, 1, 5, 7])          # Meerrettich
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

# Daten: Zutaten, Nährwerte und Tags
foods = [
    ("Zwiebel, frisch", "Gemüse", "Frische Zwiebel mit scharfen Geschmack, reich an Antioxidantien und wichtigen Nährstoffen, die für das Immunsystem förderlich sind."),
    ("Tomaten, frisch", "Gemüse", "Frische Tomate, reich an Lycopin, Vitamin C und Antioxidantien, ideal für Salate und Saucen."),
    ("Rote Paprika", "Gemüse", "Frische rote Paprika, reich an Vitamin C und Beta-Carotin, gut für das Immunsystem und die Augen."),
    ("Karotten", "Gemüse", "Frische Karotte, reich an Beta-Carotin und Ballaststoffen, unterstützt die Augengesundheit und die Verdauung."),
    ("Brokkoli", "Gemüse", "Frischer Brokkoli, voller Vitamine und Mineralstoffe, insbesondere Vitamin K und C, gut für die Knochengesundheit."),
    ("Blumenkohl", "Gemüse", "Frischer Blumenkohl, vielseitig verwendbar, reich an Ballaststoffen und Vitamin C, fördert die Verdauung."),
    ("Spinat", "Gemüse", "Frischer Spinat, reich an Eisen, Magnesium und Vitamin K, unterstützt die Blutbildung und Muskelfunktion."),
    ("Gurke", "Gemüse", "Frische Gurke, sehr wasserhaltig, kalorienarm und ideal zur Hydrierung und als Snack für zwischendurch."),
    ("Aubergine", "Gemüse", "Frische Aubergine, reich an Ballaststoffen und Antioxidantien, gut für das Herz und die Verdauung."),
    ("Zucchini", "Gemüse", "Frische Zucchini, kalorienarm und reich an Vitamin C und Kalium, gut für die Herzgesundheit."),
    ("Kartoffeln", "Gemüse", "Frische Kartoffeln, reich an komplexen Kohlenhydraten und Kalium, liefern langanhaltende Energie."),
    ("Kürbis", "Gemüse", "Frischer Kürbis, reich an Beta-Carotin, Vitamin A und Ballaststoffen, gut für die Augengesundheit."),
    ("Knoblauch", "Gemüse", "Frischer Knoblauch, bekannt für seine antibakteriellen Eigenschaften, gut für das Immunsystem."),
    ("Eisbergsalat", "Gemüse", "Frischer Eisbergsalat, kalorienarm und reich an Wasser, ideal für Salate und zum Hydrieren."),
    ("Spargel", "Gemüse", "Frischer Spargel, reich an Folsäure und Vitaminen, unterstützt die Entgiftung des Körpers."),
    ("Rosenkohl", "Gemüse", "Frischer Rosenkohl, reich an Ballaststoffen und Vitamin K, gut für die Verdauung und Knochengesundheit."),
    ("Rettich", "Gemüse", "Frischer Rettich, reich an Vitamin C und Senfölen, unterstützt die Verdauung und das Immunsystem."),
    ("Radieschen", "Gemüse", "Frische Radieschen, reich an Senfölen und Vitamin C, ideal für Salate und zur Verdauungsförderung."),
    ("Kohlrabi", "Gemüse", "Frischer Kohlrabi, reich an Vitamin C und Ballaststoffen, unterstützt die Verdauung und das Immunsystem."),
    ("Sellerie", "Gemüse", "Frischer Sellerie, reich an Ballaststoffen und Kalium, gut für die Verdauung und Herzgesundheit."),
    ("Lauch", "Gemüse", "Frischer Lauch, reich an Vitamin K und Folsäure, unterstützt die Knochengesundheit und die Blutbildung."),
    ("Rucola", "Gemüse", "Frischer Rucola, reich an Vitamin K und Antioxidantien, gut für die Blutgerinnung und das Immunsystem."),
    ("Fenchel", "Gemüse", "Frischer Fenchel, reich an Ballaststoffen und Vitamin C, unterstützt die Verdauung und das Immunsystem."),
    ("Grüner Paprika", "Gemüse", "Frischer grüner Paprika, reich an Vitamin C und Antioxidantien, gut für das Immunsystem."),
    ("Weißkohl", "Gemüse", "Frischer Weißkohl, reich an Vitamin C und Ballaststoffen, gut für die Verdauung und das Immunsystem."),
    ("Rotkohl", "Gemüse", "Frischer Rotkohl, reich an Vitamin C und Anthocyanen, gut für die Herzgesundheit und das Immunsystem."),
    ("Mangold", "Gemüse", "Frischer Mangold, reich an Vitamin A, C und K, unterstützt die Augengesundheit und die Blutgerinnung."),
    ("Kohlrübe", "Gemüse", "Frische Kohlrübe, reich an Ballaststoffen und Vitamin C, unterstützt die Verdauung und das Immunsystem."),
    ("Bohnen, grün", "Gemüse", "Frische grüne Bohnen, reich an Ballaststoffen und Eiweiß, gut für die Verdauung und Muskelaufbau."),
    ("Erbsen", "Gemüse", "Frische grüne Erbsen, reich an Protein und Ballaststoffen, gut für die Muskeln und die Verdauung."),
    ("Mais", "Gemüse", "Frischer Mais, reich an Ballaststoffen und Kohlenhydraten, ideal als Energielieferant."),
    ("Okra", "Gemüse", "Frische Okra, reich an Ballaststoffen und Vitamin C, unterstützt die Verdauung und das Immunsystem."),
    ("Artischocken", "Gemüse", "Frische Artischocken, reich an Ballaststoffen und Antioxidantien, fördern die Verdauung und Lebergesundheit."),
    ("Süßkartoffeln", "Gemüse", "Frische Süßkartoffeln, reich an Beta-Carotin und Ballaststoffen, gut für die Augengesundheit und das Immunsystem."),
    ("Chinakohl", "Gemüse", "Frischer Chinakohl, reich an Vitamin C und Ballaststoffen, gut für die Verdauung und das Immunsystem."),
    ("Bok Choy", "Gemüse", "Frischer Bok Choy, reich an Vitamin A, C und K, gut für die Knochengesundheit und das Immunsystem."),
    ("Kresse", "Gemüse", "Frische Kresse, reich an Vitamin C und K, ideal für Salate und gut für das Immunsystem."),
    ("Rettich, rot", "Gemüse", "Frischer roter Rettich, reich an Senfölen und Vitamin C, fördert die Verdauung und das Immunsystem."),
    ("Schwarzwurzeln", "Gemüse", "Frische Schwarzwurzeln, reich an Ballaststoffen und Vitamin E, unterstützt die Verdauung und Hautgesundheit."),
    ("Wirsing", "Gemüse", "Frischer Wirsing, reich an Vitamin K und Ballaststoffen, gut für die Blutgerinnung und Verdauung."),
    ("Endivien", "Gemüse", "Frische Endivien, reich an Folsäure und Vitamin A, gut für die Zellbildung und Augengesundheit."),
    ("Pak Choi", "Gemüse", "Frischer Pak Choi, reich an Vitamin K und C, gut für die Blutgerinnung und das Immunsystem."),
    ("Batavia-Salat", "Gemüse", "Frischer Batavia-Salat, kalorienarm und reich an Ballaststoffen, ideal für Salate und fördert die Verdauung."),
    ("Grünkohl", "Gemüse", "Frischer Grünkohl, sehr nährstoffreich, reich an Vitamin K, C und A, gut für das Immunsystem und die Knochengesundheit."),
    ("Topinambur", "Gemüse", "Frischer Topinambur, reich an Ballaststoffen und Inulin, fördert die Verdauung und unterstützt eine gesunde Darmflora."),
    ("Pastinaken", "Gemüse", "Frische Pastinaken, reich an Ballaststoffen, Vitamin C und Folsäure, unterstützen die Verdauung und das Immunsystem."),
    ("Mairübe", "Gemüse", "Frische Mairübe, kalorienarm und reich an Vitamin C, unterstützt das Immunsystem und die Verdauung."),
    ("Löwenzahnblätter", "Gemüse", "Frische Löwenzahnblätter, reich an Vitamin A, C und K, fördern die Lebergesundheit und wirken entzündungshemmend."),
    ("Portulak", "Gemüse", "Frischer Portulak, reich an Omega-3-Fettsäuren, Vitamin A und C, unterstützt die Herzgesundheit und hat antioxidative Eigenschaften."),
    ("Gartenkresse", "Gemüse", "Frische Gartenkresse, reich an Vitamin C, A und K, ideal für Salate und fördert das Immunsystem."),
    ("Radicchio", "Gemüse", "Frischer Radicchio, reich an Ballaststoffen, Vitamin K und Antioxidantien, fördert die Verdauung und unterstützt die Knochengesundheit."),
    ("Chicorée", "Gemüse", "Frischer Chicorée, reich an Ballaststoffen und Folsäure, unterstützt die Verdauung und hilft bei der Entgiftung des Körpers."),
    ("Sauerampfer", "Gemüse", "Frischer Sauerampfer, reich an Vitamin C und Antioxidantien, unterstützt das Immunsystem und wirkt antioxidativ."),
    ("Brunnenkresse", "Gemüse", "Frische Brunnenkresse, reich an Vitamin K, C und A, wirkt antioxidativ und fördert die Blutgerinnung."),
    ("Bambussprossen", "Gemüse", "Frische Bambussprossen, kalorienarm, reich an Ballaststoffen und fördern die Verdauung."),
    ("Zuckerschoten", "Gemüse", "Frische Zuckerschoten, reich an Ballaststoffen und Vitamin C, ideal als Snack und gut für das Immunsystem."),
    ("Schalotten", "Gemüse", "Frische Schalotten, mild im Geschmack, reich an Antioxidantien und gut für das Immunsystem."),
    ("Knollensellerie", "Gemüse", "Frischer Knollensellerie, reich an Ballaststoffen, Vitamin K und C, unterstützt die Verdauung und fördert die Herzgesundheit."),
    ("Romanesco", "Gemüse", "Frischer Romanesco, reich an Vitamin C, K und Ballaststoffen, unterstützt die Verdauung und das Immunsystem."),
    ("Meerrettich", "Gemüse", "Frischer Meerrettich, reich an Vitamin C und Senfölen, wirkt antibakteriell und unterstützt das Immunsystem."),
    ("Rote Bete", "Gemüse", "Frische Rote Bete, reich an Folsäure, Vitamin C und Eisen, fördert die Blutbildung und unterstützt die Entgiftung."),
    ("Chayote", "Gemüse", "Frische Chayote, kalorienarm, reich an Vitamin C und Ballaststoffen, unterstützt die Verdauung."),
    ("Yacon", "Gemüse", "Frischer Yacon, reich an Präbiotika und Ballaststoffen, fördert die Darmgesundheit und unterstützt die Verdauung."),
    ("Petersilienwurzel", "Gemüse", "Frische Petersilienwurzel, reich an Vitamin C und Eisen, gut für die Blutbildung und die Verdauung."),
    ("Wasabi", "Gemüse", "Frischer Wasabi, reich an Senfölen, wirkt antibakteriell und unterstützt die Verdauung."),
    ("Eichblattsalat", "Gemüse", "Frischer Eichblattsalat, reich an Vitamin K und Folsäure, ideal für Salate und unterstützt die Blutgerinnung."),
    ("Mizuna", "Gemüse", "Frischer Mizuna, eine asiatische Blattgemüsesorte, reich an Vitamin A, C und K, ideal für Salate und Suppen."),
    ("Grüne Bohnen", "Gemüse", "Frische grüne Bohnen, reich an Ballaststoffen, Vitamin C und Folsäure, unterstützt die Verdauung und das Immunsystem."),
    ("Kaiserschoten", "Gemüse", "Frische Kaiserschoten, süßlich im Geschmack, reich an Vitamin C und Ballaststoffen, ideal für Salate und zum Snacken."),
    ("Gelbe Paprika", "Gemüse", "Frische gelbe Paprika, reich an Vitamin C und Beta-Carotin, unterstützt das Immunsystem und die Augengesundheit."),
    ("Lila Karotten", "Gemüse", "Frische lila Karotten, reich an Anthocyanen und Beta-Carotin, gut für die Augengesundheit und antioxidative Wirkung."),
    ("Spaghettikürbis", "Gemüse", "Frischer Spaghettikürbis, kalorienarm, reich an Ballaststoffen und ideal als gesunde Nudelalternative."),
    ("Klettenwurzel", "Gemüse", "Frische Klettenwurzel, reich an Ballaststoffen und Mineralstoffen, unterstützt die Lebergesundheit und die Entgiftung."),
    ("Herbstkürbis", "Gemüse", "Frischer Herbstkürbis, reich an Beta-Carotin und Ballaststoffen, unterstützt die Augengesundheit und das Immunsystem."),
    ("Yamswurzel", "Gemüse", "Frische Yamswurzel, reich an komplexen Kohlenhydraten, Kalium und Vitamin C, unterstützt die Energieversorgung."),
    ("Puntarelle", "Gemüse", "Frische Puntarelle, eine italienische Zichorienart, reich an Vitamin K und Ballaststoffen, unterstützt die Verdauung."),
    ("Palmherzen", "Gemüse", "Frische Palmherzen, kalorienarm, reich an Ballaststoffen und Eisen, unterstützt die Blutbildung und die Verdauung."),
    ("Gelbe Zucchini", "Gemüse", "Frische gelbe Zucchini, ähnlich wie grüne Zucchini, reich an Vitamin C und Kalium, unterstützt die Herzgesundheit."),
    ("Kohlblätter", "Gemüse", "Frische Kohlblätter, reich an Vitamin C, K und Ballaststoffen, ideal für Kohlwickel und fördert die Verdauung."),
    ("Feigenkaktus", "Gemüse", "Frischer Feigenkaktus, reich an Ballaststoffen, Vitamin C und Magnesium, unterstützt die Verdauung und Blutzuckerregulation."),
    ("Malabarspinat", "Gemüse", "Frischer Malabarspinat, eine tropische Blattgemüsesorte, reich an Vitamin A und C, unterstützt die Augengesundheit.")
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
    (16, 0.7, 3.0, 0.2),   # Sellerie
    (31, 2.1, 6.1, 0.3),   # Lauch
    (25, 2.6, 3.7, 0.7),   # Rucola
    (31, 1.2, 7.3, 0.2),   # Fenchel
    (20, 0.9, 4.6, 0.1),   # Grüner Paprika
    (25, 1.3, 5.8, 0.1),   # Weißkohl
    (29, 1.4, 6.7, 0.2),   # Rotkohl
    (19, 1.8, 3.7, 0.2),   # Mangold
    (37, 1.1, 8.6, 0.3),   # Kohlrübe
    (31, 1.8, 7.0, 0.1),   # Bohnen, grün
    (81, 5.4, 14.5, 0.4),  # Erbsen
    (86, 3.3, 19.0, 1.2),  # Mais
    (33, 2.0, 7.0, 0.1),   # Okra
    (47, 3.3, 10.5, 0.2),  # Artischocken
    (86, 1.6, 20.0, 0.1),  # Süßkartoffeln
    (13, 1.1, 2.2, 0.1),   # Chinakohl
    (13, 1.5, 2.2, 0.2),   # Bok Choy
    (32, 2.6, 4.4, 0.7),   # Kresse
    (15, 0.7, 3.4, 0.1),   # Rettich, rot
    (82, 3.0, 18.0, 0.3),  # Schwarzwurzeln
    (27, 2.1, 5.5, 0.2),   # Wirsing
    (17, 1.2, 3.4, 0.2),   # Endivien
    (13, 1.5, 2.2, 0.2),   # Pak Choi
    (16, 1.2, 2.7, 0.2),   # Batavia-Salat
    (49, 4.3, 8.7, 0.9),   # Grünkohl
    (73, 2.0, 17.4, 0.1),  # Topinambur
    (75, 1.2, 18.0, 0.3),  # Pastinaken
    (28, 0.9, 6.5, 0.1),   # Mairübe
    (45, 2.7, 9.2, 0.6),   # Löwenzahnblätter
    (20, 1.3, 3.8, 0.1),   # Portulak
    (32, 2.5, 4.4, 0.6),   # Gartenkresse
    (23, 1.4, 4.5, 0.2),   # Radicchio
    (17, 0.9, 3.3, 0.1),   # Chicorée
    (22, 2.0, 3.2, 0.7),   # Sauerampfer
    (11, 0.8, 1.5, 0.2),   # Brunnenkresse
    (27, 2.6, 5.2, 0.3),   # Bambussprossen
    (42, 2.8, 7.6, 0.1),   # Zuckerschoten
    (72, 2.5, 16.8, 0.1),  # Schalotten
    (42, 1.4, 9.2, 0.3),   # Knollensellerie
    (25, 2.0, 4.6, 0.3),   # Romanesco
    (48, 1.5, 11.5, 0.1),  # Meerrettich
    (43, 1.6, 10.0, 0.2),  # Rote Bete
    (19, 0.8, 4.5, 0.1),   # Chayote
    (54, 1.0, 12.8, 0.1),  # Yacon
    (36, 1.3, 8.9, 0.4),   # Petersilienwurzel
    (109, 4.8, 23.5, 0.6), # Wasabi
    (14, 1.1, 2.1, 0.2),   # Eichblattsalat
    (21, 2.0, 4.0, 0.2),   # Mizuna
    (31, 1.8, 6.9, 0.1),   # Grüne Bohnen
    (42, 2.3, 7.9, 0.2),   # Kaiserschoten
    (27, 1.0, 6.1, 0.1),   # Gelbe Paprika
    (41, 1.0, 9.0, 0.2),   # Lila Karotten
    (31, 0.6, 7.0, 0.1),   # Spaghettikürbis
    (72, 2.0, 17.0, 0.1),  # Klettenwurzel
    (29, 1.1, 7.3, 0.1),   # Herbstkürbis
    (118, 1.5, 28.0, 0.2), # Yamswurzel
    (17, 1.4, 3.1, 0.1),   # Puntarelle
    (45, 3.6, 3.9, 0.2),   # Palmherzen
    (16, 1.2, 3.1, 0.2),   # Gelbe Zucchini
    (24, 1.8, 5.2, 0.3),   # Kohlblätter
    (41, 0.9, 9.2, 0.1),   # Feigenkaktus
    (19, 1.8, 3.2, 0.3)    # Malabarspinat
]

tags = [
    ("Gemüse",),
    ("Gesund",),
    ("Kalorienarm",),
    ("Low-Carb",),
    ("Ballaststoffreich",),
    ("Vitaminreich",),
    ("Antioxidantien",),
    ("Vegan",),
    ("Glutenfrei",),
    ("Roh verzehrbar",),
    ("Saisonales Gemüse",)
]

food_tags = [
    (0, [0, 1, 2, 4, 5, 7]),    # Zwiebel
    (1, [0, 1, 3, 5, 7, 9]),    # Tomaten
    (2, [0, 1, 5, 6, 7]),       # Paprika
    (3, [0, 1, 2, 5, 7]),       # Karotten
    (4, [0, 1, 5, 6, 7]),       # Brokkoli
    (5, [0, 1, 2, 5, 7]),       # Blumenkohl
    (6, [0, 1, 5, 6, 7]),       # Spinat
    (7, [0, 2, 7, 9]),          # Gurke
    (8, [0, 2, 7]),             # Aubergine
    (9, [0, 1, 7, 9]),          # Zucchini
    (10, [0, 1, 8]),            # Kartoffeln
    (11, [0, 2, 7]),            # Kürbis
    (12, [0, 1, 3, 5, 7]),      # Knoblauch
    (13, [0, 2, 7, 9]),         # Eisbergsalat
    (14, [0, 1, 2, 5, 7]),      # Spargel
    (15, [0, 1, 5, 7]),         # Rosenkohl
    (16, [0, 1, 7]),            # Rettich
    (17, [0, 2, 7, 9]),         # Radieschen
    (18, [0, 1, 5, 7]),         # Kohlrabi
    (19, [0, 1, 2, 5, 7]),      # Sellerie
    (20, [0, 1, 5, 7]),         # Lauch
    (21, [0, 1, 2, 5, 7]),      # Rucola
    (22, [0, 1, 2, 5, 7]),      # Fenchel
    (23, [0, 1, 5, 7]),         # Grüner Paprika
    (24, [0, 1, 2, 5, 7]),      # Weißkohl
    (25, [0, 1, 5, 7]),         # Rotkohl
    (26, [0, 1, 5, 7]),         # Mangold
    (27, [0, 1, 2, 5, 7]),      # Kohlrübe
    (28, [0, 1, 5, 7]),         # Bohnen, grün
    (29, [0, 1, 2, 5, 7]),      # Erbsen
    (30, [0, 1, 5, 7]),         # Mais
    (31, [0, 1, 5, 7]),         # Okra
    (32, [0, 1, 5, 7]),         # Artischocken
    (33, [0, 1, 5, 7]),         # Süßkartoffeln
    (34, [0, 1, 5, 7]),         # Chinakohl
    (35, [0, 1, 5, 7]),         # Bok Choy
    (36, [0, 1, 2, 5, 7]),      # Kresse
    (37, [0, 1, 5, 7]),         # Rettich, rot
    (38, [0, 1, 5, 7]),         # Schwarzwurzeln
    (39, [0, 1, 2, 5, 7]),      # Wirsing
    (40, [0, 1, 5, 7]),         # Endivien
    (41, [0, 1, 5, 7]),         # Pak Choi
    (42, [0, 1, 5, 7]),         # Batavia-Salat
    (43, [0, 1, 5, 7]),         # Grünkohl
    (44, [0, 1, 2, 5, 7]),      # Topinambur
    (45, [0, 1, 2, 5, 7]),      # Pastinaken
    (46, [0, 1, 2, 5, 7]),      # Mairübe
    (47, [0, 1, 5, 7]),         # Löwenzahnblätter
    (48, [0, 1, 2, 5, 7]),      # Portulak
    (49, [0, 1, 2, 5, 7]),      # Gartenkresse
    (50, [0, 1, 5, 7]),         # Radicchio
    (51, [0, 1, 5, 7]),         # Chicorée
    (52, [0, 1, 5, 7]),         # Sauerampfer
    (53, [0, 1, 5, 7]),         # Brunnenkresse
    (54, [0, 1, 5, 7]),         # Bambussprossen
    (55, [0, 1, 5, 7]),         # Zuckerschoten
    (56, [0, 1, 5, 7]),         # Schalotten
    (57, [0, 1, 5, 7]),         # Knollensellerie
    (58, [0, 1, 5, 7]),         # Romanesco
    (59, [0, 1, 5, 7]),         # Meerrettich
    (60, [0, 1, 5, 7]),         # Rote Bete
    (61, [0, 1, 5, 7]),         # Chayote
    (62, [0, 1, 5, 7]),         # Yacon
    (63, [0, 1, 5, 7]),         # Petersilienwurzel
    (64, [0, 1, 5, 7]),         # Wasabi
    (65, [0, 1, 5, 7]),         # Eichblattsalat
    (66, [0, 1, 5, 7]),         # Mizuna
    (67, [0, 1, 5, 7]),         # Grüne Bohnen
    (68, [0, 1, 5, 7]),         # Kaiserschoten
    (69, [0, 1, 5, 7]),         # Gelbe Paprika
    (70, [0, 1, 5, 7]),         # Lila Karotten
    (71, [0, 1, 5, 7]),         # Spaghettikürbis
    (72, [0, 1, 5, 7]),         # Klettenwurzel
    (73, [0, 1, 5, 7]),         # Herbstkürbis
    (74, [0, 1, 5, 7]),         # Yamswurzel
    (75, [0, 1, 5, 7]),         # Puntarelle
    (76, [0, 1, 5, 7]),         # Palmherzen
    (77, [0, 1, 5, 7]),         # Gelbe Zucchini
    (78, [0, 1, 5, 7]),         # Kohlblätter
    (79, [0, 1, 5, 7]),         # Feigenkaktus
    (80, [0, 1, 5, 7])          # Malabarspinat
]

