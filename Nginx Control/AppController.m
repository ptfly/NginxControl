//
//  AppController.m
//  Nginx Control
//
//  Created by Plamen Todorov on 9.09.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import "AppController.h"

#define kServerPath         @"/usr/local/bin/nginx"
#define kPidFilePath        @"/usr/local/var/run/nginx.pid"
#define kConfigFilePath     @"/usr/local/etc/nginx/nginx.conf"

#define kConfigEditor       @"TextMate" // falls back to TextEdit

typedef enum : NSUInteger {
    StartStop    = 1,
    ReloadConfig = 2,
} ServerAction;

@interface AppController () <NSMenuDelegate>
{
    NSStatusItem *statusBar;
    NSString *currentPassword;
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
    
    currentPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"sudoPasswd"];
}

#pragma mark - SHELL

-(void)exec:(NSArray *)arguments
{
    NSString *pass = @"";
    if(currentPassword){
        pass = [NSString stringWithFormat:@"password \"%@\"", currentPassword];
    }
    
    NSString *args         = (arguments.count > 0 ? [NSString stringWithFormat:@" %@", [arguments componentsJoinedByString:@" "]] : @"");
    NSString *command	   = [NSString stringWithFormat:@"do shell script \"sudo %@%@\" %@ with administrator privileges", kServerPath, args, pass];
    NSAppleScript *script  = [[NSAppleScript alloc] initWithSource:command];

    NSLog(@"%@", command);
    
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
    
    [[NSWorkspace sharedWorkspace] openFile:kConfigFilePath withApplication:app];
}

-(IBAction)setCredentials:(id)sender
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"Seting Up Sudo Access"
                                     defaultButton:@"Save"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@"You could save your password here and not having to enter it every time!"];
    
    
    NSSecureTextField *input = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];

    if(currentPassword){
        [input setStringValue:currentPassword];
    }
    
    [alert setAccessoryView:input];
    
    NSInteger button = [alert runModal];
    
    if(button == NSAlertDefaultReturn)
    {
        [input validateEditing];
        currentPassword = [input stringValue];
        [[NSUserDefaults standardUserDefaults] setObject:currentPassword forKey:@"sudoPasswd"];
    }
}

@end
