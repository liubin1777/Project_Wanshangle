//
//  CinemaListTableViewDelegate.m
//  WanShangLe
//
//  Created by stephenliu on 13-6-8.
//  Copyright (c) 2013年 stephenliu. All rights reserved.
//

#import "CinemaListTableViewDelegate.h"
#import "CinemaViewController.h"
#import "CinemaTableViewCell.h"
#import "CinemaTableViewCellSection.h"
#import "ScheduleViewController.h"
#import "CinemaMovieViewController.h"
#import "MovieViewController.h"
#import "SearchCoreManager.h"
#import "MCinema.h"
#import <QuartzCore/QuartzCore.h>
#import"OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"
#import "OHASBasicMarkupParser.h"

static NSInteger const kAttributedLabelTag = 100;
static CGFloat const kLabelWidth = 300;
static CGFloat const kLabelVMargin = 10;

@interface CinemaListTableViewDelegate(){
    
}
@property (nonatomic,retain) NSMutableDictionary *contactDic;
@property (nonatomic,retain) NSMutableArray *searchByName;
@property (nonatomic,retain) NSMutableArray *searchByPhone;
@end

@implementation CinemaListTableViewDelegate

- (id)init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

- (void)dealloc{
    
    self.searchByName = nil;
    self.searchByPhone = nil;
    self.contactDic = nil;
    
    [super dealloc];
}

- (void)initData{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    self.contactDic = dic;
    [dic release];
    
    NSMutableArray *nameIDArray = [[NSMutableArray alloc] init];
    self.searchByName = nameIDArray;
    [nameIDArray release];
    NSMutableArray *phoneIDArray = [[NSMutableArray alloc] init];
    
    self.searchByPhone = phoneIDArray;
    [phoneIDArray release];
}

-(void)getAllSearchCinemaData{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *array = [[DataBaseManager sharedInstance] getAllCinemasListFromCoreData];
        for (int i=0; i<[array count]; i++) {
            MCinema *cienma = [array objectAtIndex:i];
            [[SearchCoreManager share] AddContact:cienma.uid name:cienma.name phone:nil];
            [self.contactDic setObject:cienma forKey:cienma.uid];
        }
    });
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        return [_parentViewController.cinemasArray count];
    }
    
    //搜索模式
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        
        if (self.isOpen) {
            if (self.selectIndex.section == section) {
                return [[[_parentViewController.cinemasArray objectAtIndex:section] objectForKey:@"list"] count]+1;;
            }
        }
        return 1;
        
    } else {//搜索模式
        return [self.searchByName count] + [self.searchByPhone count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        
        if (self.isOpen&&self.selectIndex.section == indexPath.section&&indexPath.row!=0) {
            return [self cinemaCelltableView:tableView cellForRowAtIndexPath:indexPath];
        }else
        {
            return [self cinemaSectiontableView:tableView cellForRowAtIndexPath:indexPath];
        }
    }
    
    return [self cinemaSearchtableView:tableView cellForRowAtIndexPath:indexPath];
}

-(UITableViewCell *)cinemaCelltableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"mCinemaCell";
    /*
     static BOOL nibsRegistered = NO;
     if (!nibsRegistered) {
     UINib *nib = [UINib nibWithNibName:@"CinemaTableViewCell" bundle:nil];
     [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
     nibsRegistered = YES;
     }*/
    
    CinemaTableViewCell *cell = (CinemaTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CinemaTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    NSArray *list = [[_parentViewController.cinemasArray objectAtIndex:self.selectIndex.section] objectForKey:@"list"];
    
    [self configureCell:cell withObject:[list objectAtIndex:indexPath.row-1]];
    
    return cell;
    
}

-(UITableViewCell *)cinemaSectiontableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"mCinemaDistrictCell";
    static BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"CinemaTableViewCellSection" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    
    CinemaTableViewCellSection *cell = (CinemaTableViewCellSection *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        [self createNewMocieCell];
    }
    
    NSString *name = [[_parentViewController.cinemasArray objectAtIndex:indexPath.section] objectForKey:@"name"];
    NSArray *list = [[_parentViewController.cinemasArray objectAtIndex:self.selectIndex.section] objectForKey:@"list"];
    cell.cinema_district.text = [NSString stringWithFormat:@"%@  (共%d家)",name,[list count]];
    [cell changeArrowWithUp:([self.selectIndex isEqual:indexPath]?YES:NO)];
    return cell;
    
}

-(UITableViewCell *)cinemaSearchtableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *indentifier = @"CinemaCellSearch";
    CinemaTableViewCell *cell = (CinemaTableViewCell*)[tableView dequeueReusableCellWithIdentifier:indentifier];
    OHAttributedLabel* attrLabel = nil;
    
    if (cell == nil) {
        cell = [[[CinemaTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:indentifier] autorelease];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        attrLabel = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(10,kLabelVMargin,kLabelWidth,25)];
        attrLabel.centerVertically = YES;
        attrLabel.backgroundColor = [UIColor clearColor];
        attrLabel.tag = kAttributedLabelTag;
        [cell addSubview:attrLabel];
        [attrLabel release];
	}
    
    NSNumber *localID = nil;
    NSMutableString *matchString = [NSMutableString string];
    NSMutableArray *matchPos = [NSMutableArray array];
    NSRange cHRange = NSMakeRange(-1, -1);
    if (indexPath.row < [_searchByName count]) {
        localID = [self.searchByName objectAtIndex:indexPath.row];
        
        if ([_parentViewController.searchBar.text length]) {
            [[SearchCoreManager share] GetPinYin:localID pinYin:matchString matchPos:matchPos matchCNPos:&cHRange];
        }
    } else {
        localID = [self.searchByPhone objectAtIndex:indexPath.row-[_searchByName count]];
        NSMutableArray *matchPhones = [NSMutableArray array];
        
        if ([_parentViewController.searchBar.text length]) {
            [[SearchCoreManager share] GetPhoneNum:localID phone:matchPhones matchPos:matchPos];
            [matchString appendString:[matchPhones objectAtIndex:0]];
        }
    }
    ABLoggerInfo(@"返回cell");
    MCinema *contact = [self.contactDic objectForKey:localID];
    
    attrLabel = (OHAttributedLabel*)[cell viewWithTag:kAttributedLabelTag];
    [attrLabel setText:contact.name];
    
    if (!(cHRange.location == -1) && !(cHRange.length == -1)) {
        if ([contact.name length]<cHRange.length) {
            cHRange.length = [contact.name length];
        }
        
        NSMutableAttributedString* attrStr = [attrLabel.attributedText mutableCopy];
        [attrStr setTextColor:[UIColor colorWithRed:0.082 green:0.587 blue:0.827 alpha:1.000] range:cHRange];
        //[attrStr setFontFamily:@"helvetica" size:25 bold:YES italic:YES range:cHRange];
        [attrStr setTextBold:YES range:cHRange];
        attrLabel.attributedText = attrStr;
        [attrStr release];
    }
    
    return cell;
}

- (void)configureCell:(CinemaTableViewCell *)cell withObject:(MCinema *)cinema {
    
    cell.cinema_name.text = cinema.name;
    cell.cinema_address.text = cinema.address;
    cell.cinema_count.text = [NSString stringWithFormat:@"34场"];
    cell.cinema_price.text = [NSString stringWithFormat:@"25-75元"];
    cell.cinema_tuan.hidden = NO;
}

-(CinemaTableViewCell *)createNewMocieCell{
    ABLoggerMethod();
    CinemaTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"CinemaTableViewCellSection" owner:self options:nil] objectAtIndex:0];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //    cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history_menu_cell_background"]] autorelease];
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        if (indexPath.row!=0) {
            return 80.0f;
        }
        return 44.0f;
    }
    
    return 44.0f;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
        if (indexPath.row == 0) {
            if ([indexPath isEqual:self.selectIndex]) {
                self.isOpen = NO;
                [self didSelectCellRowFirstDo:NO nextDo:NO];
                self.selectIndex = nil;
                
            }else
            {
                if (!self.selectIndex) {
                    self.selectIndex = indexPath;
                    [self didSelectCellRowFirstDo:YES nextDo:NO];
                    
                }else
                {
                    
                    [self didSelectCellRowFirstDo:NO nextDo:YES];
                }
            }
            
        }else
        {
            NSDictionary *dic = [_parentViewController.cinemasArray objectAtIndex:indexPath.section];
            NSArray *list = [dic objectForKey:@"list"];
            MCinema *mCinema = [list objectAtIndex:indexPath.row-1];
            
            if (!_parentViewController.movieDetailButton.hidden) {
                ScheduleViewController *scheduleViewController = [[ScheduleViewController alloc]
                                                                  initWithNibName:(iPhone5?@"ScheduleViewController_5":@"ScheduleViewController")
                                                                  bundle:nil];
                scheduleViewController.mCinema = mCinema;
                scheduleViewController.mMovie = _parentViewController.mMovie;
                [_parentViewController.mparentController.navigationController pushViewController:scheduleViewController animated:YES];
                [scheduleViewController release];
            }else{
                CinemaMovieViewController *cinemaMovieController = [[CinemaMovieViewController alloc]
                                                                    initWithNibName:(iPhone5?@"CinemaMovieViewController_5":@"CinemaMovieViewController")
                                                                    bundle:nil];
                cinemaMovieController.mCinema = mCinema;
                cinemaMovieController.mMovie = _parentViewController.mMovie;
                [_parentViewController.mparentController.navigationController pushViewController:cinemaMovieController animated:YES];
                [cinemaMovieController release];
            }
            
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else {//搜索模式
        
    }
}

- (void)didSelectCellRowFirstDo:(BOOL)firstDoInsert nextDo:(BOOL)nextDoInsert
{
    self.isOpen = firstDoInsert;
    
    CinemaTableViewCellSection *cell = (CinemaTableViewCellSection *)[_parentViewController.cinemaTableView cellForRowAtIndexPath:self.selectIndex];
    [cell changeArrowWithUp:firstDoInsert];
    
    [_parentViewController.cinemaTableView beginUpdates];
    
    int section = self.selectIndex.section;
    int contentCount = [[[_parentViewController.cinemasArray objectAtIndex:section] objectForKey:@"list"] count];
	NSMutableArray* rowToInsert = [[NSMutableArray alloc] init];
	for (NSUInteger i = 1; i < contentCount + 1; i++) {
		NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:i inSection:section];
		[rowToInsert addObject:indexPathToInsert];
	}
	
	if (firstDoInsert)
    {   [_parentViewController.cinemaTableView insertRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
	else
    {
        [_parentViewController.cinemaTableView deleteRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
    
	[rowToInsert release];
	
	[_parentViewController.cinemaTableView endUpdates];
    if (nextDoInsert) {
        self.isOpen = YES;
        self.selectIndex = [_parentViewController.cinemaTableView indexPathForSelectedRow];
        [self didSelectCellRowFirstDo:YES nextDo:NO];
    }
    if (self.isOpen) [_parentViewController.cinemaTableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark -
#pragma mark UIScrollViewDelegate
- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [_parentViewController.cinemaTableView setContentOffset:CGPointMake(0, 44) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([_parentViewController.searchBar.text length] <= 0) {//正常模式
    if (scrollView.contentOffset.y < 44) {
        _parentViewController.cinemaTableView.scrollIndicatorInsets = UIEdgeInsetsMake(CGRectGetHeight(_parentViewController.searchBar.bounds) - MAX(scrollView.contentOffset.y, 0), 0, 0, 0);
    } else {
        _parentViewController.cinemaTableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }
    
    CGRect searchBarFrame = _parentViewController.searchBar.frame;
    searchBarFrame.origin.y = MIN(scrollView.contentOffset.y, 0);

    _parentViewController.searchBar.frame = searchBarFrame;
    }
}


#pragma mark -
#pragma mark UISearchBarDelegate methods
/*
- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
{
    [[SearchCoreManager share] Search:searchText searchArray:nil nameMatch:_searchByName phoneMatch:self.searchByPhone];

    ABLoggerInfo(@"_searchByName count ==== %d",[_searchByName count]);
    ABLoggerInfo(@"searchByPhone count ==== %d",[_searchByPhone count]);
    [_parentViewController.cinemaTableView reloadData];
}*/

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    [_parentViewController endSearch];
    [_parentViewController.cinemaTableView resignFirstResponder];
    [self scrollTableViewToSearchBarAnimated:YES];

    _parentViewController.searchBar.text = nil;
    
    [self.searchByName removeAllObjects];
    [self.searchByPhone removeAllObjects];
    [self.contactDic removeAllObjects];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_parentViewController.cinemaTableView resignFirstResponder];
    [self scrollTableViewToSearchBarAnimated:YES];
}


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    [_parentViewController beginSearch];
    [self getAllSearchCinemaData];
    
    _parentViewController.searchBar.showsScopeBar = YES;
    [_parentViewController.searchBar sizeToFit];
    [_parentViewController.searchBar setShowsCancelButton:YES animated:YES];
    
    for(id cc in [_parentViewController.searchBar subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            [btn setTitle:@"取消"  forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"searchBarBackground"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"searchBarBackground2"] forState:UIControlStateSelected];
            [btn setBackgroundImage:[UIImage imageNamed:@"searchBarBackground2"] forState:UIControlStateHighlighted];
        }
    }
    
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    [self.searchByName removeAllObjects];
    [self.searchByPhone removeAllObjects];
    
    [self scrollTableViewToSearchBarAnimated:YES];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
    [[SearchCoreManager share] Search:searchString searchArray:nil nameMatch:_searchByName phoneMatch:_searchByPhone];
    
    ABLoggerDebug(@"search Name = %d",[_searchByName count]);

    [_parentViewController.cinemaTableView reloadData];
    
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView{
    ABLoggerDebug(@"subViews = %d",[controller.searchResultsTableView.subviews count]);
    for(UIView *subview in controller.searchResultsTableView.subviews) {
        
        if([subview isKindOfClass:[UILabel class]]) {
            [(UILabel*)subview setText:@"无结果"];
        }
    }
}

@end
