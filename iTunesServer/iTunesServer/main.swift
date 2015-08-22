//
//  main.swift
//  iTunesServer
//
//  Created by Ben Navetta on 8/19/15.
//  Copyright © 2015 Ben Navetta. All rights reserved.
//

import Foundation
import iTunesLibrary
import ScriptingBridge

extension ITLibrary {
    func search(predicate: ITLibMediaItem -> Bool) -> [ITLibMediaItem] {
        let tracks = self.allMediaItems as! Array<ITLibMediaItem>;
        return tracks.filter(predicate);
    }
    
    func searchPlaylists(predicate: ITLibPlaylist -> Bool) -> [ITLibPlaylist] {
        let playlists = self.allPlaylists as! Array<ITLibPlaylist>;
        return playlists.filter(predicate);
    }
    
    func lookup(persistentID: PersistentID) -> ITLibMediaItem? {
        return self.search({$0.persistentID == persistentID.value}).first;
    }
    
    func lookupPlaylist(persistentID: PersistentID) -> ITLibPlaylist? {
        return self.searchPlaylists({$0.persistentID == persistentID.value}).first;
    }
}

do {
    let library: ITLibrary = try ITLibrary.libraryWithAPIVersion("1.1") as! ITLibrary;
    
    print("iTunes \(library.applicationVersion) (API v\(library.apiMajorVersion).\(library.apiMinorVersion))");
    
    // API endpoint exposing artwork?
    
    let song = library.search({$0.title == "Sunday Bloody Sunday"}).first!;
    print("Found \(song.title) by \(song.artist.name) in \(song.album.title)");
    
    let playlist = library.searchPlaylists({$0.name == "Music"}).first!;
    print("Found playlist \(playlist.name)");
    
    let iTunes = iTunesController();
    iTunes.run();
    iTunes.volume = 100;
    
//    iTunes.play(PersistentID(fromNumber: song.persistentID).value);
    iTunes.play(PersistentID(fromNumber: playlist.persistentID).value);
    
    iTunes.resume();
    
    let currentSong = library.lookup(PersistentID(fromHex: iTunes.currentTrack!))!;
    
    if let currentPlaylistID = iTunes.currentPlaylist,
        currentPlaylist = library.lookupPlaylist(PersistentID(fromHex: currentPlaylistID)) {
        print("Currently playing \(currentSong.title) by \(currentSong.artist.name) from \(currentPlaylist.name)");
    }
    else {
        print("Currently playing \(currentSong.title) by \(currentSong.artist.name) on \(currentSong.album.title)");
    }
    
    iTunes.setShuffle(true);
    iTunes.setShuffleMode(.Songs);
    iTunes.setRepeatMode(.Off);
    
    assert(iTunes.playerState == PlayerState.Playing);
    
    
} catch let error as NSError {
    print(error.localizedDescription)
}
