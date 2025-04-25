import SwiftUI
import Speech
import AVFoundation
/// Eine Ansicht, die die einzelnen Zubereitungsschritte eines Rezepts anzeigt.
/// Der Nutzer kann per Button oder Spracheingabe („weiter“, „zurück“) durch die Schritte navigieren.
struct CookingModeView: View {
    var recipe: Recipe // Das zu verwendende Rezept

    // 🔢 Aktueller Schrittindex
    @State private var currentStepIndex = 0

    // 🎤 Sprachsteuerung
    @State private var isListening = false
    @State private var recognizedText = ""
    @State private var lastProcessedSegmentIndex = 0

    // 🔊 Spracherkennungskomponenten
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "de-DE"))
    let audioEngine = AVAudioEngine()

    // 👉 Für Slide-Animationen beim Wechseln der Schritte
    enum SlideDirection {
        case forward
        case backward
    }
    @State private var direction: SlideDirection = .forward
    @State private var stepText: String = ""
    @State private var offset: CGFloat = 0

    // 📋 Liste der geladenen Schritte
    @State private var steps: [InstructionItem] = []

    var body: some View {
        VStack {
            // Anzeige des aktuellen Schritts
            Text("Schritt \(currentStepIndex + 1) von \(steps.count)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 20)

            Spacer()

            // Schritttext mit animierter Verschiebung
            Text(stepText)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()
                .offset(x: offset)
                .animation(.easeInOut(duration: 0.3), value: offset)

            Spacer()

            // Optional: Zeige erkannte Sprache
            if !recognizedText.isEmpty {
                Text("Erkannt: \"\(recognizedText)\"")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
            }

            // Steuerelemente
            VStack(spacing: 15) {
                HStack(spacing: 20) {
                    // Zurück-Button
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
                    .disabled(currentStepIndex == 0)

                    // Weiter-Button
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
                    .disabled(currentStepIndex == steps.count - 1)
                }

                // Sprachsteuerung aktivieren/deaktivieren
                Button(action: {
                    isListening ? stopRecording() : startRecording()
                }) {
                    Label(isListening ? "Stoppen" : "Sprachsteuerung", systemImage: isListening ? "mic.slash.fill" : "mic.fill")
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
            // Schritte laden und sortieren
            self.steps = recipe.instructions.sorted { ($0.number ?? 0) < ($1.number ?? 0) }
            self.stepText = steps.isEmpty ? "" : steps[currentStepIndex].text
        }
        .onDisappear {
            stopRecording() // Mikrofon bei Verlassen deaktivieren
        }
    }

    // MARK: - Animation bei Schrittwechsel

    /// Führt eine Slide-Animation aus und wechselt den Text
    func animateStepChange(to newIndex: Int, direction: SlideDirection) {
        guard newIndex >= 0 && newIndex < steps.count else { return }
        self.direction = direction

        let width = UIScreen.main.bounds.width

        // Alte Ansicht rausschieben
        withAnimation {
            offset = direction == .forward ? -width : width
        }

        // Nach kurzer Verzögerung: Schritt wechseln, neue Ansicht reinschieben
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentStepIndex = newIndex
            stepText = steps[newIndex].text
            offset = direction == .forward ? width : -width

            withAnimation {
                offset = 0
            }
        }
    }

    // MARK: - Sprachaufnahme starten

    func startRecording() {
        // Erst Autorisierung einholen
        SFSpeechRecognizer.requestAuthorization { status in
            guard status == .authorized else {
                print("🔴 Sprach-Erlaubnis nicht erteilt")
                return
            }

            DispatchQueue.main.async {
                self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
                guard let recognitionRequest = self.recognitionRequest else { return }

                recognitionRequest.shouldReportPartialResults = true
                self.startAudioSession()

                let inputNode = self.audioEngine.inputNode
                let format = inputNode.outputFormat(forBus: 0)

                // Sprachpuffer „anzapfen“
                inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                    recognitionRequest.append(buffer)
                }

                // Aufnahme starten
                self.audioEngine.prepare()
                do {
                    try self.audioEngine.start()
                    self.isListening = true
                    self.lastProcessedSegmentIndex = 0
                } catch {
                    print("Audio Engine konnte nicht gestartet werden: \(error.localizedDescription)")
                }

                // Sprachverarbeitung
                self.recognitionTask = self.recognizer?.recognitionTask(with: recognitionRequest) { result, error in
                    if let result = result {
                        let newSegments = result.bestTranscription.segments.dropFirst(self.lastProcessedSegmentIndex)
                        for segment in newSegments {
                            let word = segment.substring.lowercased()
                            print("📣 Neues Wort: \(word)")
                            self.processSpeech(word)
                        }
                        self.lastProcessedSegmentIndex = result.bestTranscription.segments.count
                    }

                    if let error = error {
                        print("Recognition Error: \(error.localizedDescription)")
                        self.stopRecording()
                    }
                }
            }
        }
    }

    /// Aufnahme stoppen und alles zurücksetzen
    func stopRecording() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        isListening = false
        recognizedText = ""
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    /// Konfiguriert das Mikrofon & AudioSession für Sprachaufnahmen
    func startAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio Session Error: \(error.localizedDescription)")
        }
    }

    // MARK: - Sprachverarbeitung

    /// Prüft erkannte Wörter und löst bei Bedarf einen Schrittwechsel aus
    func processSpeech(_ text: String) {
        if text.contains("weiter") {
            animateStepChange(to: currentStepIndex + 1, direction: .forward)
        } else if text.contains("zurück") {
            animateStepChange(to: currentStepIndex - 1, direction: .backward)
        }
    }
}
