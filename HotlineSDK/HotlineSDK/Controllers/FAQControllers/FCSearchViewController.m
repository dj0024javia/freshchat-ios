//
//  FDCoreDataFetchManager.m
//  FreshdeskSDK
//
//  Created by Aravinth Chandran on 29/04/14.
//  Copyright (c) 2014 Freshdesk. All rights reserved.
//

#import "FCSearchViewController.h"
#import "FCUtilities.h"
#import "FCSecureStore.h"
#import "FCMacros.h"
#import "FCRanking.h"
#import "FCTheme.h"
#import "FCDataManager.h"
#import "FCButton.h"
#import "FCTableViewCell.h"
#import "FCArticleContent.h"
#import "FCSearchBar.h"
#import "FCContainerController.h"
#import "FCListViewController.h"
#import "FreshchatSDK.h"
#import "FCLocalization.h"
#import "FCBarButtonItem.h"
#import "FCArticleListCell.h"
#import "FCEmptyResultView.h"
#import "FCAutolayoutHelper.h"
#import "FCFAQUtil.h"

#define SEARCH_CELL_REUSE_IDENTIFIER @"SearchCell"
#define SEARCH_BAR_HEIGHT 44

@interface  FCSearchViewController () <UISearchDisplayDelegate,UISearchBarDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UIView *trialView;
@property (strong, nonatomic) UITapGestureRecognizer *recognizer;
@property (strong, nonatomic) FCTheme *theme;
@property (strong, nonatomic) UIImageView *emptySearchImgView;
@property (strong, nonatomic) UILabel *emptyResultLbl;
@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic) BOOL isKeyboardOpen;
@property (nonatomic, strong) FCEmptyResultView *emptyResultView;
@property (nonatomic, strong) FAQOptions *faqOptions;
@end

@implementation FCSearchViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self setupSubviews];
    [self setupTap];
    self.view.userInteractionEnabled=YES;
    [self configureBackButton];
}

-(UIViewController<UIGestureRecognizerDelegate> *)gestureDelegate{
    return self;
}

-(void)localNotificationSubscription{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)setFAQOptions:(FAQOptions *)options{
    self.faqOptions = options;
}

// NOT Used - Need to be used when we figure out how to show Contact us on search
-(BOOL)canDisplayFooterView{
    return self.faqOptions && self.faqOptions.showContactUsOnFaqScreens;
}

-(FCTheme *)theme{
    if(!_theme) _theme = [FCTheme sharedInstance];
    return _theme;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self localNotificationSubscription];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self localNotificationUnSubscription];
}

-(void)localNotificationUnSubscription{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)setupTap{
    self.recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
    [self.recognizer setNumberOfTapsRequired:1];
    if(self.searchResults.count == 0){
        [self.view addGestureRecognizer:self.recognizer];
    }
}

- (void)handleTapBehind:(UITapGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateEnded){
        if (self.searchResults.count == 0) {
            CGPoint location = [sender locationInView:nil]; //Passing nil gives us coordinates in the window
            UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
            CGPoint pointInSubview = [self.view convertPoint:location fromView:mainWindow];
            if (!CGRectContainsPoint(self.searchBar.bounds, pointInSubview)) {
                // Remove the recognizer first so it's view.window is valid.
                [self.view removeGestureRecognizer:sender];
                [self dismissModalViewControllerAnimated:YES];
            }
        }
    }
}

-(void)setupSubviews{
    self.searchBar = [[FCSearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SEARCH_BAR_HEIGHT)];
    self.searchBar.hidden = NO;
    
    self.searchBar.delegate = self;
    self.searchBar.placeholder = HLLocalizedString(LOC_SEARCH_PLACEHOLDER_TEXT);
    self.searchBar.showsCancelButton = YES;
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.searchBar becomeFirstResponder];
    
    UITextField *txtSearchField = [self.searchBar valueForKey:@"_searchField"];
    [txtSearchField setBorderStyle:UITextBorderStyleRoundedRect];
    txtSearchField.layer.cornerRadius = 4;
    txtSearchField.layer.borderWidth = 1.0f;
    txtSearchField.layer.borderColor = [self.theme searchBarTextViewBorderColor].CGColor;
    [txtSearchField setValue:[self.theme SearchBarTextPlaceholderColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    UIView *mainSubView = [self.searchBar.subviews lastObject];
    for (id subview in mainSubView.subviews) {
        if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)subview;
            textField.backgroundColor = [self.theme searchBarInnerBackgroundColor];
        }
    }
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.5];
    self.tableView.separatorColor = [self.theme articleListCellSeperatorColor];
    self.tableView.translatesAutoresizingMaskIntoConstraints=NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [self.view addSubview:self.tableView];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-(SEARCH_BAR_HEIGHT/2), 0, SEARCH_BAR_HEIGHT, 0);
    
    [self setEmptySearchResultView];

    [self.view addSubview:self.searchBar];
    
    NSDictionary *views = @{ @"top":self.topLayoutGuide,@"searchBar" : self.searchBar,@"trial":self.tableView};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[searchBar]|"
                                                                      options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[trial]|"
                                                                      options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[top][searchBar][trial]|"
                                                                      options:0 metrics:nil views:views]];
}

- (void) setEmptySearchResultView{
    self.emptyResultView = [[FCEmptyResultView alloc]initWithImage:[self.theme getImageWithKey:IMAGE_EMPTY_SEARCH_ICON] withType:1  andText:HLLocalizedString(LOC_SEARCH_EMPTY_RESULT_TEXT)];
    self.emptyResultView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.emptyResultView];
    [FCAutolayoutHelper centerX:self.emptyResultView onView:self.view];
    [FCAutolayoutHelper centerY:self.emptyResultView onView:self.view M:0.5 C:0];
    self.emptyResultView.hidden = YES;
}

- (void) showEmptySearchView{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.emptyResultView.hidden = NO;
    });
}

- (void) hideEmptySearchView{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.emptyResultView.hidden = YES;
    });
}

#pragma mark Keyboard delegate

-(void) keyboardWillShow:(NSNotification *)note{
    NSTimeInterval animationDuration = [[note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    self.isKeyboardOpen = YES;
    CGRect keyboardFrame = [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardRect = [self.view convertRect:keyboardFrame fromView:nil];
    CGFloat keyboardCoveredHeight = self.view.bounds.size.height - keyboardRect.origin.y;
    self.keyboardHeight = keyboardCoveredHeight;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void) keyboardWillHide:(NSNotification *)note{
    self.isKeyboardOpen = NO;
    NSTimeInterval animationDuration = [[note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    self.keyboardHeight = 0.0;
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}


#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)sectionIndex{
    return self.searchResults.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = SEARCH_CELL_REUSE_IDENTIFIER;
    FCArticleListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[FCArticleListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.numberOfLines = 3;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    if (indexPath.row < self.searchResults.count) {
        FCArticleContent *article = self.searchResults[indexPath.row];
        [cell.textLabel sizeToFit];
        cell.articleText.text = article.title;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UIFont *cellFont = [self.theme articleListFont];
    FCArticles *searchArticle = self.searchResults[indexPath.row];
    CGFloat heightOfcell = 0;
    if (searchArticle) {
        heightOfcell = [FCListViewController heightOfCell:cellFont];
    }
    return heightOfcell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.searchResults.count) {
        FCArticleContent *article = self.searchResults[indexPath.row];
        [FCFAQUtil launchArticleID:article.articleID withNavigationCtlr:self andFaqOptions:self.faqOptions fromLink:false]; //TODO: - Pass this from outside - Rex
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell     forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)filterArticlesForSearchTerm:(NSString *)term{
    if (term.length > 2){
        term = [FCStringUtil replaceSpecialCharacters:term with:@""];
        NSManagedObjectContext *context = [FCDataManager sharedInstance].backgroundContext ;
        [context performBlock:^{
            NSArray *articles = [FCRanking rankTheArticleForSearchTerm:term withContext:context];
            if ([articles count] > 0) {
                [self hideEmptySearchView];
                self.searchResults = articles;
                [self reloadSearchResults];
            }else{
                
                self.searchResults = nil;
                [self showEmptySearchView];
                [self reloadSearchResults];
            }
        }];
    }else{
        [self hideEmptySearchView];
        [self fetchAllArticles];
    }
}

-(void)fetchAllArticles{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:FRESHCHAT_ARTICLES_ENTITY];
    NSManagedObjectContext *context = [FCDataManager sharedInstance].mainObjectContext;
    [context performBlock:^{
        self.searchResults = [context executeFetchRequest:request error:nil];
        [self reloadSearchResults];
    }];
}

-(void)reloadSearchResults{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

-(void)viewWillLayoutSubviews{
    self.searchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
}


-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self dismissModalViewControllerAnimated:NO];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    searchText = trimString(searchText);
    if (searchText.length!=0) {
        [self.tableView setBackgroundColor:[self.theme articleListBackgroundColor]];
        [self filterArticlesForSearchTerm:searchText];
        [self.view removeGestureRecognizer:self.recognizer];
    }else{
        [self.view addGestureRecognizer:self.recognizer];
        self.tableView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.5];
        self.searchResults = nil;
        [self hideEmptySearchView];
        [self.tableView reloadData];
    }
}

-(void)marginalView:(FCMarginalView *)marginalView handleTap:(id)sender{
    if([FCFAQUtil hasContactUsTags:self.faqOptions]){
        ConversationOptions *options = [ConversationOptions new];
        [options filterByTags:self.faqOptions.contactUsTags withTitle:self.faqOptions.contactUsTitle];
        [[Freshchat sharedInstance] showConversations:self withOptions:options];
    }
    else{
        [[Freshchat sharedInstance] showConversations:self];
    }
} 

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES]; 
}

@end