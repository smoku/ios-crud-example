//
//  PostsViewController.m
//  crud
//
//  Created by Pawel Smoczyk on 01.03.2013.
//  Copyright (c) 2013 GeoRun. All rights reserved.
//

#import "PostsViewController.h"
#import "Post.h"
#import "User.h"

@implementation PostsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Posts"];
    
    [self.navigationItem setLeftBarButtonItem:[self editButtonItem]];
    
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [_refreshControl addTarget:self action:@selector(reloadRemoteData) forControlEvents:UIControlEventValueChanged];

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"guid" ascending:NO]]];
     
    _fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                   managedObjectContext:[[RKManagedObjectStore defaultStore] mainQueueManagedObjectContext]
                                                                     sectionNameKeyPath:nil
                                                                              cacheName:nil];
     
    [_fetchResultsController setDelegate:self];
    [_fetchResultsController performFetch:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadRemoteData];
}

#pragma mark - Actions

- (void)reloadRemoteData
{
    [_refreshControl beginRefreshing];
    
    // Use JSON stored in dropbox instead of API
    [[RKObjectManager sharedManager] getObjectsAtPath:@"u/3183488/posts.json" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [_refreshControl endRefreshing];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [_refreshControl endRefreshing];
    }];
    
    //[[RKObjectManager sharedManager] getObjectsAtPath:@"api/posts" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    //    [_refreshControl endRefreshing];
    //} failure:^(RKObjectRequestOperation *operation, NSError *error) {
    //    [_refreshControl endRefreshing];
    //}];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_fetchResultsController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    Post *post = [_fetchResultsController objectAtIndexPath:indexPath];
    [cell.textLabel setText:post.title];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@ (%@ %@)", post.body, post.user.firstName, post.user.lastName]];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        Post *post = [_fetchResultsController objectAtIndexPath:indexPath];
//        NSString *resourcePath = [NSString stringWithFormat:@"api/posts/%@", post.guid];
//        [[RKObjectManager sharedManager] deleteObject:post path:resourcePath parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//            
//            
//        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//            
//        }];
    }
}

#pragma mark - NSFetchResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

@end
