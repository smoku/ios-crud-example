//
//  PostsViewController.h
//  crud
//
//  Created by Pawel Smoczyk on 01.03.2013.
//  Copyright (c) 2013 GeoRun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ODRefreshControl.h"

@interface PostsViewController : UITableViewController<NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *_fetchResultsController;
    ODRefreshControl *_refreshControl;
}

@end
