import sqlite3
import uuid

def setDatabase(tags, foods, nutrition_facts, food_tags):
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
            name TEXT UNIQUE
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

    # Tags in die Datenbank einfügen (nur, wenn sie noch nicht existieren)
    tag_ids = {}
    for tag in tags:
        # Überprüfen, ob der Tag bereits existiert
        cursor.execute('SELECT id FROM Tag WHERE name = ?', (tag[0],))
        existing_tag = cursor.fetchone()
        
        if existing_tag:
            # Falls der Tag bereits existiert, verwende die vorhandene ID
            tag_id = existing_tag[0]
        else:
            # Falls der Tag nicht existiert, füge ihn ein und erstelle eine neue ID
            tag_id = str(uuid.uuid4())
            cursor.execute('INSERT INTO Tag (id, name) VALUES (?, ?)', (tag_id, tag[0]))

        # Speichere die Tag-ID in das Dictionary
        tag_ids[tag[0]] = tag_id

    # Lebensmittel und Nährwerte einfügen
    for i, (food, nutrition) in enumerate(zip(foods, nutrition_facts)):
        food_id = str(uuid.uuid4())
        cursor.execute('INSERT INTO Food (id, name, category, info) VALUES (?, ?, ?, ?)', (food_id, food[0], food[1], food[2]))
        cursor.execute('INSERT INTO NutritionFacts (id, calories, protein, carbohydrates, fat, food_id) VALUES (?, ?, ?, ?, ?, ?)',
                       (str(uuid.uuid4()), nutrition[0], nutrition[1], nutrition[2], nutrition[3], food_id))
        
        # Tags zuweisen
        for tag_index in food_tags[i][1]:
            tag_name = tags[tag_index][0]  # Den Tag-Namen aus der ursprünglichen tags-Liste abrufen
            tag_id = tag_ids[tag_name]  # Die entsprechende Tag-ID aus dem Dictionary abrufen
            cursor.execute('INSERT INTO FoodTag (foodId, tagId) VALUES (?, ?)', (food_id, tag_id))

    # Änderungen speichern und Verbindung schließen
    conn.commit()
    conn.close()

    print("Daten wurden erfolgreich in die Datenbank eingefügt.")



# Daten: Zutaten, Nährwerte und Tags
foodsGemüse = [
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

nutritionGemüse_facts = [
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
    ("Saisonales Gemüse",),
    ("Proteinreich",),
    ("Mineralstoffreich",),
    ("Hydrierend",),
    ("Immunsystemstärkend",),
    ("Herzgesund",),
    ("Entzündungshemmend",),
    ("Augengesund",),
    ("Knochengesund",),
    ("Hautgesundheit",),
    ("Eisenreich",),
    ("Stärkt die Verdauung",)
]

foodGemüse_tags = [
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

# Gemüse
setDatabase( tags,foodsGemüse,nutritionGemüse_facts, foodGemüse_tags)



foodsObst = [
    ("Apfel", "Obst", "Frischer Apfel, reich an Ballaststoffen, Vitamin C und Antioxidantien, unterstützt die Verdauung und stärkt das Immunsystem."),
    ("Banane", "Obst", "Frische Banane, reich an Kalium, Vitamin B6 und Kohlenhydraten, liefert schnelle Energie und unterstützt die Herzgesundheit."),
    ("Erdbeere", "Obst", "Frische Erdbeere, reich an Vitamin C, Mangan und Antioxidantien, unterstützt das Immunsystem und die Hautgesundheit."),
    ("Orange", "Obst", "Frische Orange, reich an Vitamin C und Ballaststoffen, unterstützt das Immunsystem und die Herzgesundheit."),
    ("Blaubeere", "Obst", "Frische Blaubeere, reich an Antioxidantien, Vitamin C und K, fördert die Gehirngesundheit und das Immunsystem."),
    ("Kirsche", "Obst", "Frische Kirsche, reich an Anthocyanen, Vitamin C und Kalium, wirkt entzündungshemmend und unterstützt die Herzgesundheit."),
    ("Wassermelone", "Obst", "Frische Wassermelone, reich an Lycopin, Vitamin C und Wasser, unterstützt die Hydrierung und das Immunsystem."),
    ("Pfirsich", "Obst", "Frischer Pfirsich, reich an Vitamin A, C und Ballaststoffen, fördert die Hautgesundheit und die Verdauung."),
    ("Birne", "Obst", "Frische Birne, reich an Ballaststoffen, Vitamin C und K, unterstützt die Verdauung und das Immunsystem."),
    ("Kiwi", "Obst", "Frische Kiwi, reich an Vitamin C, K und Ballaststoffen, fördert das Immunsystem und die Verdauung."),
    ("Ananas", "Obst", "Frische Ananas, reich an Vitamin C, Bromelain und Mangan, unterstützt die Verdauung und das Immunsystem."),
    ("Mango", "Obst", "Frische Mango, reich an Vitamin A, C und Antioxidantien, fördert die Hautgesundheit und das Immunsystem."),
    ("Granatapfel", "Obst", "Frischer Granatapfel, reich an Antioxidantien, Vitamin C und K, unterstützt die Herzgesundheit und wirkt entzündungshemmend."),
    ("Traube", "Obst", "Frische Traube, reich an Resveratrol, Vitamin K und C, unterstützt die Herzgesundheit und wirkt antioxidativ."),
    ("Papaya", "Obst", "Frische Papaya, reich an Vitamin C, A und Papain, unterstützt die Verdauung und das Immunsystem."),
    ("Feige", "Obst", "Frische Feige, reich an Ballaststoffen, Kalium und Kalzium, unterstützt die Verdauung und die Knochengesundheit."),
    ("Zitrone", "Obst", "Frische Zitrone, reich an Vitamin C und Antioxidantien, unterstützt das Immunsystem und fördert die Verdauung."),
    ("Aprikose", "Obst", "Frische Aprikose, reich an Vitamin A, C und Ballaststoffen, unterstützt die Hautgesundheit und die Verdauung."),
    ("Passionsfrucht", "Obst", "Frische Passionsfrucht, reich an Vitamin C, A und Ballaststoffen, unterstützt das Immunsystem und die Verdauung."),
    ("Himbeere", "Obst", "Frische Himbeere, reich an Ballaststoffen, Vitamin C und Antioxidantien, unterstützt die Verdauung und das Immunsystem."),
    ("Johannisbeere", "Obst", "Frische Johannisbeere, reich an Vitamin C, Mangan und Antioxidantien, unterstützt das Immunsystem und die Knochenstärke."),
    ("Brombeere", "Obst", "Frische Brombeere, reich an Ballaststoffen, Vitamin C und K, unterstützt die Verdauung und die Herzgesundheit."),
    ("Melone", "Obst", "Frische Melone, reich an Vitamin A, C und Wasser, unterstützt die Hydrierung und das Immunsystem."),
    ("Nektarine", "Obst", "Frische Nektarine, reich an Vitamin C, A und Ballaststoffen, fördert die Hautgesundheit und die Verdauung."),
    ("Guave", "Obst", "Frische Guave, reich an Vitamin C, Ballaststoffen und Folsäure, unterstützt das Immunsystem und die Verdauung."),
    ("Litschi", "Obst", "Frische Litschi, reich an Vitamin C, B6 und Antioxidantien, unterstützt das Immunsystem und die Hautgesundheit."),
    ("Drachenfrucht", "Obst", "Frische Drachenfrucht, reich an Vitamin C, Magnesium und Ballaststoffen, unterstützt das Immunsystem und die Verdauung."),
    ("Kaktusfeige", "Obst", "Frische Kaktusfeige, reich an Ballaststoffen, Vitamin C und Magnesium, unterstützt die Verdauung und die Blutzuckerregulation."),
    ("Maracuja", "Obst", "Frische Maracuja, reich an Vitamin C, A und Antioxidantien, unterstützt das Immunsystem und fördert die Verdauung."),
    ("Quitte", "Obst", "Frische Quitte, reich an Ballaststoffen, Vitamin C und Antioxidantien, unterstützt die Verdauung und das Immunsystem."),
    ("Sternfrucht", "Obst", "Frische Sternfrucht, reich an Vitamin C und Ballaststoffen, unterstützt das Immunsystem und die Verdauung."),
    ("Kumquat", "Obst", "Frische Kumquat, reich an Vitamin C, Ballaststoffen und Antioxidantien, unterstützt das Immunsystem und die Verdauung."),
    ("Mandarine", "Obst", "Frische Mandarine, reich an Vitamin C und Ballaststoffen, fördert die Hautgesundheit und das Immunsystem."),
    ("Cranberry", "Obst", "Frische Cranberry, reich an Vitamin C und Antioxidantien, unterstützt die Harnwegsgesundheit und das Immunsystem."),
    ("Pflaume", "Obst", "Frische Pflaume, reich an Ballaststoffen, Vitamin C und K, fördert die Verdauung und die Knochengesundheit."),
    ("Kaktusbirne", "Obst", "Frische Kaktusbirne, reich an Ballaststoffen, Vitamin C und Magnesium, unterstützt die Verdauung und das Immunsystem."),
    ("Jujube", "Obst", "Frische Jujube, reich an Vitamin C und Ballaststoffen, unterstützt die Verdauung und das Immunsystem."),
    ("Physalis", "Obst", "Frische Physalis, reich an Vitamin C, A und Antioxidantien, unterstützt das Immunsystem und die Hautgesundheit."),
    ("Pomelo", "Obst", "Frische Pomelo, reich an Vitamin C und Ballaststoffen, unterstützt das Immunsystem und die Verdauung."),
    ("Dattel", "Obst", "Frische Dattel, reich an Ballaststoffen, Kalium und natürlichen Zuckern, unterstützt die Verdauung und liefert Energie."),
    ("Zuckerapfel", "Obst", "Frischer Zuckerapfel, reich an Vitamin C und Ballaststoffen, fördert das Immunsystem und die Verdauung."),
    ("Schlehe", "Obst", "Frische Schlehe, reich an Vitamin C und Antioxidantien, fördert die Verdauung und das Immunsystem."),
    ("Kirschtomate", "Obst", "Frische Kirschtomate, reich an Lycopin, Vitamin C und Antioxidantien, unterstützt das Immunsystem und die Hautgesundheit."),
    ("Cantaloupe", "Obst", "Frische Cantaloupe-Melone, reich an Vitamin A, C und Wasser, unterstützt die Hydrierung und das Immunsystem."),
    ("Salak", "Obst", "Frischer Salak, auch Schlangenhautfrucht genannt, reich an Vitamin C und Ballaststoffen, unterstützt die Verdauung."),
    ("Mangostan", "Obst", "Frische Mangostan, reich an Vitamin C und Antioxidantien, unterstützt das Immunsystem und wirkt entzündungshemmend."),
    ("Longan", "Obst", "Frische Longan, reich an Vitamin C, unterstützt das Immunsystem und wirkt antioxidativ."),
    ("Rambutan", "Obst", "Frischer Rambutan, reich an Vitamin C, unterstützt das Immunsystem und fördert die Hautgesundheit."),
    ("Maulbeere", "Obst", "Frische Maulbeere, reich an Vitamin C, Eisen und Ballaststoffen, unterstützt die Blutbildung und das Immunsystem."),
    ("Mirabelle", "Obst", "Frische Mirabelle, reich an Vitamin C, Kalium und Ballaststoffen, unterstützt die Verdauung und das Immunsystem."),
    ("Nashi-Birne", "Obst", "Frische Nashi-Birne, reich an Wasser, Vitamin C und Ballaststoffen, unterstützt die Hydrierung und das Immunsystem."),
    ("Gojibeere", "Obst", "Frische Gojibeere, reich an Antioxidantien, Vitamin A und C, unterstützt die Augengesundheit und das Immunsystem."),
    ("Pampelmuse", "Obst", "Frische Pampelmuse, reich an Vitamin C und Ballaststoffen, unterstützt das Immunsystem und fördert die Verdauung."),
    ("Buddhas Hand", "Obst", "Frische Buddhas Hand, reich an Vitamin C und duftenden Ölen, wird häufig als Zutat oder Dekoration verwendet."),
    ("Rosenapfel", "Obst", "Frischer Rosenapfel, reich an Wasser und Vitamin C, unterstützt die Hydrierung und das Immunsystem."),
    ("Hagebutte", "Obst", "Frische Hagebutte, reich an Vitamin C und Antioxidantien, stärkt das Immunsystem und unterstützt die Hautgesundheit."),
    ("Jackfrucht", "Obst", "Frische Jackfrucht, reich an Ballaststoffen, Vitamin C und Kalium, unterstützt die Verdauung und das Immunsystem."),
    ("Akebia", "Obst", "Frische Akebia, eine exotische Frucht mit hohem Wassergehalt, die zur Hydrierung und als Delikatesse verwendet wird."),
    ("Durian", "Obst", "Frische Durian, bekannt für ihren intensiven Geruch, reich an Vitamin C, Kalium und Ballaststoffen, unterstützt die Verdauung."),
    ("Sapote", "Obst", "Frische Sapote, reich an Vitamin A und C, unterstützt die Augengesundheit und das Immunsystem."),
    ("Satsuma", "Obst", "Frische Satsuma, eine kernlose Mandarinenart, reich an Vitamin C, fördert das Immunsystem und die Hautgesundheit."),
    ("Fingerlimette", "Obst", "Frische Fingerlimette, auch bekannt als Kaviar-Limette, reich an Vitamin C, ideal als Gourmetzutat."),
    ("Loquat", "Obst", "Frische Loquat, reich an Vitamin A und Ballaststoffen, unterstützt die Verdauung und die Augengesundheit."),
    ("Cloudberry", "Obst", "Frische Cloudberry, reich an Vitamin C und Antioxidantien, unterstützt das Immunsystem und wirkt entzündungshemmend."),
    ("Ackerminze", "Obst", "Frische Ackerminze, reich an Antioxidantien und ätherischen Ölen, häufig in Salaten oder als Dekoration verwendet."),
    ("Kapstachelbeere", "Obst", "Frische Kapstachelbeere, auch bekannt als Physalis, reich an Vitamin C und A, unterstützt das Immunsystem."),
    ("Cherimoya", "Obst", "Frische Cherimoya, cremige Frucht, reich an Vitamin C, unterstützt das Immunsystem und die Verdauung."),
    ("Kaffirlimette", "Obst", "Frische Kaffirlimette, reich an Vitamin C und ätherischen Ölen, häufig in der asiatischen Küche verwendet."),
    ("Pepino", "Obst", "Frische Pepino, reich an Vitamin C und Ballaststoffen, unterstützt das Immunsystem und die Verdauung."),
    ("Jocote", "Obst", "Frische Jocote, reich an Vitamin C und Kalium, unterstützt die Verdauung und das Immunsystem."),
    ("Korallenbeere", "Obst", "Frische Korallenbeere, reich an Antioxidantien und Vitamin C, unterstützt das Immunsystem."),
    ("Medlar", "Obst", "Frische Medlar, reich an Vitamin C und Ballaststoffen, unterstützt die Verdauung und das Immunsystem."),
    ("Santol", "Obst", "Frische Santol, reich an Vitamin C und Antioxidantien, unterstützt das Immunsystem und die Verdauung."),
    ("Ugli-Frucht", "Obst", "Frische Ugli-Frucht, eine Hybride aus Grapefruit, Orange und Mandarine, reich an Vitamin C, unterstützt das Immunsystem."),
    ("Monstera", "Obst", "Frische Monstera, auch bekannt als Fensterblatt, reich an Vitamin C und Kalzium, unterstützt die Knochenstärke."),
    ("Guanabana", "Obst", "Frische Guanabana, auch bekannt als Stachelannone, reich an Vitamin C und Ballaststoffen, unterstützt das Immunsystem."),
    ("Hainbuche", "Obst", "Frische Hainbuche, eine seltene Frucht, die als exotische Delikatesse verwendet wird."),
    ("Jabotikaba", "Obst", "Frische Jabotikaba, reich an Vitamin C und Antioxidantien, unterstützt das Immunsystem und wirkt entzündungshemmend."),
    ("Sapodilla", "Obst", "Frische Sapodilla, reich an Ballaststoffen, Vitamin A und C, unterstützt die Verdauung und das Immunsystem."),
    ("Sauerampfer", "Obst", "Frischer Sauerampfer, reich an Vitamin C und Antioxidantien, unterstützt das Immunsystem und wirkt antioxidativ."),
    ("Weinbergpfirsich", "Obst", "Frischer Weinbergpfirsich, reich an Vitamin A, C und Ballaststoffen, fördert die Hautgesundheit und die Verdauung."),
    ("Wollmispel", "Obst", "Frische Wollmispel, reich an Vitamin C, Ballaststoffen und Antioxidantien, unterstützt die Verdauung."),
    ("Starapple", "Obst", "Frische Starapple, reich an Vitamin C und Kalzium, unterstützt die Knochengesundheit und das Immunsystem."),
    ("Ziziphus", "Obst", "Frische Ziziphus, reich an Ballaststoffen, Vitamin C und Antioxidantien, fördert die Verdauung und das Immunsystem."),
    ("Ackerlupine", "Obst", "Frische Ackerlupine, eine seltene Frucht, reich an Protein und Ballaststoffen, unterstützt die Muskelgesundheit."),
    ("Amerikanische Persimone", "Obst", "Frische Amerikanische Persimone, reich an Vitamin A und C, unterstützt die Augengesundheit und das Immunsystem."),
    ("Bitterorange", "Obst", "Frische Bitterorange, reich an Vitamin C und Antioxidantien, wird häufig zur Zubereitung von Marmelade verwendet."),
    ("Brotfrucht", "Obst", "Frische Brotfrucht, reich an Ballaststoffen, Vitamin C und Kalium, unterstützt die Verdauung und die Energieversorgung."),
    ("Kastanienkirsche", "Obst", "Frische Kastanienkirsche, reich an Vitamin C und Antioxidantien, fördert das Immunsystem."),
    ("Keule", "Obst", "Frische Keule, eine exotische Frucht, die in speziellen Gerichten als Delikatesse verwendet wird."),
    ("Mispel", "Obst", "Frische Mispel, reich an Ballaststoffen und Vitamin C, unterstützt die Verdauung und das Immunsystem."),
    ("Paradiesfeige", "Obst", "Frische Paradiesfeige, reich an Ballaststoffen, Kalium und Vitamin C, unterstützt die Verdauung und das Immunsystem."),
    ("Prunus", "Obst", "Frische Prunus, reich an Vitamin C, unterstützt die Verdauung und das Immunsystem."),
    ("Purpurgranatapfel", "Obst", "Frischer Purpurgranatapfel, reich an Antioxidantien, Vitamin C und K, unterstützt das Immunsystem."),
    ("Schwarze Sapote", "Obst", "Frische Schwarze Sapote, auch bekannt als Schokoladenpudding-Frucht, reich an Vitamin C und unterstützt das Immunsystem."),
    ("Sommerhimbeere", "Obst", "Frische Sommerhimbeere, reich an Ballaststoffen und Vitamin C, unterstützt das Immunsystem und die Verdauung."),
    ("Tamarillo", "Obst", "Frische Tamarillo, auch Baumtomate genannt, reich an Vitamin C und Ballaststoffen, unterstützt die Verdauung."),
    ("Wachsapfel", "Obst", "Frischer Wachsapfel, reich an Vitamin C und Antioxidantien, unterstützt die Hautgesundheit und das Immunsystem.")
]
nutritionObst_facts = [
    (52, 0.3, 13.8, 0.2),   # Apfel
    (89, 1.1, 22.8, 0.3),   # Banane
    (32, 0.7, 7.7, 0.3),    # Erdbeere
    (47, 0.9, 11.8, 0.1),   # Orange
    (57, 0.7, 14.5, 0.3),   # Blaubeere
    (50, 1.0, 12.2, 0.3),   # Kirsche
    (30, 0.6, 7.6, 0.2),    # Wassermelone
    (39, 0.9, 9.5, 0.2),    # Pfirsich
    (57, 0.4, 15.0, 0.1),   # Birne
    (61, 1.1, 14.7, 0.5),   # Kiwi
    (50, 0.5, 13.1, 0.1),   # Ananas
    (60, 0.8, 15.0, 0.4),   # Mango
    (83, 1.7, 18.7, 1.2),   # Granatapfel
    (69, 0.7, 17.0, 0.2),   # Traube
    (43, 0.5, 10.8, 0.3),   # Papaya
    (74, 0.8, 19.2, 0.3),   # Feige
    (29, 1.1, 9.3, 0.3),    # Zitrone
    (48, 1.4, 11.1, 0.4),   # Aprikose
    (97, 2.2, 23.4, 0.5),   # Passionsfrucht
    (52, 1.2, 11.9, 0.6),   # Himbeere
    (56, 1.4, 13.8, 0.2),   # Johannisbeere
    (43, 1.4, 9.6, 0.5),    # Brombeere
    (34, 0.8, 8.1, 0.2),    # Melone
    (44, 1.1, 10.6, 0.3),   # Nektarine
    (68, 2.6, 14.3, 1.0),   # Guave
    (66, 0.8, 16.5, 0.4),   # Litschi
    (50, 1.1, 11.0, 0.4),   # Drachenfrucht
    (41, 0.6, 9.6, 0.5),    # Kaktusfeige
    (97, 2.2, 23.4, 0.4),   # Maracuja
    (57, 0.4, 15.3, 0.1),   # Quitte
    (31, 1.0, 6.7, 0.3),    # Sternfrucht
    (71, 1.9, 16.0, 0.9),   # Kumquat
    (53, 0.8, 13.3, 0.3),   # Mandarine
    (46, 0.1, 12.2, 0.1),   # Cranberry
    (46, 0.7, 11.4, 0.3),   # Pflaume
    (42, 0.9, 9.6, 0.5),    # Kaktusbirne
    (79, 1.2, 20.2, 0.2),   # Jujube
    (53, 1.9, 11.2, 0.7),   # Physalis
    (38, 0.8, 9.6, 0.1),    # Pomelo
    (282, 2.5, 75.0, 0.4),  # Dattel
    (94, 2.1, 22.6, 0.3),   # Zuckerapfel
    (54, 1.3, 12.1, 0.5),   # Schlehe
    (18, 0.9, 3.9, 0.2),    # Kirschtomate
    (34, 0.8, 8.3, 0.2),    # Cantaloupe
    (82, 1.4, 22.3, 0.4),   # Salak
    (73, 0.6, 18.1, 0.3),   # Mangostan
    (60, 1.3, 15.2, 0.1),   # Longan
    (68, 0.9, 16.5, 0.2),   # Rambutan
    (43, 1.4, 9.8, 0.4),    # Maulbeere
    (62, 0.6, 15.3, 0.2),   # Mirabelle
    (43, 0.5, 11.6, 0.2),   # Nashi-Birne
    (83, 4.0, 19.3, 0.4),   # Gojibeere
    (38, 0.8, 9.6, 0.1),    # Pampelmuse
    (30, 1.0, 6.7, 0.3),    # Buddhas Hand
    (25, 0.6, 5.6, 0.2),    # Rosenapfel
    (162, 1.5, 38.4, 0.3),  # Hagebutte
    (95, 1.7, 23.5, 0.3),   # Jackfrucht
    (55, 1.1, 13.4, 0.1),   # Akebia
    (147, 1.5, 27.1, 5.3),  # Durian
    (80, 1.0, 19.1, 0.3),   # Sapote
    (42, 0.8, 10.5, 0.1),   # Satsuma
    (30, 0.3, 7.7, 0.1),    # Fingerlimette
    (47, 0.4, 12.1, 0.1),   # Loquat
    (51, 1.3, 10.4, 0.4),   # Cloudberry
    (20, 0.8, 4.3, 0.1),    # Ackerminze
    (77, 1.9, 15.9, 0.7),   # Kapstachelbeere
    (75, 1.5, 19.3, 0.2),   # Cherimoya
    (47, 0.6, 11.5, 0.2),   # Kaffirlimette
    (40, 1.0, 10.5, 0.1),   # Pepino
    (76, 1.4, 20.1, 0.1),   # Jocote
    (55, 1.3, 14.2, 0.4),   # Korallenbeere
    (44, 1.3, 10.4, 0.2),   # Medlar
    (50, 0.6, 12.9, 0.3),   # Santol
    (47, 0.9, 11.8, 0.1),   # Ugli-Frucht
    (22, 0.8, 5.3, 0.1),    # Monstera
    (66, 1.0, 16.5, 0.3),   # Guanabana
    (33, 0.7, 7.8, 0.1),    # Hainbuche
    (43, 0.6, 10.5, 0.2),   # Jabotikaba
    (83, 1.4, 20.0, 0.4),   # Sapodilla
    (20, 1.0, 4.0, 0.1),    # Sauerampfer
    (39, 0.9, 9.0, 0.2),    # Weinbergpfirsich
    (30, 0.6, 7.6, 0.1),    # Wollmispel
    (67, 1.3, 16.2, 0.3),   # Starapple
    (79, 1.8, 20.2, 0.2),   # Ziziphus
    (31, 1.2, 6.7, 0.2),    # Ackerlupine
    (81, 1.1, 20.4, 0.3),   # Amerikanische Persimone
    (45, 0.7, 11.2, 0.1),   # Bitterorange
    (103, 1.5, 27.1, 0.5),  # Brotfrucht
    (56, 0.8, 13.7, 0.1),   # Kastanienkirsche
    (46, 1.0, 12.2, 0.1),   # Keule
    (74, 1.2, 19.3, 0.3),   # Mispel
    (60, 1.6, 14.2, 0.2),   # Paradiesfeige
    (47, 1.0, 12.1, 0.1),   # Prunus
    (84, 1.9, 18.7, 0.3),   # Purpurgranatapfel
    (45, 0.6, 11.4, 0.1),   # Schwarze Sapote
    (42, 1.1, 10.6, 0.2),   # Sommerhimbeere
    (31, 0.8, 7.6, 0.1),    # Tamarillo
    (45, 0.7, 11.0, 0.1)    # Wachsapfel
]

foodObst_tags = [
    (0, [0, 1, 2, 3, 6, 7, 9, 14, 19]),    # Apfel
    (1, [0, 1, 4, 6, 7, 9, 16]),            # Banane
    (2, [0, 1, 2, 3, 4, 6, 9, 15, 20]),     # Erdbeere
    (3, [0, 1, 2, 3, 6, 7, 9, 15]),         # Orange
    (4, [0, 1, 4, 3, 6, 9, 15, 17]),        # Blaubeere
    (5, [0, 1, 4, 3, 6, 9, 16, 15]),        # Kirsche
    (6, [0, 1, 2, 3, 6, 7, 9, 13]),         # Wassermelone
    (7, [0, 1, 2, 3, 6, 7, 9, 19]),         # Pfirsich
    (8, [0, 1, 2, 3, 6, 7, 9, 14, 19]),     # Birne
    (9, [0, 1, 4, 3, 6, 7, 9, 14]),         # Kiwi
    (10, [0, 1, 4, 3, 6, 7, 9, 20]),        # Ananas
    (11, [0, 1, 4, 3, 6, 7, 9, 19]),        # Mango
    (12, [0, 1, 4, 3, 6, 7, 9, 15, 16]),    # Granatapfel
    (13, [0, 1, 4, 3, 6, 7, 9, 15, 16]),    # Traube
    (14, [0, 1, 2, 3, 6, 7, 9, 14]),        # Papaya
    (15, [0, 1, 2, 3, 6, 7, 9, 20]),        # Feige
    (16, [0, 1, 2, 3, 6, 7, 9, 13]),        # Zitrone
    (17, [0, 1, 2, 3, 6, 7, 9, 19]),        # Aprikose
    (18, [0, 1, 4, 3, 6, 7, 9, 14, 17]),    # Passionsfrucht
    (19, [0, 1, 4, 3, 6, 7, 9, 19]),        # Himbeere
    (20, [0, 1, 4, 3, 6, 7, 9, 17]),        # Johannisbeere
    (21, [0, 1, 4, 3, 6, 7, 9, 19]),        # Brombeere
    (22, [0, 1, 2, 3, 6, 7, 9, 13]),        # Melone
    (23, [0, 1, 2, 3, 6, 7, 9, 19]),        # Nektarine
    (24, [0, 1, 4, 3, 6, 7, 9, 16, 17]),    # Guave
    (25, [0, 1, 4, 3, 6, 7, 9, 14]),        # Litschi
    (26, [0, 1, 4, 3, 6, 7, 9, 14, 15]),    # Drachenfrucht
    (27, [0, 1, 4, 3, 6, 7, 9, 19]),        # Kaktusfeige
    (28, [0, 1, 4, 3, 6, 7, 9, 14]),        # Maracuja
    (29, [0, 1, 2, 3, 6, 7, 9, 20]),        # Quitte
    (30, [0, 1, 2, 3, 6, 7, 9, 17]),        # Sternfrucht
    (31, [0, 1, 4, 3, 6, 7, 9, 15]),        # Kumquat
    (32, [0, 1, 4, 3, 6, 7, 9, 16]),        # Mandarine
    (33, [0, 1, 4, 3, 6, 7, 9, 15, 17]),    # Cranberry
    (34, [0, 1, 4, 3, 6, 7, 9, 19]),        # Pflaume
    (35, [0, 1, 4, 3, 6, 7, 9, 15]),        # Kaktusbirne
    (36, [0, 1, 4, 3, 6, 7, 9, 20]),        # Jujube
    (37, [0, 1, 4, 3, 6, 7, 9, 16]),        # Physalis
    (38, [0, 1, 4, 3, 6, 7, 9, 14]),        # Pomelo
    (39, [0, 1, 4, 3, 6, 7, 9, 20]),        # Dattel
    (40, [0, 1, 4, 3, 6, 7, 9, 17]),        # Zuckerapfel
    (41, [0, 1, 4, 3, 6, 7, 9, 15, 19]),    # Schlehe
    (42, [0, 1, 4, 3, 6, 7, 9, 14, 17]),    # Kirschtomate
    (43, [0, 1, 4, 3, 6, 7, 9, 13, 15]),    # Cantaloupe
    (44, [0, 1, 4, 3, 6, 7, 9, 14]),        # Salak
    (45, [0, 1, 4, 3, 6, 7, 9, 16, 19]),    # Mangostan
    (46, [0, 1, 4, 3, 6, 7, 9, 14, 20]),    # Longan
    (47, [0, 1, 4, 3, 6, 7, 9, 17]),        # Rambutan
    (48, [0, 1, 4, 3, 6, 7, 9, 15, 16, 20]),# Maulbeere
    (49, [0, 1, 2, 3, 6, 7, 9, 19]),        # Mirabelle
    (50, [0, 1, 2, 3, 6, 7, 9, 14]),        # Nashi-Birne
    (51, [0, 1, 4, 3, 6, 7, 9, 15, 16]),    # Gojibeere
    (52, [0, 1, 4, 3, 6, 7, 9, 13, 17]),    # Pampelmuse
    (53, [0, 1, 4, 3, 6, 7, 9, 16]),        # Buddhas Hand
    (54, [0, 1, 2, 3, 6, 7, 9, 14, 15]),    # Rosenapfel
    (55, [0, 1, 4, 3, 6, 7, 9, 16]),        # Hagebutte
    (56, [0, 1, 4, 3, 6, 7, 9, 19]),        # Jackfrucht
    (57, [0, 1, 4, 3, 6, 7, 9, 17]),        # Akebia
    (58, [0, 1, 4, 3, 6, 7, 9, 15, 20]),    # Durian
    (59, [0, 1, 4, 3, 6, 7, 9, 16]),        # Sapote
    (60, [0, 1, 4, 3, 6, 7, 9, 14]),        # Satsuma
    (61, [0, 1, 4, 3, 6, 7, 9, 17]),        # Fingerlimette
    (62, [0, 1, 4, 3, 6, 7, 9, 15]),        # Loquat
    (63, [0, 1, 4, 3, 6, 7, 9, 16]),        # Cloudberry
    (64, [0, 1, 4, 3, 6, 7, 9, 17]),        # Ackerminze
    (65, [0, 1, 4, 3, 6, 7, 9, 15]),        # Kapstachelbeere
    (66, [0, 1, 4, 3, 6, 7, 9, 20]),        # Cherimoya
    (67, [0, 1, 4, 3, 6, 7, 9, 17]),        # Kaffirlimette
    (68, [0, 1, 4, 3, 6, 7, 9, 16]),        # Pepino
    (69, [0, 1, 4, 3, 6, 7, 9, 14]),        # Jocote
    (70, [0, 1, 4, 3, 6, 7, 9, 19]),        # Korallenbeere
    (71, [0, 1, 4, 3, 6, 7, 9, 15]),        # Medlar
    (72, [0, 1, 4, 3, 6, 7, 9, 16]),        # Santol
    (73, [0, 1, 4, 3, 6, 7, 9, 15]),        # Ugli-Frucht
    (74, [0, 1, 4, 3, 6, 7, 9, 13, 20]),    # Monstera
    (75, [0, 1, 4, 3, 6, 7, 9, 17]),        # Guanabana
    (76, [0, 1, 4, 3, 6, 7, 9, 15]),        # Hainbuche
    (77, [0, 1, 4, 3, 6, 7, 9, 16]),        # Jabotikaba
    (78, [0, 1, 4, 3, 6, 7, 9, 20]),        # Sapodilla
    (79, [0, 1, 4, 3, 6, 7, 9, 17]),        # Sauerampfer
    (80, [0, 1, 4, 3, 6, 7, 9, 14]),        # Weinbergpfirsich
    (81, [0, 1, 4, 3, 6, 7, 9, 15]),        # Wollmispel
    (82, [0, 1, 4, 3, 6, 7, 9, 16]),        # Starapple
    (83, [0, 1, 4, 3, 6, 7, 9, 17]),        # Ziziphus
    (84, [0, 1, 4, 3, 6, 7, 9, 20]),        # Ackerlupine
    (85, [0, 1, 4, 3, 6, 7, 9, 15]),        # Amerikanische Persimone
    (86, [0, 1, 4, 3, 6, 7, 9, 16]),        # Bitterorange
    (87, [0, 1, 4, 3, 6, 7, 9, 19]),        # Brotfrucht
    (88, [0, 1, 4, 3, 6, 7, 9, 17]),        # Kastanienkirsche
    (89, [0, 1, 4, 3, 6, 7, 9, 16]),        # Keule
    (90, [0, 1, 4, 3, 6, 7, 9, 20]),        # Mispel
    (91, [0, 1, 4, 3, 6, 7, 9, 15]),        # Paradiesfeige
    (92, [0, 1, 4, 3, 6, 7, 9, 14]),        # Prunus
    (93, [0, 1, 4, 3, 6, 7, 9, 17]),        # Purpurgranatapfel
    (94, [0, 1, 4, 3, 6, 7, 9, 16]),        # Schwarze Sapote
    (95, [0, 1, 4, 3, 6, 7, 9, 15]),        # Sommerhimbeere
    (96, [0, 1, 4, 3, 6, 7, 9, 17]),        # Tamarillo
    (97, [0, 1, 4, 3, 6, 7, 9, 14])         # Wachsapfel
]



# Obst
setDatabase( tags,foodsObst,nutritionObst_facts, foodObst_tags)