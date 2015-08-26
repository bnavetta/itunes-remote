//
//  main.m
//  itunes-indexer
//
//  Created by Ben Navetta on 8/25/15.
//  Copyright © 2015 Ben Navetta. All rights reserved.
//

@import Foundation;
@import iTunesLibrary;

#import "MusicDataManager.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSError* error = nil;
        ITLibrary* library = [ITLibrary libraryWithAPIVersion:@"1.0" error:&error];
        if (library == nil)
        {
            NSLog(@"Error opening iTunes library: %@", error);
            return 1;
        }
        
        NSString* dbPath = [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:@"itunes.sqlite3"];
        NSLog(@"Generating index in %@", dbPath);
        
        MusicDataManager* dataManager = [[MusicDataManager alloc] initWithPath:dbPath];
        [dataManager createSchema];
        [dataManager indexLibrary:library];
    }
    return 0;
}
