//
//  AppDelegate.m
//  crud
//
//  Created by Pawel Smoczyk on 01.03.2013.
//  Copyright (c) 2013 GeoRun. All rights reserved.
//

#import "AppDelegate.h"
#import "PostsViewController.h"
#import "User.h"
#import "Post.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configureRestKit];
    [self configureMapping];
    
    PostsViewController *postsViewController = [[PostsViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *postsNavigationViewController = [[UINavigationController alloc] initWithRootViewController:postsViewController];
    
    UIViewController *secondViewController = [[UIViewController alloc] init];
    [secondViewController setTitle:@"Users"];
    [secondViewController.view setBackgroundColor:[UIColor whiteColor]];
    
    self.tabBarController = [[UITabBarController alloc] init];
    [self.tabBarController setViewControllers:@[postsNavigationViewController, secondViewController]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:self.tabBarController];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
}

#pragma mark - Helpers

- (void)configureRestKit {
    NSURL *baseURL = [NSURL URLWithString:@"http://localhost:3000/"];
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseURL];
    [[objectManager HTTPClient] setDefaultHeader:@"Accept" value:@"application/json"];
    
    // Initialize managed object store
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    objectManager.managedObjectStore = managedObjectStore;
    
    [managedObjectStore createPersistentStoreCoordinator];
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"crud.sqlite"];
    NSError *error;
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    
    // Create the managed object contexts
    [managedObjectStore createManagedObjectContexts];
    
    // Configure a managed object cache to ensure we do not create duplicate objects
    [managedObjectStore setManagedObjectCache:[[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext]];
}

- (void)configureMapping {
    // Configure mappings
    RKEntityMapping *userMapping = [RKEntityMapping mappingForEntityForName:@"User" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [userMapping setIdentificationAttributes:@[@"guid"]];
    [userMapping addAttributeMappingsFromDictionary:@{
        @"id": @"guid",
        @"first_name": @"firstName",
        @"last_name": @"lastName"
    }];
    
    RKEntityMapping *postMapping = [RKEntityMapping mappingForEntityForName:@"Post" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [postMapping setIdentificationAttributes:@[@"guid"]];
    [postMapping addAttributeMappingsFromDictionary:@{
        @"id": @"guid",
        @"title": @"title",
        @"body": @"body",
        @"user_id": @"userGuid",
    }];
    [postMapping addConnectionForRelationship:@"user" connectedBy:@{@"userGuid": @"guid"}];

    RKDynamicMapping *referenceMapping = [[RKDynamicMapping alloc] init];
    [referenceMapping addMatcher:[RKObjectMappingMatcher matcherWithKeyPath:@"type" expectedValue:@"User" objectMapping:userMapping]];
    
    
    // Hook mappings to response key paths
    RKResponseDescriptor *postsDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:postMapping
                                                                                   pathPattern:nil
                                                                                       keyPath:@"posts"
                                                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *referencesDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:referenceMapping
                                                                                   pathPattern:nil
                                                                                       keyPath:@"references"
                                                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [[RKObjectManager sharedManager] addResponseDescriptorsFromArray:@[postsDescriptor, referencesDescriptor]];
}

@end
