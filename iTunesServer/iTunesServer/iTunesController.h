//
//  iTunesController.h
//  iTunesServer
//
//  Created by Ben Navetta on 8/20/15.
//  Copyright © 2015 Ben Navetta. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(NSUInteger, PlayerState) {
    PlayerStateStopped,
    PlayerStatePlaying,
    PlayerStatePaused,
    PlayerStateFastForwarding,
    PlayerStateRewinding
};

typedef NS_ENUM(NSUInteger, ShuffleMode) {
    ShuffleModeSongs,
    ShuffleModeAlbums,
    ShuffleModeGroupings
};

typedef NS_ENUM(NSUInteger, RepeatMode) {
    RepeatModeOff,
    RepeatModeAll,
    RepeatModeOne
};

@interface iTunesController : NSObject

/**
 * @name Initialization
 */
#pragma mark - Initialization

- (instancetype)init;

/**
 * @name Application State
 */
#pragma mark - Application State

/**
 * Whether or not iTunes is the frontmost application.
 */
@property (readonly) BOOL frontmost;

/**
 * Whether or not iTunes is open.
 */
@property (readonly) BOOL running;

/**
 * Run iTunes
 */
- (void)run;

/**
 * @name Track Selection
 */
#pragma mark - Track Selection

/**
 * The persistent ID of the currently targeted track.
 */
@property (readonly) NSString* currentTrack;

/**
 * The persistent ID of the currently targeted playlist.
 */
@property (readonly) NSString* currentPlaylist;

/**
 * Return to the beginning of the current track or move to the previous track if already
 * at the beginning of the current track.
 *
 * @see previousTrack:
 * @see nextTrack:
 */
- (void)backTrack;

/**
 * Return to the previous track in the current playlist.
 *
 * @see backTrack:
 * @see nextTrack:
 */
- (void)previousTrack;

/**
 * Move to the next track in the current playlist.
 *
 * @see backTrack:
 * @see previousTrack:
 */
- (void)nextTrack;

/**
 * @name Shuffle and Repeat
 */
#pragma mark - Shuffle and Repeat

/**
 * Enable or disable shuffling.
 *
* @see setShuffleMode:
 */
- (void)setShuffle:(BOOL)shuffle;

/**
 * Set the mode by which items will be shuffled.
 *
 * @see setShuffle:
 */
- (void)setShuffleMode:(ShuffleMode)mode;

/**
 * Set a mode for repeating items.
 */
- (void)setRepeatMode:(RepeatMode)mode;

/**
 * @name Playback
 */
#pragma mark - Playback

/**
 * The sound output volume from 0 to 100.
 */
@property NSInteger volume;

/**
 * The position in seconds of the music player. Setting this property will
 * seek within the current track.
 */
@property double playerPosition;

/**
 * The current state of the player.
 */
@property (readonly) PlayerState playerState;

/**
 * Play an item in iTunes.
 *
 * @param persistentID The iTunes persistent ID of the item to play.
 * @see play:once:
 */
- (void)play:(NSUInteger)persistentID;

/**
 * Play an item in iTunes one or more times.
 *
 * @param persistentID The iTunes persistent ID of the item to play.
 * @param once Whether or not to play the track only once.
 * @see play:
 */
- (void)play:(NSUInteger)persistentID once:(BOOL)once;

/**
 * Pause playback.
 *
 * @see resume:
 * @see playPause:
 */
- (void)pause;

/**
 * Resume playback.
 *
 * @see pause:
 * @see playPause:
 */
- (void)resume;

/**
 * Stop playback.
 */
- (void)stop;

/**
 * Toggle between playing and pausing.
 *
 * @see pause:
 * @see resume:
 */
- (void)playPause;

@end
