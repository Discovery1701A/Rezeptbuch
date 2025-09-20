import SwiftUI
import Speech
import AVFoundation

/// Eine Ansicht, die die einzelnen Zubereitungsschritte eines Rezepts anzeigt.
/// Der Nutzer kann per Button oder Spracheingabe („weiter“, „zurück“) durch die Schritte navigieren.
struct CookingModeView: View {
    var recipe: Recipe // Das übergebene Rezept mit den Zubereitungsschritten

    // MARK: - 🔢 Aktueller Schrittindex
    @State private var currentStepIndex = 0 // Welcher Schritt gerade angezeigt wird

    // MARK: - 🎤 Sprachsteuerung Status
    @State private var isListening = false               // Ob Sprachsteuerung aktiv ist
    @State private var recognizedText = ""               // Zuletzt erkannter Text (Debuganzeige)
    @State private var lastProcessedSegmentIndex = 0     // Letzter verarbeiteter Transkriptions-Segmentindex

    // MARK: - 🔊 Spracherkennungskomponenten
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest? // Erkennungspuffer
    @State private var recognitionTask: SFSpeechRecognitionTask? // Erkennungs-Task
    let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "de-DE")) // Sprachmodell: Deutsch
    let audioEngine = AVAudioEngine() // Mikrofon-Audio-Engine

    // MARK: - 👉 Für Slide-Animationen
    enum SlideDirection {
        case forward, backward
    }
    @State private var direction: SlideDirection = .forward // Richtung des letzten Wechsels
    @State private var stepText: String = "" // Der aktuell angezeigte Schritttext
    @State private var offset: CGFloat = 0   // Für Slide-Animationen

    // MARK: - 📋 Schritte aus dem Rezept
    @State private var steps: [InstructionItem] = [] // Die sortierten Schritte

    // MARK: - Hauptansicht
    var body: some View {
        VStack {
            // 🔢 Schrittzähler
            Text("Schritt \(currentStepIndex + 1) von \(steps.count)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 20)

            Spacer()

            // 📝 Schritttext mit Slide-Animation
            Text(stepText)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()
                .offset(x: offset) // animierte Verschiebung
                .animation(.easeInOut(duration: 0.3), value: offset)

            Spacer()

            // 🗣️ Debuganzeige: erkannte Sprache
//            if !recognizedText.isEmpty {
//                Text("Erkannt: \"\(recognizedText)\"")
//                    .font(.footnote)
//                    .foregroundColor(.gray)
//                    .padding(.bottom, 10)
//            }

            // MARK: - Steuerelemente
            VStack(spacing: 15) {
                HStack(spacing: 20) {
                    // ◀️ Zurück-Button
                    Button(action: {
                        animateStepChange(to: currentStepIndex - 1, direction: .backward)
                    }) {
                        Label("Zurück", systemImage: "arrow.left")
                            .padding()
                            .frame(minWidth: 120)
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                    }
                    .disabled(currentStepIndex == 0) // deaktivieren bei Schritt 0

                    // ▶️ Weiter-Button
                    Button(action: {
                        animateStepChange(to: currentStepIndex + 1, direction: .forward)
                    }) {
                        Label("Weiter", systemImage: "arrow.right")
                            .padding()
                            .frame(minWidth: 120)
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                    }
                    .disabled(currentStepIndex == steps.count - 1) // deaktivieren bei letztem Schritt
                }

                // 🎤 Sprachsteuerung starten/stoppen
                Button(action: {
                    isListening ? stopRecording() : startRecording()
                }) {
                    Label(
                        isListening ? "Stoppen" : "Sprachsteuerung",
                        systemImage: isListening ? "mic.slash.fill" : "mic.fill"
                    )
                    .padding()
                    .frame(minWidth: 200)
                    .background(isListening ? Color.red.opacity(0.8) : Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .scaleEffect(isListening ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: isListening)
                }
            }
            .padding(.bottom, 30)
        }
        .padding()
        .onAppear {
            // Beim Anzeigen: Schritte laden & Text initialisieren
            self.steps = recipe.instructions.sorted { ($0.number ?? 0) < ($1.number ?? 0) }
            self.stepText = steps.isEmpty ? "" : steps[currentStepIndex].text
        }
        .onDisappear {
            stopRecording() // Mikrofon ausschalten beim Verlassen
        }
    }

    // MARK: - 🔁 Schritt-Animation
    /// Führt eine Slide-Animation aus und wechselt danach zum neuen Schritttext
    func animateStepChange(to newIndex: Int, direction: SlideDirection) {
        guard newIndex >= 0 && newIndex < steps.count else { return }
        self.direction = direction

        let width = UIScreen.main.bounds.width

        // Schritttext nach außen schieben (altes raus)
        withAnimation {
            offset = direction == .forward ? -width : width
        }

        // Nach der Animation: Index wechseln, neuen Text laden und von außen reinschieben
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentStepIndex = newIndex
            stepText = steps[newIndex].text
            offset = direction == .forward ? width : -width

            // Neue Ansicht in die Mitte schieben
            withAnimation {
                offset = 0
            }
        }
    }

    // MARK: - 🎙️ Sprachaufnahme starten
    func startRecording() {
        // Autorisierung anfordern
        SFSpeechRecognizer.requestAuthorization { status in
            guard status == .authorized else {
                print("🔴 Sprach-Erlaubnis nicht erteilt")
                return
            }

            DispatchQueue.main.async {
                self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
                guard let recognitionRequest = self.recognitionRequest else { return }

                recognitionRequest.shouldReportPartialResults = true // auch Zwischenergebnisse erhalten
                self.startAudioSession()

                let inputNode = self.audioEngine.inputNode
                let format = inputNode.outputFormat(forBus: 0)

                // Mikrofon-Tap installieren → Sprachdaten werden gesammelt
                inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                    recognitionRequest.append(buffer)
                }

                // AudioEngine starten
                self.audioEngine.prepare()
                do {
                    try self.audioEngine.start()
                    self.isListening = true
                    self.lastProcessedSegmentIndex = 0
                } catch {
                    print("Audio Engine Fehler: \(error.localizedDescription)")
                }

                // Spracherkennung starten
                self.recognitionTask = self.recognizer?.recognitionTask(with: recognitionRequest) { result, error in
                    if let result = result {
                        // Neue, noch nicht verarbeitete Worte
                        let newSegments = result.bestTranscription.segments.dropFirst(self.lastProcessedSegmentIndex)
                        for segment in newSegments {
                            let word = segment.substring.lowercased()
                            print("📣 Neues Wort: \(word)")
                            self.processSpeech(word)
                        }
                        self.lastProcessedSegmentIndex = result.bestTranscription.segments.count
                        self.recognizedText = result.bestTranscription.formattedString
                    }

                    if let error = error {
                        print("Recognition Error: \(error.localizedDescription)")
                        self.stopRecording()
                    }
                }
            }
        }
    }

    // MARK: - 🎙️ Aufnahme stoppen
    func stopRecording() {
        audioEngine.inputNode.removeTap(onBus: 0) // Tap entfernen
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        isListening = false
        recognizedText = ""
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    // MARK: - 🎛️ Audio Session vorbereiten
    func startAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio Session Fehler: \(error.localizedDescription)")
        }
    }

    // MARK: - 📢 Sprachbefehle verarbeiten
    /// Reagiert auf bestimmte erkannte Wörter wie „weiter“ oder „zurück“
    func processSpeech(_ text: String) {
        if text.contains("weiter") {
            animateStepChange(to: currentStepIndex + 1, direction: .forward)
        } else if text.contains("zurück") {
            animateStepChange(to: currentStepIndex - 1, direction: .backward)
        }
    }
}
