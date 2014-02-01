//
//  SearchViewController.m
//  pixster
//
//  Created by Timothy Lee on 7/30/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "SearchViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"

@interface SearchViewController ()

@property (nonatomic, strong) NSMutableArray *imageResults;
@property (weak, nonatomic) IBOutlet UICollectionView *imageCollectionView;


@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Pixster";
        self.imageResults = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *version = [[UIDevice currentDevice] systemVersion];
    NSComparisonResult verComparison = [version compare:@"7.0"];
    if ((verComparison == NSOrderedSame) || (verComparison == NSOrderedDescending)) {
        // running 7.0 or higher.
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self.imageCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ImageCell"];
    self.imageCollectionView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.imageResults count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"generating cell");
    static NSString *CellIdentifier = @"ImageCell";

    // Dequeue or create a cell of the appropriate type.
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    UIImageView *imageView = nil;
    const int IMAGE_TAG = 100;
    if (cell == nil) {
        NSLog(@"cell is nil");
        cell = [[UICollectionViewCell alloc] initWithFrame:CGRectMake(0,0,150,150)];
        cell.backgroundColor = [UIColor whiteColor];
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 148, 148)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.tag = IMAGE_TAG;
        [cell.contentView addSubview:imageView];
    } else {
        NSLog(@"cell is not nil");
        imageView = (UIImageView *)[cell.contentView viewWithTag:IMAGE_TAG];
    }

    // Clear the previous image
    //imageView.image = nil;
    NSURL *imageURL = [NSURL URLWithString:[self.imageResults[indexPath.row] valueForKeyPath:@"url"]];
    NSLog(@"%@", imageURL);
//    imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
    [imageView setImageWithURL:imageURL];
    
    //HOW TO DEBUG WHEN IMAGE DOESN'T SHOW UP ?????
    
    
//    cell.backgroundColor = [UIColor colorWithRed:((10 * indexPath.row)/255.0) green:((20 * indexPath.row)/255.0) blue:((30 * indexPath.row)/255.0) alpha:1];

    return cell;
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(150, 150);
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(50, 20, 50, 20);
}

//
//#pragma mark - UISearchDisplay delegate
//
//- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
//    [self.imageResults removeAllObjects];
//    [self.searchDisplayController.searchResultsTableView reloadData];
//}
//
//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
//{
//    return NO;
//}

#pragma mark - UISearchBar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@", [searchBar.text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        id results = [JSON valueForKeyPath:@"responseData.results"];
        if ([results isKindOfClass:[NSArray class]]) {
            [self.imageResults removeAllObjects];
            [self.imageResults addObjectsFromArray:results];
            [self.imageCollectionView reloadData];
        }
    } failure:nil];
    
    [operation start];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    return YES;
}

@end
