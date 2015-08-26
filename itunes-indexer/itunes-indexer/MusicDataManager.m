//
//  MusicDataManager.m
//  itunes-indexer
//
//  Created by Ben Navetta on 8/25/15.
//  Copyright © 2015 Ben Navetta. All rights reserved.
//

#import "MusicDataManager.h"

@implementation MusicDataManager

- (void)createSchema
{
    [self executeUpdateInTransaction:^BOOL(FMDatabase *db) {
        NSString* schema = @"CREATE TABLE IF NOT EXISTS artist (name TEXT PRIMARY KEY);"
                            "CREATE INDEX IF NOT EXISTS artist_name on artist (name);"
                            "CREATE TABLE IF NOT EXISTS  album (title TEXT PRIMARY KEY, rating INTEGER, disc_number UNSIGNED INTEGER, disc_count UNSIGNED_INTEGER, compilation BOOLEAN, album_artist TEXT, FOREIGN KEY(album_artist) REFERENCES artist(name));"
                            "CREATE INDEX IF NOT EXISTS album_title ON album(title);"
                            "CREATE INDEX IF NOT EXISTS album_artist ON album(album_artist);"
                            "CREATE TABLE IF NOT EXISTS song (persistent_id UNSIGNED INTEGER PRIMARY KEY, title TEXT, artist TEXT, composer TEXT, rating INTEGER, album TEXT, genre TEXT, file_size UNSIGNED INTEGER, total_time UNSIGNED INTEGER, track_number UNSIGNED INTEGER, play_count UNSIGNED INTEGER, last_played_date DATE, location TEXT, release_date DATE, year UNSIGNED INTEGER, FOREIGN KEY(artist) REFERENCES artist(name), FOREIGN KEY(album) REFERENCES album(title));"
                            "CREATE INDEX IF NOT EXISTS song_title ON song(title);"
                            "CREATE INDEX IF NOT EXISTS song_artist ON song(artist);"
                            "CREATE INDEX IF NOT EXISTS song_album ON song(album);"
                            "CREATE TABLE IF NOT EXISTS playlist (persistent_id UNSIGNED INTEGER PRIMARY KEY, name TEXT, visible BOOLEAN);"
                            "CREATE INDEX IF NOT EXISTS playlist_name ON playlist(name);"
                            "CREATE TABLE IF NOT EXISTS playlist_items (playlist_id UNSIGNED INTEGER, item_id UNSIGNED INTEGER, FOREIGN KEY(playlist_id) REFERENCES playlist(persistent_id), FOREIGN KEY(item_id) REFERENCES song(persistent_id));";
        
        return [db executeStatements:schema];
    }];
}

- (void)clearIndex
{
    [self executeUpdateInTransaction:^BOOL(FMDatabase *db)
    {
        NSString* sql = @"DELETE FROM artist; DELETE FROM album; DELETE FROM song; DELETE FROM playlist; DELETE FROM playlist_items";
        return [db executeStatements:sql];
    }];
}


BOOL isMusicPlaylist(ITLibPlaylist* playlist)
{
    switch (playlist.distinguishedKind)
    {
        case ITLibDistinguishedPlaylistKind90sMusic:
        case ITLibDistinguishedPlaylistKindClassicalMusic:
        case ITLibDistinguishedPlaylistKindLovedSongs:
        case ITLibDistinguishedPlaylistKindMusic:
        case ITLibDistinguishedPlaylistKindMyTopRated:
        case ITLibDistinguishedPlaylistKindNone:
        case ITLibDistinguishedPlaylistKindPurchases:
        case ITLibDistinguishedPlaylistKindRecentlyAdded:
        case ITLibDistinguishedPlaylistKindRecentlyPlayed:
        case ITLibDistinguishedPlaylistKindTop25MostPlayed:
            return YES;
        default:
            return NO;
    }
}

- (void)indexLibrary:(ITLibrary *)library
{
    [self executeUpdateInTransaction:^BOOL(FMDatabase *db) {
       // Clear out playlist items in case any tracks were removed
        if (![db executeStatements:@"DELETE FROM playlist_items"])
        {
            return NO;
        }
        
        NSMutableSet<NSString*>* insertedArtists = [NSMutableSet set];
        NSMutableSet<NSString*>* insertedAlbums = [NSMutableSet set];
        
        for (ITLibMediaItem* item in library.allMediaItems)
        {
            if (item.mediaKind != ITLibMediaItemMediaKindSong) continue;
            
            NSString* artistName = item.artist.name ?: @"Unknown Artist";
            
            if (artistName != nil && ![insertedArtists containsObject:artistName])
            {
                if (![db executeUpdate:@"INSERT OR REPLACE INTO artist (name) VALUES (?)", artistName])
                {
                    return NO;
                }
                
                [insertedArtists addObject:artistName];
            }
            
            NSString* albumTitle = item.album.title ?: @"Unknown Album";
            
            if (albumTitle != nil && ![insertedAlbums containsObject:albumTitle])
            {
                ITLibAlbum* album = item.album;
                
                NSString* albumArtist = nil;
                if (album.albumArtist != nil)
                {
                    albumArtist = album.albumArtist;
                }
                else if (album.artist != nil)
                {
                    albumArtist = album.artist.name;
                }
                else
                {
                    albumArtist = artistName;
                }
                    
                
                BOOL result = [db executeUpdate:@"INSERT OR REPLACE INTO album (title, rating, disc_number, disc_count, compilation, album_artist) VALUES (?, ?, ?, ?, ?, ?)", albumTitle, @(album.rating), @(album.discNumber), @(album.discCount), @(album.compilation), albumArtist];
                if (!result) {
                    return NO;
                }
                
                [insertedAlbums addObject:albumTitle];
            }
            
            NSString* title = item.title ?: @"Unknown";
            
//            NSLog(@"Inserting song: %@, %@, %@, %@, %ld, %@, %@, %llu, %lu, %lu, %lu, %@, %@, %@, %lu", item.persistentID, item.title, item.artist.name, item.composer, (long)item.rating, item.album.title, item.genre, (unsigned long long)item.fileSize, (unsigned long)item.totalTime, (unsigned long)item.trackNumber, (unsigned long)item.playCount, item.lastPlayedDate, item.location.absoluteString, item.releaseDate, (unsigned long)item.year);
            BOOL result = [db executeUpdate:@"INSERT OR REPLACE INTO song (persistent_id, title, artist, composer, rating, album, genre, file_size, total_time, track_number, play_count, last_played_date, location, release_date, year) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", item.persistentID, title, artistName, item.composer, @(item.rating), albumTitle, item.genre, @(item.fileSize), @(item.totalTime), @(item.trackNumber), @(item.playCount), item.lastPlayedDate, item.location.absoluteString, item.releaseDate, @(item.year)];
            if (!result)
            {
                return NO;
            }
        }
        
        for (ITLibPlaylist* playlist in library.allPlaylists)
        {
            if (!isMusicPlaylist(playlist)) continue;
            
            BOOL result = [db executeUpdate:@"INSERT OR REPLACE INTO playlist (persistent_id, name, visible) VALUES (?, ?, ?)", playlist.persistentID, playlist.name, @(playlist.visible)];
            if (!result)
            {
                return NO;
            }
            
            for (ITLibMediaItem* item in playlist.items)
            {
                if (item.mediaKind != ITLibMediaItemMediaKindSong) continue;
                
                BOOL result = [db executeUpdate:@"INSERT INTO playlist_items (playlist_id, item_id) VALUES (?, ?)", playlist.persistentID, item.persistentID];
                if (!result)
                {
                    return NO;
                }
            }
        }
        
        return YES;
    }];
}

@end