//
//  MMFAppDelegate.m
//  MyanmarFallBack
//
//  Created by Htain Lin Shwe on 20/8/13.
//  Copyright (c) 2013 comquas. All rights reserved.
//

#import "MMFAppDelegate.h"
#import "NSFileManager+DirectoryLocations.h"
#import "BLAuthentication.h"

#define MOVE @"/bin/mv"
#define COPY @"/bin/cp"

enum MMFontsName {
    Zawgyi = 1,
    Mon3 = 2,
    Myanmar3 = 3,
    MyMyanmar = 4,
    Tharlon = 5,
    Other = 6
    };

@interface MMFAppDelegate()

@property (nonatomic,strong) NSMutableArray* cursive;
@property (nonatomic,strong) NSMutableArray* defaultFonts;
@property (nonatomic,strong) NSMutableArray* fantasy;
@property (nonatomic,strong) NSMutableArray* monospace;
@property (nonatomic,strong) NSMutableArray* sansSerif;
@property (nonatomic,strong) NSMutableArray* serif;

@property (nonatomic,strong) NSMutableDictionary* fallBackFile;
@property (weak) IBOutlet NSTextField *fontFamilyTextField;

@end
@implementation MMFAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

-(void)addFonts:(NSString*)fontName
{
    if(_cursive)
    {
        [_cursive insertObject:fontName atIndex:7];
    }
    
    if(_defaultFonts){
        [_defaultFonts insertObject:fontName atIndex:7];
    }
    if(_fantasy){
        [_fantasy insertObject:fontName atIndex:7];
    }
    if(_monospace){
        [_monospace insertObject:fontName atIndex:7];
    }
    if(_sansSerif){
        [_sansSerif insertObject:fontName atIndex:7];
    }
    if(_serif){
        [_serif insertObject:fontName atIndex:7];
    }
    
    if(_fallBackFile[@"cursive"]) {
        _fallBackFile[@"cursive"] = _cursive;
    }
    
    if(_fallBackFile[@"default"]) {
        _fallBackFile[@"default"] = _defaultFonts;
    }
    
    if(_fallBackFile[@"fantasy"]) {
        _fallBackFile[@"fantasy"] = _fantasy;
    }
    
    if(_fallBackFile[@"monospace"]) {
        _fallBackFile[@"monospace"] = _monospace;
    }
    
    if(_fallBackFile[@"sans-serif"]) {
        _fallBackFile[@"sans-serif"] = _sansSerif;
    }
    
    
    if(_fallBackFile[@"serif"]) {
        _fallBackFile[@"serif"] = _serif;
    }
    
    
}

-(NSString*)backupOriginalFile
{
    NSString *path = [[NSFileManager defaultManager] applicationSupportDirectory];
    
    
    NSString* backupFile = [path stringByAppendingPathComponent:@"DefaultFontFallbacks.plist"];
    
    NSString* original = @"/System/Library/Frameworks/CoreText.framework/Versions/A/Resources/DefaultFontFallbacks.plist";
    
    
    //if original file not backup yet , backup the original
    if(![[NSFileManager defaultManager] fileExistsAtPath:backupFile])
    {
        [[NSFileManager defaultManager] copyItemAtPath:original toPath:backupFile error:nil];
    }
    return backupFile;
}

-(void)prepareFallBack:(NSString*)backupFile
{
    _fallBackFile = [[NSMutableDictionary alloc] initWithContentsOfFile:backupFile];
    
    
    if(_fallBackFile[@"cursive"]) {
        _cursive = [[NSMutableArray alloc] initWithArray:_fallBackFile[@"cursive"]];
    }
    
    if(_fallBackFile[@"default"]) {
        _defaultFonts = [[NSMutableArray alloc] initWithArray:_fallBackFile[@"default"]];
    }
    
    if(_fallBackFile[@"fantasy"]) {
        _fantasy = [[NSMutableArray alloc] initWithArray:_fallBackFile[@"fantasy"]];
    }
    
    if(_fallBackFile[@"monospace"]) {
        _monospace = [[NSMutableArray alloc] initWithArray:_fallBackFile[@"monospace"]];
    }
    
    if(_fallBackFile[@"sans-serif"]) {
        _sansSerif = [[NSMutableArray alloc] initWithArray:_fallBackFile[@"sans-serif"]];
    }
    
    
    if(_fallBackFile[@"serif"]) {
        _serif = [[NSMutableArray alloc] initWithArray:_fallBackFile[@"serif"]];
    }
    

}

- (IBAction)checkingOtherFont:(NSMatrix *)sender {
    
    if(_fontOption.selectedTag == 6) {
        _fontFamilyTextField.enabled = YES;
        [_fontFamilyTextField becomeFirstResponder];
    }
    else {
        _fontFamilyTextField.enabled = NO;
        [_fontFamilyTextField setStringValue:@""];
    }
    
}

-(void)updateFallBack:(id)sender {
    
    NSString* backupFile = [self backupOriginalFile];
    [self prepareFallBack:backupFile];
    
    if(_fontOption.selectedTag==Zawgyi)
    {
        [self addFonts:@"Zawgyi-One"];
    }
    else if(_fontOption.selectedTag==Mon3)
    {
        [self addFonts:@"MON3 Anonta 1"];
    }
    else if(_fontOption.selectedTag==Myanmar3)
    {
        [self addFonts:@"Myanmar3"];
    }
    else if(_fontOption.selectedTag==MyMyanmar)
    {
        [self addFonts:@"MyMyanmar Universal"];
    }
    else if(_fontOption.selectedTag==Tharlon)
    {
        [self addFonts:@"Tharlon"];
    }
    else if(_fontOption.selectedTag==Other)
    {
        if ([_fontFamilyTextField.stringValue isEqualToString:@""]) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please! enter the font family name"];
            [alert runModal];
            
            [_fontFamilyTextField becomeFirstResponder];
            return;
            
        }
    }

    [self writeToFile];
    
    NSAlert *alert = [NSAlert alertWithMessageText:@"" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Fallback font already update. Please logout and login again"];
    [alert runModal];

}

-(void)writeToFile
{
    NSString *path = [[NSFileManager defaultManager] applicationSupportDirectory];
    
    NSString* tmpFile = [path stringByAppendingPathComponent:@"DefaultFontFallbacks_tmp.plist"];
    
     NSString* original = @"/System/Library/Frameworks/CoreText.framework/Versions/A/Resources/DefaultFontFallbacks.plist";
    
    [_fallBackFile writeToFile:tmpFile atomically:YES];
    
    
    if (![[BLAuthentication sharedInstance] isAuthenticated:COPY]) {
        [[BLAuthentication sharedInstance] authenticate:COPY];
    }
    
    NSArray *arguments = [NSArray arrayWithObjects:tmpFile, original, nil];
    [[BLAuthentication sharedInstance] executeCommand:COPY withArgs:arguments];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

-(void)clearFallBack:(id)sender
{
    NSString *path = [[NSFileManager defaultManager] applicationSupportDirectory];
    
    
    NSString* backupFile = [path stringByAppendingPathComponent:@"DefaultFontFallbacks.plist"];
    NSString* original = @"/System/Library/Frameworks/CoreText.framework/Versions/A/Resources/DefaultFontFallbacks.plist";
    
    if([[NSFileManager defaultManager] fileExistsAtPath:backupFile]) {
        
        if (![[BLAuthentication sharedInstance] isAuthenticated:COPY]) {
            [[BLAuthentication sharedInstance] authenticate:COPY];
        }
        
        NSArray *arguments = [NSArray arrayWithObjects:backupFile, original, nil];
        [[BLAuthentication sharedInstance] executeCommand:COPY withArgs:arguments];
        
    }
    
}
@end
