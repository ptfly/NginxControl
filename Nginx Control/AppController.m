//
//  AppController.m
//  Nginx Control
//
//  Created by Plamen Todorov on 9.09.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import "AppController.h"

#define kServerPath   @"/usr/local/bin/nginx"
#define kPidFilePath  @"/usr/local/var/run/nginx.pid"
#define kConfigEditor @"TextMate" // falls back to TextEdit

@interface AppController () <NSMenuDelegate>
{
    NSStatusItem *statusBar;
}

@property (nonatomic, weak) IBOutlet NSMenu *mainMenu;

@end

@implementation AppController
@synthesize mainMenu;

-(void)awakeFromNib
{
    statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusBar setMenu:mainMenu];
    [statusBar setHighlightMode:YES];
    [statusBar setEnabled:YES];
    
    [statusBar setImage:[NSImage imageNamed:@"mbi"]];
    [statusBar setAlternateImage:[NSImage imageNamed:@"mbi-w"]];
    [statusBar setToolTip:@"Nginx Control Panel"];
}

#pragma mark - SHELL

-(void)exec:(NSArray *)arguments
{
    NSString *args         = (arguments.count > 0 ? [NSString stringWithFormat:@" %@", [arguments componentsJoinedByString:@" "]] : @"");
    NSString *command	   = [NSString stringWithFormat:@"do shell script \"sudo %@%@\" with administrator privileges", kServerPath, args];
    NSAppleScript *script  = [[NSAppleScript alloc] initWithSource:command];

    NSDictionary *error;
    [script executeAndReturnError:&error];

    if(error)
    {
        NSAlert *alert = [NSAlert alertWithMessageText:[error valueForKey:NSAppleScriptErrorAppName] defaultButton:@"OK" alternateButton:nil otherButton:nil
                             informativeTextWithFormat:@"%@", [error valueForKey:NSAppleScriptErrorMessage]];
        [alert runModal];
    }
}

-(BOOL)validateMenuItem:(NSMenuItem *)anItem
{
    BOOL isRunning = [[NSFileManager defaultManager] fileExistsAtPath:kPidFilePath isDirectory:NO];
    
    ServerAction action = (ServerAction)anItem.tag;
    
    if(action == StartStop){
        anItem.title = (isRunning ? @"Stop Server" : @"Start Server");
        anItem.action = (isRunning ? @selector(stopService:) : @selector(startService:));
    }
    else if(action == ReloadConfig){
        return isRunning;
    }
    
    return YES;
}

#pragma mark - Actions

-(IBAction)startService:(id)sender
{
    [self exec:nil];
}

-(IBAction)stopService:(id)sender
{
    [self exec:@[@"-s", @"quit"]];
}

-(IBAction)reloadService:(id)sender
{
    [self exec:@[@"-s", @"reload"]];
}

-(IBAction)openConfig:(id)sender
{
    NSString *app = kConfigEditor;
    NSString *mate = [[NSWorkspace sharedWorkspace] fullPathForApplication:app];
    
    if(!mate || [mate isEqualToString:@""]){
        app = @"TextEdit";
    }
    
    [[NSWorkspace sharedWorkspace] openFile:@"/usr/local/etc/nginx/nginx.conf" withApplication:app];
}

@end
