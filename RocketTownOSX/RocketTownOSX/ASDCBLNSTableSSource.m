//
//  ASDCBLNSTableSSource.m
//  RocketTownOSX
//
//  Created by Mike Hagedorn on 3/9/16.
//  Copyright © 2016 Mike Hagedorn. All rights reserved.
//


//'https://github.com/couchbase/couchbase-lite-ios/blob/master/Source/API/CBLUITableSource.m'

#import <CouchbaseLite/CouchbaseLite.h>
#import "ASDCBLNSTableSSource.h"

@interface ASDCBLNSTableSSource ()
{
@private
  NSTableView* _tableView;
  CBLLiveQuery* _query;
  NSMutableArray* _rows;
  NSString* _labelProperty;
  BOOL _deletionAllowed;
}
@end

@implementation ASDCBLNSTableSSource

- (instancetype) init {
  self = [super init];
  if (self) {
    _deletionAllowed = YES;
  }
  return self;
}

- (void)dealloc {
  [_query removeObserver: self forKeyPath: @"rows"];
}

#pragma mark -
#pragma mark ACCESSORS:


@synthesize tableView=_tableView;
@synthesize rows=_rows;



- (nullable CBLQueryRow *)rowAtIndex:(NSUInteger)index {
  return [_rows objectAtIndex: index];
}

- (nullable NSIndexPath *)indexPathForDocument:(CBLDocument *)document {
  NSString* documentID = document.documentID;
  NSUInteger index = 0;
  for (CBLQueryRow* row in _rows) {
    if ([row.documentID isEqualToString: documentID])
      return [NSIndexPath indexPathForRow: index inSection: 0];
    ++index;
  }
  return nil;
}

- (nullable CBLQueryRow *)rowAtIndexPath:(NSIndexPath *)path {
  if (path.section == 0)
    return [_rows objectAtIndex: path.row];
  return nil;
}

- (nullable CBLDocument *)documentAtIndexPath:(NSIndexPath *)path {
  return [self rowAtIndexPath: path].document;
}

#define TELL_DELEGATE(sel, obj) \
    ({id<NSTableViewDelegate> delegate = _tableView.delegate; \
     [delegate respondsToSelector: sel] \
        ? [delegate performSelector: sel withObject: self withObject: obj] \
        : nil;})

#pragma mark -
#pragma mark QUERY HANDLING:


- (CBLLiveQuery*) query {
  return _query;
}

- (void) setQuery:(CBLLiveQuery *)query {
  if (query != _query) {
    [_query removeObserver: self forKeyPath: @"rows"];
    _query = query;
    [_query addObserver: self forKeyPath: @"rows" options: 0 context: NULL];
    [self reloadFromQuery];
  }
}

- (void)reloadFromQuery {
  CBLQueryEnumerator* rowEnum = _query.rows;
  if (rowEnum) {
    NSArray *oldRows = _rows;
    _rows = [rowEnum.allObjects mutableCopy];
    TELL_DELEGATE(@selector(couchTableSource:willUpdateFromQuery:), _query);

    id delegate = _tableView.delegate;
    SEL selector = @selector(couchTableSource:updateFromQuery:previousRows:);
    if ([delegate respondsToSelector: selector]) {
      [delegate couchTableSource: self
                 updateFromQuery: _query
                    previousRows: oldRows];
    } else {
      [self.tableView reloadData];
    }
  }

}

- (void) observeValueForKeyPath: (NSString*)keyPath ofObject: (id)object
                         change: (NSDictionary*)change context: (void*)context
{
  if (object == _query)
    [self reloadFromQuery];
}


- (BOOL)deleteDocumentsAtIndexes:(CBLArrayOf(NSIndexPath*) *)indexPaths error:(NSError **)outError {
  return NO;
}

- (BOOL)deleteDocuments:(CBLArrayOf(CBLDocument*) *)documents error:(NSError **)outError {
  return NO;
}


@end
