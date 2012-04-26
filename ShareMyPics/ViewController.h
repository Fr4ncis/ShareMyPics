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
    __weak IBOutlet UIImageView *launchImage;
}

- (IBAction)choosePicsPressed:(id)sender;
- (void)createZipFile:(NSArray *)info;
- (IBAction)linkDropboxPressed:(id)sender;
- (IBAction)uploadFilePressed:(id)sender;
- (IBAction)shareEmailPressed:(id)sender;
- (IBAction)shareFbPressed:(id)sender;
- (IBAction)shareTwitterPressed:(id)sender;
- (IBAction)restartProcess:(id)sender;
@property (retain, nonatomic) IBOutlet UIImageView *zippingImg;
@property (retain, nonatomic) IBOutlet UIImageView *uploadingImg;
@property (retain, nonatomic) IBOutlet UIImageView *shareImg;
@property (retain, nonatomic) NSString *shareLink;
@property (retain, nonatomic) IBOutlet UIImageView *animatedLoadImage;

@end
