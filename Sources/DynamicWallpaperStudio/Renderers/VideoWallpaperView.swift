import AppKit
import SwiftUI
import AVFoundation

public struct VideoWallpaperView: NSViewRepresentable {
    public let videoURL: URL
    public let isMuted: Bool
    public let isPaused: Bool
    public let targetFPS: Int
    
    public init(videoURL: URL, isMuted: Bool = true, isPaused: Bool = false, targetFPS: Int = 60) {
        self.videoURL = videoURL
        self.isMuted = isMuted
        self.isPaused = isPaused
        self.targetFPS = targetFPS
    }
    
    public func makeNSView(context: Context) -> AVPlayerContainerView {
        let view = AVPlayerContainerView(url: videoURL)
        view.setMuted(isMuted)
        if isPaused {
            view.pause()
        } else {
            view.play()
        }
        return view
    }
    
    public func updateNSView(_ nsView: AVPlayerContainerView, context: Context) {
        nsView.updateURL(videoURL)
        nsView.setMuted(isMuted)
        if isPaused {
            nsView.pause()
        } else {
            nsView.play()
        }
    }
}

public final class AVPlayerContainerView: NSView {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerItemObserver: Any?
    private var currentURL: URL?
    
    public init(url: URL) {
        super.init(frame: .zero)
        self.wantsLayer = true
        setupPlayer(url: url)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPlayer(url: URL) {
        self.currentURL = url
        let asset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: false])
        let playerItem = AVPlayerItem(asset: asset)
        
        let player = AVPlayer(playerItem: playerItem)
        player.actionAtItemEnd = .none
        
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        layer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        
        self.layer?.addSublayer(layer)
        self.playerLayer = layer
        self.player = player
        
        // Loop video seamlessly
        playerItemObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak player] _ in
            player?.seek(to: .zero)
            player?.play()
        }
    }
    
    public func updateURL(_ url: URL) {
        guard currentURL != url else { return }
        cleanup()
        setupPlayer(url: url)
    }
    
    public func setMuted(_ muted: Bool) {
        player?.isMuted = muted
    }
    
    public func play() {
        if player?.rate == 0 {
            player?.play()
        }
    }
    
    public func pause() {
        player?.pause()
    }
    
    override public func layout() {
        super.layout()
        playerLayer?.frame = self.bounds
    }
    
    private func cleanup() {
        if let observer = playerItemObserver {
            NotificationCenter.default.removeObserver(observer)
            playerItemObserver = nil
        }
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil
    }
    
    deinit {
        cleanup()
    }
}
