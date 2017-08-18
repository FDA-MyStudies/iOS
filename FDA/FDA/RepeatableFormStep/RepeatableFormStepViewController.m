//
//  RepeatableFormStepViewController.m
//  ORKCatalog
//
//  Created by Vinay on 02/03/17.
//  Copyright © 2017 researchkit.org. All rights reserved.
//

#import "RepeatableFormStepViewController.h"
#import "RepeatableFormStep.h"

@interface ORKFormStepViewController (Internal)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;



- (void) stepDidChange;

@end


@interface RepeatableFormStepViewController ()

@property (nonatomic, strong) NSArray *originalFormItems;

@property(nonatomic, weak) UITableView *originalTableView;

@property (nonatomic, assign) NSInteger repeatableTextSection;

@property (nonatomic, assign) NSInteger lastSectionRowCount;

@end

@implementation RepeatableFormStepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSInteger originalItemCount = [[self formStep] initialItemCount];
    NSMutableArray *items = [[[self formStep] formItems] mutableCopy];
    [items removeLastObject];
    if (items.count > originalItemCount) {
        [items removeObjectsInRange:NSMakeRange(originalItemCount, items.count - originalItemCount)];
    }
    _originalFormItems = items;
    
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (RepeatableFormStep *)formStep {
    NSAssert(!self.step || [self.step isKindOfClass:[RepeatableFormStep class]], nil);
    return (RepeatableFormStep *)self.step;
}


- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
    if (![self formStep].repeatable) {
        return;
    }
    
    _originalTableView = tableView;
    
    NSInteger sections = [super numberOfSectionsInTableView:tableView];
    
    NSLog(@"sections-> %d", sections);

    if (sections - 1 == section) {
        if ([view.subviews.lastObject isKindOfClass:[UIButton class]]) {
            return;
        }
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        //button.frame = view.bounds;
        
        
        [button setTitle:[self formStep].repeatableText forState:UIControlStateNormal];
        
        
        
        
        UIFont *font1 = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0f];
       
        NSDictionary *dict1 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle),
                                NSFontAttributeName:font1,
                                NSForegroundColorAttributeName:[UIColor colorWithRed: 0.0f / 255.0f green: 124.0f / 255.0f blue: 186.0f / 255.0f alpha:1]}; // Added line
        
        
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] init];
        [attString appendAttributedString:[[NSAttributedString alloc] initWithString:[self formStep].repeatableText    attributes:dict1]];
       
        
        CGSize buttonSize = [[self formStep].repeatableText sizeWithAttributes:dict1];
        
        
        CGFloat x = (view.bounds.size.width - (buttonSize.width + 10)) / 2   ;
        
        button.frame =  CGRectMake((x > 0 ? x : 0), view.bounds.origin.y, buttonSize.width + 10.0f, buttonSize.height);
        
        [button setAttributedTitle:attString forState:UIControlStateNormal];
       
        [button addTarget:self action:@selector(addMoreAction:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        
        _repeatableTextSection = section;
        
        _lastSectionRowCount = [_originalTableView numberOfRowsInSection:section - 1];
        
    }
}

- (void)tableView:(UITableView* )tableView willDisplayCell:(UITableViewCell* )cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    _originalTableView = tableView;
}




- (void) addMoreAction:(id)sender {
    
    
    NSMutableArray *mItems = [[[self formStep] formItems] mutableCopy];
    [mItems removeLastObject];
    
   // NSInteger count = mItems.count - 1;
    
    NSInteger count = mItems.count ;
    NSInteger suffix = count / _originalFormItems.count ;
    
    for (ORKFormItem *item in _originalFormItems) {
        NSString *identifier = [item.identifier stringByAppendingFormat:@"_%ld", (long)suffix];
        ORKFormItem *mItem;
        if (item.answerFormat != nil) {
            mItem = [[ORKFormItem alloc] initWithIdentifier:identifier text:item.text answerFormat:[item.answerFormat copy] optional:item.optional];
            mItem.placeholder = item.placeholder;
        }
        else {
            mItem = [[ORKFormItem alloc] initWithSectionTitle:item.text];
        }
        [mItems addObject:mItem];

    }

    [[self formStep] setFormItems:mItems];
    [super stepDidChange];
    
   
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSLog(@"tcs-> %@ %@", NSStringFromCGSize(self.originalTableView.contentSize), NSStringFromCGSize(self.originalTableView.frame.size));

        if (self.originalTableView.contentSize.height > self.originalTableView.frame.size.height)
        {
//            CGPoint offset = CGPointMake(0, self.originalTableView.contentSize.height - self.originalTableView.frame.size.height);
//            
//            NSInteger sections = [self.originalTableView numberOfSections];
//            
//            NSInteger lastSection = _repeatableTextSection - 1;

            
            NSInteger previousLastSectionRowCount = [_originalTableView numberOfRowsInSection:_repeatableTextSection - 1];
            
            NSIndexPath *scrollToIndexPath;
            
            if (_lastSectionRowCount < previousLastSectionRowCount) {
                scrollToIndexPath = [NSIndexPath indexPathForRow:previousLastSectionRowCount - 1 inSection:_repeatableTextSection - 1];
            }
            else {
                scrollToIndexPath = [NSIndexPath indexPathForRow:0 inSection:_repeatableTextSection];
            }
            
            [self.originalTableView scrollToRowAtIndexPath:scrollToIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
//            UITableViewCell *cell = [_originalTableView cellForRowAtIndexPath:scrollToIndexPath];
//            [cell becomeFirstResponder];
            
            
            
            
            
            /*
            NSInteger noOfSections  =  mItems.count - _originalFormItems.count + 1 ;
            
            if (self.originalFormItems.count > 2){
            
            noOfSections = noOfSections - ((NSInteger*)(noOfSections /_originalFormItems.count) > 0 ? (noOfSections /_originalFormItems.count) : 0);
            }
            NSIndexPath *secondLastIndexPath = [NSIndexPath indexPathForRow:0 inSection:noOfSections];
            
            
            [self.originalTableView scrollToRowAtIndexPath:secondLastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            */
            //[self.originalTableView setContentOffset:offset animated:YES];
        }
        
    });

    
    
    
    //NSIndexPath *ip = [NSIndexPath indexPathForRow:mItems.count - 1 inSection:0];
   // [_originalTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
