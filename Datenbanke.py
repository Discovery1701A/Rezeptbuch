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
    ("Stärkt die Verdauung",),
    ("Omega-3-reich",),
    ("Kollagenquelle",),
    ("Hoher Vitamin-B-Gehalt",),
    ("Geringer Fettgehalt",),
    ("Reich an Aminosäuren",),
    ("Gelenkgesundheit",),
    ("Muskelaufbau",),
    ("Gehalt an ungesättigten Fettsäuren",),
    ("Keto-freundlich",),
    ("Reich an Zink",),
    ("Laktosefrei",),
    ("Stärkt die Knochengesundheit",),
    ("Hochwertiges Eiweiß",),
    ("Hoher Selengehalt",),
    ("Fördert die Blutbildung",),
    ("Energiequelle",),
    ("Unterstützt die Gehirnfunktion",),
    ("Fettsäurereiches Fleisch",),
    ("Hoher Phosphorgehalt",),
    ("Paleo-freundlich",),
    ("Niedriger Kohlenhydratgehalt",),
    ("Reich an Kalium",),
    ("Stärkt das Nervensystem",),
    ("Fördert die Wundheilung",),
    ("Hoher Kupfergehalt",),
    ("Fördert den Zellaufbau",),
    ("Hoher Magnesiumgehalt",)
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


foodsFleisch = [
    ("Rinderfilet", "Fleisch", "Zartes Rinderfilet, reich an Protein und Eisen, ideal zum Kurzbraten."),
    ("Rinderhüfte", "Fleisch", "Saftiges Rinderhüftstück, mager und vielseitig verwendbar für Braten oder Steaks."),
    ("Rinderbrust", "Fleisch", "Fettarme Rinderbrust, gut geeignet für Schmorgerichte und Suppen."),
    ("Rinderknochenmark", "Fleisch", "Nahrhaftes Rinderknochenmark, reich an gesunden Fetten und Nährstoffen, ideal für Brühen."),
    ("Rinderhackfleisch", "Fleisch", "Mageres Rinderhackfleisch, ideal für Bolognese, Frikadellen oder Burger."),
    ("Rinderzunge", "Fleisch", "Zarte Rinderzunge, eine Delikatesse, die langsam gegart am besten schmeckt."),
    ("Rinderleber", "Fleisch", "Nährstoffreiche Rinderleber, reich an Vitamin A und Eisen, ideal für eine kräftige Mahlzeit."),
    ("Rinderschulter", "Fleisch", "Saftige Rinderschulter, perfekt für Schmorgerichte und Suppen."),
    ("Rindersteak", "Fleisch", "Klassisches Rindersteak, zart und saftig, ideal für den Grill oder die Pfanne."),
    ("Entrecôte (Rind)", "Fleisch", "Marmoriertes Entrecôte, reich an Geschmack, ideal für ein saftiges Steak."),
    ("Tafelspitz (Rind)", "Fleisch", "Traditioneller Tafelspitz, ideal für Kochfleisch oder Schmorgerichte."),
    ("Rinderbacke", "Fleisch", "Zarte Rinderbacke, ideal für langes Schmoren, bis das Fleisch butterzart ist."),
    ("Rinderkotelett", "Fleisch", "Saftiges Rinderkotelett, ideal für den Grill oder die Pfanne."),
    ("Kalbsfilet", "Fleisch", "Zartes Kalbsfilet, reich an Protein und ideal zum Kurzbraten."),
    ("Kalbsschnitzel", "Fleisch", "Mageres Kalbsschnitzel, ideal zum Panieren oder für leichte Gerichte."),
    ("Kalbsrücken", "Fleisch", "Kalbsrücken, mager und zart, ideal für Braten oder Steaks."),
    ("Kalbsbäckchen", "Fleisch", "Zarte Kalbsbäckchen, perfekt für lange Schmorgerichte."),
    ("Kalbshaxe", "Fleisch", "Saftige Kalbshaxe, ideal zum Schmoren, besonders als Osso Buco."),
    ("Kalbsleber", "Fleisch", "Nährstoffreiche Kalbsleber, reich an Vitamin A, ideal für kurze Bratzeiten."),
    ("Kalbsnieren", "Fleisch", "Zarte Kalbsnieren, eine Delikatesse, die langsam gegart wird."),
    ("Kalbszunge", "Fleisch", "Milde Kalbszunge, eine Delikatesse, die sanft gekocht am besten schmeckt."),
    ("Kalbsbrust", "Fleisch", "Fettarme Kalbsbrust, ideal für Füllungen oder zum Schmoren."),
    ("Schweinefilet", "Fleisch", "Mageres Schweinefilet, zart und saftig, ideal zum Kurzbraten."),
    ("Schweinebauch", "Fleisch", "Saftiger Schweinebauch, ideal für knusprige Braten oder asiatische Gerichte."),
    ("Schweinekotelett", "Fleisch", "Saftiges Schweinekotelett, ideal für den Grill oder die Pfanne."),
    ("Schweineschnitzel", "Fleisch", "Mageres Schweineschnitzel, ideal zum Panieren und Braten."),
    ("Schweineschulter", "Fleisch", "Schweineschulter, ideal zum Schmoren oder für Pulled Pork."),
    ("Schweinehaxe", "Fleisch", "Saftige Schweinehaxe, perfekt für lange Garzeiten und knusprige Haut."),
    ("Schweinerücken", "Fleisch", "Magerer Schweinerücken, ideal für Braten oder Steaks."),
    ("Schweineleber", "Fleisch", "Nährstoffreiche Schweineleber, ideal für deftige Gerichte."),
    ("Schweinebacke", "Fleisch", "Zarte Schweinebacke, ideal für Schmorgerichte."),
    ("Schweinespeck", "Fleisch", "Fettreicher Schweinespeck, ideal für das Würzen von Gerichten."),
    ("Schweineohren", "Fleisch", "Knusprige Schweineohren, oft als Delikatesse gegessen."),
    ("Schweinefuß", "Fleisch", "Schweinefuß, reich an Kollagen, ideal für Suppen und Brühen."),
    ("Schweineherz", "Fleisch", "Mageres Schweineherz, reich an Protein, ideal für deftige Gerichte."),
    ("Schweinezunge", "Fleisch", "Zarte Schweinezunge, eine Delikatesse, die langsam gegart am besten schmeckt."),
    ("Lammkeule", "Fleisch", "Saftige Lammkeule, ideal zum Schmoren oder für Braten."),
    ("Lammkotelett", "Fleisch", "Zarte Lammkoteletts, perfekt für den Grill oder die Pfanne."),
    ("Lammrücken", "Fleisch", "Magerer Lammrücken, ideal für Braten oder Steaks."),
    ("Lammhaxe", "Fleisch", "Saftige Lammhaxe, perfekt für langes Schmoren."),
    ("Lammschulter", "Fleisch", "Zarte Lammschulter, ideal für Schmorgerichte."),
    ("Lammfilet", "Fleisch", "Zartes Lammfilet, ideal zum Kurzbraten."),
    ("Lammleber", "Fleisch", "Nährstoffreiche Lammleber, reich an Eisen, ideal für deftige Gerichte."),
    ("Lammnieren", "Fleisch", "Zarte Lammnieren, eine Delikatesse, die langsam gegart wird."),
    ("Lammbrust", "Fleisch", "Saftige Lammbrust, ideal für Schmorgerichte."),
    ("Ziegenkeule", "Fleisch", "Zarte Ziegenkeule, ideal zum Schmoren oder für Braten."),
    ("Ziegenrücken", "Fleisch", "Magerer Ziegenrücken, ideal für Braten oder Steaks."),
    ("Ziegenkotelett", "Fleisch", "Zarte Ziegenkoteletts, perfekt für den Grill oder die Pfanne."),
    ("Ziegenfilet", "Fleisch", "Zartes Ziegenfilet, ideal zum Kurzbraten."),
    ("Hähnchenbrust", "Fleisch", "Mageres Hähnchenbrustfilet, reich an Protein, ideal zum Grillen oder Braten."),
    ("Hähnchenkeulen", "Fleisch", "Saftige Hähnchenkeulen, ideal für den Ofen oder Grill."),
    ("Hähnchenflügel", "Fleisch", "Knusprige Hähnchenflügel, ideal für den Grill oder die Fritteuse."),
    ("Hähnchenrücken", "Fleisch", "Hähnchenrücken, ideal für Suppen oder Brühen."),
    ("Hähnchenleber", "Fleisch", "Nährstoffreiche Hähnchenleber, ideal für herzhafte Gerichte."),
    ("Hähnchenherz", "Fleisch", "Mageres Hähnchenherz, ideal für deftige Gerichte."),
    ("Hähnchenflügelspitzen", "Fleisch", "Hähnchenflügelspitzen, ideal für Suppen oder Brühen."),
    ("Entenbrust", "Fleisch", "Zarte Entenbrust, ideal zum Kurzbraten oder Schmoren."),
    ("Entenkeulen", "Fleisch", "Saftige Entenkeulen, ideal zum Schmoren oder Braten."),
    ("Entenrücken", "Fleisch", "Entenrücken, ideal für Suppen oder Schmorgerichte."),
    ("Entenleber", "Fleisch", "Nährstoffreiche Entenleber, ideal für feine Pasteten."),
    ("Entenflügel", "Fleisch", "Knusprige Entenflügel, ideal zum Braten oder für die Fritteuse."),
    ("Entenhals", "Fleisch", "Entenhals, ideal für Suppen oder Schmorgerichte."),
    ("Gänsebrust", "Fleisch", "Zarte Gänsebrust, ideal für den Ofen oder zum Schmoren."),
    ("Gänsekeulen", "Fleisch", "Saftige Gänsekeulen, ideal zum Braten oder Schmoren."),
    ("Gänseleber", "Fleisch", "Nährstoffreiche Gänseleber, ideal für feine Gerichte oder Pasteten."),
    ("Gänseherz", "Fleisch", "Mageres Gänseherz, ideal für Schmorgerichte."),
    ("Gänsehals", "Fleisch", "Gänsehals, ideal für Suppen oder Brühen."),
    ("Wildschweinrücken", "Fleisch", "Magerer Wildschweinrücken, ideal für Braten oder Steaks."),
    ("Wildschweinkeule", "Fleisch", "Saftige Wildschweinkeule, ideal für lange Schmorgerichte."),
    ("Wildschweinfilet", "Fleisch", "Zartes Wildschweinfilet, ideal zum Kurzbraten."),
    ("Wildschweinhaxe", "Fleisch", "Saftige Wildschweinhaxe, ideal zum Schmoren."),
    ("Hirschrücken", "Fleisch", "Zarter Hirschrücken, ideal für Braten oder Steaks."),
    ("Hirschkeule", "Fleisch", "Saftige Hirschkeule, ideal für Schmorgerichte."),
    ("Hirschfilet", "Fleisch", "Zartes Hirschfilet, ideal zum Kurzbraten."),
    ("Hirschmedaillons", "Fleisch", "Zarte Hirschmedaillons, perfekt für edle Gerichte."),
    ("Rehrücken", "Fleisch", "Zarter Rehrücken, ideal für feine Braten."),
    ("Rehkeule", "Fleisch", "Saftige Rehkeule, ideal für Schmorgerichte."),
    ("Rehfilet", "Fleisch", "Zartes Rehfilet, ideal zum Kurzbraten."),
    ("Rehleber", "Fleisch", "Nährstoffreiche Rehleber, ideal für deftige Gerichte."),
    ("Taubenbrust", "Fleisch", "Zarte Taubenbrust, ideal für feine Gerichte."),
    ("Wachtelkeulen", "Fleisch", "Zarte Wachtelkeulen, ideal zum Kurzbraten."),
    ("Wachtelbrust", "Fleisch", "Zarte Wachtelbrust, ideal für edle Gerichte."),
    ("Kaninchenkeule", "Fleisch", "Zarte Kaninchenkeule, ideal zum Schmoren."),
    ("Kaninchenrücken", "Fleisch", "Zarter Kaninchenrücken, ideal für Braten."),
    ("Kaninchenleber", "Fleisch", "Nährstoffreiche Kaninchenleber, ideal für deftige Gerichte."),
    ("Ziegenherz", "Fleisch", "Mageres Ziegenherz, ideal für deftige Schmorgerichte."),
    ("Truthahnbrust", "Fleisch", "Mageres Truthahnbrustfilet, ideal für gesunde Gerichte."),
    ("Truthahnkeule", "Fleisch", "Saftige Truthahnkeule, ideal zum Schmoren."),
    ("Truthahnflügel", "Fleisch", "Knusprige Truthahnflügel, ideal zum Braten oder Grillen."),
    ("Straußenfilet", "Fleisch", "Zartes Straußenfilet, mager und reich an Protein."),
    ("Straußensteak", "Fleisch", "Saftiges Straußensteak, ideal zum Kurzbraten."),
    ("Kängurufilet", "Fleisch", "Mageres Kängurufilet, ideal für gesunde Gerichte."),
    ("Känguru-Hüftsteak", "Fleisch", "Zartes Känguru-Hüftsteak, ideal für den Grill."),
    ("Bisonfilet", "Fleisch", "Zartes Bisonfilet, mager und reich an Nährstoffen."),
    ("Bisonrücken", "Fleisch", "Magerer Bisonrücken, ideal für Braten."),
    ("Perlhuhnkeulen", "Fleisch", "Zarte Perlhuhnkeulen, ideal zum Braten."),
    ("Perlhuhnbrust", "Fleisch", "Zarte Perlhuhnbrust, ideal für edle Gerichte."),
    ("Fasanenbrust", "Fleisch", "Zarte Fasanenbrust, ideal für feine Gerichte."),
    ("Fasanenkeulen", "Fleisch", "Saftige Fasanenkeulen, ideal für Schmorgerichte."),
    ("Hasenrücken", "Fleisch", "Zarter Hasenrücken, ideal für feine Braten.")
]
nutritionFleisch_facts = [
    (123, 20.0, 0.0, 4.0),    # Rinderfilet
    (150, 21.0, 0.0, 7.0),    # Rinderhüfte
    (251, 17.0, 0.0, 20.0),   # Rinderbrust
    (786, 6.7, 0.0, 84.0),    # Rinderknochenmark
    (241, 19.0, 0.0, 17.0),   # Rinderhackfleisch
    (224, 16.0, 0.0, 17.0),   # Rinderzunge
    (135, 20.0, 3.0, 4.0),    # Rinderleber
    (175, 20.0, 0.0, 10.0),   # Rinderschulter
    (271, 25.0, 0.0, 18.0),   # Rindersteak
    (220, 20.0, 0.0, 15.0),   # Entrecôte (Rind)
    (102, 18.0, 0.0, 3.0),    # Tafelspitz (Rind)
    (206, 17.0, 0.0, 15.0),   # Rinderbacke
    (297, 25.0, 0.0, 22.0),   # Rinderkotelett
    (108, 20.0, 0.0, 3.0),    # Kalbsfilet
    (118, 21.0, 0.0, 4.0),    # Kalbsschnitzel
    (150, 19.0, 0.0, 7.0),    # Kalbsrücken
    (165, 18.0, 0.0, 9.0),    # Kalbsbäckchen
    (206, 16.0, 0.0, 15.0),   # Kalbshaxe
    (132, 19.0, 3.0, 5.0),    # Kalbsleber
    (87, 16.0, 0.0, 2.0),     # Kalbsnieren
    (226, 15.0, 0.0, 18.0),   # Kalbszunge
    (122, 19.0, 0.0, 5.0),    # Kalbsbrust
    (143, 22.0, 0.0, 5.0),    # Schweinefilet
    (518, 9.0, 0.0, 53.0),    # Schweinebauch
    (263, 18.0, 0.0, 21.0),   # Schweinekotelett
    (123, 21.0, 0.0, 3.0),    # Schweineschnitzel
    (239, 18.0, 0.0, 18.0),   # Schweineschulter
    (300, 15.0, 0.0, 26.0),   # Schweinehaxe
    (115, 23.0, 0.0, 2.0),    # Schweinerücken
    (139, 22.0, 0.0, 5.0),    # Schweineleber
    (210, 15.0, 0.0, 16.0),   # Schweinebacke
    (657, 7.0, 0.0, 70.0),    # Schweinespeck
    (337, 19.0, 0.0, 30.0),   # Schweineohren
    (216, 19.0, 0.0, 15.0),   # Schweinefuß
    (119, 21.0, 0.0, 4.0),    # Schweineherz
    (224, 16.0, 0.0, 17.0),   # Schweinezunge
    (179, 20.0, 0.0, 11.0),   # Lammkeule
    (282, 16.0, 0.0, 24.0),   # Lammkotelett
    (231, 20.0, 0.0, 17.0),   # Lammrücken
    (255, 18.0, 0.0, 20.0),   # Lammhaxe
    (218, 19.0, 0.0, 15.0),   # Lammschulter
    (125, 23.0, 0.0, 4.0),    # Lammfilet
    (139, 20.0, 3.0, 5.0),    # Lammleber
    (101, 17.0, 0.0, 3.0),    # Lammnieren
    (219, 18.0, 0.0, 16.0),   # Lammbrust
    (173, 21.0, 0.0, 10.0),   # Ziegenkeule
    (195, 23.0, 0.0, 12.0),   # Ziegenrücken
    (215, 19.0, 0.0, 16.0),   # Ziegenkotelett
    (135, 22.0, 0.0, 6.0),    # Ziegenfilet
    (120, 21.0, 0.0, 3.0),    # Hähnchenbrust
    (170, 18.0, 0.0, 11.0),   # Hähnchenkeulen
    (191, 16.0, 0.0, 14.0),   # Hähnchenflügel
    (137, 18.0, 0.0, 8.0),    # Hähnchenrücken
    (116, 17.0, 3.0, 4.0),    # Hähnchenleber
    (119, 20.0, 0.0, 4.0),    # Hähnchenherz
    (203, 15.0, 0.0, 16.0),   # Hähnchenflügelspitzen
    (201, 19.0, 0.0, 14.0),   # Entenbrust
    (221, 16.0, 0.0, 17.0),   # Entenkeulen
    (171, 20.0, 0.0, 11.0),   # Entenrücken
    (132, 18.0, 3.0, 5.0),    # Entenleber
    (236, 15.0, 0.0, 19.0),   # Entenflügel
    (124, 16.0, 0.0, 8.0),    # Entenhals
    (229, 20.0, 0.0, 17.0),   # Gänsebrust
    (269, 17.0, 0.0, 23.0),   # Gänsekeulen
    (130, 17.0, 3.0, 5.0),    # Gänseleber
    (129, 21.0, 0.0, 5.0),    # Gänseherz
    (147, 17.0, 0.0, 9.0),    # Gänsehals
    (123, 23.0, 0.0, 3.0),    # Wildschweinrücken
    (188, 20.0, 0.0, 13.0),   # Wildschweinkeule
    (119, 24.0, 0.0, 2.0),    # Wildschweinfilet
    (210, 19.0, 0.0, 15.0),   # Wildschweinhaxe
    (121, 25.0, 0.0, 2.0),    # Hirschrücken
    (184, 20.0, 0.0, 12.0),   # Hirschkeule
    (114, 24.0, 0.0, 1.0),    # Hirschfilet
    (127, 23.0, 0.0, 4.0),    # Hirschmedaillons
    (124, 22.0, 0.0, 3.0),    # Rehrücken
    (183, 21.0, 0.0, 11.0),   # Rehkeule
    (115, 23.0, 0.0, 2.0),    # Rehfilet
    (125, 19.0, 3.0, 5.0),    # Rehleber
    (124, 21.0, 0.0, 3.0),    # Taubenbrust
    (177, 18.0, 0.0, 12.0),   # Wachtelkeulen
    (125, 22.0, 0.0, 4.0),    # Wachtelbrust
    (167, 20.0, 0.0, 10.0),   # Kaninchenkeule
    (142, 23.0, 0.0, 6.0),    # Kaninchenrücken
    (131, 19.0, 3.0, 5.0),    # Kaninchenleber
    (110, 20.0, 0.0, 3.0),    # Ziegenherz
    (108, 24.0, 0.0, 1.0),    # Truthahnbrust
    (159, 18.0, 0.0, 10.0),   # Truthahnkeule
    (201, 16.0, 0.0, 15.0),   # Truthahnflügel
    (98, 22.0, 0.0, 1.0),     # Straußenfilet
    (105, 21.0, 0.0, 2.0),    # Straußensteak
    (101, 23.0, 0.0, 1.0),    # Kängurufilet
    (108, 22.0, 0.0, 3.0),    # Känguru-Hüftsteak
    (132, 24.0, 0.0, 4.0),    # Bisonfilet
    (115, 22.0, 0.0, 3.0),    # Bisonrücken
    (160, 18.0, 0.0, 11.0),   # Perlhuhnkeulen
    (132, 20.0, 0.0, 7.0),    # Perlhuhnbrust
    (142, 23.0, 0.0, 5.0),    # Fasanenbrust
    (179, 18.0, 0.0, 13.0),   # Fasanenkeulen
    (123, 22.0, 0.0, 3.0)     # Hasenrücken
]


foodFleisch_tags = [
    (0, [11, 25, 28, 29, 30, 33, 36]),    # Rinderfilet
    (1, [11, 25, 30, 33, 36]),             # Rinderhüfte
    (2, [11, 33, 36, 39]),                 # Rinderbrust
    (3, [23, 28, 40]),                     # Rinderknochenmark
    (4, [11, 33, 36]),                     # Rinderhackfleisch
    (5, [11, 25, 33, 36]),                 # Rinderzunge
    (6, [11, 19, 20, 21, 33]),             # Rinderleber
    (7, [11, 33, 36, 39]),                 # Rinderschulter
    (8, [11, 29, 33, 36]),                 # Rindersteak
    (9, [11, 28, 29, 36]),                 # Entrecôte (Rind)
    (10, [11, 25, 30, 33]),                # Tafelspitz (Rind)
    (11, [11, 28, 33, 36]),                # Rinderbacke
    (12, [11, 29, 33, 36]),                # Rinderkotelett
    (13, [11, 25, 30, 33, 36]),            # Kalbsfilet
    (14, [11, 25, 30, 33]),                # Kalbsschnitzel
    (15, [11, 30, 33, 36]),                # Kalbsrücken
    (16, [11, 28, 33]),                    # Kalbsbäckchen
    (17, [11, 33, 36]),                    # Kalbshaxe
    (18, [11, 19, 25, 33]),                # Kalbsleber
    (19, [11, 33, 36]),                    # Kalbsnieren
    (20, [11, 25, 33, 36]),                # Kalbszunge
    (21, [11, 30, 33, 36]),                # Kalbsbrust
    (22, [11, 25, 30, 33, 36]),            # Schweinefilet
    (23, [11, 36, 39]),                    # Schweinebauch
    (24, [11, 33, 36]),                    # Schweinekotelett
    (25, [11, 25, 30, 33]),                # Schweineschnitzel
    (26, [11, 33, 36]),                    # Schweineschulter
    (27, [11, 33, 36, 39]),                # Schweinehaxe
    (28, [11, 25, 30, 33]),                # Schweinerücken
    (29, [11, 19, 20, 33]),                # Schweineleber
    (30, [11, 33, 36]),                    # Schweinebacke
    (31, [23, 39]),                        # Schweinespeck
    (32, [11, 28, 33, 36]),                # Schweineohren
    (33, [11, 33, 36, 39]),                # Schweinefuß
    (34, [11, 25, 30, 33]),                # Schweineherz
    (35, [11, 25, 33, 36]),                # Schweinezunge
    (36, [11, 33, 36]),                    # Lammkeule
    (37, [11, 28, 29, 33, 36]),            # Lammkotelett
    (38, [11, 30, 33, 36]),                # Lammrücken
    (39, [11, 33, 36]),                    # Lammhaxe
    (40, [11, 33, 36]),                    # Lammschulter
    (41, [11, 25, 30, 33]),                # Lammfilet
    (42, [11, 19, 20, 33]),                # Lammleber
    (43, [11, 33, 36]),                    # Lammnieren
    (44, [11, 33, 36]),                    # Lammbrust
    (45, [11, 33, 36]),                    # Ziegenkeule
    (46, [11, 30, 33, 36]),                # Ziegenrücken
    (47, [11, 29, 33, 36]),                # Ziegenkotelett
    (48, [11, 25, 33, 36]),                # Ziegenfilet
    (49, [11, 25, 30, 33, 36]),            # Hähnchenbrust
    (50, [11, 33, 36]),                    # Hähnchenkeulen
    (51, [11, 33, 36, 39]),                # Hähnchenflügel
    (52, [11, 33, 36]),                    # Hähnchenrücken
    (53, [11, 19, 25, 33]),                # Hähnchenleber
    (54, [11, 25, 30, 33]),                # Hähnchenherz
    (55, [11, 33, 36, 39]),                # Hähnchenflügelspitzen
    (56, [11, 29, 33, 36]),                # Entenbrust
    (57, [11, 33, 36]),                    # Entenkeulen
    (58, [11, 33, 36]),                    # Entenrücken
    (59, [11, 19, 25, 33]),                # Entenleber
    (60, [11, 33, 36, 39]),                # Entenflügel
    (61, [11, 33, 36]),                    # Entenhals
    (62, [11, 29, 33, 36]),                # Gänsebrust
    (63, [11, 33, 36]),                    # Gänsekeulen
    (64, [11, 19, 25, 33]),                # Gänseleber
    (65, [11, 25, 33]),                    # Gänseherz
    (66, [11, 33, 36]),                    # Gänsehals
    (67, [11, 25, 30, 33, 36]),            # Wildschweinrücken
    (68, [11, 33, 36]),                    # Wildschweinkeule
    (69, [11, 25, 33, 36]),                # Wildschweinfilet
    (70, [11, 33, 36]),                    # Wildschweinhaxe
    (71, [11, 25, 30, 33, 36]),            # Hirschrücken
    (72, [11, 33, 36]),                    # Hirschkeule
    (73, [11, 25, 33, 36]),                # Hirschfilet
    (74, [11, 25, 30, 33]),                # Hirschmedaillons
    (75, [11, 25, 30, 33, 36]),            # Rehrücken
    (76, [11, 33, 36]),                    # Rehkeule
    (77, [11, 25, 33, 36]),                # Rehfilet
    (78, [11, 19, 25, 33]),                # Rehleber
    (79, [11, 25, 30, 33]),                # Taubenbrust
    (80, [11, 33, 36]),                    # Wachtelkeulen
    (81, [11, 25, 30, 33]),                # Wachtelbrust
    (82, [11, 33, 36]),                    # Kaninchenkeule
    (83, [11, 25, 30, 33]),                # Kaninchenrücken
    (84, [11, 19, 25, 33]),                # Kaninchenleber
    (85, [11, 25, 30, 33]),                # Ziegenherz
    (86, [11, 25, 30, 33, 36]),            # Truthahnbrust
    (87, [11, 33, 36]),                    # Truthahnkeule
    (88, [11, 33, 36, 39]),                # Truthahnflügel
    (89, [11, 25, 33, 36]),                # Straußenfilet
    (90, [11, 25, 29, 33]),                # Straußensteak
    (91, [11, 25, 30, 33, 36]),            # Kängurufilet
    (92, [11, 25, 30, 33]),                # Känguru-Hüftsteak
    (93, [11, 25, 30, 33]),                # Bisonfilet
    (94, [11, 25, 30, 33, 36]),            # Bisonrücken
    (95, [11, 33, 36]),                    # Perlhuhnkeulen
    (96, [11, 25, 30, 33]),                # Perlhuhnbrust
    (97, [11, 25, 30, 33]),                # Fasanenbrust
    (98, [11, 33, 36]),                    # Fasanenkeulen
    (99, [11, 25, 30, 33, 36])             # Hasenrücken
]

setDatabase(tags,foodsFleisch,nutritionFleisch_facts,foodFleisch_tags)

foodsFisch = [
    ("Aal", "Fisch", "Frischer Aal, reich an Omega-3-Fettsäuren, ideal zum Räuchern oder Braten."),
    ("Anchovis (Sardellen)", "Fisch", "Salzige Sardellen, ideal zum Verfeinern von Salaten oder Pastagerichten."),
    ("Barsch", "Fisch", "Magerer Barsch, ideal zum Grillen oder Braten."),
    ("Blaufisch", "Fisch", "Blaufisch, reich an Omega-3-Fettsäuren, ideal zum Backen oder Braten."),
    ("Butterfisch", "Fisch", "Zarter Butterfisch, reich an ungesättigten Fettsäuren, ideal zum Grillen."),
    ("Cicso", "Fisch", "Köstlicher Cicso, ideal zum Räuchern oder Braten."),
    ("Croaker", "Fisch", "Magerer Croaker, ideal zum Frittieren oder Grillen."),
    ("Fischstäbchen", "Fisch", "Panierte Fischstäbchen, besonders beliebt bei Kindern."),
    ("Goldmakrelen", "Fisch", "Zarte Goldmakrele, perfekt zum Grillen oder für Fisch-Tacos."),
    ("Hecht", "Fisch", "Magerer Hecht, ideal zum Braten oder für Fischsuppen."),
    ("Heilbutt", "Fisch", "Zarter Heilbutt, ideal zum Grillen oder Backen."),
    ("Hering", "Fisch", "Frischer Hering, ideal zum Einlegen oder Braten."),
    ("Kabeljau (Dorsch)", "Fisch", "Magerer Kabeljau, ideal zum Backen oder Braten."),
    ("Karpfen", "Fisch", "Frischer Karpfen, ideal zum Backen oder Braten."),
    ("Kaviar (Schwarz & Rot)", "Fisch", "Feiner Kaviar, ideal als edle Beilage oder Garnitur."),
    ("Lengfisch", "Fisch", "Magerer Lengfisch, ideal zum Grillen oder Braten."),
    ("Lingcod", "Fisch", "Zarter Lingcod, perfekt zum Braten oder Backen."),
    ("Lumb", "Fisch", "Milder Lumb, ideal für Schmorgerichte oder zum Grillen."),
    ("Makrele", "Fisch", "Ölige Makrele, reich an Omega-3, ideal zum Grillen oder Räuchern."),
    ("Mahi Mahi", "Fisch", "Zarter Mahi Mahi, ideal zum Grillen oder Braten."),
    ("Pangasius", "Fisch", "Milder Pangasius, ideal für einfache Gerichte oder zum Frittieren."),
    ("Rotbarsch", "Fisch", "Zarter Rotbarsch, ideal zum Braten oder Backen."),
    ("Sardinen", "Fisch", "Frische Sardinen, ideal zum Grillen oder Einlegen."),
    ("Schellfisch", "Fisch", "Magerer Schellfisch, ideal zum Räuchern oder Kochen."),
    ("Scholle", "Fisch", "Zarte Scholle, ideal zum Braten oder Pochieren."),
    ("Seelachs", "Fisch", "Magerer Seelachs, ideal für Backfisch oder zum Grillen."),
    ("Seeteufel", "Fisch", "Festfleischiger Seeteufel, ideal für edle Gerichte oder zum Grillen."),
    ("Seeforelle", "Fisch", "Zarte Seeforelle, ideal zum Grillen oder Braten."),
    ("Seesaibling", "Fisch", "Delikater Seesaibling, ideal zum Räuchern oder Braten."),
    ("Seewolf", "Fisch", "Festfleischiger Seewolf, ideal zum Grillen oder Braten."),
    ("Steinbutt", "Fisch", "Zarter Steinbutt, ideal für feine Fischgerichte."),
    ("Stör", "Fisch", "Magerer Stör, ideal zum Grillen oder für edle Gerichte."),
    ("Tilapia", "Fisch", "Milder Tilapia, ideal zum Braten oder Backen."),
    ("Thunfisch", "Fisch", "Festfleischiger Thunfisch, ideal zum Grillen oder für Sushi."),
    ("Wels", "Fisch", "Saftiger Wels, ideal zum Grillen oder Braten."),
    ("Zander", "Fisch", "Zarter Zander, ideal für edle Fischgerichte."),
    ("Alaska-Seelachs", "Fisch", "Magerer Alaska-Seelachs, ideal für Fischstäbchen oder zum Backen."),
    ("Atlantischer Lachs", "Fisch", "Öliger Lachs, reich an Omega-3, ideal zum Grillen oder Räuchern."),
    ("Barramundi", "Fisch", "Zarter Barramundi, ideal zum Braten oder Grillen."),
    ("Dorade", "Fisch", "Mild-aromatische Dorade, ideal zum Grillen oder Braten."),
    ("Flunder", "Fisch", "Zarte Flunder, ideal zum Braten oder Pochieren."),
    ("Heilbutt (geräuchert)", "Fisch", "Geräucherter Heilbutt, ideal als kalte Vorspeise."),
    ("Hering (geräuchert)", "Fisch", "Geräucherter Hering, ideal als Aufschnitt oder für Salate."),
    ("Lachs (geräuchert)", "Fisch", "Geräucherter Lachs, perfekt für Bagels oder Vorspeisen."),
    ("Makrele (geräuchert)", "Fisch", "Geräucherte Makrele, reich an Omega-3, ideal als Aufschnitt."),
    ("Sardinen (geräuchert)", "Fisch", "Geräucherte Sardinen, ideal als Vorspeise oder Snack."),
    ("Scholle (geräuchert)", "Fisch", "Geräucherte Scholle, ideal für kalte Vorspeisen."),
    ("Seelachs (geräuchert)", "Fisch", "Geräucherter Seelachs, ideal als Aufschnitt oder für Salate."),
    ("Thunfisch (geräuchert)", "Fisch", "Geräucherter Thunfisch, ideal als edler Aufschnitt."),
    ("Aal (geräuchert)", "Fisch", "Geräucherter Aal, eine Delikatesse, ideal als Vorspeise."),
    ("Forelle (geräuchert)", "Fisch", "Geräucherte Forelle, ideal als Vorspeise oder Aufschnitt."),
    ("Karpfen (geräuchert)", "Fisch", "Geräucherter Karpfen, ideal für kalte Gerichte."),
    ("Wels (geräuchert)", "Fisch", "Geräucherter Wels, ideal als Aufschnitt oder Vorspeise."),
    ("Zander (geräuchert)", "Fisch", "Geräucherter Zander, ideal als edle Vorspeise."),
    ("Garnelen", "Meeresfrüchte", "Saftige Garnelen, ideal zum Grillen, Braten oder für Salate."),
    ("Krabben", "Meeresfrüchte", "Frische Krabben, ideal für Salate oder Pasta."),
    ("Hummer", "Meeresfrüchte", "Edler Hummer, ideal für festliche Anlässe und edle Gerichte."),
    ("Languste", "Meeresfrüchte", "Zarte Languste, ideal für gehobene Gerichte oder zum Grillen."),
    ("Miesmuscheln", "Meeresfrüchte", "Frische Miesmuscheln, ideal für Suppen oder Pasta."),
    ("Jakobsmuscheln", "Meeresfrüchte", "Zarte Jakobsmuscheln, ideal zum Braten oder für edle Gerichte."),
    ("Austern", "Meeresfrüchte", "Frische Austern, ideal als edle Vorspeise."),
    ("Tintenfisch", "Meeresfrüchte", "Zarter Tintenfisch, ideal zum Grillen oder Frittieren."),
    ("Oktopus", "Meeresfrüchte", "Zarter Oktopus, ideal zum Schmoren oder Grillen."),
    ("Kalmare", "Meeresfrüchte", "Frische Kalmare, ideal zum Frittieren oder Grillen."),
    ("Seeigel", "Meeresfrüchte", "Seeigelrogen, eine Delikatesse, ideal als Vorspeise."),
    ("Seegurken", "Meeresfrüchte", "Zarte Seegurken, ideal für asiatische Gerichte."),
    ("Venusmuscheln", "Meeresfrüchte", "Zarte Venusmuscheln, ideal für Suppen oder Pasta."),
    ("Herzmuscheln", "Meeresfrüchte", "Frische Herzmuscheln, ideal für Pastagerichte."),
    ("Schnecken", "Meeresfrüchte", "Frische Schnecken, ideal für französische Gerichte."),
    ("Seespinne", "Meeresfrüchte", "Frische Seespinne, ideal für Salate oder als Vorspeise."),
    ("Taschenkrebse", "Meeresfrüchte", "Frische Taschenkrebse, ideal zum Grillen oder Kochen."),
    ("Königskrabbe", "Meeresfrüchte", "Edle Königskrabbe, ideal für gehobene Gerichte."),
    ("Kaisergranat", "Meeresfrüchte", "Zarter Kaisergranat, ideal für edle Vorspeisen."),
    ("Sepia", "Meeresfrüchte", "Frische Sepia, ideal zum Grillen oder Frittieren."),
    ("Wolfsbarsch", "Fisch", "Zarter Wolfsbarsch, ideal zum Braten oder Grillen."),
    ("Sardelle", "Fisch", "Salzige Sardelle, ideal zum Verfeinern von Gerichten."),
    ("Bonito", "Fisch", "Zarter Bonito, ideal zum Grillen oder Braten."),
    ("Glattbutt", "Fisch", "Milder Glattbutt, ideal für feine Fischgerichte."),
    ("Schwarzbarsch", "Fisch", "Magerer Schwarzbarsch, ideal zum Grillen oder Braten."),
    ("Flussbarsch", "Fisch", "Milder Flussbarsch, ideal für leichte Gerichte."),
    ("Schleie", "Fisch", "Frische Schleie, ideal zum Braten oder Räuchern."),
    ("Hornhecht", "Fisch", "Hornhecht, ideal zum Grillen oder Braten."),
    ("Seezunge", "Fisch", "Delikate Seezunge, ideal zum Braten oder Dünsten."),
    ("Rotflossen-Salmler", "Fisch", "Milder Rotflossen-Salmler, ideal für Suppen und leichte Gerichte."),
    ("Makaira (Speerfisch)", "Fisch", "Fester Makaira, ideal zum Grillen oder Braten."),
    ("Trevally (Goldmakrele)", "Fisch", "Goldmakrele, ideal zum Grillen oder für Fisch-Tacos."),
    ("Schwertfisch", "Fisch", "Fester Schwertfisch, ideal zum Grillen oder Braten."),
    ("Gelbschwanzmakrele", "Fisch", "Zarte Gelbschwanzmakrele, ideal zum Grillen."),
    ("Seehecht", "Fisch", "Magerer Seehecht, ideal für Suppen und Braten."),
    ("Graskarpfen", "Fisch", "Frischer Graskarpfen, ideal zum Braten oder Grillen."),
    ("Karpfen (Wild)", "Fisch", "Wilder Karpfen, ideal zum Backen oder Braten."),
    ("Süßwasserkrebs", "Meeresfrüchte", "Frische Süßwasserkrebse, ideal für Suppen und Salate."),
    ("Langustenschwanz", "Meeresfrüchte", "Zarter Langustenschwanz, ideal für edle Gerichte."),
    ("Meeräsche", "Fisch", "Milde Meeräsche, ideal zum Braten oder Grillen."),
    ("Lippfisch", "Fisch", "Zarter Lippfisch, ideal für leichte Fischgerichte."),
    ("Steinbeißer", "Fisch", "Fester Steinbeißer, ideal für Grill- und Schmorgerichte."),
    ("Wolfshering", "Fisch", "Frischer Wolfshering, ideal zum Braten."),
    ("Seehasenrogen", "Meeresfrüchte", "Delikater Seehasenrogen, ideal als Garnitur."),
    ("Glasaal", "Fisch", "Junger Aal, ideal zum Räuchern."),
    ("Zackenbarsch", "Fisch", "Fester Zackenbarsch, ideal für Grillgerichte.")
]

nutritionFisch_facts = [
    (184, 18.0, 0.0, 11.0),   # Aal
    (210, 20.0, 0.0, 15.0),   # Anchovis (Sardellen)
    (105, 23.0, 0.0, 2.0),    # Barsch
    (186, 20.0, 0.0, 11.0),   # Blaufisch
    (191, 14.0, 0.0, 16.0),   # Butterfisch
    (88, 18.0, 0.0, 1.0),     # Cicso
    (111, 20.0, 0.0, 3.0),    # Croaker
    (200, 15.0, 20.0, 10.0),  # Fischstäbchen
    (85, 19.0, 0.0, 1.0),     # Goldmakrelen
    (97, 21.0, 0.0, 1.0),     # Hecht
    (186, 18.0, 0.0, 13.0),   # Heilbutt
    (158, 19.0, 0.0, 9.0),    # Hering
    (82, 18.0, 0.0, 1.0),     # Kabeljau (Dorsch)
    (127, 17.0, 0.0, 6.0),    # Karpfen
    (264, 25.0, 4.0, 18.0),   # Kaviar (Schwarz & Rot)
    (100, 23.0, 0.0, 1.0),    # Lengfisch
    (85, 20.0, 0.0, 1.0),     # Lingcod
    (120, 21.0, 0.0, 4.0),    # Lumb
    (205, 19.0, 0.0, 13.0),   # Makrele
    (90, 20.0, 0.0, 2.0),     # Mahi Mahi
    (80, 15.0, 0.0, 3.0),     # Pangasius
    (110, 20.0, 0.0, 2.0),    # Rotbarsch
    (208, 24.0, 0.0, 11.0),   # Sardinen
    (90, 20.0, 0.0, 1.0),     # Schellfisch
    (80, 18.0, 0.0, 1.0),     # Scholle
    (112, 20.0, 0.0, 4.0),    # Seelachs
    (97, 21.0, 0.0, 2.0),     # Seeteufel
    (103, 20.0, 0.0, 3.0),    # Seeforelle
    (104, 19.0, 0.0, 3.0),    # Seesaibling
    (96, 22.0, 0.0, 1.0),     # Seewolf
    (95, 17.0, 0.0, 2.0),     # Steinbutt
    (105, 21.0, 0.0, 3.0),    # Stör
    (96, 26.0, 0.0, 1.0),     # Tilapia
    (144, 24.0, 0.0, 5.0),    # Thunfisch
    (80, 16.0, 0.0, 3.0),     # Wels
    (84, 20.0, 0.0, 1.0),     # Zander
    (82, 19.0, 0.0, 1.0),     # Alaska-Seelachs
    (208, 20.0, 0.0, 14.0),   # Atlantischer Lachs
    (110, 19.0, 0.0, 3.0),    # Barramundi
    (96, 18.0, 0.0, 3.0),     # Dorade
    (83, 17.0, 0.0, 1.0),     # Flunder
    (190, 19.0, 0.0, 13.0),   # Heilbutt (geräuchert)
    (217, 18.0, 0.0, 16.0),   # Hering (geräuchert)
    (203, 22.0, 0.0, 13.0),   # Lachs (geräuchert)
    (205, 21.0, 0.0, 15.0),   # Makrele (geräuchert)
    (235, 25.0, 0.0, 17.0),   # Sardinen (geräuchert)
    (178, 18.0, 0.0, 13.0),   # Scholle (geräuchert)
    (190, 20.0, 0.0, 12.0),   # Seelachs (geräuchert)
    (222, 25.0, 0.0, 15.0),   # Thunfisch (geräuchert)
    (281, 22.0, 0.0, 25.0),   # Aal (geräuchert)
    (190, 20.0, 0.0, 13.0),   # Forelle (geräuchert)
    (179, 18.0, 0.0, 12.0),   # Karpfen (geräuchert)
    (188, 19.0, 0.0, 13.0),   # Wels (geräuchert)
    (174, 21.0, 0.0, 10.0),   # Zander (geräuchert)
    (99, 24.0, 0.0, 0.8),     # Garnelen
    (82, 18.0, 0.0, 1.0),     # Krabben
    (91, 19.0, 0.0, 2.0),     # Hummer
    (112, 20.0, 0.0, 2.0),    # Languste
    (86, 12.0, 4.0, 2.0),     # Miesmuscheln
    (102, 21.0, 0.0, 1.0),    # Jakobsmuscheln
    (81, 9.0, 4.5, 2.5),      # Austern
    (175, 15.0, 1.0, 13.0),   # Tintenfisch
    (82, 14.0, 1.0, 1.0),     # Oktopus
    (92, 16.0, 1.0, 1.5),     # Kalmare
    (87, 9.0, 5.0, 4.0),      # Seeigel
    (58, 5.0, 3.0, 0.8),      # Seegurken
    (77, 13.0, 4.0, 1.0),     # Venusmuscheln
    (70, 10.0, 2.0, 1.0),     # Herzmuscheln
    (95, 16.0, 0.0, 1.5),     # Schnecken
    (82, 17.0, 0.0, 1.0),     # Seespinne
    (96, 19.0, 0.0, 2.0),     # Taschenkrebse
    (84, 18.0, 0.0, 1.5),     # Königskrabbe
    (92, 19.0, 0.0, 1.2),     # Kaisergranat
    (76, 15.0, 0.5, 1.0),     # Sepia
    (91, 19.0, 0.0, 1.0),     # Wolfsbarsch
    (105, 22.0, 0.0, 2.0),    # Sardelle
    (112, 25.0, 0.0, 1.0),    # Bonito
    (90, 21.0, 0.0, 1.0),     # Glattbutt
    (125, 19.0, 0.0, 5.0),    # Schwarzbarsch
    (84, 20.0, 0.0, 1.0),     # Flussbarsch
    (91, 19.0, 0.0, 2.0),     # Schleie
    (110, 21.0, 0.0, 3.0),    # Hornhecht
    (95, 18.0, 0.0, 1.5),     # Seezunge
    (103, 20.0, 0.0, 2.0),    # Rotflossen-Salmler
    (102, 22.0, 0.0, 1.5),    # Makaira (Speerfisch)
    (100, 19.0, 0.0, 1.2),    # Trevally (Goldmakrele)
    (120, 24.0, 0.0, 4.0),    # Schwertfisch
    (108, 20.0, 0.0, 3.0),    # Gelbschwanzmakrele
    (92, 19.0, 0.0, 2.0),     # Seehecht
    (110, 18.0, 0.0, 3.0),    # Graskarpfen
    (96, 17.0, 0.0, 2.0),     # Karpfen (Wild)
    (89, 15.0, 0.0, 1.5),     # Süßwasserkrebs
    (102, 20.0, 0.0, 2.5),    # Langustenschwanz
    (88, 16.0, 0.0, 1.5),     # Meeräsche
    (100, 18.0, 0.0, 2.0),    # Lippfisch
    (110, 19.0, 0.0, 2.0),    # Steinbeißer
    (92, 16.0, 0.0, 2.0),     # Wolfshering
    (210, 25.0, 0.0, 20.0),   # Seehasenrogen
    (155, 19.0, 0.0, 12.0),   # Glasaal
    (95, 20.0, 0.0, 2.0)      # Zackenbarsch
]

foodFisch_tags = [
    (0, [11, 23, 28, 33]),    # Aal
    (1, [11, 28, 31, 36]),     # Anchovis (Sardellen)
    (2, [11, 25, 33]),         # Barsch
    (3, [11, 23, 28]),         # Blaufisch
    (4, [11, 28, 36]),         # Butterfisch
    (5, [11, 25, 33]),         # Cicso
    (6, [11, 25, 33]),         # Croaker
    (7, [11, 26, 36]),         # Fischstäbchen
    (8, [11, 25, 33]),         # Goldmakrelen
    (9, [11, 25, 33]),         # Hecht
    (10, [11, 25, 33]),        # Heilbutt
    (11, [11, 23, 28]),        # Hering
    (12, [11, 25, 33]),        # Kabeljau (Dorsch)
    (13, [11, 25, 33]),        # Karpfen
    (14, [11, 28, 36]),        # Kaviar (Schwarz & Rot)
    (15, [11, 25, 33]),        # Lengfisch
    (16, [11, 25, 33]),        # Lingcod
    (17, [11, 25, 33]),        # Lumb
    (18, [11, 23, 28, 33]),    # Makrele
    (19, [11, 25, 33]),        # Mahi Mahi
    (20, [11, 25, 33]),        # Pangasius
    (21, [11, 25, 33]),        # Rotbarsch
    (22, [11, 28, 33]),        # Sardinen
    (23, [11, 25, 33]),        # Schellfisch
    (24, [11, 25, 33]),        # Scholle
    (25, [11, 25, 33]),        # Seelachs
    (26, [11, 25, 33]),        # Seeteufel
    (27, [11, 25, 33]),        # Seeforelle
    (28, [11, 25, 33]),        # Seesaibling
    (29, [11, 25, 33]),        # Seewolf
    (30, [11, 25, 33]),        # Steinbutt
    (31, [11, 25, 33]),        # Stör
    (32, [11, 25, 33]),        # Tilapia
    (33, [11, 23, 28, 33]),    # Thunfisch
    (34, [11, 25, 33]),        # Wels
    (35, [11, 25, 33]),        # Zander
    (36, [11, 25, 33]),        # Alaska-Seelachs
    (37, [11, 23, 28, 33]),    # Atlantischer Lachs
    (38, [11, 25, 33]),        # Barramundi
    (39, [11, 25, 33]),        # Dorade
    (40, [11, 25, 33]),        # Flunder
    (41, [11, 28, 33]),        # Heilbutt (geräuchert)
    (42, [11, 28, 33]),        # Hering (geräuchert)
    (43, [11, 28, 33]),        # Lachs (geräuchert)
    (44, [11, 28, 33]),        # Makrele (geräuchert)
    (45, [11, 28, 33]),        # Sardinen (geräuchert)
    (46, [11, 28, 33]),        # Scholle (geräuchert)
    (47, [11, 28, 33]),        # Seelachs (geräuchert)
    (48, [11, 28, 33]),        # Thunfisch (geräuchert)
    (49, [11, 28, 33]),        # Aal (geräuchert)
    (50, [11, 28, 33]),        # Forelle (geräuchert)
    (51, [11, 28, 33]),        # Karpfen (geräuchert)
    (52, [11, 28, 33]),        # Wels (geräuchert)
    (53, [11, 28, 33]),        # Zander (geräuchert)
    (54, [11, 25, 33]),        # Garnelen
    (55, [11, 25, 33]),        # Krabben
    (56, [11, 25, 33]),        # Hummer
    (57, [11, 25, 33]),        # Languste
    (58, [11, 25, 33]),        # Miesmuscheln
    (59, [11, 25, 33]),        # Jakobsmuscheln
    (60, [11, 25, 33]),        # Austern
    (61, [11, 25, 33]),        # Tintenfisch
    (62, [11, 25, 33]),        # Oktopus
    (63, [11, 25, 33]),        # Kalmare
    (64, [11, 25, 33]),        # Seeigel
    (65, [11, 25, 33]),        # Seegurken
    (66, [11, 25, 33]),        # Venusmuscheln
    (67, [11, 25, 33]),        # Herzmuscheln
    (68, [11, 25, 33]),        # Schnecken
    (69, [11, 25, 33]),        # Seespinne
    (70, [11, 25, 33]),        # Taschenkrebse
    (71, [11, 25, 33]),        # Königskrabbe
    (72, [11, 25, 33]),        # Kaisergranat
    (73, [11, 25, 33]),        # Sepia
    (74, [11, 25, 33]),        # Wolfsbarsch
    (75, [11, 28, 33]),        # Sardelle
    (76, [11, 25, 33]),        # Bonito
    (77, [11, 25, 33]),        # Glattbutt
    (78, [11, 25, 33]),        # Schwarzbarsch
    (79, [11, 25, 33]),        # Flussbarsch
    (80, [11, 25, 33]),        # Schleie
    (81, [11, 25, 33]),        # Hornhecht
    (82, [11, 25, 33]),        # Seezunge
    (83, [11, 25, 33]),        # Rotflossen-Salmler
    (84, [11, 25, 33]),        # Makaira (Speerfisch)
    (85, [11, 25, 33]),        # Trevally (Goldmakrele)
    (86, [11, 25, 33]),        # Schwertfisch
    (87, [11, 25, 33]),        # Gelbschwanzmakrele
    (88, [11, 25, 33]),        # Seehecht
    (89, [11, 25, 33]),        # Graskarpfen
    (90, [11, 25, 33]),        # Karpfen (Wild)
    (91, [11, 25, 33]),        # Süßwasserkrebs
    (92, [11, 25, 33]),        # Langustenschwanz
    (93, [11, 25, 33]),        # Meeräsche
    (94, [11, 25, 33]),        # Lippfisch
    (95, [11, 25, 33]),        # Steinbeißer
    (96, [11, 25, 33]),        # Wolfshering
    (97, [11, 28, 33]),        # Seehasenrogen
    (98, [11, 28, 33]),        # Glasaal
    (99, [11, 25, 33])         # Zackenbarsch
]

setDatabase(tags,foodsFisch,nutritionFisch_facts,foodFisch_tags)


foodsMilchprodukte = [
    ("Vollmilch", "Milchprodukt", "Frische Vollmilch, reich an Kalzium und Vitaminen, ideal zum Trinken oder Backen."),
    ("Magermilch", "Milchprodukt", "Fettarme Magermilch, ideal für kalorienbewusste Ernährung."),
    ("Halbfettmilch", "Milchprodukt", "Halbfettmilch, ideal für den täglichen Gebrauch."),
    ("H-Milch", "Milchprodukt", "Haltbare Milch, ideal für längere Lagerung."),
    ("Laktosefreie Milch", "Milchprodukt", "Milch ohne Laktose, ideal für Menschen mit Laktoseintoleranz."),
    ("Buttermilch", "Milchprodukt", "Leicht säuerliche Buttermilch, ideal zum Backen oder als Getränk."),
    ("Kondensmilch", "Milchprodukt", "Eingedickte Milch, ideal für Kaffee oder Desserts."),
    ("Kaffeesahne", "Milchprodukt", "Sahne für Kaffee, verleiht dem Kaffee eine cremige Note."),
    ("Sahne", "Milchprodukt", "Frische Sahne, ideal zum Verfeinern von Speisen."),
    ("Schlagsahne", "Milchprodukt", "Sahne zum Aufschlagen, ideal für Desserts."),
    ("Sauerrahm", "Milchprodukt", "Sauerrahm, ideal für Dips und Dressings."),
    ("Crème fraîche", "Milchprodukt", "Französische Creme, ideal zum Kochen und Backen."),
    ("Saure Sahne", "Milchprodukt", "Säuerliche Sahne, ideal für Dips und Dressings."),
    ("Schmand", "Milchprodukt", "Schmand, ideal für herzhafte und süße Gerichte."),
    ("Mascarpone", "Milchprodukt", "Italienischer Frischkäse, ideal für Desserts wie Tiramisu."),
    ("Ricotta", "Milchprodukt", "Italienischer Käse, ideal für süße und herzhafte Gerichte."),
    ("Frischkäse", "Milchprodukt", "Weicher Frischkäse, ideal als Brotaufstrich oder für Dips."),
    ("Doppelrahmfrischkäse", "Milchprodukt", "Besonders cremiger Frischkäse, ideal als Brotaufstrich."),
    ("Hüttenkäse (Cottage Cheese)", "Milchprodukt", "Körniger Frischkäse, ideal für Salate und als Snack."),
    ("Quark", "Milchprodukt", "Milder Quark, ideal für süße und herzhafte Gerichte."),
    ("Speisequark (Magerstufe)", "Milchprodukt", "Magerer Quark, ideal für eine kalorienbewusste Ernährung."),
    ("Speisequark (Halbfettstufe)", "Milchprodukt", "Quark mit Halbfett, ideal für verschiedene Speisen."),
    ("Skyr", "Milchprodukt", "Isländischer Joghurt, reich an Protein, ideal als Snack."),
    ("Kefir", "Milchprodukt", "Gesunder Kefir, reich an Probiotika, ideal als Getränk."),
    ("Joghurt (Natur)", "Milchprodukt", "Natürlicher Joghurt, ideal für Frühstück und Desserts."),
    ("Joghurt (Griechisch)", "Milchprodukt", "Cremiger griechischer Joghurt, reich an Protein."),
    ("Joghurt (Laktosefrei)", "Milchprodukt", "Joghurt ohne Laktose, ideal für Menschen mit Laktoseintoleranz."),
    ("Trinkjoghurt", "Milchprodukt", "Flüssiger Joghurt, ideal als Getränk für unterwegs."),
    ("Fruchtjoghurt", "Milchprodukt", "Joghurt mit Fruchtzusatz, ideal als süßer Snack."),
    ("Ayran", "Milchprodukt", "Salziges Joghurtgetränk, ideal zu herzhaften Speisen."),
    ("Molke", "Milchprodukt", "Flüssigkeit aus der Käseherstellung, reich an Nährstoffen."),
    ("Dickmilch", "Milchprodukt", "Dickmilch, ideal für Desserts und als Getränk."),
    ("Käsescheiben", "Milchprodukt", "Fertig geschnittene Käsescheiben, ideal für Sandwiches."),
    ("Gouda", "Milchprodukt", "Milder bis würziger Käse, ideal als Brotbelag oder zum Überbacken."),
    ("Edamer", "Milchprodukt", "Milder Edamer, ideal für Sandwiches oder als Snack."),
    ("Emmentaler", "Milchprodukt", "Käse mit Löchern, ideal zum Überbacken."),
    ("Butterkäse", "Milchprodukt", "Milder Käse, ideal als Brotbelag oder zum Überbacken."),
    ("Bergkäse", "Milchprodukt", "Kräftiger Bergkäse, ideal zum Überbacken oder als Snack."),
    ("Camembert", "Milchprodukt", "Weichkäse mit weißer Rinde, ideal als Vorspeise."),
    ("Brie", "Milchprodukt", "Weichkäse, ideal für Käseplatten und Vorspeisen."),
    ("Blauschimmelkäse", "Milchprodukt", "Würziger Blauschimmelkäse, ideal für Saucen und als Snack."),
    ("Gorgonzola", "Milchprodukt", "Italienischer Blauschimmelkäse, ideal für Saucen."),
    ("Roquefort", "Milchprodukt", "Französischer Blauschimmelkäse, ideal für Salate und Saucen."),
    ("Feta", "Milchprodukt", "Griechischer Käse, ideal für Salate."),
    ("Ziegenkäse", "Milchprodukt", "Würziger Ziegenkäse, ideal für Salate und als Vorspeise."),
    ("Hirtenkäse", "Milchprodukt", "Milder Käse, ähnlich Feta, ideal für Salate."),
    ("Mozzarella", "Milchprodukt", "Frischer Mozzarella, ideal für Salate und Pizza."),
    ("Burrata", "Milchprodukt", "Cremiger Mozzarella, ideal für Salate und als Vorspeise."),
    ("Parmesan", "Milchprodukt", "Hartkäse, ideal zum Reiben für Pasta."),
    ("Pecorino", "Milchprodukt", "Italienischer Hartkäse aus Schafsmilch, ideal für Pasta."),
    ("Halloumi", "Milchprodukt", "Grillkäse, ideal zum Braten oder Grillen."),
    ("Provolone", "Milchprodukt", "Italienischer Käse, ideal zum Überbacken."),
    ("Raclette-Käse", "Milchprodukt", "Käse für Raclette, ideal zum Schmelzen."),
    ("Appenzeller", "Milchprodukt", "Schweizer Käse, ideal für Käseplatten."),
    ("Tilsiter", "Milchprodukt", "Halbfester Käse, ideal als Brotbelag."),
    ("Limburger", "Milchprodukt", "Würziger Käse, ideal für deftige Gerichte."),
    ("Harzer Käse", "Milchprodukt", "Magerer Sauermilchkäse, ideal als Snack."),
    ("Handkäse", "Milchprodukt", "Würziger Sauermilchkäse, ideal für Salate."),
    ("Butter", "Milchprodukt", "Frische Butter, ideal zum Kochen, Backen und als Brotaufstrich."),
    ("Süßrahmbutter", "Milchprodukt", "Butter aus Süßrahm, ideal zum Backen und Kochen."),
    ("Sauerrahmbutter", "Milchprodukt", "Butter aus Sauerrahm, ideal als Brotaufstrich."),
    ("Gesalzene Butter", "Milchprodukt", "Butter mit Salz, ideal als Brotaufstrich."),
    ("Butterschmalz", "Milchprodukt", "Geklärtes Butterfett, ideal zum Braten."),
    ("Ghee", "Milchprodukt", "Geklärte Butter, ideal für die indische Küche."),
    ("Milchpulver", "Milchprodukt", "Getrocknete Milch, ideal für die Vorratshaltung."),
    ("Vollmilchpulver", "Milchprodukt", "Pulverisierte Vollmilch, ideal für die Vorratshaltung."),
    ("Magermilchpulver", "Milchprodukt", "Pulverisierte Magermilch, ideal für kalorienarme Rezepte."),
    ("Joghurtpulver", "Milchprodukt", "Pulverisierter Joghurt, ideal für Smoothies und Desserts."),
    ("Molkenpulver", "Milchprodukt", "Pulverisierte Molke, ideal für Shakes."),
    ("Sahnepulver", "Milchprodukt", "Pulverisierte Sahne, ideal zum Verfeinern von Speisen."),
    ("Käsefondue-Mischung", "Milchprodukt", "Fertig gemischte Käsefondue-Mischung, ideal für Fondue."),
    ("Rahmspinat (Milchbasis)", "Milchprodukt", "Cremiger Spinat mit Rahm, ideal als Beilage."),
    ("Milchspeiseeis", "Milchprodukt", "Cremiges Milcheis, ideal als Dessert."),
    ("Softeis", "Milchprodukt", "Cremiges Softeis, ideal als Dessert."),
    ("Frozen Joghurt", "Milchprodukt", "Gefrorener Joghurt, ideal als kalorienarmes Dessert."),
    ("Karamellmilch", "Milchprodukt", "Gesüßte Milch mit Karamellgeschmack, ideal als Getränk."),
    ("Vanillemilch", "Milchprodukt", "Gesüßte Milch mit Vanillegeschmack, ideal als Getränk."),
    ("Schokoladenmilch", "Milchprodukt", "Gesüßte Milch mit Schokoladengeschmack, ideal als Getränk."),
    ("Erdbeermilch", "Milchprodukt", "Gesüßte Milch mit Erdbeergeschmack, ideal als Getränk."),
    ("Käsecreme", "Milchprodukt", "Cremiger Käseaufstrich, ideal als Brotbelag."),
    ("Streichkäse", "Milchprodukt", "Weicher Käse zum Streichen, ideal als Brotaufstrich."),
    ("Käserinde (essbar)", "Milchprodukt", "Essbare Käserinde, ideal als Snack."),
    ("Quarkcreme", "Milchprodukt", "Cremiger Quark, ideal für Desserts."),
    ("Zaziki", "Milchprodukt", "Griechischer Joghurt-Dip mit Gurken und Knoblauch."),
    ("Lassi", "Milchprodukt", "Indisches Joghurtgetränk, ideal als Erfrischung."),
    ("Rahmkäse", "Milchprodukt", "Cremiger Käse, ideal als Brotbelag oder für Saucen."),
    ("Fromage blanc", "Milchprodukt", "Französischer Frischkäse, ideal für Desserts und als Brotaufstrich."),
    ("Petit Suisse", "Milchprodukt", "Kleiner französischer Frischkäse, ideal als Dessert."),
    ("Crème double", "Milchprodukt", "Sehr fetthaltige Sahne, ideal für Desserts."),
    ("Milchreis", "Milchprodukt", "Gekochter Reis in Milch, ideal als Dessert."),
    ("Kondensmilch (gezuckert)", "Milchprodukt", "Gezuckerte Kondensmilch, ideal für Desserts."),
    ("Ricotta salata", "Milchprodukt", "Gesalzener Ricotta, ideal zum Reiben."),
    ("Labneh", "Milchprodukt", "Abgetropfter Joghurt, ideal als Brotaufstrich."),
    ("Queso fresco", "Milchprodukt", "Frischer mexikanischer Käse, ideal für Salate."),
    ("Paneer", "Milchprodukt", "Indischer Frischkäse, ideal für Currygerichte."),
    ("Clotted Cream", "Milchprodukt", "Dicke Sahne, ideal für Scones."),
    ("Devonshire Cream", "Milchprodukt", "Cremige Sahne, ideal für Scones."),
    ("Crème Bavaroise", "Milchprodukt", "Französisches Dessert auf Sahnebasis."),
    ("Milchkaramell", "Milchprodukt", "Karamell auf Milchbasis, ideal als Süßigkeit."),
    ("Milchprotein (Casein)", "Milchprodukt", "Milchprotein, ideal für Proteinshakes.")
]

nutritionMilchprodukte_facts = [
    (64, 3.4, 4.8, 3.6),   # Vollmilch
    (34, 3.4, 5.0, 0.1),   # Magermilch
    (46, 3.4, 4.9, 1.5),   # Halbfettmilch
    (61, 3.4, 4.8, 3.5),   # H-Milch
    (42, 3.4, 4.8, 1.5),   # Laktosefreie Milch
    (35, 3.5, 4.0, 0.5),   # Buttermilch
    (135, 7.9, 10.0, 7.5), # Kondensmilch
    (118, 3.1, 4.4, 10.0), # Kaffeesahne
    (195, 2.0, 3.0, 19.0), # Sahne
    (337, 2.0, 3.0, 35.0), # Schlagsahne
    (136, 2.6, 4.0, 10.0), # Sauerrahm
    (292, 2.9, 3.8, 30.0), # Crème fraîche
    (186, 3.0, 4.5, 20.0), # Saure Sahne
    (240, 2.7, 3.2, 24.0), # Schmand
    (429, 4.5, 4.6, 42.0), # Mascarpone
    (174, 11.3, 3.3, 13.0), # Ricotta
    (253, 5.5, 4.0, 25.0), # Frischkäse
    (350, 4.0, 4.2, 33.0), # Doppelrahmfrischkäse
    (98, 11.5, 3.4, 4.3),  # Hüttenkäse (Cottage Cheese)
    (68, 12.8, 3.9, 0.2),  # Quark
    (49, 13.0, 4.0, 0.1),  # Speisequark (Magerstufe)
    (104, 11.0, 3.7, 5.0), # Speisequark (Halbfettstufe)
    (63, 11.0, 4.0, 0.2),  # Skyr
    (64, 3.5, 4.0, 1.0),   # Kefir
    (61, 3.5, 4.0, 3.5),   # Joghurt (Natur)
    (115, 5.0, 4.0, 10.0), # Joghurt (Griechisch)
    (57, 3.5, 4.0, 1.5),   # Joghurt (Laktosefrei)
    (75, 3.1, 11.0, 1.5),  # Trinkjoghurt
    (100, 3.0, 14.0, 1.5), # Fruchtjoghurt
    (40, 3.5, 4.5, 1.0),   # Ayran
    (23, 0.9, 5.2, 0.1),   # Molke
    (62, 3.1, 5.0, 3.8),   # Dickmilch
    (312, 24.0, 1.5, 24.0), # Käsescheiben
    (356, 24.9, 0.1, 28.0), # Gouda
    (347, 25.0, 0.1, 26.0), # Edamer
    (381, 29.0, 0.1, 30.0), # Emmentaler
    (322, 23.0, 0.1, 26.0), # Butterkäse
    (413, 28.0, 0.1, 33.0), # Bergkäse
    (300, 20.0, 0.1, 24.0), # Camembert
    (334, 21.0, 0.1, 27.0), # Brie
    (353, 21.0, 2.0, 29.0), # Blauschimmelkäse
    (354, 18.0, 2.0, 32.0), # Gorgonzola
    (369, 18.0, 2.0, 31.0), # Roquefort
    (265, 14.0, 4.0, 22.0), # Feta
    (305, 21.0, 0.1, 25.0), # Ziegenkäse
    (258, 15.0, 0.1, 22.0), # Hirtenkäse
    (253, 18.0, 2.0, 17.0), # Mozzarella
    (330, 17.0, 2.0, 25.0), # Burrata
    (431, 36.0, 0.1, 29.0), # Parmesan
    (387, 29.0, 0.1, 30.0), # Pecorino
    (321, 21.0, 1.0, 25.0), # Halloumi
    (351, 26.0, 2.0, 27.0), # Provolone
    (340, 24.0, 0.1, 28.0), # Raclette-Käse
    (377, 27.0, 0.1, 32.0), # Appenzeller
    (330, 23.0, 0.1, 26.0), # Tilsiter
    (327, 20.0, 0.1, 27.0), # Limburger
    (122, 29.0, 1.0, 0.5),  # Harzer Käse
    (133, 30.0, 1.0, 0.6),  # Handkäse
    (717, 0.8, 0.1, 81.0),  # Butter
    (720, 0.8, 0.1, 82.0),  # Süßrahmbutter
    (718, 0.6, 0.1, 81.5),  # Sauerrahmbutter
    (721, 0.8, 0.1, 82.0),  # Gesalzene Butter
    (879, 0.2, 0.1, 99.8),  # Butterschmalz
    (900, 0.0, 0.0, 100.0), # Ghee
    (496, 27.0, 38.0, 26.0), # Milchpulver
    (496, 27.0, 38.0, 26.0), # Vollmilchpulver
    (353, 36.0, 51.0, 1.0),  # Magermilchpulver
    (333, 27.0, 55.0, 1.5),  # Joghurtpulver
    (360, 12.0, 72.0, 1.0),  # Molkenpulver
    (460, 5.0, 50.0, 25.0),  # Sahnepulver
    (292, 13.0, 1.0, 24.0),  # Käsefondue-Mischung
    (70, 3.0, 4.0, 3.0),    # Rahmspinat (Milchbasis)
    (207, 4.0, 22.0, 11.0), # Milchspeiseeis
    (184, 3.0, 21.0, 8.0),  # Softeis
    (113, 4.5, 19.0, 3.0),  # Frozen Joghurt
    (70, 3.0, 11.0, 1.0),   # Karamellmilch
    (65, 3.0, 11.0, 1.0),   # Vanillemilch
    (90, 3.0, 13.0, 3.0),   # Schokoladenmilch
    (75, 3.0, 11.0, 2.0),   # Erdbeermilch
    (310, 7.0, 3.0, 30.0),  # Käsecreme
    (250, 7.0, 2.0, 24.0),  # Streichkäse
    (120, 7.0, 1.0, 10.0),  # Käserinde (essbar)
    (140, 8.0, 3.0, 10.0),  # Quarkcreme
    (100, 5.0, 2.0, 7.0),   # Zaziki
    (82, 3.0, 13.0, 1.0),   # Lassi
    (310, 20.0, 3.0, 26.0), # Rahmkäse
    (150, 7.0, 3.0, 11.0),  # Fromage blanc
    (210, 10.0, 5.0, 15.0), # Petit Suisse
    (400, 2.0, 2.0, 42.0),  # Crème double
    (150, 3.0, 25.0, 3.0),  # Milchreis
    (321, 8.0, 55.0, 9.0),  # Kondensmilch (gezuckert)
    (298, 22.0, 3.0, 22.0), # Ricotta salata
    (147, 10.0, 5.0, 10.0), # Labneh
    (113, 9.0, 4.0, 7.0),   # Queso fresco
    (92, 9.0, 6.0, 5.0),    # Paneer
    (586, 2.0, 2.0, 60.0),  # Clotted Cream
    (567, 2.0, 2.0, 58.0),  # Devonshire Cream
    (210, 5.0, 18.0, 15.0), # Crème Bavaroise
    (398, 5.0, 75.0, 10.0), # Milchkaramell
    (380, 30.0, 0.0, 2.0)   # Milchprotein (Casein)
]


foodMilchprodukte_tags = [
    (0, [11, 25, 33]),    # Vollmilch
    (1, [11, 25, 34]),    # Magermilch
    (2, [11, 25, 33]),    # Halbfettmilch
    (3, [11, 25, 33]),    # H-Milch
    (4, [11, 25, 34, 36]),# Laktosefreie Milch
    (5, [11, 25, 36]),    # Buttermilch
    (6, [11, 25, 36]),    # Kondensmilch
    (7, [11, 25, 36]),    # Kaffeesahne
    (8, [11, 25, 36]),    # Sahne
    (9, [11, 25, 36]),    # Schlagsahne
    (10, [11, 25, 36]),   # Sauerrahm
    (11, [11, 25, 36]),   # Crème fraîche
    (12, [11, 25, 36]),   # Saure Sahne
    (13, [11, 25, 36]),   # Schmand
    (14, [11, 25, 36]),   # Mascarpone
    (15, [11, 25, 36]),   # Ricotta
    (16, [11, 25, 36]),   # Frischkäse
    (17, [11, 25, 36]),   # Doppelrahmfrischkäse
    (18, [11, 25, 34]),   # Hüttenkäse (Cottage Cheese)
    (19, [11, 25, 34]),   # Quark
    (20, [11, 25, 34]),   # Speisequark (Magerstufe)
    (21, [11, 25, 34]),   # Speisequark (Halbfettstufe)
    (22, [11, 25, 34]),   # Skyr
    (23, [11, 25, 34]),   # Kefir
    (24, [11, 25, 34]),   # Joghurt (Natur)
    (25, [11, 25, 34]),   # Joghurt (Griechisch)
    (26, [11, 25, 34, 36]),# Joghurt (Laktosefrei)
    (27, [11, 25, 34]),   # Trinkjoghurt
    (28, [11, 25, 34]),   # Fruchtjoghurt
    (29, [11, 25, 34]),   # Ayran
    (30, [11, 25, 34]),   # Molke
    (31, [11, 25, 34]),   # Dickmilch
    (32, [11, 25, 34]),   # Käsescheiben
    (33, [11, 25, 34]),   # Gouda
    (34, [11, 25, 34]),   # Edamer
    (35, [11, 25, 34]),   # Emmentaler
    (36, [11, 25, 34]),   # Butterkäse
    (37, [11, 25, 34]),   # Bergkäse
    (38, [11, 25, 34]),   # Camembert
    (39, [11, 25, 34]),   # Brie
    (40, [11, 25, 34]),   # Blauschimmelkäse
    (41, [11, 25, 34]),   # Gorgonzola
    (42, [11, 25, 34]),   # Roquefort
    (43, [11, 25, 34]),   # Feta
    (44, [11, 25, 34]),   # Ziegenkäse
    (45, [11, 25, 34]),   # Hirtenkäse
    (46, [11, 25, 34]),   # Mozzarella
    (47, [11, 25, 34]),   # Burrata
    (48, [11, 25, 34]),   # Parmesan
    (49, [11, 25, 34]),   # Pecorino
    (50, [11, 25, 34]),   # Halloumi
    (51, [11, 25, 34]),   # Provolone
    (52, [11, 25, 34]),   # Raclette-Käse
    (53, [11, 25, 34]),   # Appenzeller
    (54, [11, 25, 34]),   # Tilsiter
    (55, [11, 25, 34]),   # Limburger
    (56, [11, 25, 34]),   # Harzer Käse
    (57, [11, 25, 34]),   # Handkäse
    (58, [11, 25, 34]),   # Butter
    (59, [11, 25, 34]),   # Süßrahmbutter
    (60, [11, 25, 34]),   # Sauerrahmbutter
    (61, [11, 25, 34]),   # Gesalzene Butter
    (62, [11, 25, 34]),   # Butterschmalz
    (63, [11, 25, 34]),   # Ghee
    (64, [11, 25, 34]),   # Milchpulver
    (65, [11, 25, 34]),   # Vollmilchpulver
    (66, [11, 25, 34]),   # Magermilchpulver
    (67, [11, 25, 34]),   # Joghurtpulver
    (68, [11, 25, 34]),   # Molkenpulver
    (69, [11, 25, 34]),   # Sahnepulver
    (70, [11, 25, 34]),   # Käsefondue-Mischung
    (71, [11, 25, 34]),   # Rahmspinat (Milchbasis)
    (72, [11, 25, 34]),   # Milchspeiseeis
    (73, [11, 25, 34]),   # Softeis
    (74, [11, 25, 34]),   # Frozen Joghurt
    (75, [11, 25, 34]),   # Karamellmilch
    (76, [11, 25, 34]),   # Vanillemilch
    (77, [11, 25, 34]),   # Schokoladenmilch
    (78, [11, 25, 34]),   # Erdbeermilch
    (79, [11, 25, 34]),   # Käsecreme
    (80, [11, 25, 34]),   # Streichkäse
    (81, [11, 25, 34]),   # Käserinde (essbar)
    (82, [11, 25, 34]),   # Quarkcreme
    (83, [11, 25, 34]),   # Zaziki
    (84, [11, 25, 34]),   # Lassi
    (85, [11, 25, 34]),   # Rahmkäse
    (86, [11, 25, 34]),   # Fromage blanc
    (87, [11, 25, 34]),   # Petit Suisse
    (88, [11, 25, 34]),   # Crème double
    (89, [11, 25, 34]),   # Milchreis
    (90, [11, 25, 34]),   # Kondensmilch (gezuckert)
    (91, [11, 25, 34]),   # Ricotta salata
    (92, [11, 25, 34]),   # Labneh
    (93, [11, 25, 34]),   # Queso fresco
    (94, [11, 25, 34]),   # Paneer
    (95, [11, 25, 34]),   # Clotted Cream
    (96, [11, 25, 34]),   # Devonshire Cream
    (97, [11, 25, 34]),   # Crème Bavaroise
    (98, [11, 25, 34]),   # Milchkaramell
    (99, [11, 25, 34])    # Milchprotein (Casein)
]

setDatabase(tags,foodsMilchprodukte,nutritionMilchprodukte_facts,foodMilchprodukte_tags)


foodsGetreide_Hülsenfrüchte = [
    ("Mais", "Getreide", "Mais, reich an Ballaststoffen, ideal für Suppen und Salate."),
    ("Reis", "Getreide", "Weißer oder brauner Reis, vielseitig verwendbar als Beilage."),
    ("Quinoa", "Pseudogetreide", "Proteinreiche Quinoa, ideal für Salate und Bowls."),
    ("Amaranth", "Pseudogetreide", "Amaranth, reich an Nährstoffen, ideal für Frühstücksgerichte."),
    ("Kamut", "Getreide", "Kamut, ein altes Getreide, reich an Proteinen und Ballaststoffen."),
    ("Emmer", "Getreide", "Emmer, ein Urgetreide, ideal für Brot und Backwaren."),
    ("Teff", "Pseudogetreide", "Kleines, proteinreiches Teff, ideal für glutenfreies Backen."),
    ("Sorghum", "Getreide", "Sorghum, reich an Ballaststoffen, ideal als Mehlersatz."),
    ("Wildreis", "Getreide", "Wildreis, nussiger Geschmack, ideal für Salate und Beilagen."),
    ("Grünkern", "Getreide", "Grünkern, gerösteter Dinkel, ideal für Aufläufe und Eintöpfe."),
    ("Bulgur", "Getreide", "Bulgur, vorgekochter Weizen, ideal für Salate und Beilagen."),
    ("Couscous", "Getreide", "Couscous, schnell zubereitet, ideal für Salate und Beilagen."),
    ("Polenta", "Getreide", "Maisgrieß, ideal als Beilage oder gebraten."),
    ("Gerstengraupen", "Getreide", "Graupen aus Gerste, ideal für Suppen und Eintöpfe."),
    ("Weizengrieß", "Getreide", "Grieß aus Weizen, ideal für Brei und Aufläufe."),
    ("Dinkelgrieß", "Getreide", "Grieß aus Dinkel, ideal für Breie und Backwaren."),
    ("Haferflocken", "Getreide", "Haferflocken, ideal für Frühstücksbrei und Müslis."),
    ("Weizenkleie", "Getreide", "Weizenkleie, reich an Ballaststoffen, ideal für Joghurts."),
    ("Haferkleie", "Getreide", "Haferkleie, ideal zur Förderung der Verdauung."),
    ("Dinkelkleie", "Getreide", "Dinkelkleie, reich an Ballaststoffen, ideal für Smoothies."),
    ("Reisflocken", "Getreide", "Reisflocken, ideal für glutenfreies Frühstück."),
    ("Hirseflocken", "Getreide", "Hirseflocken, ideal für Breie und Müslis."),
    ("Quinoaflocken", "Pseudogetreide", "Quinoaflocken, reich an Proteinen, ideal für Frühstück."),
    ("Amaranthflocken", "Pseudogetreide", "Amaranthflocken, ideal für gesunde Snacks und Müslis."),
    ("Buchweizenflocken", "Pseudogetreide", "Buchweizenflocken, ideal für glutenfreie Ernährung."),
    ("Maismehl", "Getreide", "Maismehl, ideal für glutenfreie Backwaren."),
    ("Reismehl", "Getreide", "Reismehl, ideal für glutenfreie Backwaren."),
    ("Weizenmehl", "Getreide", "Allzweckmehl aus Weizen, ideal für Brot und Gebäck."),
    ("Dinkelmehl", "Getreide", "Mehl aus Dinkel, ideal für Brot und Kuchen."),
    ("Roggenmehl", "Getreide", "Mehl aus Roggen, ideal für herzhafte Brote."),
    ("Hafermehl", "Getreide", "Mehl aus Hafer, ideal für glutenfreie Rezepte."),
    ("Hirsemehl", "Getreide", "Hirsemehl, ideal für glutenfreies Backen."),
    ("Buchweizenmehl", "Pseudogetreide", "Buchweizenmehl, ideal für Pfannkuchen und Backwaren."),
    ("Quinoamehl", "Pseudogetreide", "Quinoamehl, reich an Nährstoffen, ideal für Backen."),
    ("Amaranthmehl", "Pseudogetreide", "Amaranthmehl, ideal für proteinreiche Backwaren."),
    ("Kichererbsenmehl", "Hülsenfrüchte", "Mehl aus Kichererbsen, ideal für Pfannkuchen und Teigwaren."),
    ("Sojamehl", "Hülsenfrüchte", "Mehl aus Sojabohnen, ideal für proteinreiche Backwaren."),
    ("Linsenmehl", "Hülsenfrüchte", "Mehl aus Linsen, ideal für herzhafte Gerichte."),
    ("Erbsenmehl", "Hülsenfrüchte", "Mehl aus Erbsen, ideal für Suppen und Saucen."),
    ("Kichererbsen", "Hülsenfrüchte", "Proteinreiche Kichererbsen, ideal für Hummus und Eintöpfe."),
    ("Linsen", "Hülsenfrüchte", "Linsen, reich an Ballaststoffen, ideal für Suppen und Currys."),
    ("Erbsen", "Hülsenfrüchte", "Grüne Erbsen, ideal für Suppen und Beilagen."),
    ("Sojabohnen", "Hülsenfrüchte", "Proteinreiche Sojabohnen, ideal für Tofu und Tempeh."),
    ("Kidneybohnen", "Hülsenfrüchte", "Rote Kidneybohnen, ideal für Eintöpfe und Salate."),
    ("Schwarze Bohnen", "Hülsenfrüchte", "Schwarze Bohnen, ideal für Suppen und Burritos."),
    ("Weiße Bohnen", "Hülsenfrüchte", "Weiße Bohnen, ideal für Eintöpfe und Suppen."),
    ("Pintobohnen", "Hülsenfrüchte", "Pintobohnen, ideal für mexikanische Gerichte."),
    ("Limabohnen", "Hülsenfrüchte", "Limabohnen, cremige Konsistenz, ideal für Suppen."),
    ("Mungbohnen", "Hülsenfrüchte", "Mungbohnen, ideal für Keimlinge und Currys."),
    ("Adzukibohnen", "Hülsenfrüchte", "Adzukibohnen, ideal für Süßspeisen und Eintöpfe."),
    ("Favabohnen (Ackerbohnen)", "Hülsenfrüchte", "Favabohnen, ideal für Suppen und Salate."),
    ("Grüne Bohnen", "Hülsenfrüchte", "Grüne Bohnen, ideal als Beilage oder in Salaten."),
    ("Wachsbohnen", "Hülsenfrüchte", "Wachsbohnen, ideal als Beilage."),
    ("Zuckerschoten", "Hülsenfrüchte", "Zuckerschoten, ideal für asiatische Gerichte und Salate."),
    ("Edamame", "Hülsenfrüchte", "Grüne Sojabohnen, ideal als Snack oder in Salaten."),
    ("Lupinen", "Hülsenfrüchte", "Lupinen, proteinreich, ideal als Fleischersatz."),
    ("Kichererbsensprossen", "Sprossen", "Kichererbsensprossen, ideal für Salate."),
    ("Linsensprossen", "Sprossen", "Linsensprossen, ideal für Salate und Sandwiches."),
    ("Mungbohnensprossen", "Sprossen", "Mungbohnensprossen, ideal für asiatische Gerichte."),
    ("Sojasprossen", "Sprossen", "Sojasprossen, ideal für asiatische Wokgerichte."),
    ("Alfalfa-Sprossen", "Sprossen", "Alfalfa-Sprossen, ideal für Salate und Sandwiches."),
    ("Bambussprossen", "Sprossen", "Knackige Bambussprossen, ideal für asiatische Gerichte."),
    ("Okraschoten", "Gemüse", "Okraschoten, ideal für Eintöpfe und als Gemüsebeilage."),
    ("Johannisbrot", "Hülsenfrüchte", "Johannisbrot, ideal als natürlicher Süßstoff und für Backwaren."),
    ("Tempeh", "Sojaprodukt", "Gärprodukt aus Sojabohnen, ideal als Fleischersatz."),
    ("Tofu", "Sojaprodukt", "Proteinreicher Tofu, ideal für vegane und vegetarische Gerichte."),
    ("Seitan", "Weizenprodukt", "Proteinreicher Seitan, ideal als Fleischersatz."),
    ("Texturiertes Soja", "Sojaprodukt", "Texturiertes Soja, ideal als Fleischersatz in Eintöpfen."),
    ("Sojamilch", "Pflanzendrink", "Milchalternative aus Sojabohnen, ideal für Veganer."),
    ("Reismilch", "Pflanzendrink", "Leichte Milchalternative aus Reis, ideal für Menschen mit Laktoseintoleranz."),
    ("Hafermilch", "Pflanzendrink", "Cremige Milchalternative aus Hafer, ideal für Kaffee."),
    ("Mandeldrink", "Pflanzendrink", "Milchalternative aus Mandeln, ideal für Smoothies."),
    ("Dinkeldrink", "Pflanzendrink", "Milchalternative aus Dinkel, ideal für Frühstücksflocken."),
    ("Hanfdrink", "Pflanzendrink", "Milchalternative aus Hanf, reich an Omega-3-Fettsäuren."),
    ("Kokosdrink", "Pflanzendrink", "Leichte Milchalternative aus Kokos, ideal für tropische Gerichte."),
    ("Quinoadrink", "Pflanzendrink", "Proteinreiche Milchalternative aus Quinoa, ideal für Veganer."),
    ("Amaranthdrink", "Pflanzendrink", "Milchalternative aus Amaranth, ideal für eine abwechslungsreiche Ernährung."),
    ("Buchweizendrink", "Pflanzendrink", "Milchalternative aus Buchweizen, ideal für glutenfreie Ernährung."),
    ("Erdnüsse", "Nüsse", "Knackige Erdnüsse, ideal als Snack oder zum Kochen."),
    ("Cashewnüsse", "Nüsse", "Cremige Cashewnüsse, ideal als Snack oder für vegane Saucen."),
    ("Mandeln", "Nüsse", "Mandeln, ideal als Snack oder zum Backen."),
    ("Haselnüsse", "Nüsse", "Haselnüsse, ideal zum Backen und für Nussmischungen."),
    ("Walnüsse", "Nüsse", "Walnüsse, reich an Omega-3-Fettsäuren, ideal für Salate."),
    ("Pistazien", "Nüsse", "Grüne Pistazien, ideal als Snack oder zum Backen."),
    ("Macadamianüsse", "Nüsse", "Cremige Macadamianüsse, ideal als Snack oder für Desserts."),
    ("Paranüsse", "Nüsse", "Paranüsse, reich an Selen, ideal als Snack."),
    ("Pekannüsse", "Nüsse", "Milde Pekannüsse, ideal für Kuchen und Desserts."),
    ("Kastanien", "Nüsse", "Kastanien, ideal zum Rösten oder für Füllungen."),
    ("Kürbiskerne", "Samen", "Knackige Kürbiskerne, ideal als Snack oder für Salate."),
    ("Sonnenblumenkerne", "Samen", "Sonnenblumenkerne, ideal als Topping für Salate und Brote."),
    ("Chiasamen", "Samen", "Chiasamen, reich an Omega-3-Fettsäuren, ideal für Puddings."),
    ("Leinsamen", "Samen", "Leinsamen, reich an Ballaststoffen, ideal für Müsli und Brot."),
]


nutritionGetreideHülsenfrüchte_facts = [
    (86, 3.2, 19.0, 1.2),   # Mais
    (130, 2.7, 28.0, 0.3),  # Reis
    (120, 4.1, 21.3, 1.9),  # Quinoa
    (102, 3.8, 19.0, 1.6),  # Amaranth
    (337, 14.0, 69.0, 2.7), # Kamut
    (339, 13.0, 72.0, 2.8), # Emmer
    (367, 13.3, 73.0, 2.1), # Teff
    (329, 10.6, 72.0, 3.3), # Sorghum
    (357, 14.7, 74.9, 1.0), # Wildreis
    (337, 11.8, 63.4, 2.7), # Grünkern
    (342, 12.3, 76.7, 1.3), # Bulgur
    (112, 3.8, 23.0, 0.6),  # Couscous
    (371, 8.0, 79.0, 1.0),  # Polenta
    (354, 9.9, 73.5, 2.3),  # Gerstengraupen
    (351, 11.2, 73.0, 1.0), # Weizengrieß
    (352, 12.0, 72.0, 2.0), # Dinkelgrieß
    (389, 13.5, 66.3, 7.0), # Haferflocken
    (216, 15.5, 64.5, 5.0), # Weizenkleie
    (246, 17.3, 66.2, 7.0), # Haferkleie
    (192, 12.4, 65.2, 4.8), # Dinkelkleie
    (381, 7.5, 80.8, 0.8),  # Reisflocken
    (360, 9.7, 75.0, 3.5),  # Hirseflocken
    (376, 14.0, 68.9, 5.7), # Quinoaflocken
    (374, 15.6, 68.0, 4.8), # Amaranthflocken
    (343, 13.6, 71.5, 3.4), # Buchweizenflocken
    (351, 7.1, 79.0, 1.2),  # Maismehl
    (366, 5.9, 80.0, 0.8),  # Reismehl
    (364, 10.0, 72.5, 1.0), # Weizenmehl
    (355, 11.0, 67.0, 1.8), # Dinkelmehl
    (324, 9.0, 70.0, 1.7),  # Roggenmehl
    (389, 12.6, 66.3, 6.5), # Hafermehl
    (365, 9.8, 73.0, 4.2),  # Hirsemehl
    (343, 13.6, 71.5, 3.4), # Buchweizenmehl
    (373, 13.3, 68.9, 5.4), # Quinoamehl
    (363, 14.5, 66.4, 5.4), # Amaranthmehl
    (387, 22.0, 57.8, 6.7), # Kichererbsenmehl
    (449, 43.3, 28.8, 19.9),# Sojamehl
    (340, 25.0, 58.0, 1.5), # Linsenmehl
    (347, 24.0, 59.0, 1.2), # Erbsenmehl
    (364, 19.3, 61.0, 6.0), # Kichererbsen
    (353, 25.0, 60.0, 1.5), # Linsen
    (81, 5.4, 14.5, 0.4),   # Erbsen
    (446, 36.5, 30.2, 19.9),# Sojabohnen
    (337, 24.0, 60.0, 1.0), # Kidneybohnen
    (339, 21.6, 62.0, 0.5), # Schwarze Bohnen
    (333, 21.1, 61.0, 0.8), # Weiße Bohnen
    (347, 21.4, 63.0, 1.2), # Pintobohnen
    (338, 20.6, 62.0, 0.5), # Limabohnen
    (347, 23.9, 63.0, 1.2), # Mungbohnen
    (329, 19.8, 62.0, 0.5), # Adzukibohnen
    (341, 25.1, 58.0, 1.5), # Favabohnen (Ackerbohnen)
    (31, 1.8, 6.7, 0.2),    # Grüne Bohnen
    (33, 1.8, 7.0, 0.2),    # Wachsbohnen
    (42, 2.8, 7.6, 0.1),    # Zuckerschoten
    (122, 11.9, 8.9, 5.0),  # Edamame
    (371, 36.2, 31.4, 8.3), # Lupinen
    (367, 20.5, 55.4, 6.8), # Kichererbsensprossen
    (350, 25.8, 60.1, 1.2), # Linsensprossen
    (347, 23.9, 63.0, 1.2), # Mungbohnensprossen
    (331, 35.1, 54.2, 1.0), # Sojasprossen
    (23, 1.0, 2.1, 0.4),    # Alfalfa-Sprossen
    (27, 2.6, 5.2, 0.3),    # Bambussprossen
    (33, 1.9, 7.3, 0.3),    # Okraschoten
    (222, 4.8, 55.2, 0.6),  # Johannisbrot
    (193, 20.5, 9.4, 11.4), # Tempeh
    (76, 8.0, 2.5, 4.8),    # Tofu
    (120, 25.0, 14.0, 1.8), # Seitan
    (358, 52.0, 26.2, 1.2), # Texturiertes Soja
    (54, 3.0, 6.3, 1.8),    # Sojamilch
    (47, 0.3, 10.0, 1.0),   # Reismilch
    (45, 0.8, 7.5, 1.4),    # Hafermilch
    (22, 0.6, 3.0, 1.0),    # Mandeldrink
    (41, 0.3, 6.9, 0.7),    # Dinkeldrink
    (46, 2.2, 5.8, 1.1),    # Hanfdrink
    (19, 0.2, 2.7, 0.9),    # Kokosdrink
    (49, 1.0, 8.5, 1.5),    # Quinoadrink
    (51, 0.8, 9.0, 1.3),    # Amaranthdrink
    (44, 0.9, 7.0, 1.2),    # Buchweizendrink
    (567, 25.8, 16.1, 49.2),# Erdnüsse
    (553, 18.0, 30.2, 43.8),# Cashewnüsse
    (575, 21.2, 21.6, 49.4),# Mandeln
    (628, 15.0, 17.0, 61.0),# Haselnüsse
     (628, 15.0, 17.0, 61.0),  # Haselnüsse
    (654, 15.2, 14.0, 65.2),  # Walnüsse
    (562, 20.2, 27.2, 45.4),  # Pistazien
    (718, 7.9, 13.8, 75.8),   # Macadamianüsse
    (656, 14.3, 12.3, 66.4),  # Paranüsse
    (691, 9.2, 14.0, 72.0),   # Pekannüsse
    (131, 2.4, 28.8, 1.4),    # Kastanien
    (559, 30.2, 10.0, 46.9),  # Kürbiskerne
    (584, 20.8, 17.2, 51.5),  # Sonnenblumenkerne
    (486, 16.5, 42.1, 30.7),  # Chiasamen
    (534, 18.3, 29.0, 42.2)   # Leinsamen
]

foodGetreideHülsenfrüchte_tags = [
    (0, [2, 6, 11]),     # Mais
    (1, [2, 6, 11]),     # Reis
    (2, [2, 6, 13, 16]), # Quinoa
    (3, [2, 6, 13]),     # Amaranth
    (4, [2, 6, 11]),     # Kamut
    (5, [2, 6, 11]),     # Emmer
    (6, [2, 6, 13]),     # Teff
    (7, [2, 6, 13]),     # Sorghum
    (8, [2, 6, 13]),     # Wildreis
    (9, [2, 6, 11]),     # Grünkern
    (10, [2, 6, 11]),    # Bulgur
    (11, [2, 6, 11]),    # Couscous
    (12, [2, 6, 11]),    # Polenta
    (13, [2, 6, 11]),    # Gerstengraupen
    (14, [2, 6, 11]),    # Weizengrieß
    (15, [2, 6, 11]),    # Dinkelgrieß
    (16, [2, 6, 11, 14]),# Haferflocken
    (17, [2, 6, 11, 14]),# Weizenkleie
    (18, [2, 6, 11, 14]),# Haferkleie
    (19, [2, 6, 11, 14]),# Dinkelkleie
    (20, [2, 6, 13]),    # Reisflocken
    (21, [2, 6, 13]),    # Hirseflocken
    (22, [2, 6, 13]),    # Quinoaflocken
    (23, [2, 6, 13]),    # Amaranthflocken
    (24, [2, 6, 13]),    # Buchweizenflocken
    (25, [2, 6, 11]),    # Maismehl
    (26, [2, 6, 13]),    # Reismehl
    (27, [2, 6, 11]),    # Weizenmehl
    (28, [2, 6, 11]),    # Dinkelmehl
    (29, [2, 6, 11]),    # Roggenmehl
    (30, [2, 6, 13]),    # Hafermehl
    (31, [2, 6, 13]),    # Hirsemehl
    (32, [2, 6, 13]),    # Buchweizenmehl
    (33, [2, 6, 13]),    # Quinoamehl
    (34, [2, 6, 13]),    # Amaranthmehl
    (35, [2, 6, 11]),    # Kichererbsenmehl
    (36, [2, 6, 13]),    # Sojamehl
    (37, [2, 6, 11]),    # Linsenmehl
    (38, [2, 6, 11]),    # Erbsenmehl
    (39, [2, 6, 11]),    # Kichererbsen
    (40, [2, 6, 11]),    # Linsen
    (41, [2, 6, 11]),    # Erbsen
    (42, [2, 6, 13]),    # Sojabohnen
    (43, [2, 6, 11]),    # Kidneybohnen
    (44, [2, 6, 11]),    # Schwarze Bohnen
    (45, [2, 6, 11]),    # Weiße Bohnen
    (46, [2, 6, 11]),    # Pintobohnen
    (47, [2, 6, 11]),    # Limabohnen
    (48, [2, 6, 11]),    # Mungbohnen
    (49, [2, 6, 11]),    # Adzukibohnen
    (50, [2, 6, 11]),    # Favabohnen (Ackerbohnen)
    (51, [2, 6, 11]),    # Grüne Bohnen
    (52, [2, 6, 11]),    # Wachsbohnen
    (53, [2, 6, 11]),    # Zuckerschoten
    (54, [2, 6, 13]),    # Edamame
    (55, [2, 6, 13]),    # Lupinen
    (56, [2, 6, 11]),    # Kichererbsensprossen
    (57, [2, 6, 11]),    # Linsensprossen
    (58, [2, 6, 11]),    # Mungbohnensprossen
    (59, [2, 6, 13]),    # Sojasprossen
    (60, [2, 6, 13]),    # Alfalfa-Sprossen
    (61, [2, 6, 13]),    # Bambussprossen
    (62, [2, 6, 11]),    # Okraschoten
    (63, [2, 6, 11]),    # Johannisbrot
    (64, [2, 6, 13]),    # Tempeh
    (65, [2, 6, 13]),    # Tofu
    (66, [2, 6, 13]),    # Seitan
    (67, [2, 6, 13]),    # Texturiertes Soja
    (68, [2, 6, 13]),    # Sojamilch
    (69, [2, 6, 13]),    # Reismilch
    (70, [2, 6, 13]),    # Hafermilch
    (71, [2, 6, 13]),    # Mandeldrink
    (72, [2, 6, 13]),    # Dinkeldrink
    (73, [2, 6, 13]),    # Hanfdrink
    (74, [2, 6, 13]),    # Kokosdrink
    (75, [2, 6, 13]),    # Quinoadrink
    (76, [2, 6, 13]),    # Amaranthdrink
    (77, [2, 6, 13]),    # Buchweizendrink
    (78, [2, 6, 11]),    # Erdnüsse
    (79, [2, 6, 11]),    # Cashewnüsse
    (80, [2, 6, 11]),    # Mandeln
    (81, [2, 6, 11]),    # Haselnüsse
    (82, [2, 6, 11]),    # Walnüsse
    (83, [2, 6, 11]),    # Pistazien
    (84, [2, 6, 11]),    # Macadamianüsse
    (85, [2, 6, 11]),    # Paranüsse
    (86, [2, 6, 11]),    # Pekannüsse
    (87, [2, 6, 11]),    # Kastanien
    (88, [2, 6, 13]),    # Kürbiskerne
    (89, [2, 6, 13]),    # Sonnenblumenkerne
    (90, [2, 6, 13]),    # Chiasamen
    (91, [2, 6, 13])     # Leinsamen
]


setDatabase(tags,foodsGetreide_Hülsenfrüchte,nutritionGetreideHülsenfrüchte_facts,foodGetreideHülsenfrüchte_tags)

foodsGewürzeKräuter = [
    ("Anis", "Gewürz", "Aromatisches Gewürz, ideal für Backwaren und Tee."),
    ("Basilikum", "Kraut", "Frisches Basilikum, ideal für Salate und Pesto."),
    ("Bärlauch", "Kraut", "Wildes Kraut, ideal für Suppen und Pestos."),
    ("Bohnenkraut", "Gewürz", "Aromatisches Gewürz, ideal für Bohnengerichte."),
    ("Chili", "Gewürz", "Scharfes Gewürz, ideal für scharfe Speisen."),
    ("Currypulver", "Gewürz", "Gewürzmischung, ideal für indische Gerichte."),
    ("Dill", "Kraut", "Frisches Kraut, ideal für Fischgerichte und Salate."),
    ("Estragon", "Kraut", "Frisches Kraut, ideal für Geflügel- und Fischgerichte."),
    ("Fenchel", "Gewürz", "Aromatisches Gewürz, ideal für Tee und Gemüsegerichte."),
    ("Gewürznelken", "Gewürz", "Aromatisches Gewürz, ideal für Süßspeisen und Eintöpfe."),
    ("Ingwer", "Gewürz", "Würziges Gewürz, ideal für asiatische Gerichte und Tee."),
    ("Kardamom", "Gewürz", "Aromatisches Gewürz, ideal für Süßspeisen und indische Gerichte."),
    ("Koriander", "Kraut", "Frisches Kraut, ideal für Salate und Currys."),
    ("Kreuzkümmel", "Gewürz", "Aromatisches Gewürz, ideal für orientalische Gerichte."),
    ("Kümmel", "Gewürz", "Würziges Gewürz, ideal für Brot und Kohlgerichte."),
    ("Lavendel", "Kraut", "Duftendes Kraut, ideal für Desserts und Tees."),
    ("Liebstöckel", "Kraut", "Frisches Kraut, ideal für Suppen und Eintöpfe."),
    ("Lorbeer", "Gewürz", "Aromatisches Gewürzblatt, ideal für Schmorgerichte."),
    ("Majoran", "Kraut", "Frisches Kraut, ideal für Wurst- und Kartoffelgerichte."),
    ("Muskatnuss", "Gewürz", "Aromatisches Gewürz, ideal für Saucen und Kartoffelgerichte."),
    ("Oregano", "Kraut", "Aromatisches Kraut, ideal für italienische Gerichte."),
    ("Paprikapulver", "Gewürz", "Würziges Pulver, ideal für Eintöpfe und Saucen."),
    ("Petersilie", "Kraut", "Frisches Kraut, ideal für Garnierungen und Salate."),
    ("Pfeffer", "Gewürz", "Aromatisches Gewürz, ideal für fast alle herzhaften Speisen."),
    ("Piment", "Gewürz", "Würziges Gewürz, ideal für Schmorgerichte und Desserts."),
    ("Rosmarin", "Kraut", "Aromatisches Kraut, ideal für Fleisch- und Kartoffelgerichte."),
    ("Salbei", "Kraut", "Aromatisches Kraut, ideal für Fleischgerichte und Buttersoßen."),
    ("Schnittlauch", "Kraut", "Frisches Kraut, ideal für Salate und Dips."),
    ("Senfkörner", "Gewürz", "Würzige Samen, ideal für Marinaden und Pickles."),
    ("Thymian", "Kraut", "Aromatisches Kraut, ideal für Fleisch- und Gemüsegerichte."),
    ("Vanille", "Gewürz", "Aromatisches Gewürz, ideal für Desserts und Backwaren."),
    ("Wacholderbeeren", "Gewürz", "Würzige Beeren, ideal für Schmorgerichte und Gin."),
    ("Zimt", "Gewürz", "Aromatisches Gewürz, ideal für Süßspeisen und Heißgetränke."),
    ("Zitronenmelisse", "Kraut", "Frisches Kraut, ideal für Tees und Desserts."),
    ("Zitronengras", "Kraut", "Aromatisches Kraut, ideal für asiatische Gerichte."),
    ("Bockshornklee", "Gewürz", "Aromatisches Gewürz, ideal für indische Currys."),
    ("Cayennepfeffer", "Gewürz", "Scharfes Gewürz, ideal für pikante Gerichte."),
    ("Chilipulver", "Gewürz", "Scharfes Gewürzpulver, ideal für scharfe Saucen."),
    ("Currypaste", "Gewürz", "Würzige Paste, ideal für Currys."),
    ("Dillspitzen", "Kraut", "Frisches Kraut, ideal für Fischgerichte."),
    ("Fenchelsamen", "Gewürz", "Aromatisches Gewürz, ideal für Brot und Tee."),
    ("Galgant", "Gewürz", "Würziges Gewürz, ideal für asiatische Gerichte."),
    ("Garam Masala", "Gewürz", "Indische Gewürzmischung, ideal für Currys."),
    ("Grüner Pfeffer", "Gewürz", "Würziges Gewürz, ideal für Saucen und Marinaden."),
    ("Hibiskus", "Kraut", "Frisches Kraut, ideal für Tees und Desserts."),
    ("Kaffirlimettenblätter", "Kraut", "Aromatische Blätter, ideal für asiatische Currys."),
    ("Kardamomsamen", "Gewürz", "Aromatische Samen, ideal für Süßspeisen und Chai."),
    ("Kurkuma", "Gewürz", "Gelbes Gewürz, ideal für Currys und goldene Milch."),
    ("Lorbeerblätter", "Gewürz", "Aromatisches Gewürz, ideal für Eintöpfe und Suppen."),
    ("Macis (Muskatblüte)", "Gewürz", "Aromatisches Gewürz, ideal für Backwaren und Schmorgerichte."),
    ("Majoranblätter", "Kraut", "Frisches Kraut, ideal für herzhafte Gerichte."),
    ("Mohnsamen", "Gewürz", "Würzige Samen, ideal für Backwaren."),
    ("Nelken", "Gewürz", "Aromatisches Gewürz, ideal für Süßspeisen und Marinaden."),
    ("Oreganoblätter", "Kraut", "Aromatisches Kraut, ideal für Pizza und mediterrane Gerichte."),
    ("Paprikaflocken", "Gewürz", "Würzige Paprikaflocken, ideal für Suppen und Eintöpfe."),
    ("Pfefferminzblätter", "Kraut", "Frisches Kraut, ideal für Tees und Desserts."),
    ("Rosa Pfeffer", "Gewürz", "Milder Pfeffer, ideal für Salate und Saucen."),
    ("Safran", "Gewürz", "Teures Gewürz, ideal für Reisgerichte und Backwaren."),
    ("Salbeiblätter", "Kraut", "Aromatisches Kraut, ideal für Buttersoßen und Fleischgerichte."),
    ("Schwarzkümmel", "Gewürz", "Aromatisches Gewürz, ideal für Brot und Fladen."),
    ("Sternanis", "Gewürz", "Sternförmiges Gewürz, ideal für Tees und Desserts."),
    ("Sumach", "Gewürz", "Säuerliches Gewürz, ideal für Salate und Marinaden."),
    ("Tandoori Masala", "Gewürz", "Indische Gewürzmischung, ideal für Tandoori-Gerichte."),
    ("Tonkabohne", "Gewürz", "Aromatisches Gewürz, ideal für Desserts."),
    ("Vanilleschoten", "Gewürz", "Aromatische Schoten, ideal für Süßspeisen und Gebäck."),
    ("Weißer Pfeffer", "Gewürz", "Milder Pfeffer, ideal für helle Saucen."),
    ("Zitronenpfeffer", "Gewürz", "Frisches Gewürz, ideal für Fisch und Meeresfrüchte."),
    ("Zitronenschale", "Gewürz", "Aromatische Schale, ideal für Backwaren und Desserts."),
    ("Zitronenthymian", "Kraut", "Aromatisches Kraut, ideal für mediterrane Gerichte."),
      ("Ajowan", "Gewürz", "Aromatisches Gewürz, ideal für Currys und Brot."),
    ("Amchur (Mango-Pulver)", "Gewürz", "Säuerliches Gewürz, ideal für indische Gerichte."),
    ("Basilikumblätter", "Kraut", "Frisches Kraut, ideal für Salate und italienische Gerichte."),
    ("Bockshornkleesamen", "Gewürz", "Aromatisches Gewürz, ideal für Currys und Brot."),
    ("Chiliflocken", "Gewürz", "Scharfe Flocken, ideal für pikante Gerichte."),
    ("Chilischoten", "Gewürz", "Frische Chilischoten, ideal für scharfe Speisen."),
    ("Cumin", "Gewürz", "Aromatisches Gewürz, ideal für orientalische Gerichte."),
    ("Currykraut", "Kraut", "Aromatisches Kraut, ideal für Currys und Eintöpfe."),
    ("Dillsamen", "Gewürz", "Aromatische Samen, ideal für Gurkengerichte."),
    ("Estragonblätter", "Kraut", "Frisches Kraut, ideal für Fischgerichte."),
    ("Fenchelknolle", "Gemüse", "Knusprige Fenchelknolle, ideal für Salate und Gemüsegerichte."),
    ("Galangalwurzel", "Gewürz", "Würzige Wurzel, ideal für asiatische Gerichte."),
    ("Garam-Masala-Pulver", "Gewürz", "Würziges indisches Gewürzpulver, ideal für Currys."),
    ("Grüner Kardamom", "Gewürz", "Aromatisches Gewürz, ideal für Desserts und Tee."),
    ("Hibiskusblüten", "Kraut", "Blüten, ideal für Tees und fruchtige Desserts."),
    ("Ingwerpulver", "Gewürz", "Getrocknetes Gewürz, ideal für Backwaren und Currys."),
    ("Kaffirlimette", "Kraut", "Aromatische Limette, ideal für thailändische Currys."),
    ("Kardamomkapseln", "Gewürz", "Aromatische Kapseln, ideal für Tee und Süßspeisen."),
    ("Korianderblätter", "Kraut", "Frische Blätter, ideal für Currys und Salate."),
    ("Koriandersamen", "Gewürz", "Würzige Samen, ideal für Brot und Marinaden."),
    ("Kreuzkümmelsamen", "Gewürz", "Aromatische Samen, ideal für orientalische Gerichte."),
    ("Kümmelsamen", "Gewürz", "Würzige Samen, ideal für Brot und Kohlgerichte."),
    ("Lavendelblüten", "Kraut", "Duftende Blüten, ideal für Desserts und Tees."),
    ("Lorbeerblatt", "Gewürz", "Aromatisches Blatt, ideal für Suppen und Eintöpfe."),
    ("Majoranpulver", "Gewürz", "Getrocknetes Kraut, ideal für Kartoffel- und Fleischgerichte."),
    ("Mohn", "Gewürz", "Samen, ideal für Backwaren und Süßspeisen."),
    ("Muskat", "Gewürz", "Aromatisches Gewürz, ideal für Saucen und Kartoffelgerichte."),
    ("Nelkenpulver", "Gewürz", "Gemahlene Nelken, ideal für Marinaden und Süßspeisen."),
    ("Oreganopulver", "Gewürz", "Getrocknetes Kraut, ideal für Pizza und Pasta."),
    ("Paprikapaste", "Gewürz", "Würzige Paste, ideal für Saucen und Eintöpfe."),
    ("Pfefferminze", "Kraut", "Frisches Kraut, ideal für Tee und Desserts."),
    ("Pfefferkörner", "Gewürz", "Ganze Körner, ideal für Pfeffermühlen."),
    ("Pimentkörner", "Gewürz", "Würzige Körner, ideal für Schmorgerichte."),
    ("Rosenpaprika", "Gewürz", "Mildes Paprikapulver, ideal für Eintöpfe."),
    ("Rosmarinblätter", "Kraut", "Frische Blätter, ideal für Braten und Kartoffelgerichte."),
    ("Safranfäden", "Gewürz", "Teure Fäden, ideal für Risotto und Desserts."),
    ("Salz", "Gewürz", "Allgemeines Gewürz, ideal für alle herzhaften Speisen."),
    ("Schwarzer Pfeffer", "Gewürz", "Aromatisches Gewürz, ideal für fast alle Gerichte."),
    ("Senfsaat", "Gewürz", "Würzige Samen, ideal für Saucen und Marinaden."),
    ("Szechuanpfeffer", "Gewürz", "Würziges Gewürz, ideal für asiatische Gerichte."),
    ("Thymianblätter", "Kraut", "Frische Blätter, ideal für mediterrane Gerichte."),
    ("Vanilleextrakt", "Gewürz", "Flüssiger Vanilleextrakt, ideal für Desserts."),
    ("Wacholder", "Gewürz", "Aromatische Beeren, ideal für Schmorgerichte."),
    ("Zimtpulver", "Gewürz", "Gemahlener Zimt, ideal für Süßspeisen."),
    ("Zitronenbasilikum", "Kraut", "Frisches Kraut, ideal für asiatische und mediterrane Gerichte."),
    ("Zitronenverbene", "Kraut", "Duftendes Kraut, ideal für Tee und Desserts."),
    ("Zitronenzeste", "Gewürz", "Abgeriebene Zitronenschale, ideal für Backwaren."),
    ("Zwiebelpulver", "Gewürz", "Gemahlenes Zwiebelpulver, ideal für Gewürzmischungen."),
    ("Basilikum, getrocknet", "Kraut", "Getrocknetes Basilikum, ideal für italienische Gerichte."),
    ("Dill, getrocknet", "Kraut", "Getrockneter Dill, ideal für Fischgerichte."),
    ("Petersilie, getrocknet", "Kraut", "Getrocknete Petersilie, ideal für Suppen und Saucen."),
    ("Schnittlauch, getrocknet", "Kraut", "Getrockneter Schnittlauch, ideal für Salate."),
    ("Thymian, getrocknet", "Kraut", "Getrockneter Thymian, ideal für mediterrane Gerichte."),
    ("Oregano, getrocknet", "Kraut", "Getrockneter Oregano, ideal für Pizza."),
    ("Rosmarin, getrocknet", "Kraut", "Getrockneter Rosmarin, ideal für Braten."),
    ("Salbei, getrocknet", "Kraut", "Getrockneter Salbei, ideal für Buttersoßen."),
    ("Minze, getrocknet", "Kraut", "Getrocknete Minze, ideal für Tee."),
    ("Koriander, getrocknet", "Kraut", "Getrockneter Koriander, ideal für Currys."),
    ("Bohnenkraut, getrocknet", "Kraut", "Getrocknetes Bohnenkraut, ideal für Bohnengerichte."),
    ("Estragon, getrocknet", "Kraut", "Getrockneter Estragon, ideal für Geflügel."),
    ("Majoran, getrocknet", "Kraut", "Getrockneter Majoran, ideal für Kartoffelgerichte."),
    ("Zitronenmelisse, getrocknet", "Kraut", "Getrocknete Zitronenmelisse, ideal für Tee."),
    ("Basilikum, frisch", "Kraut", "Frisches Basilikum, ideal für Salate."),
    ("Dill, frisch", "Kraut", "Frischer Dill, ideal für Fisch."),
    ("Petersilie, frisch", "Kraut", "Frische Petersilie, ideal für Garnierungen."),
    ("Schnittlauch, frisch", "Kraut", "Frischer Schnittlauch, ideal für Dips."),
    ("Thymian, frisch", "Kraut", "Frischer Thymian, ideal für Fleischgerichte."),
    ("Oregano, frisch", "Kraut", "Frischer Oregano, ideal für Pasta."),
    ("Rosmarin, frisch", "Kraut", "Frischer Rosmarin, ideal für Braten."),
    ("Salbei, frisch", "Kraut", "Frischer Salbei, ideal für Fleisch."),
    ("Minze, frisch", "Kraut", "Frische Minze, ideal für Tee."),
    ("Koriander, frisch", "Kraut", "Frischer Koriander, ideal für Currys."),
    ("Bohnenkraut, frisch", "Kraut", "Frisches Bohnenkraut, ideal für Bohnengerichte."),
    ("Estragon, frisch", "Kraut", "Frischer Estragon, ideal für Geflügelgerichte."),
    ("Majoran, frisch", "Kraut", "Frischer Majoran, ideal für Wurstgerichte."),
    ("Zitronenmelisse, frisch", "Kraut", "Frische Zitronenmelisse, ideal für Tee."),
    ("Basilikumöl", "Öl", "Aromatisches Öl, ideal für Salate."),
    ("Dillöl", "Öl", "Aromatisches Öl, ideal für Fischgerichte."),
    ("Petersilienöl", "Öl", "Aromatisches Öl, ideal für Suppen."),
    ("Schnittlauchöl", "Öl", "Aromatisches Öl, ideal für Dips."),
    ("Thymianöl", "Öl", "Aromatisches Öl, ideal für Braten."),
    ("Oreganoöl", "Öl", "Aromatisches Öl, ideal für Pizza."),
    ("Rosmarinöl", "Öl", "Aromatisches Öl, ideal für Fleisch."),
    ("Salbeiöl", "Öl", "Aromatisches Öl, ideal für Buttersoßen."),
    ("Minzöl", "Öl", "Aromatisches Öl, ideal für Desserts."),
    ("Korianderöl", "Öl", "Aromatisches Öl, ideal für Currys."),
    ("Bohnenkrautöl", "Öl", "Aromatisches Öl, ideal für Bohnengerichte."),
    ("Estragonöl", "Öl", "Aromatisches Öl, ideal für Fischgerichte und Dressings."),
    ("Majoranöl", "Öl", "Aromatisches Öl, ideal für Kartoffel- und Fleischgerichte."),
    ("Zitronenmelissenöl", "Öl", "Aromatisches Öl, ideal für Desserts und Salate."),
    ("Basilikumpaste", "Paste", "Würzige Paste, ideal für Saucen und Pestos."),
    ("Dillpaste", "Paste", "Würzige Paste, ideal für Fischgerichte und Dips."),
    ("Petersilienpaste", "Paste", "Würzige Paste, ideal für Suppen und Dressings."),
    ("Schnittlauchpaste", "Paste", "Würzige Paste, ideal für Dips und Dressings."),
    ("Thymianpaste", "Paste", "Würzige Paste, ideal für Fleisch- und Gemüsegerichte."),
    ("Oreganopaste", "Paste", "Würzige Paste, ideal für mediterrane Saucen."),
    ("Rosmarinpaste", "Paste", "Würzige Paste, ideal für Braten und Kartoffelgerichte."),
    ("Salbeipaste", "Paste", "Würzige Paste, ideal für Fleischgerichte."),
    ("Minzpaste", "Paste", "Frische Paste, ideal für Desserts und Tees."),
    ("Korianderpaste", "Paste", "Würzige Paste, ideal für Currys und Salate."),
    ("Bohnenkrautpaste", "Paste", "Würzige Paste, ideal für Bohnengerichte."),
    ("Estragonpaste", "Paste", "Würzige Paste, ideal für Fisch- und Geflügelgerichte."),
    ("Majoranpaste", "Paste", "Würzige Paste, ideal für Kartoffelgerichte und Eintöpfe."),
]

setDatabase([],foodsGewürzeKräuter,[],[])


foodsÖleFette = [
    ("Olivenöl", "Öl", "Hochwertiges Öl, ideal für Dressings und mediterrane Gerichte."),
    ("Rapsöl", "Öl", "Vielseitiges Öl, ideal zum Braten und Backen."),
    ("Sonnenblumenöl", "Öl", "Leichtes Öl, ideal für Salate und zum Braten."),
    ("Kokosöl", "Öl", "Aromatisches Öl, ideal für asiatische Gerichte und Backwaren."),
    ("Leinöl", "Öl", "Reich an Omega-3-Fettsäuren, ideal für kalte Speisen."),
    ("Sesamöl", "Öl", "Aromatisches Öl, ideal für asiatische Gerichte."),
    ("Erdnussöl", "Öl", "Nussiges Öl, ideal für Wokgerichte und zum Frittieren."),
    ("Distelöl", "Öl", "Mildes Öl, ideal für Salate und zum Dünsten."),
    ("Traubenkernöl", "Öl", "Leichtes Öl, ideal für Dressings und Saucen."),
    ("Walnussöl", "Öl", "Aromatisches Öl, ideal für Salate und Desserts."),
    ("Avocadoöl", "Öl", "Mildes Öl, ideal zum Braten und für Salate."),
    ("Mandelöl", "Öl", "Nussiges Öl, ideal für Salate und Desserts."),
    ("Kürbiskernöl", "Öl", "Dunkles, aromatisches Öl, ideal für Salate."),
    ("Sojaöl", "Öl", "Vielseitiges Öl, ideal zum Braten und Backen."),
    ("Maiskeimöl", "Öl", "Mildes Öl, ideal für Dressings und zum Braten."),
    ("Palmöl", "Öl", "Hitzeunempfindliches Öl, ideal zum Frittieren."),
    ("Palmkernöl", "Öl", "Hitzestabiles Öl, ideal für Backwaren und Frittierfett."),
    ("Reiskeimöl", "Öl", "Mildes Öl, ideal für Salate und zum Braten."),
    ("Haselnussöl", "Öl", "Aromatisches Öl, ideal für Salate und Desserts."),
    ("Macadamianussöl", "Öl", "Cremiges Öl, ideal für Dressings und Desserts."),
    ("Arganöl", "Öl", "Nussiges, hochwertiges Öl, ideal für Salate."),
    ("Hanföl", "Öl", "Reich an Omega-3-Fettsäuren, ideal für kalte Speisen."),
    ("Chiaöl", "Öl", "Reich an Omega-3-Fettsäuren, ideal für Salate."),
    ("Aprikosenkernöl", "Öl", "Mildes Öl, ideal für Desserts und Salate."),
    ("Pistazienöl", "Öl", "Aromatisches Öl, ideal für Desserts und Dressings."),
    ("Pflanzenöl, raffiniert", "Öl", "Allzwecköl, ideal zum Kochen und Braten."),
    ("Pflanzenöl, kaltgepresst", "Öl", "Aromatisches Öl, ideal für Salate."),
    ("Butterschmalz (Ghee)", "Fett", "Geklärte Butter, ideal zum Braten."),
    ("Schweineschmalz", "Fett", "Tierisches Fett, ideal für herzhafte Gerichte."),
    ("Gänseschmalz", "Fett", "Aromatisches Fett, ideal für Schmorgerichte."),
    ("Rindertalg", "Fett", "Tierisches Fett, ideal für Braten und Schmorgerichte."),
    ("Entenschmalz", "Fett", "Aromatisches Fett, ideal für Braten und Schmorgerichte."),
    ("Lammfett", "Fett", "Tierisches Fett, ideal für Schmorgerichte."),
    ("Fischöl", "Öl", "Reich an Omega-3-Fettsäuren, ideal als Nahrungsergänzung."),
    ("Lebertran", "Öl", "Reich an Omega-3-Fettsäuren und Vitamin D, ideal als Nahrungsergänzung."),
    ("Kakaobutter", "Fett", "Aromatisches Fett, ideal für Schokolade und Backwaren."),
    ("Sheabutter", "Fett", "Pflanzliches Fett, ideal für Desserts und Hautpflege."),
    ("Kokosfett", "Fett", "Aromatisches Fett, ideal zum Braten und Backen."),
    ("Margarine, ungesalzen", "Fett", "Pflanzliches Streichfett, ideal für Brot und Backen."),
    ("Margarine, gesalzen", "Fett", "Pflanzliches Streichfett, ideal für Brot."),
    ("Halbfettmargarine", "Fett", "Kalorienreduzierte Margarine, ideal für leichten Genuss."),
    ("Pflanzenmargarine", "Fett", "Streichfett aus pflanzlichen Ölen, ideal für Brot und Backen."),
    ("Diätmargarine", "Fett", "Kalorienreduzierte Margarine, ideal für diätische Ernährung."),
    ("Butter, ungesalzen", "Fett", "Klassische Butter, ideal zum Kochen und Backen."),
    ("Butter, gesalzen", "Fett", "Gesalzene Butter, ideal für Brot und Kochen."),
    ("Süßrahmbutter", "Fett", "Butter ohne Milchsäure, ideal für süße Speisen."),
    ("Mildgesäuerte Butter", "Fett", "Butter mit leichtem Säuregehalt, ideal für Brot."),
    ("Kräuterbutter", "Fett", "Butter mit Kräutern, ideal für Grillgerichte."),
    ("Knoblauchbutter", "Fett", "Butter mit Knoblauch, ideal für Baguette und Fleisch."),
    ("Trüffelbutter", "Fett", "Butter mit Trüffelaroma, ideal für edle Gerichte."),
    ("Laktosefreie Butter", "Fett", "Butter ohne Laktose, ideal für laktoseintolerante Menschen."),
    ("Buttermischung mit Rapsöl", "Fett", "Butter-Rapsöl-Mischung, ideal zum Streichen."),
    ("Streichfett, 70% Fett", "Fett", "Halbfestes Fett, ideal für Brot."),
    ("Streichfett, 60% Fett", "Fett", "Halbfestes Fett, ideal für Brot."),
    ("Streichfett, 40% Fett", "Fett", "Kalorienreduziertes Streichfett, ideal für leichte Kost."),
    ("Streichfett, 20% Fett", "Fett", "Sehr kalorienreduziertes Streichfett, ideal für Diäten."),
    ("Bratfett, pflanzlich", "Fett", "Pflanzliches Fett, ideal zum Braten."),
    ("Bratfett, tierisch", "Fett", "Tierisches Fett, ideal für herzhafte Braten."),
    ("Frittierfett", "Fett", "Hitzeresistentes Fett, ideal zum Frittieren."),
    ("Backfett", "Fett", "Pflanzliches Fett, ideal für Backwaren."),
    ("Kokosnussöl, nativ", "Öl", "Aromatisches Öl, ideal für asiatische Gerichte."),
    ("Kokosnussöl, raffiniert", "Öl", "Mildes Öl, ideal zum Braten und Backen."),
    ("Olivenöl, extra vergine", "Öl", "Hochwertiges, kaltgepresstes Olivenöl, ideal für Salate."),
    ("Olivenöl, nativ", "Öl", "Mildes Olivenöl, ideal für Dressings und Saucen."),
     ("Rapsöl, kaltgepresst", "Öl", "Aromatisches Öl, ideal für Salate."),
    ("Rapsöl, raffiniert", "Öl", "Mildes Öl, ideal zum Braten und Backen."),
    ("Sonnenblumenöl, kaltgepresst", "Öl", "Aromatisches Öl, ideal für Dressings."),
    ("Sonnenblumenöl, raffiniert", "Öl", "Mildes Öl, ideal für Braten und Backen."),
    ("Sesamöl, geröstet", "Öl", "Aromatisches Öl, ideal für asiatische Gerichte."),
    ("Sesamöl, ungeröstet", "Öl", "Mildes Öl, ideal für Dressings."),
    ("Erdnussöl, kaltgepresst", "Öl", "Aromatisches Öl, ideal für Wokgerichte."),
    ("Erdnussöl, raffiniert", "Öl", "Mildes Öl, ideal für Frittieren."),
    ("Distelöl, kaltgepresst", "Öl", "Aromatisches Öl, ideal für Salate."),
    ("Distelöl, raffiniert", "Öl", "Mildes Öl, ideal für Braten."),
    ("Traubenkernöl, kaltgepresst", "Öl", "Leichtes Öl, ideal für Dressings."),
    ("Traubenkernöl, raffiniert", "Öl", "Mildes Öl, ideal zum Braten."),
    ("Walnussöl, kaltgepresst", "Öl", "Aromatisches Öl, ideal für Salate."),
    ("Walnussöl, raffiniert", "Öl", "Mildes Öl, ideal für Dressings."),
    ("Avocadoöl, kaltgepresst", "Öl", "Mildes Öl, ideal für Salate."),
    ("Avocadoöl, raffiniert", "Öl", "Mildes Öl, ideal für Braten."),
    ("Mandelöl, kaltgepresst", "Öl", "Nussiges Öl, ideal für Desserts."),
    ("Mandelöl, raffiniert", "Öl", "Mildes Öl, ideal für Salate."),
    ("Kürbiskernöl, kaltgepresst", "Öl", "Dunkles, aromatisches Öl, ideal für Dressings."),
    ("Kürbiskernöl, raffiniert", "Öl", "Mildes Öl, ideal für Salate."),
    ("Sojaöl, kaltgepresst", "Öl", "Vielseitiges Öl, ideal für Dressings."),
    ("Sojaöl, raffiniert", "Öl", "Mildes Öl, ideal zum Braten."),
    ("Maiskeimöl, kaltgepresst", "Öl", "Mildes Öl, ideal für Dressings."),
    ("Maiskeimöl, raffiniert", "Öl", "Vielseitiges Öl, ideal zum Braten."),
    ("Palmöl, ungehärtet", "Öl", "Hitzeresistentes Öl, ideal zum Braten."),
    ("Palmöl, gehärtet", "Öl", "Hitzestabiles Öl, ideal für industrielle Zwecke."),
    ("Palmkernöl, ungehärtet", "Öl", "Hitzestabiles Öl, ideal zum Backen."),
    ("Palmkernöl, gehärtet", "Öl", "Fetthaltiges Öl, ideal für industrielle Anwendungen."),
    ("Reiskeimöl, kaltgepresst", "Öl", "Mildes Öl, ideal für Dressings."),
    ("Reiskeimöl, raffiniert", "Öl", "Vielseitiges Öl, ideal zum Braten."),
    ("Haselnussöl, kaltgepresst", "Öl", "Aromatisches Öl, ideal für Desserts."),
    ("Haselnussöl, raffiniert", "Öl", "Mildes Öl, ideal für Dressings."),
    ("Macadamianussöl, kaltgepresst", "Öl", "Cremiges Öl, ideal für Desserts."),
    ("Macadamianussöl, raffiniert", "Öl", "Mildes Öl, ideal für Salate."),
    ("Arganöl, kaltgepresst", "Öl", "Nussiges, hochwertiges Öl, ideal für Salate."),
    ("Arganöl, raffiniert", "Öl", "Mildes Öl, ideal für Dressings."),
]

nutritionÖleFette_facts = [
    (884, 0.0, 0.0, 100.0),  # Olivenöl
    (884, 0.0, 0.0, 100.0),  # Rapsöl
    (884, 0.0, 0.0, 100.0),  # Sonnenblumenöl
    (862, 0.0, 0.0, 100.0),  # Kokosöl
    (884, 0.0, 0.0, 100.0),  # Leinöl
    (884, 0.0, 0.0, 100.0),  # Sesamöl
    (884, 0.0, 0.0, 100.0),  # Erdnussöl
    (884, 0.0, 0.0, 100.0),  # Distelöl
    (884, 0.0, 0.0, 100.0),  # Traubenkernöl
    (884, 0.0, 0.0, 100.0),  # Walnussöl
    (884, 0.0, 0.0, 100.0),  # Avocadoöl
    (884, 0.0, 0.0, 100.0),  # Mandelöl
    (884, 0.0, 0.0, 100.0),  # Kürbiskernöl
    (884, 0.0, 0.0, 100.0),  # Sojaöl
    (884, 0.0, 0.0, 100.0),  # Maiskeimöl
    (884, 0.0, 0.0, 100.0),  # Palmöl
    (884, 0.0, 0.0, 100.0),  # Palmkernöl
    (884, 0.0, 0.0, 100.0),  # Reiskeimöl
    (884, 0.0, 0.0, 100.0),  # Haselnussöl
    (884, 0.0, 0.0, 100.0),  # Macadamianussöl
    (884, 0.0, 0.0, 100.0),  # Arganöl
    (884, 0.0, 0.0, 100.0),  # Hanföl
    (884, 0.0, 0.0, 100.0),  # Chiaöl
    (884, 0.0, 0.0, 100.0),  # Aprikosenkernöl
    (884, 0.0, 0.0, 100.0),  # Pistazienöl
    (884, 0.0, 0.0, 100.0),  # Pflanzenöl, raffiniert
    (884, 0.0, 0.0, 100.0),  # Pflanzenöl, kaltgepresst
    (876, 0.2, 0.0, 99.8),   # Butterschmalz (Ghee)
    (900, 0.0, 0.0, 100.0),  # Schweineschmalz
    (900, 0.0, 0.0, 100.0),  # Gänseschmalz
    (902, 0.0, 0.0, 100.0),  # Rindertalg
    (900, 0.0, 0.0, 100.0),  # Entenschmalz
    (902, 0.0, 0.0, 100.0),  # Lammfett
    (902, 0.0, 0.0, 100.0),  # Fischöl
    (902, 0.0, 0.0, 100.0),  # Lebertran
    (884, 0.0, 0.0, 100.0),  # Kakaobutter
    (884, 0.0, 0.0, 100.0),  # Sheabutter
    (862, 0.0, 0.0, 100.0),  # Kokosfett
    (717, 0.5, 0.7, 81.0),   # Margarine, ungesalzen
    (717, 0.5, 0.7, 81.0),   # Margarine, gesalzen
    (369, 0.5, 1.0, 40.0),   # Halbfettmargarine
    (717, 0.5, 0.7, 81.0),   # Pflanzenmargarine
    (369, 0.5, 1.0, 40.0),   # Diätmargarine
    (717, 0.5, 0.7, 81.0),   # Butter, ungesalzen
    (717, 0.5, 0.7, 81.0),   # Butter, gesalzen
    (717, 0.5, 0.7, 81.0),   # Süßrahmbutter
    (717, 0.5, 0.7, 81.0),   # Mildgesäuerte Butter
    (717, 0.5, 0.7, 81.0),   # Kräuterbutter
    (717, 0.5, 0.7, 81.0),   # Knoblauchbutter
    (717, 0.5, 0.7, 81.0),   # Trüffelbutter
    (717, 0.5, 0.7, 81.0),   # Laktosefreie Butter
    (717, 0.5, 0.7, 81.0),   # Buttermischung mit Rapsöl
    (630, 0.5, 1.0, 70.0),   # Streichfett, 70% Fett
    (540, 0.5, 1.0, 60.0),   # Streichfett, 60% Fett
    (360, 0.5, 1.0, 40.0),   # Streichfett, 40% Fett
    (180, 0.5, 1.0, 20.0),   # Streichfett, 20% Fett
    (884, 0.0, 0.0, 100.0),  # Bratfett, pflanzlich
    (902, 0.0, 0.0, 100.0),  # Bratfett, tierisch
    (884, 0.0, 0.0, 100.0),  # Frittierfett
    (884, 0.0, 0.0, 100.0),  # Backfett
    (862, 0.0, 0.0, 100.0),  # Kokosnussöl, nativ
    (884, 0.0, 0.0, 100.0),  # Kokosnussöl, raffiniert
    (884, 0.0, 0.0, 100.0),  # Olivenöl, extra vergine
    (884, 0.0, 0.0, 100.0),  # Olivenöl, nativ
    (884, 0.0, 0.0, 100.0),  # Rapsöl, kaltgepresst
    (884, 0.0, 0.0, 100.0),  # Rapsöl, raffiniert
    (884, 0.0, 0.0, 100.0),  # Sonnenblumenöl, kaltgepresst
    (884, 0.0, 0.0, 100.0),  # Sonnenblumenöl, raffiniert
    (884, 0.0, 0.0, 100.0),  # Sesamöl, geröstet
    (884, 0.0, 0.0, 100.0),  # Sesamöl, ungeröstet
    (884, 0.0, 0.0, 100.0),  # Erdnussöl, kaltgepresst
    (884, 0.0, 0.0, 100.0),  # Erdnussöl, raffiniert
    (884, 0.0, 0.0, 100.0),  # Distelöl, kaltgepresst
    (884, 0.0, 0.0, 100.0),  # Distelöl, raffiniert
    (884, 0.0, 0.0, 100.0),  # Traubenkernöl, kaltgepresst
    (884, 0.0, 0.0, 100.0),  # Traubenkernöl, raffiniert
    (884, 0.0, 0.0, 100.0),  # Walnussöl, kaltgepresst
    (884, 0.0, 0.0, 100.0),  # Walnussöl, raffiniert
    (884, 0.0, 0.0, 100.0),  # Avocadoöl, kaltgepresst
    (884, 0.0, 0.0, 100.0),  # Avocadoöl, raffiniert
    (884, 0.0, 0.0, 100.0),  # Mandelöl, kaltgepresst
    (884, 0.0, 0.0, 100.0),  # Mandelöl, raffiniert
    (884, 0.0, 0.0, 100.0),  # Kürbiskernöl, kaltgepresst
    (884, 0.0, 0.0, 100.0),  # Kürbiskernöl, raffiniert
    (884, 0.0, 0.0, 100.0),  # Sojaöl, kaltgepresst
    (884, 0.0, 0.0, 100.0),  # Sojaöl, raffiniert
    (884, 0.0, 0.0, 100.0),  # Maiskeimöl, kaltgepresst
    (884, 0.0, 0.0, 100.0),  # Maiskeimöl, raffiniert
    (884, 0.0, 0.0, 100.0),  # Palmöl, ungehärtet
    (884, 0.0, 0.0, 100.0),  # Palmöl, gehärtet
    (884, 0.0, 0.0, 100.0),  # Palmkernöl, ungehärtet
    (884, 0.0, 0.0, 100.0),  # Palmkernöl, gehärtet
    (884, 0.0, 0.0, 100.0),  # Reiskeimöl, kaltgepresst
    (884, 0.0, 0.0, 100.0),  # Reiskeimöl, raffiniert
    (884, 0.0, 0.0, 100.0),  # Haselnussöl, kaltgepresst
    (884, 0.0, 0.0, 100.0),  # Haselnussöl, raffiniert
    (884, 0.0, 0.0, 100.0),  # Macadamianussöl, kaltgepresst
    (884, 0.0, 0.0, 100.0),  # Macadamianussöl, raffiniert
    (884, 0.0, 0.0, 100.0),  # Arganöl, kaltgepresst
    (884, 0.0, 0.0, 100.0),  # Arganöl, raffiniert
]

foodÖleFette_tags = [
    (0, [6, 17]),   # Olivenöl
    (1, [6, 17]),   # Rapsöl
    (2, [6, 17]),   # Sonnenblumenöl
    (3, [6, 17]),   # Kokosöl
    (4, [6, 17, 19]),   # Leinöl
    (5, [6, 17]),   # Sesamöl
    (6, [6, 17]),   # Erdnussöl
    (7, [6, 17]),   # Distelöl
    (8, [6, 17]),   # Traubenkernöl
    (9, [6, 17, 19]),   # Walnussöl
    (10, [6, 17]),  # Avocadoöl
    (11, [6, 17]),  # Mandelöl
    (12, [6, 17]),  # Kürbiskernöl
    (13, [6, 17]),  # Sojaöl
    (14, [6, 17]),  # Maiskeimöl
    (15, [6, 17]),  # Palmöl
    (16, [6, 17]),  # Palmkernöl
    (17, [6, 17]),  # Reiskeimöl
    (18, [6, 17]),  # Haselnussöl
    (19, [6, 17]),  # Macadamianussöl
    (20, [6, 17]),  # Arganöl
    (21, [6, 17, 19]),  # Hanföl
    (22, [6, 17]),  # Chiaöl
    (23, [6, 17]),  # Aprikosenkernöl
    (24, [6, 17]),  # Pistazienöl
    (25, [6, 17]),  # Pflanzenöl, raffiniert
    (26, [6, 17]),  # Pflanzenöl, kaltgepresst
    (27, [6, 12]),  # Butterschmalz (Ghee)
    (28, [6]),      # Schweineschmalz
    (29, [6]),      # Gänseschmalz
    (30, [6]),      # Rindertalg
    (31, [6]),      # Entenschmalz
    (32, [6]),      # Lammfett
    (33, [6, 19]),  # Fischöl
    (34, [6, 19]),  # Lebertran
    (35, [6, 17]),  # Kakaobutter
    (36, [6, 17]),  # Sheabutter
    (37, [6, 17]),  # Kokosfett
    (38, [6]),      # Margarine, ungesalzen
    (39, [6]),      # Margarine, gesalzen
    (40, [6]),      # Halbfettmargarine
    (41, [6]),      # Pflanzenmargarine
    (42, [6]),      # Diätmargarine
    (43, [6]),      # Butter, ungesalzen
    (44, [6]),      # Butter, gesalzen
    (45, [6]),      # Süßrahmbutter
    (46, [6]),      # Mildgesäuerte Butter
    (47, [6, 18]),  # Kräuterbutter
    (48, [6, 18]),  # Knoblauchbutter
    (49, [6, 18]),  # Trüffelbutter
    (50, [6]),      # Laktosefreie Butter
    (51, [6, 17]),  # Buttermischung mit Rapsöl
    (52, [6]),      # Streichfett, 70% Fett
    (53, [6]),      # Streichfett, 60% Fett
    (54, [6]),      # Streichfett, 40% Fett
    (55, [6]),      # Streichfett, 20% Fett
    (56, [6, 17]),  # Bratfett, pflanzlich
    (57, [6]),      # Bratfett, tierisch
    (58, [6, 17]),  # Frittierfett
    (59, [6, 17]),  # Backfett
    (60, [6, 17]),  # Kokosnussöl, nativ
    (61, [6, 17]),  # Kokosnussöl, raffiniert
    (62, [6, 17]),  # Olivenöl, extra vergine
    (63, [6, 17]),  # Olivenöl, nativ
    (64, [6, 17]),  # Rapsöl, kaltgepresst
    (65, [6, 17]),  # Rapsöl, raffiniert
    (66, [6, 17]),  # Sonnenblumenöl, kaltgepresst
    (67, [6, 17]),  # Sonnenblumenöl, raffiniert
    (68, [6, 17]),  # Sesamöl, geröstet
    (69, [6, 17]),  # Sesamöl, ungeröstet
    (70, [6, 17]),  # Erdnussöl, kaltgepresst
    (71, [6, 17]),  # Erdnussöl, raffiniert
    (72, [6, 17]),  # Distelöl, kaltgepresst
    (73, [6, 17]),  # Distelöl, raffiniert
    (74, [6, 17]),  # Traubenkernöl, kaltgepresst
    (75, [6, 17]),  # Traubenkernöl, raffiniert
    (76, [6, 17]),  # Walnussöl, kaltgepresst
    (77, [6, 17]),  # Walnussöl, raffiniert
    (78, [6, 17]),  # Avocadoöl, kaltgepresst
    (79, [6, 17]),  # Avocadoöl, raffiniert
    (80, [6, 17]),  # Mandelöl, kaltgepresst
    (81, [6, 17]),  # Mandelöl, raffiniert
    (82, [6, 17]),  # Kürbiskernöl, kaltgepresst
    (83, [6, 17]),  # Kürbiskernöl, raffiniert
    (84, [6, 17]),  # Sojaöl, kaltgepresst
    (85, [6, 17]),  # Sojaöl, raffiniert
    (86, [6, 17]),  # Maiskeimöl, kaltgepresst
    (87, [6, 17]),  # Maiskeimöl, raffiniert
    (88, [6, 17]),  # Palmöl, ungehärtet
    (89, [6, 17]),  # Palmöl, gehärtet
    (90, [6, 17]),  # Palmkernöl, ungehärtet
    (91, [6, 17]),  # Palmkernöl, gehärtet
    (92, [6, 17]),  # Reiskeimöl, kaltgepresst
    (93, [6, 17]),  # Reiskeimöl, raffiniert
    (94, [6, 17]),  # Haselnussöl, kaltgepresst
    (95, [6, 17]),  # Haselnussöl, raffiniert
    (96, [6, 17]),  # Macadamianussöl, kaltgepresst
    (97, [6, 17]),  # Macadamianussöl, raffiniert
    (98, [6, 17]),  # Arganöl, kaltgepresst
    (99, [6, 17]),  # Arganöl, raffiniert
]

setDatabase(tags, foodsÖleFette, nutritionÖleFette_facts, foodÖleFette_tags)


foodsNüsse = [
    ("Pinienkerne", "Samen", "Aromatische Samen, ideal für Pesto und Salate."),
    ("Sesamsamen", "Samen", "Nussige Samen, ideal zum Backen und Kochen."),
    ("Mohnsamen", "Samen", "Kleine, würzige Samen, ideal für Backwaren."),
    ("Hanfsamen", "Samen", "Reich an Proteinen, ideal für Müsli und Smoothies."),
    ("Macadamianüsse", "Nüsse", "Cremige Nüsse, ideal für Desserts und Snacks."),
    ("Paranüsse", "Nüsse", "Reich an Selen, ideal als Snack oder für Desserts."),
    ("Pekannüsse", "Nüsse", "Milde Nüsse, ideal für Kuchen und Desserts."),
    ("Kastanien (Edelkastanien)", "Nüsse", "Milde Nüsse, ideal zum Rösten oder für Füllungen."),
    ("Ginkgo-Nüsse", "Nüsse", "Nüsse, traditionell in der asiatischen Küche verwendet."),
    ("Lotosblumensamen", "Samen", "Aromatische Samen, ideal für asiatische Gerichte."),
    ("Baumwollsamen", "Samen", "Würzige Samen, traditionell in bestimmten Küchen verwendet."),
    ("Brotnussbaum-Samen", "Samen", "Samen, die als nährstoffreicher Snack dienen."),
    ("Saflor (Färberdistel) Samen", "Samen", "Würzige Samen, ideal zum Würzen und in Salaten."),
    ("Pinyon-Kiefersamen", "Samen", "Aromatische Samen, ideal für Snacks und zum Kochen."),
    ("Schwarznüsse (Schwarze Walnüsse)", "Nüsse", "Würzige Nüsse, ideal für Desserts und Backwaren."),
    ("Erdmandeln (Tigernüsse)", "Nüsse", "Knusprige Nüsse, ideal als Snack oder in Desserts."),
    ("Wassermelonenkerne", "Samen", "Nährstoffreiche Samen, ideal als Snack oder für Salate."),
    ("Basilikumsamen", "Samen", "Würzige Samen, ideal für Desserts und Getränke."),
    ("Mohnsamen, blau", "Samen", "Würzige Samen, ideal für Backwaren."),
    ("Mohnsamen, weiß", "Samen", "Milde Samen, ideal für Desserts und Backwaren."),
    ("Chiasamen, schwarz", "Samen", "Reich an Omega-3-Fettsäuren, ideal für Puddings und Müsli."),
    ("Chiasamen, weiß", "Samen", "Reich an Omega-3-Fettsäuren, ideal für Smoothies und Desserts."),
    ("Sesamsamen, schwarz", "Samen", "Aromatische Samen, ideal zum Backen und für asiatische Gerichte."),
    ("Sesamsamen, weiß", "Samen", "Nussige Samen, ideal zum Backen und für Saucen."),
    ("Kürbiskerne, grün", "Samen", "Knackige Samen, ideal als Snack oder für Salate."),
    ("Kürbiskerne, weiß", "Samen", "Milde Samen, ideal für Backwaren und Salate."),
    ("Sonnenblumenkerne, geschält", "Samen", "Milde Kerne, ideal für Müsli und Salate."),
    ("Sonnenblumenkerne, ungeschält", "Samen", "Knackige Kerne, ideal als Snack."),
    ("Leinsamen, braun", "Samen", "Reich an Omega-3-Fettsäuren, ideal für Backwaren."),
    ("Leinsamen, golden", "Samen", "Reich an Ballaststoffen, ideal für Müsli und Brot."),
    ("Hanfsamen, geschält", "Samen", "Reich an Proteinen, ideal für Smoothies und Salate."),
    ("Hanfsamen, ungeschält", "Samen", "Reich an Ballaststoffen, ideal für Müsli und Snacks."),
    ("Erdnüsse, blanchiert", "Nüsse", "Milde Nüsse, ideal als Snack oder zum Kochen."),
    ("Erdnüsse, geröstet", "Nüsse", "Knusprige Nüsse, ideal als Snack."),
    ("Erdnüsse, ungesalzen", "Nüsse", "Milde Nüsse, ideal für Saucen und als Snack."),
    ("Erdnüsse, gesalzen", "Nüsse", "Knusprige Nüsse, ideal als Snack."),
    ("Cashewnüsse, roh", "Nüsse", "Cremige Nüsse, ideal als Snack oder für vegane Saucen."),
    ("Cashewnüsse, geröstet", "Nüsse", "Knusprige Nüsse, ideal als Snack."),
    ("Cashewnüsse, gesalzen", "Nüsse", "Knusprige Nüsse, ideal als Snack."),
    ("Mandeln, roh", "Nüsse", "Knusprige Nüsse, ideal als Snack oder zum Backen."),
    ("Mandeln, geröstet", "Nüsse", "Aromatische Nüsse, ideal als Snack."),
    ("Mandeln, gesalzen", "Nüsse", "Knusprige Nüsse, ideal als Snack."),
    ("Haselnüsse, roh", "Nüsse", "Milde Nüsse, ideal für Desserts und Backwaren."),
    ("Haselnüsse, geröstet", "Nüsse", "Aromatische Nüsse, ideal für Desserts."),
    ("Haselnüsse, blanchiert", "Nüsse", "Milde Nüsse, ideal für Desserts und Backwaren."),
    ("Walnüsse, roh", "Nüsse", "Reich an Omega-3-Fettsäuren, ideal für Salate und Desserts."),
    ("Walnüsse, geröstet", "Nüsse", "Aromatische Nüsse, ideal als Snack."),
    ("Pistazien, roh", "Nüsse", "Grüne Nüsse, ideal als Snack oder für Desserts."),
    ("Pistazien, geröstet", "Nüsse", "Aromatische Nüsse, ideal als Snack."),
    ("Pistazien, gesalzen", "Nüsse", "Knusprige Nüsse, ideal als Snack."),
    ("Macadamianüsse, roh", "Nüsse", "Cremige Nüsse, ideal als Snack oder für Desserts."),
    ("Macadamianüsse, geröstet", "Nüsse", "Aromatische Nüsse, ideal als Snack."),
    ("Paranüsse, roh", "Nüsse", "Reich an Selen, ideal als Snack."),
    ("Paranüsse, geröstet", "Nüsse", "Aromatische Nüsse, ideal als Snack."),
    ("Pekannüsse, roh", "Nüsse", "Milde Nüsse, ideal für Kuchen und Desserts."),
    ("Pekannüsse, geröstet", "Nüsse", "Aromatische Nüsse, ideal als Snack."),
    ("Kastanien, roh", "Nüsse", "Milde Nüsse, ideal zum Rösten oder für Füllungen."),
    ("Kastanien, geröstet", "Nüsse", "Aromatische Nüsse, ideal als Snack."),
    ("Ginkgo-Nüsse, roh", "Nüsse", "Nüsse, traditionell in der asiatischen Küche verwendet."),
    ("Ginkgo-Nüsse, gekocht", "Nüsse", "Gekochte Nüsse, ideal für asiatische Gerichte."),
    ("Lotosblumensamen, roh", "Samen", "Aromatische Samen, ideal für asiatische Gerichte."),
    ("Lotosblumensamen, getrocknet", "Samen", "Trockene Samen, ideal für Suppen und Eintöpfe."),
    ("Baumwollsamen, roh", "Samen", "Würzige Samen, traditionell in bestimmten Küchen verwendet."),
    ("Baumwollsamen, geröstet", "Samen", "Geröstete Samen, ideal als Snack."),
    ("Brotnussbaum-Samen, roh", "Samen", "Samen, die als nährstoffreicher Snack dienen."),
    ("Brotnussbaum-Samen, getrocknet", "Samen", "Getrocknete Samen, ideal für Suppen und Eintöpfe."),
    ("Saflor-Samen, roh", "Samen", "Würzige Samen, ideal zum Würzen und in Salaten."),
    ("Saflor-Samen, getrocknet", "Samen", "Getrocknete Samen, ideal zum Würzen."),
    ("Pinyon-Kiefersamen, roh", "Samen", "Aromatische Samen, ideal für Snacks und zum Kochen."),
    ("Pinyon-Kiefersamen, geröstet", "Samen", "Geröstete Samen, ideal als Snack."),
    ("Schwarznüsse, roh", "Nüsse", "Würzige Nüsse, ideal für Desserts und Backwaren."),
    ("Schwarznüsse, getrocknet", "Nüsse", "Getrocknete Nüsse, ideal für Backwaren."),
    ("Erdmandeln, roh", "Nüsse", "Knusprige Nüsse, ideal als Snack oder in Desserts."),
    ("Erdmandeln, getrocknet", "Nüsse", "Getrocknete Nüsse, ideal für Müslis und Backwaren."),
    ("Wassermelonenkerne, roh", "Samen", "Nährstoffreiche Samen, ideal als Snack oder für Salate."),
    ("Wassermelonenkerne, geröstet", "Samen", "Geröstete Samen, ideal als Snack."),
    ("Basilikumsamen, roh", "Samen", "Würzige Samen, ideal für Desserts und Getränke."),
    ("Basilikumsamen, getrocknet", "Samen", "Getrocknete Samen, ideal für Tee und Desserts."),
    ("Mohnsamen, blau, roh", "Samen", "Würzige Samen, ideal für Backwaren."),
    ("Mohnsamen, weiß, roh", "Samen", "Milde Samen, ideal für Desserts und Backwaren."),
    ("Chiasamen, schwarz, roh", "Samen", "Reich an Omega-3-Fettsäuren, ideal für Puddings und Müslis."),
    ("Chiasamen, weiß, roh", "Samen", "Reich an Omega-3-Fettsäuren, ideal für Smoothies und Desserts."),
    ("Sesamsamen, schwarz, roh", "Samen", "Aromatische Samen, ideal zum Backen und für asiatische Gerichte."),
    ("Sesamsamen, weiß, roh", "Samen", "Nussige Samen, ideal zum Backen und für Saucen."),
    ("Kürbiskerne, grün, roh", "Samen", "Knackige Samen, ideal als Snack oder für Salate."),
    ("Kürbiskerne, weiß, roh", "Samen", "Milde Samen, ideal für Backwaren und Salate."),
    ("Sonnenblumenkerne, geschält, roh", "Samen", "Milde Kerne, ideal für Müsli und Salate."),
    ("Sonnenblumenkerne, ungeschält, roh", "Samen", "Knackige Kerne, ideal als Snack."),
    ("Leinsamen, braun, roh", "Samen", "Reich an Omega-3-Fettsäuren, ideal für Backwaren."),
    ("Leinsamen, golden, roh", "Samen", "Reich an Ballaststoffen, ideal für Müsli und Brot."),
    ("Hanfsamen, geschält, roh", "Samen", "Reich an Proteinen, ideal für Smoothies und Salate."),
    ("Hanfsamen, ungeschält, roh", "Samen", "Reich an Ballaststoffen, ideal für Müslis und Snacks."),
    ("Erdnussbutter", "Butter", "Cremige Paste, ideal für Brotaufstrich und Backwaren."),
    ("Mandelbutter", "Butter", "Aromatische Nussbutter, ideal für Brotaufstrich und Desserts."),
    ("Cashewbutter", "Butter", "Cremige Paste, ideal für Brotaufstrich und vegane Rezepte."),
    ("Haselnusscreme", "Butter", "Süße Nusscreme, ideal als Brotaufstrich und für Desserts."),
    ("Tahini (Sesampaste)", "Paste", "Würzige Sesampaste, ideal für Saucen und Hummus."),
    ("Pistazienpaste", "Paste", "Cremige Paste, ideal für Desserts und Saucen."),
    ("Macadamianussbutter", "Butter", "Cremige Nussbutter, ideal für Brotaufstrich und Desserts."),
    ("Sonnenblumenkernbutter", "Butter", "Cremige Butter, ideal für Brotaufstrich und Backen."),
]


nutritionNüsse_facts = [
    (673, 13.7, 13.1, 68.4),  # Pinienkerne
    (573, 17.0, 23.5, 49.7),  # Sesamsamen
    (525, 20.5, 28.1, 42.2),  # Mohnsamen
    (553, 32.0, 8.7, 48.8),   # Hanfsamen
    (718, 7.8, 13.8, 75.8),   # Macadamianüsse
    (656, 14.3, 12.3, 66.4),  # Paranüsse
    (691, 9.2, 13.9, 72.0),   # Pekannüsse
    (196, 2.4, 45.5, 1.8),    # Kastanien (Edelkastanien)
    (182, 4.3, 37.6, 1.3),    # Ginkgo-Nüsse
    (332, 17.0, 64.0, 1.9),   # Lotosblumensamen
    (506, 17.0, 13.3, 40.0),  # Baumwollsamen
    (431, 7.0, 53.0, 16.0),   # Brotnussbaum-Samen
    (517, 14.0, 21.0, 37.0),  # Saflor (Färberdistel) Samen
    (592, 8.8, 20.5, 47.0),   # Pinyon-Kiefersamen
    (618, 24.0, 12.3, 59.0),  # Schwarznüsse (Schwarze Walnüsse)
    (450, 4.0, 50.0, 25.0),   # Erdmandeln (Tigernüsse)
    (557, 28.3, 15.3, 47.0),  # Wassermelonenkerne
    (233, 2.9, 54.0, 1.7),    # Basilikumsamen
    (525, 20.5, 28.1, 42.2),  # Mohnsamen, blau
    (525, 20.5, 28.1, 42.2),  # Mohnsamen, weiß
    (486, 16.5, 42.1, 30.7),  # Chiasamen, schwarz
    (486, 16.5, 42.1, 30.7),  # Chiasamen, weiß
    (573, 17.0, 23.5, 49.7),  # Sesamsamen, schwarz
    (573, 17.0, 23.5, 49.7),  # Sesamsamen, weiß
    (559, 30.2, 10.7, 49.1),  # Kürbiskerne, grün
    (559, 30.2, 10.7, 49.1),  # Kürbiskerne, weiß
    (584, 24.4, 20.0, 51.5),  # Sonnenblumenkerne, geschält
    (584, 24.4, 20.0, 51.5),  # Sonnenblumenkerne, ungeschält
    (534, 18.3, 29.0, 42.2),  # Leinsamen, braun
    (534, 18.3, 29.0, 42.2),  # Leinsamen, golden
    (553, 32.0, 8.7, 48.8),   # Hanfsamen, geschält
    (553, 32.0, 8.7, 48.8),   # Hanfsamen, ungeschält
    (567, 25.8, 16.1, 49.2),  # Erdnüsse, blanchiert
    (585, 25.2, 16.1, 49.7),  # Erdnüsse, geröstet
    (567, 25.8, 16.1, 49.2),  # Erdnüsse, ungesalzen
    (585, 25.2, 16.1, 49.7),  # Erdnüsse, gesalzen
    (553, 18.2, 30.2, 43.8),  # Cashewnüsse, roh
    (574, 15.3, 32.7, 46.4),  # Cashewnüsse, geröstet
    (574, 15.3, 32.7, 46.4),  # Cashewnüsse, gesalzen
    (579, 21.2, 21.7, 49.9),  # Mandeln, roh
    (607, 20.0, 21.0, 54.0),  # Mandeln, geröstet
    (607, 20.0, 21.0, 54.0),  # Mandeln, gesalzen
    (628, 15.0, 17.0, 61.0),  # Haselnüsse, roh
    (646, 14.0, 16.7, 63.5),  # Haselnüsse, geröstet
    (646, 14.0, 16.7, 63.5),  # Haselnüsse, blanchiert
    (654, 15.2, 13.7, 65.2),  # Walnüsse, roh
    (684, 15.0, 14.0, 68.0),  # Walnüsse, geröstet
    (557, 21.0, 27.0, 44.0),  # Pistazien, roh
    (571, 21.0, 28.0, 45.0),  # Pistazien, geröstet
    (571, 21.0, 28.0, 45.0),  # Pistazien, gesalzen
    (718, 7.8, 13.8, 75.8),   # Macadamianüsse, roh
    (740, 7.5, 14.2, 78.0),   # Macadamianüsse, geröstet
    (656, 14.3, 12.3, 66.4),  # Paranüsse, roh
    (670, 13.5, 12.0, 68.2),  # Paranüsse, geröstet
    (691, 9.2, 13.9, 72.0),   # Pekannüsse, roh
    (705, 9.0, 14.0, 74.0),   # Pekannüsse, geröstet
    (196, 2.4, 45.5, 1.8),    # Kastanien, roh
    (245, 3.2, 51.2, 2.5),    # Kastanien, geröstet
    (182, 4.3, 37.6, 1.3),    # Ginkgo-Nüsse, roh
    (185, 5.0, 39.0, 1.5),    # Ginkgo-Nüsse, gekocht
    (332, 17.0, 64.0, 1.9),   # Lotosblumensamen, roh
    (370, 19.0, 70.0, 2.5),   # Lotosblumensamen, getrocknet
    (506, 17.0, 13.3, 40.0),  # Baumwollsamen, roh
    (525, 17.5, 14.0, 42.0),  # Baumwollsamen, geröstet
    (431, 7.0, 53.0, 16.0),   # Brotnussbaum-Samen, roh
    (460, 8.0, 56.0, 18.0),   # Brotnussbaum-Samen, getrocknet
    (517, 14.0, 21.0, 37.0),  # Saflor-Samen, roh
    (540, 15.0, 23.0, 39.0),  # Saflor-Samen, getrocknet
    (592, 8.8, 20.5, 47.0),   # Pinyon-Kiefersamen, roh
    (610, 9.0, 21.0, 49.0),   # Pinyon-Kiefersamen, geröstet
    (618, 24.0, 12.3, 59.0),  # Schwarznüsse, roh
    (630, 25.0, 13.0, 60.0),  # Schwarznüsse, getrocknet
    (450, 4.0, 50.0, 25.0),   # Erdmandeln, roh
    (470, 4.5, 52.0, 26.0),   # Erdmandeln, getrocknet
    (557, 28.3, 15.3, 47.0),  # Wassermelonenkerne, roh
    (580, 29.0, 16.0, 49.0),  # Wassermelonenkerne, geröstet
    (233, 2.9, 54.0, 1.7),    # Basilikumsamen, roh
    (245, 3.2, 57.0, 1.9),    # Basilikumsamen, getrocknet
    (525, 20.5, 28.1, 42.2),  # Mohnsamen, blau, roh
    (525, 20.5, 28.1, 42.2),  # Mohnsamen, weiß, roh
    (486, 16.5, 42.1, 30.7),  # Chiasamen, schwarz, roh
    (486, 16.5, 42.1, 30.7),  # Chiasamen, weiß, roh
    (573, 17.0, 23.5, 49.7),  # Sesamsamen, schwarz, roh
    (573, 17.0, 23.5, 49.7),  # Sesamsamen, weiß, roh
    (559, 30.2, 10.7, 49.1),  # Kürbiskerne, grün, roh
    (559, 30.2, 10.7, 49.1),  # Kürbiskerne, weiß, roh
    (584, 24.4, 20.0, 51.5),  # Sonnenblumenkerne, geschält, roh
    (584, 24.4, 20.0, 51.5),  # Sonnenblumenkerne, ungeschält, roh
    (534, 18.3, 29.0, 42.2),  # Leinsamen, braun, roh
    (534, 18.3, 29.0, 42.2),  # Leinsamen, golden, roh
    (553, 32.0, 8.7, 48.8),   # Hanfsamen, geschält, roh
    (553, 32.0, 8.7, 48.8),   # Hanfsamen, ungeschält, roh
    (567, 25.8, 16.1, 49.2),  # Erdnussbutter
    (614, 21.2, 18.0, 56.0),  # Mandelbutter
    (580, 18.5, 27.0, 47.5),  # Cashewbutter
    (572, 13.0, 57.0, 37.0),  # Haselnusscreme
    (595, 17.0, 26.0, 50.0),  # Tahini (Sesampaste)
    (620, 18.0, 28.0, 53.0),  # Pistazienpaste
    (716, 7.8, 13.0, 78.5),   # Macadamianussbutter
    (619, 18.3, 26.0, 55.3),  # Sonnenblumenkernbutter
]

foodNüsse_tags = [
    (0, [6, 19]),  # Pinienkerne
    (1, [6, 17]),  # Sesamsamen
    (2, [6, 17]),  # Mohnsamen
    (3, [6, 12, 17]),  # Hanfsamen
    (4, [6, 12]),  # Macadamianüsse
    (5, [6, 12, 21]),  # Paranüsse
    (6, [6, 12]),  # Pekannüsse
    (7, [6, 17, 22]),  # Kastanien (Edelkastanien)
    (8, [6, 19]),  # Ginkgo-Nüsse
    (9, [6, 17]),  # Lotosblumensamen
    (10, [6, 17]),  # Baumwollsamen
    (11, [6, 17]),  # Brotnussbaum-Samen
    (12, [6, 17]),  # Saflor (Färberdistel) Samen
    (13, [6, 17]),  # Pinyon-Kiefersamen
    (14, [6, 12]),  # Schwarznüsse (Schwarze Walnüsse)
    (15, [6, 17]),  # Erdmandeln (Tigernüsse)
    (16, [6, 17]),  # Wassermelonenkerne
    (17, [6, 17]),  # Basilikumsamen
    (18, [6, 17]),  # Mohnsamen, blau
    (19, [6, 17]),  # Mohnsamen, weiß
    (20, [6, 17, 19]),  # Chiasamen, schwarz
    (21, [6, 17, 19]),  # Chiasamen, weiß
    (22, [6, 17]),  # Sesamsamen, schwarz
    (23, [6, 17]),  # Sesamsamen, weiß
    (24, [6, 17, 19]),  # Kürbiskerne, grün
    (25, [6, 17, 19]),  # Kürbiskerne, weiß
    (26, [6, 17, 19]),  # Sonnenblumenkerne, geschält
    (27, [6, 17, 19]),  # Sonnenblumenkerne, ungeschält
    (28, [6, 17, 19]),  # Leinsamen, braun
    (29, [6, 17, 19]),  # Leinsamen, golden
    (30, [6, 17, 19]),  # Hanfsamen, geschält
    (31, [6, 17, 19]),  # Hanfsamen, ungeschält
    (32, [6, 12, 19]),  # Erdnüsse, blanchiert
    (33, [6, 12, 19]),  # Erdnüsse, geröstet
    (34, [6, 12, 19]),  # Erdnüsse, ungesalzen
    (35, [6, 12, 19]),  # Erdnüsse, gesalzen
    (36, [6, 12]),  # Cashewnüsse, roh
    (37, [6, 12]),  # Cashewnüsse, geröstet
    (38, [6, 12]),  # Cashewnüsse, gesalzen
    (39, [6, 12, 19]),  # Mandeln, roh
    (40, [6, 12, 19]),  # Mandeln, geröstet
    (41, [6, 12, 19]),  # Mandeln, gesalzen
    (42, [6, 12]),  # Haselnüsse, roh
    (43, [6, 12]),  # Haselnüsse, geröstet
    (44, [6, 12]),  # Haselnüsse, blanchiert
    (45, [6, 12, 19]),  # Walnüsse, roh
    (46, [6, 12, 19]),  # Walnüsse, geröstet
    (47, [6, 12]),  # Pistazien, roh
    (48, [6, 12]),  # Pistazien, geröstet
    (49, [6, 12]),  # Pistazien, gesalzen
    (50, [6, 12]),  # Macadamianüsse, roh
    (51, [6, 12]),  # Macadamianüsse, geröstet
    (52, [6, 12, 21]),  # Paranüsse, roh
    (53, [6, 12, 21]),  # Paranüsse, geröstet
    (54, [6, 12]),  # Pekannüsse, roh
    (55, [6, 12]),  # Pekannüsse, geröstet
    (56, [6, 17, 22]),  # Kastanien, roh
    (57, [6, 17, 22]),  # Kastanien, geröstet
    (58, [6, 19]),  # Ginkgo-Nüsse, roh
    (59, [6, 19]),  # Ginkgo-Nüsse, gekocht
    (60, [6, 17]),  # Lotosblumensamen, roh
    (61, [6, 17]),  # Lotosblumensamen, getrocknet
    (62, [6, 17]),  # Baumwollsamen, roh
    (63, [6, 17]),  # Baumwollsamen, geröstet
    (64, [6, 17]),  # Brotnussbaum-Samen, roh
    (65, [6, 17]),  # Brotnussbaum-Samen, getrocknet
    (66, [6, 17]),  # Saflor-Samen, roh
    (67, [6, 17]),  # Saflor-Samen, getrocknet
    (68, [6, 17]),  # Pinyon-Kiefersamen, roh
    (69, [6, 17]),  # Pinyon-Kiefersamen, geröstet
    (70, [6, 12]),  # Schwarznüsse, roh
    (71, [6, 12]),  # Schwarznüsse, getrocknet
    (72, [6, 17, 19]),  # Erdmandeln, roh
    (73, [6, 17, 19]),  # Erdmandeln, getrocknet
    (74, [6, 17, 19]),  # Wassermelonenkerne, roh
    (75, [6, 17, 19]),  # Wassermelonenkerne, geröstet
    (76, [6, 17]),  # Basilikumsamen, roh
    (77, [6, 17]),  # Basilikumsamen, getrocknet
    (78, [6, 17]),  # Mohnsamen, blau, roh
    (79, [6, 17]),  # Mohnsamen, weiß, roh
    (80, [6, 17, 19]),  # Chiasamen, schwarz, roh
    (81, [6, 17, 19]),  # Chiasamen, weiß, roh
    (82, [6, 17]),  # Sesamsamen, schwarz, roh
    (83, [6, 17]),  # Sesamsamen, weiß, roh
    (84, [6, 17, 19]),  # Kürbiskerne, grün, roh
    (85, [6, 17, 19]),  # Kürbiskerne, weiß, roh
    (86, [6, 17, 19]),  # Sonnenblumenkerne, geschält, roh
    (87, [6, 17, 19]),  # Sonnenblumenkerne, ungeschält, roh
    (88, [6, 17, 19]),  # Leinsamen, braun, roh
    (89, [6, 17, 19]),  # Leinsamen, golden, roh
    (90, [6, 17, 19]),  # Hanfsamen, geschält, roh
    (91, [6, 17, 19]),  # Hanfsamen, ungeschält, roh
    (92, [6, 19]),  # Erdnussbutter
    (93, [6, 19]),  # Mandelbutter
    (94, [6, 19]),  # Cashewbutter
    (95, [6, 19]),  # Haselnusscreme
    (96, [6, 19]),  # Tahini (Sesampaste)
    (97, [6, 19]),  # Pistazienpaste
    (98, [6, 19]),  # Macadamianussbutter
    (99, [6, 19]),  # Sonnenblumenkernbutter
]

setDatabase(tags,foodsNüsse,nutritionNüsse_facts,foodNüsse_tags)

foodsBackzutaten = [
    ("Backpulver", "Backzutat", "Ein chemisches Triebmittel, das Teige auflockert und ihnen Volumen verleiht."),
    ("Natron (Speisesoda)", "Backzutat", "Wird als Backtriebmittel verwendet, insbesondere in Kombination mit sauren Zutaten."),
    ("Hefe", "Backzutat", "Ein biologisches Triebmittel, das Teige durch Gärung aufgehen lässt."),
    ("Hirschhornsalz", "Backzutat", "Ein traditionelles Backtriebmittel, hauptsächlich für flache Gebäcke wie Lebkuchen."),
    ("Pottasche", "Backzutat", "Wird in der Weihnachtsbäckerei verwendet, um Teige aufzulockern."),
    ("Vanillezucker", "Backzutat", "Aromatisiert Backwaren mit Vanillegeschmack."),
    ("Zitronenschale (abgeriebene)", "Backzutat", "Verleiht Teigen und Füllungen ein frisches Aroma."),
    ("Orangenschale (abgeriebene)", "Backzutat", "Für ein fruchtiges Aroma in Backwaren."),
    ("Kakaopulver", "Backzutat", "Für schokoladigen Geschmack in Kuchen und Keksen."),
    ("Schokoladenstückchen", "Backzutat", "Kleine Schokostücke, die in Teige eingearbeitet werden."),
    ("Kuvertüre", "Backzutat", "Hochwertige Schokolade zum Überziehen von Gebäck."),
    ("Puddingpulver", "Backzutat", "Basis für Puddingfüllungen in Kuchen und Gebäck."),
    ("Speisestärke", "Backzutat", "Zum Binden von Füllungen und Auflockern von Teigen."),
    ("Gelatine", "Backzutat", "Zum Gelieren von Cremes und Füllungen."),
    ("Agar-Agar", "Backzutat", "Pflanzliches Geliermittel als Alternative zu Gelatine."),
    ("Pektin", "Backzutat", "Natürliches Geliermittel, oft in Fruchtfüllungen verwendet."),
    ("Tortenguss", "Backzutat", "Zum Überziehen von Obstkuchen, um einen glänzenden Abschluss zu erzielen."),
    ("Marzipan", "Backzutat", "Süße Mandelmasse für Füllungen und Dekorationen."),
    ("Fondant", "Backzutat", "Weiche Zuckermasse zum Überziehen und Dekorieren von Torten."),
    ("Zitronat", "Backzutat", "Kandierte Zitronenschale, verwendet in Früchtebroten und Kuchen."),
    ("Orangeat", "Backzutat", "Kandierte Orangenschale für aromatische Backwaren."),
    ("Rosinen", "Backzutat", "Getrocknete Weintrauben, die in vielen Backwaren verwendet werden."),
    ("Sultaninen", "Backzutat", "Helle Rosinen, oft in Hefeteigen verwendet."),
    ("Korinten", "Backzutat", "Kleine, dunkle Rosinen mit intensivem Geschmack."),
    ("Cranberries (getrocknet)", "Backzutat", "Für eine fruchtige Note in Gebäck."),
    ("Datteln (getrocknet)", "Backzutat", "Süße Trockenfrüchte für Brote und Kuchen."),
    ("Feigen (getrocknet)", "Backzutat", "Aromatische Ergänzung in Backwaren."),
    ("Aprikosen (getrocknet)", "Backzutat", "Für eine fruchtige Komponente in Gebäck."),
    ("Backoblaten", "Backzutat", "Essbare Unterlagen für Makronen und Lebkuchen."),
    ("Mohnfüllung", "Backzutat", "Fertige Mischung für Mohnkuchen und -gebäck."),
    ("Nussfüllung", "Backzutat", "Fertige Füllung aus gemahlenen Nüssen für Gebäck."),
    ("Zuckerstreusel", "Dekoration", "Bunte Dekoration für Kuchen und Kekse."),
    ("Schokostreusel", "Dekoration", "Schokoladige Dekoration für Backwaren."),
    ("Perlzucker", "Dekoration", "Grober Zucker für dekorative Zwecke."),
    ("Kokosraspeln", "Backzutat", "Getrocknete Kokosflocken für Teige und Dekoration."),
    ("Mandelblättchen", "Dekoration", "Dünne Scheiben von Mandeln, oft als Topping verwendet."),
    ("Gehackte Nüsse", "Dekoration", "Kleine Nussstücke für Teige und als Dekoration."),
    ("Kandiszucker", "Dekoration", "Große Zuckerkristalle, die langsam schmelzen und Süße abgeben."),
    ("Honig", "Süßungsmittel", "Natürlicher Süßstoff mit eigenem Aroma."),
    ("Ahornsirup", "Süßungsmittel", "Süßungsmittel mit charakteristischem Geschmack."),
    ("Agavendicksaft", "Süßungsmittel", "Pflanzlicher Süßstoff aus der Agave."),
    ("Reissirup", "Süßungsmittel", "Milder Süßstoff aus Reis."),
    ("Kokosblütenzucker", "Süßungsmittel", "Zucker mit karamellartigem Geschmack."),
    ("Stevia", "Süßungsmittel", "Pflanzlicher Süßstoff ohne Kalorien."),
    ("Erythrit", "Süßungsmittel", "Zuckeralkohol als kalorienarmer Zuckerersatz."),
]
nutritionBackzutaten_facts = [
    (288, 0.0, 71.0, 0.5),   # Backpulver
    (0, 0.0, 0.0, 0.0),      # Natron (Speisesoda)
    (321, 40.0, 5.1, 1.2),   # Hefe
    (0, 0.0, 0.0, 0.0),      # Hirschhornsalz
    (0, 0.0, 0.0, 0.0),      # Pottasche
    (374, 0.0, 93.6, 0.0),   # Vanillezucker
    (47, 1.3, 12.2, 0.3),    # Zitronenschale (abgeriebene)
    (47, 0.9, 11.3, 0.2),    # Orangenschale (abgeriebene)
    (228, 19.6, 11.9, 13.7), # Kakaopulver
    (489, 5.2, 57.0, 25.0),  # Schokoladenstückchen
    (533, 5.4, 51.5, 31.0),  # Kuvertüre
    (371, 0.5, 89.0, 0.2),   # Puddingpulver
    (381, 0.2, 91.0, 0.1),   # Speisestärke
    (346, 84.0, 0.0, 0.0),   # Gelatine
    (26, 0.0, 0.1, 0.0),     # Agar-Agar
    (87, 0.0, 22.0, 0.0),    # Pektin
    (301, 0.0, 75.3, 0.0),   # Tortenguss
    (457, 6.5, 50.0, 25.0),  # Marzipan
    (384, 0.0, 92.5, 0.0),   # Fondant
    (329, 0.3, 82.4, 0.2),   # Zitronat
    (337, 0.3, 83.3, 0.1),   # Orangeat
    (299, 3.1, 79.2, 0.5),   # Rosinen
    (304, 3.3, 80.0, 0.5),   # Sultaninen
    (283, 3.6, 74.1, 0.5),   # Korinten
    (325, 1.0, 82.0, 1.5),   # Cranberries (getrocknet)
    (282, 2.5, 65.0, 0.6),   # Datteln (getrocknet)
    (274, 2.7, 62.0, 1.3),   # Feigen (getrocknet)
    (241, 3.4, 62.0, 0.5),   # Aprikosen (getrocknet)
    (367, 0.0, 90.0, 0.0),   # Backoblaten
    (355, 6.7, 45.0, 13.0),  # Mohnfüllung
    (418, 10.0, 34.0, 27.0), # Nussfüllung
    (389, 0.0, 98.0, 0.0),   # Zuckerstreusel
    (491, 2.8, 69.1, 25.6),  # Schokostreusel
    (400, 0.0, 100.0, 0.0),  # Perlzucker
    (660, 7.0, 23.0, 64.0),  # Kokosraspeln
    (579, 21.2, 21.7, 49.9), # Mandelblättchen
    (654, 15.2, 13.7, 65.2), # Gehackte Nüsse
    (399, 0.0, 100.0, 0.0),  # Kandiszucker
    (304, 0.3, 82.4, 0.0),   # Honig
    (260, 0.0, 67.0, 0.1),   # Ahornsirup
    (310, 0.0, 76.0, 0.1),   # Agavendicksaft
    (316, 0.5, 78.0, 0.1),   # Reissirup
    (380, 0.6, 92.0, 0.4),   # Kokosblütenzucker
    (0, 0.0, 0.0, 0.0),      # Stevia
    (0, 0.0, 0.0, 0.0),      # Erythrit
]

foodBackzutaten_tags = [
    (0, [6]),  # Backpulver
    (1, [6]),  # Natron (Speisesoda)
    (2, [6, 22]),  # Hefe
    (3, [6]),  # Hirschhornsalz
    (4, [6]),  # Pottasche
    (5, [6, 18]),  # Vanillezucker
    (6, [6, 18]),  # Zitronenschale (abgeriebene)
    (7, [6, 18]),  # Orangenschale (abgeriebene)
    (8, [6, 18]),  # Kakaopulver
    (9, [6, 18]),  # Schokoladenstückchen
    (10, [6, 18]),  # Kuvertüre
    (11, [6]),  # Puddingpulver
    (12, [6]),  # Speisestärke
    (13, [6]),  # Gelatine
    (14, [6, 23]),  # Agar-Agar
    (15, [6, 23]),  # Pektin
    (16, [6]),  # Tortenguss
    (17, [6, 18]),  # Marzipan
    (18, [6, 18]),  # Fondant
    (19, [6, 18]),  # Zitronat
    (20, [6, 18]),  # Orangeat
    (21, [6, 19]),  # Rosinen
    (22, [6, 19]),  # Sultaninen
    (23, [6, 19]),  # Korinten
    (24, [6, 19]),  # Cranberries (getrocknet)
    (25, [6, 19]),  # Datteln (getrocknet)
    (26, [6, 19]),  # Feigen (getrocknet)
    (27, [6, 19]),  # Aprikosen (getrocknet)
    (28, [6]),  # Backoblaten
    (29, [6, 18]),  # Mohnfüllung
    (30, [6, 18]),  # Nussfüllung
    (31, [6, 18]),  # Zuckerstreusel
    (32, [6, 18]),  # Schokostreusel
    (33, [6]),  # Perlzucker
    (34, [6, 18]),  # Kokosraspeln
    (35, [6, 18]),  # Mandelblättchen
    (36, [6, 18]),  # Gehackte Nüsse
    (37, [6]),  # Kandiszucker
    (38, [6, 20]),  # Honig
    (39, [6, 20]),  # Ahornsirup
    (40, [6, 20]),  # Agavendicksaft
    (41, [6, 20]),  # Reissirup
    (42, [6, 20]),  # Kokosblütenzucker
    (43, [6, 20]),  # Stevia
    (44, [6, 20]),  # Erythrit
]
