import AVFoundation
import SwiftUI
import UIKit

/// Reads story text aloud for early readers.
final class Narrator {
    static let shared = Narrator()
    private let synthesizer = AVSpeechSynthesizer()

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
    }

    func speak(_ text: String) {
        if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }
        let utterance = AVSpeechUtterance(string: text.replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: ""))
        // Use the family's local English accent (en-IN, en-NG, en-AU…) when the device has one.
        let region = Locale.current.region?.identifier ?? "US"
        utterance.voice = AVSpeechSynthesisVoice(language: "en-\(region)") ?? AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.44
        utterance.pitchMultiplier = 1.12
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}

enum Haptics {
    static func tap() { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func oops() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
}

/// Small round "read it to me" button.
struct SpeakButton: View {
    let text: String
    var tint: Color = Palette.lavenderDeep

    var body: some View {
        Button {
            Haptics.tap()
            Narrator.shared.speak(text)
        } label: {
            Image(systemName: "speaker.wave.2.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(Circle().fill(tint))
        }
        .buttonStyle(PressableStyle())
        .accessibilityLabel("Read aloud")
    }
}
