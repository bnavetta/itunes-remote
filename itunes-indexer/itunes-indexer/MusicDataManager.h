//
//  MusicDataManager.h
//  itunes-indexer
//
//  Created by Ben Navetta on 8/25/15.
//  Copyright © 2015 Ben Navetta. All rights reserved.
//

@import iTunesLibrary;

#import "DataManager.h"

@interface MusicDataManager : DataManager

- (void)createSchema;

- (void)clearIndex;

- (void)indexLibrary:(ITLibrary*)library;

@end
