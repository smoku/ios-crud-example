//
//  Post.h
//  crud
//
//  Created by Pawel Smoczyk on 01.03.2013.
//  Copyright (c) 2013 GeoRun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Post : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSNumber * userGuid;
@property (nonatomic, retain) NSNumber * guid;
@property (nonatomic, retain) User *user;

@end
