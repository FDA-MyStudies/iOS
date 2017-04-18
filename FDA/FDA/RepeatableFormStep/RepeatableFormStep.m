//
//  RepeatableFormStep.m
//  ORKCatalog
//
//  Created by Vinay on 13/04/17.
//  Copyright © 2017 researchkit.org. All rights reserved.
//

#import "RepeatableFormStep.h"
#import "RepeatableFormStepViewController.h"

@implementation RepeatableFormStep

+ (Class)stepViewControllerClass {
    return [RepeatableFormStepViewController class];
}

- (void)setFormItems:(NSArray<ORKFormItem *> *)formItems {
    if (_repeatable) {
        NSMutableArray *mItems = [formItems mutableCopy];
        ORKFormItem *item = [[ORKFormItem alloc] initWithSectionTitle:@""];
        [mItems addObject:item];
        [super setFormItems:mItems];
    }
    else {
        [super setFormItems:formItems];
    }
}
@end
