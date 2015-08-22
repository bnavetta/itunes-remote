//
//  iTunesController.m
//  iTunesServer
//
//  Created by Ben Navetta on 8/20/15.
//  Copyright © 2015 Ben Navetta. All rights reserved.
//

#import "iTunesController.h"
#import "itunes.h"
#import "SystemEvents.h"

@interface iTunesController ()

@property (strong, atomic) iTunesApplication* iTunes;
@property (strong, atomic) SystemEventsApplication* systemEvents;
@property (strong, atomic) NSCache* itemCache; // persistentID as NSNumber to iTunesItem

@property (readonly) iTunesSource* library;
@property (readonly) iTunesPlaylist* musicLibrary;
@property (readonly) SystemEventsProcess* iTunesProcess;

- (iTunesItem*)item:(NSUInteger)persistentID;

@end

@implementation iTunesController

#pragma mark - Initialization

- (instancetype)init
{
    if (self = [super init])
    {
        self.iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
        self.systemEvents = [SBApplication applicationWithBundleIdentifier:@"com.apple.systemevents"];
        self.itemCache = [NSCache new];
    }
    
    return self;
}

#pragma mark - Application State

- (BOOL)frontmost
{
    return self.iTunes.frontmost;
}

- (BOOL)running
{
    return self.iTunes.running;
}

- (void)run
{
    [self.iTunes run];
}

#pragma mark - Track Selection

- (NSString*)currentTrack
{
    return self.iTunes.currentTrack.persistentID;
}

- (NSString*)currentPlaylist
{
    return self.iTunes.currentPlaylist.persistentID;
}

- (void)nextTrack
{
    [self.iTunes nextTrack];
}

- (void)backTrack
{
    [self.iTunes backTrack];
}

- (void)previousTrack
{
    [self.iTunes previousTrack];
}

#pragma mark - Playback

- (void)play:(NSUInteger)persistentID
{
    [[self item:persistentID] playOnce:YES];
}

- (void)play:(NSUInteger)persistentID once:(BOOL)once
{
    [[self item:persistentID] playOnce:once];
}

- (void)pause
{
    [self.iTunes pause];
}

- (void)resume
{
    [self.iTunes resume];
}

- (void)playPause
{
    [self.iTunes playpause];
}

- (void)stop
{
    [self.iTunes stop];
}

- (double)playerPosition
{
    return self.iTunes.playerPosition;
}

- (void)setPlayerPosition:(double)playerPosition
{
    self.iTunes.playerPosition = playerPosition;
}

- (PlayerState)playerState {
    switch (self.iTunes.playerState) {
        case iTunesEPlSPaused:
            return PlayerStatePaused;
        case iTunesEPlSPlaying:
            return PlayerStatePlaying;
        case iTunesEPlSFastForwarding:
            return PlayerStateFastForwarding;
        case iTunesEPlSRewinding:
            return PlayerStateRewinding;
        case iTunesEPlSStopped:
            return PlayerStateStopped;
    }
}

- (NSInteger)volume
{
    return self.iTunes.soundVolume;
}

- (void)setVolume:(NSInteger)volume
{
    self.iTunes.soundVolume = volume;
}

#pragma mark - Shuffle and Repeat

// Adapted from http://blog.zenspider.com/blog/2014/12/updated-itunes-bedtime-script.html
// TODO: move this into a menuItemByName / menuBarItemByName category on SystemEventsMenuBar and SystemEventsMenu

- (SystemEventsMenu*)controlsMenu
{
    for (SystemEventsMenuBarItem* item in self.iTunesProcess.menuBars[0].menuBarItems)
    {
        if ([item.name isEqualToString:@"Controls"])
        {
            return item.menus[0];
        }
    }
    return nil;
}

- (SystemEventsMenu*)shuffleMenu
{
    for (SystemEventsMenuItem* item in [self controlsMenu].menuItems)
    {
        if ([item.name isEqualToString:@"Shuffle"])
        {
            return item.menus[0];
        }
    }
    return nil;
}

- (SystemEventsMenu*)repeatMenu
{
    for (SystemEventsMenuItem* item in [self controlsMenu].menuItems)
    {
        if ([item.name isEqualToString:@"Repeat"])
        {
            return item.menus[0];
        }
    }
    return nil;
}

- (void)setShuffle:(BOOL)shuffle
{
    for (SystemEventsMenuItem* item in [self shuffleMenu].menuItems)
    {
        if (shuffle && [item.name isEqualToString:@"On"])
        {
            [item clickAt:item.position];
            return;
        }
        else if (!shuffle && [item.name isEqualToString:@"Off"])
        {
            [item clickAt:item.position];
            return;
        }
    }
}

- (void)setShuffleMode:(ShuffleMode)mode
{
    NSString* itemName = nil;
    switch (mode)
    {
        case ShuffleModeAlbums:
            itemName = @"Albums";
            break;
        case ShuffleModeSongs:
            itemName = @"Songs";
            break;
        case ShuffleModeGroupings:
            itemName = @"Groupings";
            break;
    }
    
    for (SystemEventsMenuItem* item in [self shuffleMenu].menuItems)
    {
        if ([item.name isEqualToString:itemName])
        {
            [item clickAt:item.position];
        }
    }
}

- (void)setRepeatMode:(RepeatMode)mode
{
    NSString* itemName = nil;
    switch (mode)
    {
        case RepeatModeAll:
            itemName = @"All";
            break;
        case RepeatModeOff:
            itemName = @"Off";
            break;
        case RepeatModeOne:
            itemName = @"One";
            break;
    }
    
    for (SystemEventsMenuItem* item in [self repeatMenu].menuItems)
    {
        if ([item.name isEqualToString:itemName])
        {
            [item clickAt:item.position];
        }
    }
}

#pragma mark - Private Methods

- (iTunesItem *)item:(NSUInteger)persistentID
{
    @synchronized(self.itemCache) {
        iTunesItem* item = [self.itemCache objectForKey:@(persistentID)];
        if (item == nil)
        {
            for (iTunesTrack* track in self.musicLibrary.tracks)
            {
                // Use number instead of string because of issues with leading 0
                NSUInteger trackID = strtoul(track.persistentID.UTF8String, NULL, 16);
                
                if (trackID == persistentID)
                {
                    item = track;
                    break;
                }
            }
            
            if (item == nil)
            {
                for (iTunesPlaylist* playlist in self.library.playlists)
                {
                    // Use number instead of string because of issues with leading 0
                    NSUInteger playlistID = strtoul(playlist.persistentID.UTF8String, NULL, 16);
                    
                    if (playlistID == persistentID)
                    {
                        item = playlist;
                        break;
                    }
                }
            }
            
            if (item != nil)
            {
                [self.itemCache setObject:item forKey:@(persistentID)];
            }
        }
        
        return item;
    }
}

- (iTunesSource*)library
{
    for (iTunesSource* source in self.iTunes.sources)
    {
        if (source.kind == iTunesESrcLibrary)
        {
            return source;
        }
    }
    return nil;
}

- (iTunesPlaylist *)musicLibrary
{
    for (iTunesPlaylist* libraryPlaylist in self.library.libraryPlaylists)
    {
        if (libraryPlaylist.specialKind == iTunesESpKLibrary)
        {
            return libraryPlaylist;
        }
    }
    
    return nil;
}

- (SystemEventsProcess *)iTunesProcess
{
    for (SystemEventsProcess* process in self.systemEvents.processes)
    {
        if ([process.bundleIdentifier isEqualToString:@"com.apple.iTunes"])
        {
            return process;
        }
    }
    return nil;
}

@end
