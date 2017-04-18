//
//  RepeatableFormStep.h
//  ORKCatalog
//
//  Created by Vinay on 13/04/17.
//  Copyright © 2017 researchkit.org. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@interface RepeatableFormStep : ORKFormStep

@property (nonatomic, assign) BOOL repeatable;
@property (nonatomic, copy, nullable) NSString *repeatableText;

@end
