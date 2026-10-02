import AVFoundation
import SwiftUI

/// Records a grandparent's (or parent's) voice to a local file. Recordings
/// stay on the device; nothing is uploaded.
@Observable
final class VoiceRecorder: NSObject, AVAudioRecorderDelegate {
    private(set) var isRecording = false
    private(set) var fileName: String?
    private(set) var permissionDenied = false
    private(set) var seconds = 0
    private var recorder: AVAudioRecorder?
    private var timer: Timer?

    func toggle() {
        isRecording ? stop() : start()
    }

    func start() {
        AVAudioApplication.requestRecordPermission { granted in
            DispatchQueue.main.async {
                guard granted else {
                    self.permissionDenied = true
                    return
                }
                self.beginRecording()
            }
        }
    }

    private func beginRecording() {
        Narrator.shared.stop()
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try? session.setActive(true)

        // Re-recording replaces the previous take.
        if let old = fileName { VoiceFiles.delete(old) }
        let name = VoiceFiles.newFileName()
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 22_050,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
        ]
        guard let recorder = try? AVAudioRecorder(url: VoiceFiles.url(for: name), settings: settings) else { return }
        recorder.delegate = self
        recorder.record(forDuration: 180)
        self.recorder = recorder
        fileName = name
        seconds = 0
        isRecording = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.seconds += 1
        }
    }

    func stop() {
        recorder?.stop()
        finish()
    }

    /// Throws away an unsaved take.
    func discard() {
        stop()
        if let name = fileName { VoiceFiles.delete(name) }
        fileName = nil
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        finish()
    }

    private func finish() {
        timer?.invalidate()
        timer = nil
        isRecording = false
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
    }
}

/// Plays a family recording.
@Observable
final class VoicePlayer: NSObject, AVAudioPlayerDelegate {
    static let shared = VoicePlayer()
    private(set) var playingFile: String?
    private var player: AVAudioPlayer?

    func toggle(_ file: String) {
        if playingFile == file {
            stop()
            return
        }
        Narrator.shared.stop()
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
        guard let player = try? AVAudioPlayer(contentsOf: VoiceFiles.url(for: file)) else { return }
        player.delegate = self
        player.play()
        self.player = player
        playingFile = file
    }

    func stop() {
        player?.stop()
        playingFile = nil
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playingFile = nil
    }
}

/// Big record button with a timer.
struct RecordButton: View {
    var recorder: VoiceRecorder
    var tint: Color = Palette.roseDeep

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 14) {
                Button {
                    Haptics.tap()
                    recorder.toggle()
                } label: {
                    ZStack {
                        Circle().fill(tint).frame(width: 64, height: 64)
                        if recorder.isRecording {
                            RoundedRectangle(cornerRadius: 5).fill(.white).frame(width: 22, height: 22)
                        } else {
                            Circle().fill(.white).frame(width: 24, height: 24)
                        }
                    }
                    .shadow(color: tint.opacity(0.5), radius: recorder.isRecording ? 12 : 6)
                }
                .buttonStyle(PressableStyle())
                .accessibilityLabel(recorder.isRecording ? "Stop recording" : "Record")

                VStack(alignment: .leading, spacing: 2) {
                    Text(recorder.isRecording ? "Recording… \(recorder.seconds)s" :
                            recorder.fileName == nil ? "Tap to record" : "Recorded! Tap to record again")
                        .font(.kid(15, weight: .heavy))
                        .foregroundStyle(Palette.ink)
                    Text("Saved only on this device")
                        .font(.kid(12, weight: .semibold))
                        .foregroundStyle(Palette.inkSoft)
                }
                Spacer(minLength: 0)
                if let file = recorder.fileName, !recorder.isRecording {
                    PlayVoiceButton(file: file)
                }
            }
            if recorder.permissionDenied {
                Text("The microphone is off. A grown-up can turn it on in Settings → Tiffin Tales.")
                    .font(.kid(13, weight: .bold))
                    .foregroundStyle(Palette.inkSoft)
            }
        }
    }
}

struct PlayVoiceButton: View {
    let file: String
    var player = VoicePlayer.shared

    var body: some View {
        Button {
            Haptics.tap()
            player.toggle(file)
        } label: {
            Image(systemName: player.playingFile == file ? "stop.fill" : "play.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(Circle().fill(Palette.mintDeep))
        }
        .buttonStyle(PressableStyle())
        .accessibilityLabel("Play family recording")
    }
}
