//
//  SpotifyController.swift
//  https://github.com/benzguo/SpotifyController
//  https://github.com/mcelal/SpotifyController
//

import Foundation

enum SpotifyPlayerState : String {
    case Duraklatildi = "paused"
    case Caliyor = "playing"
    case Durdu = "stopped"
}

class SpotifyController {
    
    class func task(command: String) -> String? {
        let task = Process()
        let prefix = "tell application \"Spotify\" to"
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", "\(prefix) \(command)"]
        let outPipe = Pipe()
        task.standardOutput = outPipe
        task.launch()
        task.waitUntilExit()
        let outHandle = outPipe.fileHandleForReading
        let output = NSString(data: outHandle.availableData, encoding: String.Encoding.utf8.rawValue) as NSString?
        return output?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
    
    class func trackInfoTask(command: String) -> String? {
        return task(command: "\(command) of current track")
    }
    
    // MARK: Composite commands
    class func setRepeating(repeating: Bool) {
        let maybeCurrent = isRepeating()
        if let current = maybeCurrent {
            if current == repeating { return }
            else { task(command: "set repeating to not repeating") }
        }
    }
    
    class func setShuffling(shuffling: Bool) {
        let maybeCurrent = isShuffling()
        if let current = maybeCurrent {
            if current == shuffling { return }
            else { task(command: "set shuffling to not shuffling") }
        }
    }
    
    // MARK: Application Info
    
    /// Is repeating on or off?
    class func isRepeating() -> Bool? { return task(command: "repeating")?.range(of: "true") != nil }
    
    /// Is shuffling on or off?
    class func isShuffling() -> Bool? { return task(command: "shuffling")?.range(of: "true") != nil }
    
    /// The sound output volume (0 = minimum, 100 = maximum)
    class func volume() -> Int! { return Int(task(command: "sound volume")!.description)! }
    
    /// The player's position within the currently playing track in seconds.
    /// Note: this doesn't appear to work on (1.0.3.101.gbfa97dfe)
        class func playerPosition() -> Int? {
        return task(command: "player position").map { ($0 as NSString).integerValue }
    }
    
    /// Is Spotify stopped, paused, or playing?
    class func playerState() -> SpotifyPlayerState? {
        return task(command: "player state").flatMap { SpotifyPlayerState(rawValue: $0) }
    }
    
    // MARK: Track Info
    /// The URL of the track.
    class func currentTrackURL() -> String? { return trackInfoTask(command: "spotify url") }
    
    /// The ID of the track.
    /// Note: same as URL
    class func currentTrackID() -> String? { return trackInfoTask(command: "id") }
    
    /// The name of the track.
    class func currentTrackName() -> String? { return trackInfoTask(command: "name") }
    
    /// The artist of the track.
    class func currentTrackArtist() -> String? { return trackInfoTask(command: "artist") }
    
    /// The album of the track.
    class func currentTrackAlbum() -> String? { return trackInfoTask(command: "album") }
    
    /// The track number of the track.
    class func currentTrackNumber() -> Int! { return Int(trackInfoTask(command: "track number")!.description)! }
    
    /// The disc number of the track.
    class func currentTrackDiscNumber() -> Int! { return Int(trackInfoTask(command: "disc number")!.description)! }
    
    /// The album artist of the track.
    class func currentTrackAlbumArtist() -> String? { return trackInfoTask(command: "album artist") }
    
    /// The length of the track in seconds.
    class func currentTrackDuration() -> Int! { return Int(trackInfoTask(command: "duration")!.description)! / 1000 }
    
    /// The number of times this track has been played.
    /// Note: This is the number of times the current user has played the track, and does not update immediately.
    class func currentTrackPlayCount() -> Int? { return Int(trackInfoTask(command: "played count")!.description) }
    
    /// How popular is this track? 0-100
    class func currentTrackPopularity() -> Int? { return Int(trackInfoTask(command: "popularity")!.description) }
    
    /// Is the track starred?
    //    class func currentTrackIsStarred() -> Bool? { return trackInfoTask(command: "starred")?.range(of: "true") != nil }
    
    // MARK: Commands
    /// Pause playback.
    class func pause() { task(command: "pause") }
    
    /// Resume playback.
    class func play() { task(command: "play") }
    
    
    /// Play the given spotify URL.
    class func play(spotifyURL: String) { task(command: "play track \"\(spotifyURL)\"") }
    
    /// Skip to the next track.
    class func nextTrack() { task(command: "next track") }
    
    /// Skip to the previous track.
    class func previousTrack() { task(command: "previous track") }
    
    // MARK: Standard app commands
    class func quit() { task(command: "quit") }
    
    class func version() -> String? { return task(command: "version") }
    
    class func frontmost() -> Bool? { return task(command: "frontmost")?.range(of: "true") != nil }
}
