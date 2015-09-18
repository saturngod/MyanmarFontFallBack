//
//  MMFAppDelegate.h
//  MyanmarFallBack
//
//  Created by Htain Lin Shwe on 20/8/13.
//  Copyright (c) 2013 comquas. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MMFAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSMatrix *fontOption;


-(IBAction)updateFallBack:(id)sender;

-(IBAction)clearFallBack:(id)sender;
@end
