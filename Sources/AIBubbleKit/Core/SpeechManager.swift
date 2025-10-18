import Foundation
import AVFoundation
import Speech

/// Handles speech recognition and text-to-speech functionality
@MainActor
public class SpeechManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published public var isRecording: Bool = false
    @Published public var isSpeaking: Bool = false
    @Published public var recognitionPermissionGranted: Bool = false
    @Published public var speechPermissionGranted: Bool = false
    
    // MARK: - Private Properties
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var speechSynthesizer = AVSpeechSynthesizer()
    
    // MARK: - Initialization
    public override init() {
        super.init()
        setupAudioSession()
        requestPermissions()
    }
    
    // MARK: - Public Methods
    
    /// Request necessary permissions for speech recognition and synthesis
    public func requestPermissions() {
        // Request speech recognition permission
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                self?.recognitionPermissionGranted = authStatus == .authorized
            }
        }
        
        // Request microphone permission
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                // We'll assume speech permission is granted if microphone is granted
                self?.speechPermissionGranted = granted
            }
        }
    }
    
    /// Start recording audio for speech recognition
    public func startRecording() {
        guard !isRecording else { return }
        guard recognitionPermissionGranted else {
            print("Speech recognition permission not granted")
            return
        }
        
        do {
            try startAudioEngine()
            isRecording = true
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    /// Stop recording and return the recorded audio data
    public func stopRecording() -> Data {
        guard isRecording else { return Data() }
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        isRecording = false
        
        // In a real implementation, you would capture and return the actual audio data
        // For now, we'll return empty data as a placeholder
        return Data()
    }
    
    /// Transcribe audio data to text
    public func transcribe(_ audioData: Data) async throws -> String {
        guard recognitionPermissionGranted else {
            throw SpeechError.permissionDenied
        }
        
        guard let speechRecognizer = speechRecognizer else {
            throw SpeechError.recognizerUnavailable
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = SFSpeechURLRecognitionRequest(url: createTemporaryAudioFile(from: audioData))
            
            speechRecognizer.recognitionTask(with: request) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if let result = result {
                    if result.isFinal {
                        continuation.resume(returning: result.bestTranscription.formattedString)
                    }
                }
            }
        }
    }
    
    /// Speak the given text
    public func speak(_ text: String) {
        guard speechPermissionGranted else {
            print("Speech synthesis permission not granted")
            return
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        speechSynthesizer.speak(utterance)
        isSpeaking = true
    }
    
    /// Stop current speech
    public func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
    
    /// Check if currently speaking
    public var isCurrentlySpeaking: Bool {
        return speechSynthesizer.isSpeaking
    }
    
    // MARK: - Private Methods
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func startAudioEngine() throws {
        let inputNode = audioEngine.inputNode
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechError.requestCreationFailed
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            if let error = error {
                print("Recognition error: \(error)")
            }
        }
    }
    
    private func createTemporaryAudioFile(from audioData: Data) -> URL {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp_audio.wav")
        
        // In a real implementation, you would properly format the audio data
        // For now, we'll create a simple placeholder
        try? audioData.write(to: tempURL)
        
        return tempURL
    }
}

// MARK: - Speech Errors

public enum SpeechError: Error, LocalizedError {
    case permissionDenied
    case recognizerUnavailable
    case requestCreationFailed
    case audioEngineFailed
    case transcriptionFailed
    
    public var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Speech recognition permission denied"
        case .recognizerUnavailable:
            return "Speech recognizer is not available"
        case .requestCreationFailed:
            return "Failed to create recognition request"
        case .audioEngineFailed:
            return "Audio engine failed to start"
        case .transcriptionFailed:
            return "Failed to transcribe audio"
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension SpeechManager: AVSpeechSynthesizerDelegate {
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
}
