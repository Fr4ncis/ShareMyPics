//
//  AppDelegate.h
//  ShareMyPics
//
//  Created by Francesco Mattia on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, DBSessionDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
