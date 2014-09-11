//
//  AppController.h
//  Nginx Control
//
//  Created by Plamen Todorov on 9.09.14.
//  Copyright (c) 2014 г. Plamen Todorov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    StartStop    = 1,
    ReloadConfig = 2,
} ServerAction;

@interface AppController : NSObject

@end
