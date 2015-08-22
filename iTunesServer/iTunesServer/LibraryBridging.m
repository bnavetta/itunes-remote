//
//  LibraryBridging.m
//  iTunesServer
//
//  Created by Ben Navetta on 8/20/15.
//  Copyright © 2015 Ben Navetta. All rights reserved.
//

@import Foundation;
@import iTunesLibrary;


//typedef NS_ENUM(NSUInteger, PlaylistKind) {
//    PlaylistKindRegular,
//    PlaylistKindSmart,
//    PlaylistKindGenius,
//    PlaylistKindFolder,
//    PlaylistKindGeniusMix
//};
//
//PlaylistKind fromLibraryPlaylistKind(ITLibPlaylistKind libraryKind)
//{
//    switch (libraryKind) {
//        case ITLibPlaylistKindRegular:
//            return PlaylistKindRegular;
//        case ITLibPlaylistKindSmart:
//            return PlaylistKindSmart;
//        case ITLibPlaylistKindGenius:
//            return PlaylistKindGenius;
//        case ITLibPlaylistKindFolder:
//            return PlaylistKindFolder;
//        case ITLibPlaylistKindGeniusMix:
//            return PlaylistKindGeniusMix;
//        default:
//            NSCAssert(false, @"Unknown ITLibPlaylistKind: %lu", (unsigned long)libraryKind);
//            return -1;
//    }
//}

NSString* playlistKindString(ITLibPlaylistKind playlistKind)
{
    switch (playlistKind) {
        case ITLibPlaylistKindRegular:
            return @"regular";
        case ITLibPlaylistKindSmart:
            return @"smart";
        case ITLibPlaylistKindGenius:
            return @"genius";
        case ITLibPlaylistKindFolder:
            return @"folder";
        case ITLibPlaylistKindGeniusMix:
            return @"genius mix";
        default:
            NSCAssert(false, @"Unknown ITLibPlaylistKind: %lu", (NSUInteger)playlistKind);
            return @"unknown";
    }
}