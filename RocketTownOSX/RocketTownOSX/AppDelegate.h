//
//  AppDelegate.h
//  RocketTownOSX
//
//  Created by Mike Hagedorn on 3/1/16.
//  Copyright © 2016 Mike Hagedorn. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MasterViewController.h"
#import <CouchBaseLite/CouchBaseLite.h>
#import "CBLSyncManager.h"

#define kSyncUrl  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ASDRocketCouchbaseURL"]

#define kDBName @"rocket_data"
#define kCBLPrefKeyUserID @"kCBLPrefKeyUserID"


//http://www.slideshare.net/Couchbase/webinar-developing-with-couchbase-lite-on-i-os

@interface AppDelegate : NSObject <NSApplicationDelegate>

    @property (assign) IBOutlet NSWindow *window;
    @property (strong, nonatomic) CBLDatabase *database;
    @property (strong, nonatomic) CBLSyncManager *cblSync;

- (void)loginAndSync: (void (^)())complete;

@end

