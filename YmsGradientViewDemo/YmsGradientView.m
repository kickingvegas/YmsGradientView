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


- (id)initWithFrame:(CGRect)frame withResourceName:(NSString *)name {
    self.resourceName = name;
    self = [self initWithFrame:frame];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //[self initConfig];
    }
    return self;
}




- (void)drawRect:(CGRect)rect {
    
    if (self.resourceName == nil) {
        self.resourceName = NSStringFromClass([self class]);
    }
    
    NSLog(@"Rendering gradient using %@.plist", self.resourceName);
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:self.resourceName ofType:@"plist"];
    
    if (path == nil) {
        NSLog(@"WARNING: resource %@.plist does not exist. Using default resource YmsGradientView.plist.", self.resourceName);
        self.resourceName = @"YmsGradientView";
        path = [[NSBundle mainBundle] pathForResource:self.resourceName ofType:@"plist"];
    }
    
    NSDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    if ([self validateConfiguration:config]) {
        NSArray *colorArray = (NSArray *)[config objectForKey:@"colors"];
        NSArray *locationsArray = (NSArray *)[config objectForKey:@"locations"];
        NSArray *startPointArray = (NSArray *)[config objectForKey:@"startPoint"];
        NSArray *endPointArray = (NSArray *)[config objectForKey:@"endPoint"];
        
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
        
        [self addGraphics:context];
    }
    else {
        [NSException raise:@"Invalid YmsGradientView Configuration" 
                    format:@"Please revise the file %@.plist to confirm that it has legal values.", self.resourceName];

    }
}


- (void)addGraphics:(CGContextRef)context {
    // Override this method to add more graphics to the context.
}


- (BOOL)validateConfiguration:(NSDictionary *)gradientConfig {
    BOOL result = YES;
    
    NSArray *colorArray = (NSArray *)[gradientConfig objectForKey:@"colors"];
    NSArray *locations = (NSArray *)[gradientConfig objectForKey:@"locations"];
    NSArray *startPoint = (NSArray *)[gradientConfig objectForKey:@"startPoint"];
    NSArray *endPoint = (NSArray *)[gradientConfig objectForKey:@"endPoint"];

    
    
    if ((colorArray == nil) || (colorArray.count == 0)) { 
        NSLog(@"ERROR: colors array is not defined in %@.plist", self.resourceName);
        result = result & NO;
    }
    else {
        if (locations != nil) {
            if (colorArray.count < locations.count)
                NSLog(@"WARNING: colors and locations array count mismatch in %@.plist. " 
                      "They should either be equal or there should be no elements in the locations array.", self.resourceName);
            
            else if ((colorArray.count > locations.count) && (locations.count > 0)) {
                NSLog(@"ERROR:The size of the array colors and the array locations do not match in %@.plist. "
                      "They should either be equal or there should be no elements in the locations array.", self.resourceName);
                result = result & NO;
            }
        }
    }
    
    if (startPoint == nil) {
        NSLog(@"ERROR: startPoint is not defined in %@.plist", self.resourceName);
        result = result & NO;
    }
    else {
        if (startPoint.count != 2) {
            NSLog(@"ERROR: startPoint must have 2 elements (default 0.5, 0.0) in %@.plist", self.resourceName);
            result = result & NO;
        }
    }
    
    if (endPoint == nil) {
        NSLog(@"ERROR: endPoint is not defined in %@.plist", self.resourceName);
        result = result & NO;
    } 
    else {
        if (endPoint.count != 2) {
            NSLog(@"ERROR: endPoint must have 2 elements (default 0.5, 1.0) in %@.plist", self.resourceName);
            result = result & NO;
        }
    }

    return result;
}


@end
