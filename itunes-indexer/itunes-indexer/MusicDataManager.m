//
//  MusicDataManager.m
//  itunes-indexer
//
//  Created by Ben Navetta on 8/25/15.
//  Copyright © 2015 Ben Navetta. All rights reserved.
//

#import "MusicDataManager.h"

@interface MusicDataManager ()

@property NSDateFormatter* dateFormatter;

@end

@implementation MusicDataManager

- (instancetype)initWithPath:(NSString *)path {
    if (self = [super initWithPath:path])
    {
        // http://oleb.net/blog/2011/11/working-with-date-and-time-in-cocoa-part-2/
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        self.dateFormatter.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        self.dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        self.dateFormatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'";
    }
    return self;
}

- (void)createSchema
{
    [self executeUpdateInTransaction:^BOOL(FMDatabase *db) {
        // Use TEXT for persistent_id due to some weirdness with unsigned values
        NSString* schema = @"CREATE TABLE IF NOT EXISTS artist (name TEXT PRIMARY KEY);"
                            "CREATE INDEX IF NOT EXISTS artist_name on artist (name);"
                            "CREATE TABLE IF NOT EXISTS  album (title TEXT PRIMARY KEY, rating INTEGER, disc_number UNSIGNED INTEGER, disc_count UNSIGNED_INTEGER, compilation BOOLEAN, album_artist TEXT, FOREIGN KEY(album_artist) REFERENCES artist(name));"
                            "CREATE INDEX IF NOT EXISTS album_title ON album(title);"
                            "CREATE INDEX IF NOT EXISTS album_artist ON album(album_artist);"
                            "CREATE TABLE IF NOT EXISTS song (persistent_id TEXT PRIMARY KEY, title TEXT, artist TEXT, composer TEXT, rating INTEGER, album TEXT, genre TEXT, file_size UNSIGNED INTEGER, total_time UNSIGNED INTEGER, track_number UNSIGNED INTEGER, play_count UNSIGNED INTEGER, last_played_date DATE, location TEXT, release_date DATE, year UNSIGNED INTEGER, FOREIGN KEY(artist) REFERENCES artist(name), FOREIGN KEY(album) REFERENCES album(title));"
                            "CREATE INDEX IF NOT EXISTS song_title ON song(title);"
                            "CREATE INDEX IF NOT EXISTS song_artist ON song(artist);"
                            "CREATE INDEX IF NOT EXISTS song_album ON song(album);"
                            "CREATE TABLE IF NOT EXISTS playlist (persistent_id TEXT PRIMARY KEY, name TEXT, visible BOOLEAN);"
                            "CREATE INDEX IF NOT EXISTS playlist_name ON playlist(name);"
                            "CREATE TABLE IF NOT EXISTS playlist_items (playlist_id TEXT, item_id TEXT, FOREIGN KEY(playlist_id) REFERENCES playlist(persistent_id), FOREIGN KEY(item_id) REFERENCES song(persistent_id));";
        
        return [db executeStatements:schema];
    }];
}

- (void)clearIndex
{
    [self executeUpdateInTransaction:^BOOL(FMDatabase *db)
    {
        NSLog(@"Clearing index database...");
        NSString* sql = @"DELETE FROM artist; DELETE FROM album; DELETE FROM song; DELETE FROM playlist; DELETE FROM playlist_items";
        NSLog(@"Done!");
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

NSString* persistentIDString(NSNumber* persistentID)
{
    return [NSString stringWithFormat:@"%lX", persistentID.unsignedLongValue];
}

- (void)indexLibrary:(ITLibrary *)library
{
    [self executeUpdateInTransaction:^BOOL(FMDatabase *db) {
        [db setDateFormat:self.dateFormatter];
        
        NSLog(@"Generating index...");
        
       // Clear out playlist items in case any tracks were removed
        if (![db executeStatements:@"DELETE FROM playlist_items"])
        {
            NSLog(@"Error emptying playlist items: %@", [db lastErrorMessage]);
            return NO;
        }
        
        NSMutableSet<NSString*>* insertedArtists = [NSMutableSet set];
        NSMutableSet<NSString*>* insertedAlbums = [NSMutableSet set];
        
        NSLog(@"Processing %lu items", library.allMediaItems.count);
        
        for (ITLibMediaItem* item in library.allMediaItems)
        {
            if (item.mediaKind != ITLibMediaItemMediaKindSong) continue;
            
            NSString* artistName = item.artist.name ?: @"Unknown Artist";
            
            if (artistName != nil && ![insertedArtists containsObject:artistName])
            {
                if (![db executeUpdate:@"INSERT OR REPLACE INTO artist (name) VALUES (?)", artistName])
                {
                    NSLog(@"Error indexing artist <%@>: %@", artistName, [db lastErrorMessage]);
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
                    NSLog(@"Error indexing album <%@>: %@", albumTitle, [db lastErrorMessage]);
                    return NO;
                }
                
                [insertedAlbums addObject:albumTitle];
            }
            
            NSString* title = item.title ?: @"Unknown";
            NSString* persistentID = persistentIDString(item.persistentID);
            id lastPlayedDate = item.lastPlayedDate ?: [NSNull null];
            id releaseDate = item.releaseDate ?: [NSNull null];
            
            BOOL result = [db executeUpdate:@"INSERT OR REPLACE INTO song (persistent_id, title, artist, composer, rating, album, genre, file_size, total_time, track_number, play_count, last_played_date, location, release_date, year) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", persistentID, title, artistName, item.composer, @(item.rating), albumTitle, item.genre, @(item.fileSize), @(item.totalTime), @(item.trackNumber), @(item.playCount), lastPlayedDate, item.location.absoluteString, releaseDate, @(item.year)];
            if (!result)
            {
                NSLog(@"Error indexing song <%@>: %@", title, [db lastErrorMessage]);
                return NO;
            }
        }
        
        NSLog(@"Processing %lu playlists", library.allPlaylists.count);
        
        for (ITLibPlaylist* playlist in library.allPlaylists)
        {
            if (!isMusicPlaylist(playlist)) continue;
            
            NSString* persistentID = persistentIDString(playlist.persistentID);
            BOOL result = [db executeUpdate:@"INSERT OR REPLACE INTO playlist (persistent_id, name, visible) VALUES (?, ?, ?)", persistentID, playlist.name, @(playlist.visible)];
            if (!result)
            {
                NSLog(@"Error indexing playlist <%@>: %@", playlist.name, [db lastErrorMessage]);
                return NO;
            }
            
            for (ITLibMediaItem* item in playlist.items)
            {
                if (item.mediaKind != ITLibMediaItemMediaKindSong) continue;
                
                BOOL result = [db executeUpdate:@"INSERT INTO playlist_items (playlist_id, item_id) VALUES (?, ?)", persistentID, persistentIDString(item.persistentID)];
                if (!result)
                {
                    NSLog(@"Error adding item <%@> to playlist <%@>: %@", item.title, playlist.name, [db lastErrorMessage]);
                    return NO;
                }
            }
        }
        
        NSLog(@"Done!");
        
        return YES;
    }];
}

@end