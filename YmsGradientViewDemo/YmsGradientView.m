// 
// Copyright 2012 Yummy Melon Software LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Author: Charles Y. Choi <charles.choi@yummymelon.com>
//
//  YmsGradientView.m
//


#import "YmsGradientView.h"

@implementation YmsGradientView

@synthesize resourceName;
@synthesize config;

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initConfig];
}

- (void)initConfig {
    if (self.resourceName == nil) {
        self.resourceName = NSStringFromClass([self class]);
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:self.resourceName ofType:@"plist"];
    
    if (path == nil) {
        NSLog(@"WARNING: resource %@.plist does not exist. Using default resource YmsGradientView.plist.", self.resourceName);
        self.resourceName = @"YmsGradientView";
        path = [[NSBundle mainBundle] pathForResource:self.resourceName ofType:@"plist"];
    }
    self.config = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
}

- (id)initWithFrame:(CGRect)frame withResourceName:(NSString *)name {
    self.resourceName = name;
    self = [self initWithFrame:frame];
    return self;
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initConfig];
    }
    return self;
}




- (void)drawRect:(CGRect)rect {
    //NSLog(@"Rendering gradient using %@.plist", self.resourceName);
    

    NSArray *colorArray = (NSArray *)[self.config objectForKey:@"colors"];
    NSArray *locationsArray = (NSArray *)[self.config objectForKey:@"locations"];
    NSArray *startPointArray = (NSArray *)[self.config objectForKey:@"startPoint"];
    NSArray *endPointArray = (NSArray *)[self.config objectForKey:@"endPoint"];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Render Gradient
    CGGradientRef stateGradient;
    CGColorSpaceRef rgbColorspace;
    
    CGFloat *locations = malloc(sizeof(CGFloat) * locationsArray.count);
    
    for (int i = 0; i < locationsArray.count; i++) {
        NSNumber *e = (NSNumber *)[locationsArray objectAtIndex:i];
        
        CGFloat val = [e floatValue];
        
        locations[i] = val;
    }
    
    size_t numLocations = locationsArray.count;
    
    CGFloat *components = malloc(sizeof(CGFloat) * colorArray.count * 4);
    
    for (int i=0;  i < colorArray.count; i++) {
        NSNumber *e = (NSNumber *)[colorArray objectAtIndex:i];
        int rgb = [e integerValue];
        
        double r = (rgb >> 16 & 0xFF)/255.0;
        double g = (rgb >> 8 & 0xFF)/255.0;
        double b = (rgb & 0xFF)/255.0;
        double a = (rgb >> 24 & 0xFF)/255.0;
        
        components[i * 4] = r;
        components[(i * 4) + 1] = g;
        components[(i * 4) + 2] = b;
        components[(i * 4) + 3] = a;
    }
    
    
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    stateGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, numLocations);
    
    CGRect currentBounds = self.bounds;
    
    float startPointNormalizeX = [(NSNumber *)[startPointArray objectAtIndex:0] floatValue];
    float startPointNormalizeY = [(NSNumber *)[startPointArray objectAtIndex:1] floatValue];
    float endPointNormalizeX = [(NSNumber *)[endPointArray objectAtIndex:0] floatValue];
    float endPointNormalizeY = [(NSNumber *)[endPointArray objectAtIndex:1] floatValue];
    
    CGPoint startPoint = CGPointMake(CGRectGetMaxX(currentBounds) * startPointNormalizeX, CGRectGetMaxY(currentBounds) * startPointNormalizeY);
    CGPoint endPoint = CGPointMake(CGRectGetMaxX(currentBounds) * endPointNormalizeX, CGRectGetMaxY(currentBounds) * endPointNormalizeY);
    CGContextDrawLinearGradient(context, stateGradient, startPoint, endPoint, 0);
    
    CGGradientRelease(stateGradient);
    CGColorSpaceRelease(rgbColorspace); 
    
    free(locations);
    free(components);
}


@end
