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

int main(int argc, char* const argv[]) {
    @autoreleasepool {
        NSString* dbFile = @"itunes.sqlite3";
        BOOL clearDatabase = NO;
        
        while (true)
        {
            char opt = getopt(argc, argv, "d:c");
            if (opt == -1) break;
            
            switch (opt)
            {
                case 'd':
                    dbFile = [NSString stringWithUTF8String:optarg];
                    break;
                case 'c':
                    clearDatabase = YES;
                    break;
                default:
                    NSLog(@"Unknown option: %c", opt);
                    abort();
            }
        }
        
        NSError* error = nil;
        ITLibrary* library = [ITLibrary libraryWithAPIVersion:@"1.0" error:&error];
        if (library == nil)
        {
            NSLog(@"Error opening iTunes library: %@", error);
            abort();
        }
        
        NSLog(@"Using database: %@", dbFile);
        MusicDataManager* dataManager = [[MusicDataManager alloc] initWithPath:dbFile];
        [dataManager createSchema];
        
        if (clearDatabase)
        {
            [dataManager clearIndex];
        }
        
        [dataManager indexLibrary:library];
        [dataManager close];
    }
    return 0;
}
