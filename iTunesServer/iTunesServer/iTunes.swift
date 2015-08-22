//
//  iTunes.swift
//  iTunesServer
//
//  Created by Ben Navetta on 8/20/15.
//  Copyright © 2015 Ben Navetta. All rights reserved.
//

import Foundation
import iTunesLibrary

struct PersistentID: CustomStringConvertible, Equatable {
    let value: UInt
    
    var description: String {
        return String(self.value, radix: 16, uppercase: true)
    }
    
    init(fromHex hex: String) {
        self.value = UInt(hex, radix: 16)!
    }
    
    init(fromValue value: UInt) {
        self.value = value
    }
    
    init(fromNumber number: NSNumber) {
        self.value = number.unsignedLongValue;
    }
}

func ==(lhs: PersistentID, rhs: PersistentID) -> Bool {
    return lhs.value == rhs.value;
}

extension ITLibMediaEntity {
    var id: PersistentID {
        return PersistentID(fromNumber: self.persistentID)
    }
}

private enum IndexState {
    case Unindexed, Indexing, Indexed
}

class iTunesLibrary {
    let library: ITLibrary!
    
    private(set) var albums: [ITLibAlbum] = []
    
    private(set) var artists: [ITLibArtist] = []
    
    lazy private var operationQueue: NSOperationQueue = {
        var queue = NSOperationQueue();
        queue.name = "iTunes Library Operations";
        queue.maxConcurrentOperationCount = 1;
        return queue;
    }()
    
    private var indexState = IndexState.Unindexed;
    
    var tracks: [ITLibMediaItem] {
        return library.allMediaItems as! [ITLibMediaItem]
    }
    
    var playlists: [ITLibPlaylist] {
        return library.allPlaylists as! [ITLibPlaylist]
    }
    
    init() throws {
        do {
            self.library = try ITLibrary.libraryWithAPIVersion("1.0") as! ITLibrary;
        }
        catch let error {
            self.library = nil
            throw error
        }
    }
    
    func indexLibrary() {
        switch self.indexState {
        case .Indexed, .Indexing:
            return;
        case .Unindexed:
            let task = BuildIndex(tracks: self.tracks, albums: self.albums, artists: self.artists);
            task.completionBlock = {
                self.indexState = .Indexed;
            }
            self.operationQueue.addOperation(task);
            self.indexState = .Indexing;
        }
    }
    
    func waitForIndexing() {
        self.operationQueue.waitUntilAllOperationsAreFinished()
    }
    
    func searchTracks(predicate: ITLibMediaItem -> Bool) -> [ITLibMediaItem] {
        return self.tracks.filter(predicate)
    }
    
    func searchPlaylists(predicate: ITLibPlaylist -> Bool) -> [ITLibPlaylist] {
        return self.playlists.filter(predicate)
    }
    
    func lookupTrack(id: PersistentID) -> ITLibMediaItem? {
        return self.searchTracks({$0.id == id}).first;
    }
    
    func lookupPlaylist(id: PersistentID) -> ITLibPlaylist? {
        return self.searchPlaylists({$0.id == id}).first;
    }
}

private class BuildIndex : NSOperation {
    let tracks: [ITLibMediaItem];
    var artists: [ITLibArtist];
    var albums: [ITLibAlbum];
    
    init(tracks: [ITLibMediaItem], albums: [ITLibAlbum], artists: [ITLibArtist]) {
        self.tracks = tracks
        self.artists = artists
        self.albums = albums
    }
    
    override func main() {
        let startTime = NSDate()
        if self.cancelled {
            return
        }
        
        for track in self.tracks {
            if !self.artists.contains({$0.name == track.artist?.name}) {
                self.artists.append(track.artist);
            }
            
            if !self.albums.contains({$0.title == track.album?.title && $0.albumArtist == track.album?.albumArtist}) {
                self.albums.append(track.album);
            }
        }
        
        let runTime = startTime.timeIntervalSinceNow;
        print("Indexing took \(runTime) seconds");
        
    }
}