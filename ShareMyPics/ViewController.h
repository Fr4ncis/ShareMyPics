//
//  ViewController.h
//  ShareMyPics
//
//  Created by Francesco Mattia on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface ViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, DBRestClientDelegate> {
    DBRestClient *restClient;
}
- (IBAction)choosePicsPressed:(id)sender;
- (IBAction)linkDropboxPressed:(id)sender;
- (IBAction)unlinkDropboxPressed:(id)sender;
- (IBAction)uploadFilePressed:(id)sender;
- (IBAction)shareEmailPressed:(id)sender;
- (IBAction)shareFbPressed:(id)sender;
- (IBAction)shareTwitterPressed:(id)sender;

@end
