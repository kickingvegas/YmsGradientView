//
//  YmsViewController.m
//  YmsGradientViewDemo
//
//  Created by Charles Y. Choi on 1/21/12.
//  Copyright (c) 2012 Yummy Melon Software LLC. All rights reserved.
//

#import "YmsViewController.h"
#import "YmsGradientView.h"

@implementation YmsViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load YmsGraidentView using Example1.plist configuration.
    YmsGradientView *gradientView = [[YmsGradientView alloc] initWithFrame:CGRectMake(80, 90, 100, 100) withResourceName:@"Example1"];
    
    [self.view addSubview:gradientView];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
