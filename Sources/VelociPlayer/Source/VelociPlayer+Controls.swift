//
//  VelociPlayer+Controls.swift
//  VelociPlayer
//
//  Created by Ethan Humphrey on 2/1/22.
//

import Foundation
import AVFoundation
import MediaPlayer
import Combine

extension VelociPlayer {
    // MARK: - Controls
    
    /// Begin playback of the current item
    nonisolated public override func play() {
        Task { @MainActor in
            self.beginPlayerObservationIfNeeded()
            self.autoPlay = true
            super.play()
        }
    }
    
    /// Pause playback of the current item
    nonisolated public override func pause() {
        Task { @MainActor in
            self.autoPlay = false
            super.pause()
        }
    }
    
    /// Rewind the player based on the ``seekInterval``
    public func rewind() {
        let newTime = currentTime().seconds - self.seekInterval
        seek(to: newTime)
    }
    
    /// Go forward based on the ``seekInterval``
    public func skipForward() {
        let newTime = currentTime().seconds + self.seekInterval
        seek(to: newTime)
    }
    
    /// Toggle playback for the current item.
    public func togglePlayback() {
        if isPaused {
            play()
        } else {
            pause()
        }
    }
    
    /// Stop playback and end any observation on the player.
    public func stop() {
        if let timeObserver = timeObserver, timeControlStatus == .playing {
            self.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        
        subscribers.removeAll()
        currentItemSubscribers.removeAll()
        
        self.displayInSystemPlayer = false
        self.pause()
        
        #if os(iOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)
        Task.detached {
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
        #endif
    }
    
    
    /// Attempt to reload the current item
    public func reload() {
        self.currentError = nil
        guard let currentItem = self.currentItem else {
            self.currentError = .unableToBuffer
            return
        }
        self.mediaURL = nil
        self.mediaURL = (currentItem.asset as? AVURLAsset)?.url
    }
}
