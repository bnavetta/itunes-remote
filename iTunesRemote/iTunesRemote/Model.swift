//
//  iTunesLibrary.swift
//  iTunesRemote
//
//  Created by Ben Navetta on 8/29/15.
//  Copyright © 2015 Ben Navetta. All rights reserved.
//

import Foundation

import Argo
import Curry

struct ArtistReference { let name: String }

extension ArtistReference: Decodable {
    static func decode(j: JSON) -> Decoded<ArtistReference> {
        return curry(ArtistReference.init)
            <^> j <| "title";
    }
}

extension ArtistReference: CustomDebugStringConvertible {
    var debugDescription: String {
        return "ArtistReference[\(self.name)]"
    }
}

struct AlbumReference { let title: String }

extension AlbumReference: Decodable {
    static func decode(j: JSON) -> Decoded<AlbumReference> {
        return curry(AlbumReference.init)
            <^> j <| "title"
    }
}

extension AlbumReference: CustomDebugStringConvertible {
    var debugDescription: String {
        return "AlbumReference[\(self.title)]"
    }
}

struct SongReference { let persistentID: PersistentID, title: String }

extension SongReference: Decodable {
    static func decode(j: JSON) -> Decoded<SongReference> {
        return curry(SongReference.init)
            <^> j <| "persistent_id"
            <*> j <| "title"
    }
}

extension SongReference: CustomDebugStringConvertible {
    var debugDescription: String {
        return "SongReference[\(self.persistentID): \(self.title)]"
    }
}

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

extension PersistentID: Decodable {
    static func decode(j: JSON) -> Decoded<PersistentID> {
        return String.decode(j).map({ PersistentID(fromHex: $0) })
    }
}

struct Artist {
    let name: String
    let albums: [AlbumReference]
    let songs: [SongReference]
}

extension Artist: Decodable {
    static func decode(j: JSON) -> Decoded<Artist> {
        return curry(Artist.init)
            <^> j <| "name"
            <*> j <|| "albums"
            <*> j <|| "songs"
    }
}

extension Artist: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        return self.name
    }
    
    var debugDescription: String {
        return "Artist[name: \(self.name.debugDescription), songs: \(self.songs.debugDescription), albums: \(self.albums.debugDescription)]"
    }
}

struct Album {
    let title: String
    let rating: Int
    let discNumber: UInt
    let discCount: UInt
    let compilation: Bool
    let artist: ArtistReference
    let tracks: [SongReference]
}

extension Album: Decodable {
    static func decode(j: JSON) -> Decoded<Album> {
        return curry(Album.init)
            <^> j <| "title"
            <*> j <| "rating"
            <*> j <| "disc_number"
            <*> j <| "disc_count"
            <*> j <| "compilation"
            <*> j <| "artist"
            <*> j <|| "tracks"
    }
}

extension Album: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        return self.title
    }
    
    var debugDescription: String {
        return "Album[title: \(self.title.debugDescription), rating: \(self.rating), discNumber: \(self.discNumber), discCount: \(self.discCount), compilation: \(self.compilation), artist: \(self.artist.debugDescription), tracks: \(self.tracks.debugDescription)]"
    }
}

struct Song {
    let persistentID: PersistentID
    let title: String
    let artist: ArtistReference
    let album: AlbumReference
    let totalTime: UInt
    let trackNumber: UInt
    let playCount: UInt
    let lastPlayedDate: NSDate?
    let location: NSURL
    let releaseDate: NSDate?
    let year: UInt
}

extension Song: Decodable {
    static func decode(j: JSON) -> Decoded<Song> {
        // Swift doesn't support currying this many parameters
        // https://github.com/thoughtbot/Argo/issues/106
        
        let partial = curry(Song.init)
            <^> j <| "persistent_id"
            <*> j <| "title"
            <*> j <| "artist"
            <*> j <| "album"
            <*> j <| "total_time"
            <*> j <| "track_number"
            <*> j <| "play_count"
        
        return partial
            <*> j <|? "last_played_date"
            <*> j <| "location"
            <*> j <|? "release_date"
            <*> j <| "year"
    }
}

extension Song: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        return self.title
    }
    
    var debugDescription: String {
        return "Song[persistentId: \(self.persistentID), title: \(self.title.debugDescription)], artist: \(self.artist.debugDescription), album: \(self.album.debugDescription), totalTime: \(self.totalTime), trackNumber: \(self.trackNumber), playCount: \(self.playCount), lastPlayedDate: \(self.lastPlayedDate), location: \(self.location), releaseDate: \(self.releaseDate), year: \(self.year)]"
    }
}

struct Playlist {
    let persistentID: PersistentID
    let name: String
    let items: [SongReference]
    let visible: Bool
}

extension Playlist: Decodable {
    static func decode(j: JSON) -> Decoded<Playlist> {
        return curry(Playlist.init)
            <^> j <| "persistent_id"
            <*> j <| "name"
            <*> j <|| "items"
            <*> j <| "visible"
    }
}

extension Playlist: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        return self.name
    }
    
    var debugDescription: String {
        return "Playlist[persistentID: \(self.persistentID), name: \(self.name.debugDescription), items: \(self.items.debugDescription), visible: \(self.visible)]"
    }
}