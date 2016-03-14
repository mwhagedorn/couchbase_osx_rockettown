//
//  ASDCBLNSTableSSource.h
//  RocketTownOSX
//
//  Created by Mike Hagedorn on 3/9/16.
//  Copyright © 2016 Mike Hagedorn. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AppKit;
@class CBLLiveQuery;

/** A NSTableView data source driven by a CBLLiveQuery.
 It populates the table rows from the query rows, and automatically updates the table as the
 query results change when the database is updated.
 A CBLUITableSource can be created in a nib. If so, its tableView outlet should be wired up to
 the UITableView it manages, and the table view's dataSource outlet should be wired to it. */

@interface ASDCBLNSTableSSource : NSObject <NSTableViewDataSource>

/** The table view to manage. */
@property (nonatomic, retain) IBOutlet NSTableView* tableView;

/** The query whose rows will be displayed in the table. */
@property (retain) CBLLiveQuery* query;

/** Rebuilds the table from the query's current .rows property. */
-(void) reloadFromQuery;


#pragma mark Row Accessors:

/** The current array of CBLQueryRows being used as the data source for the table. */
@property (nonatomic, readonly, nullable) CBLArrayOf(CBLQueryRow*)* rows;

/** Convenience accessor to get the row object for a given table row index. */
- (nullable CBLQueryRow*) rowAtIndex: (NSUInteger)index;

/** Convenience accessor to find the index path of the row with a given document. */
- (nullable NSIndexPath*) indexPathForDocument: (CBLDocument*)document;

/** Convenience accessor to return the query row at a given index path. */
- (nullable CBLQueryRow*) rowAtIndexPath: (NSIndexPath*)path;

/** Convenience accessor to return the document at a given index path. */
- (nullable CBLDocument*) documentAtIndexPath: (NSIndexPath*)path;


#pragma mark Displaying The Table:

/** If non-nil, specifies the property name of the query row's value that will be used for the table row's visible label.
If the row's value is not a dictionary, or if the property doesn't exist, the property will next be looked up in the document's properties.
If this doesn't meet your needs for labeling rows, you should implement -couchTableSource:willUseCell:forRow: in the table's delegate. */
@property (copy, nullable) NSString* labelProperty;


#pragma mark Editing The Table:

/** Is the user allowed to delete rows by UI gestures? (Defaults to YES.) */
@property (nonatomic) BOOL deletionAllowed;

/** Deletes the documents at the given row indexes, animating the removal from the table. */
- (BOOL) deleteDocumentsAtIndexes: (CBLArrayOf(NSIndexPath*)*)indexPaths
    error: (NSError**)outError;

/** Asynchronously deletes the given documents, animating the removal from the table. */
- (BOOL) deleteDocuments: (CBLArrayOf(CBLDocument*)*)documents
    error: (NSError**)outError;


@end
