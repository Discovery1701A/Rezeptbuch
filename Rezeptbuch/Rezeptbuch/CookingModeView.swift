//
//  CookingModeView.swift
//  Rezeptbuch
//
//  Created by Anna Rieckmann on 29.03.24.
//
import SwiftUI
import Speech

struct CookingModeView: View {
    var recipe: Recipe
    @State private var currentStepIndex = 0
    @State private var isListening = false
    @State private var recognizedText = ""
    let synthesizer = AVSpeechSynthesizer()
    let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "de-DE")) // Setzen Sie die Sprache entsprechend ein
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    var body: some View {
        VStack {
            Text(recipe.instructions[currentStepIndex])
                .padding()
            
            Button(action: {
                if self.isListening {
                    self.stopRecording()
                } else {
                    self.startRecording()
                }
            }) {
                Text(self.isListening ? "Stop Listening" : "Start Listening")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            HStack {
                Button(action: {
                    self.goToPreviousStep()
                }) {
                    Text("Previous")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    self.goToNextStep()
                }) {
                    Text("Next")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(10)
                }
            }
        }
        .onAppear {
            self.prepareSpeechRecognition()
        }
    }
    
    func prepareSpeechRecognition() {
        if let recognizer = recognizer {
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            recognitionRequest?.shouldReportPartialResults = true
            
            recognitionTask = recognizer.recognitionTask(with: recognitionRequest!) { result, error in
                if let result = result {
                    self.recognizedText = result.bestTranscription.formattedString.lowercased() // Kleinschreibung für den Text
                    if result.isFinal {
                        self.processSpeech(result.bestTranscription.formattedString)
                    }
                } else if let error = error {
                    print("Recognition error: \(error.localizedDescription)")
                }
            }
        } else {
            print("Speech recognizer not available")
        }
    }
    
    func startRecording() {
        isListening = true
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup error: \(error.localizedDescription)")
        }
        
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine start error: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        isListening = false
        
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        recognitionRequest?.endAudio()
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }

    
    func processSpeech(_ text: String) {
        if text.contains("weiter") {
            goToNextStep()
        } else if text.contains("zurück") {
            goToPreviousStep()
        }
        
        print("Recognized text: \(text)")
    }
    
    func goToPreviousStep() {
        if currentStepIndex > 0 {
            currentStepIndex -= 1
        }
    }
    
    func goToNextStep() {
        if currentStepIndex < recipe.instructions.count - 1 {
            currentStepIndex += 1
        }
    }
}
