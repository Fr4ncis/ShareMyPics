//
//  ViewController.m
//  ShareMyPics
//
//  Created by Francesco Mattia on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "ZipFile.h"
#import "ZipWriteStream.h"
#import "SHK.h"
#import "SHKFacebook.h"
#import "SHKTwitter.h"
#import "SHKMail.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize zippingImg;
@synthesize uploadingImg;
@synthesize shareImg;
@synthesize shareLink;
@synthesize activityIndicator;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self performSelector:@selector(choosePicsPressed:) withObject:nil afterDelay:0.5];
}


- (void)viewDidUnload
{
    launchImage = nil;
    [self setZippingImg:nil];
    [self setUploadingImg:nil];
    [self setShareImg:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)choosePicsPressed:(id)sender {
    ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName:@"ELCAlbumPickerController" bundle:[NSBundle mainBundle]];    
	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    [albumController setParent:elcPicker];
	[elcPicker setDelegate:self];
    
    [elcPicker setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
	[self presentModalViewController:elcPicker animated:YES];
    [launchImage setHidden:YES];
    [elcPicker release];
    [albumController release];
}

- (IBAction)linkDropboxPressed:(id)sender {
    if (![[DBSession sharedSession] isLinked]) {
        NSLog(@"Going to link dropbox.");
		[[DBSession sharedSession] link];
    } else {
        NSLog(@"Dropbox already linked.");
        [self performSelector:@selector(uploadFilePressed:) withObject:nil afterDelay:0.1];
    }
}

- (IBAction)uploadFilePressed:(id)sender {
    [UIView animateWithDuration:0.5 animations:^(void){
        zippingImg.frame = CGRectMake(-320, 0, 320, 100);
        uploadingImg.frame = CGRectMake(0, 0, 320, 100);
    }];
    NSLog(@"Uploading file to Dropbox.");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *zipFile = [documentsDirectory stringByAppendingPathComponent:@"temp.zip"];
    NSString *destDir = @"/";
    [[self restClient] uploadFile:@"tempUploaded.zip" toPath:destDir
                    withParentRev:nil fromPath:zipFile];
}

- (IBAction)shareEmailPressed:(id)sender {
    NSLog(@"Sharing via email");
    NSString *shareString = @"Cool event!";
    // Create the item to share (in this example, a url)
	NSURL *url = [NSURL URLWithString:shareLink];
	SHKItem *item = [SHKItem URL:url title:shareString];
    NSLog(@"Share EMAIL");
    [SHKMail shareItem:item];
}

- (IBAction)shareFbPressed:(id)sender {
    NSLog(@"Sharing link on Facebook");
    NSString *shareString = @"Cool event!";
    // Create the item to share (in this example, a url)
	NSURL *url = [NSURL URLWithString:shareLink];
	SHKItem *item = [SHKItem URL:url title:shareString];
    [SHKFacebook shareItem:item];
}

- (IBAction)shareTwitterPressed:(id)sender {
    NSLog(@"Sharing link on twitter");
    NSString *shareString = @"Cool event!";
    // Create the item to share (in this example, a url)
	NSURL *url = [NSURL URLWithString:shareLink];
	SHKItem *item = [SHKItem URL:url title:shareString];
    [SHKTwitter shareItem:item];
}

- (IBAction)restartProcess:(id)sender {
}


- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
    [client loadSharableLinkForFile:destPath];
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occurred trying to upload the file to Dropbox." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:@"Panic!",nil];
    [alert show];
}

- (void)restClient:(DBRestClient*)restClient loadedSharableLink:(NSString*)link 
           forFile:(NSString*)path {
    NSLog(@"Loaded sharable Link %@", link);
    shareLink = [link copy];
    [self showShareScreen];
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    NSLog(@"Files selected: %d",[info count]);
    [self performSelector:@selector(nextScreen:) withObject:info afterDelay:0.1];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)nextScreen:(NSArray *)info {
    [activityIndicator startAnimating];
    [launchImage setHidden:YES];
    [UIView animateWithDuration:0.5 animations:^(void){
        [zippingImg setAlpha:1.0];
    }];
    [self performSelector:@selector(createZipFile:) withObject:info afterDelay:0.5];
}

- (void)createZipFile:(NSArray *)info {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *zipFile = [documentsDirectory stringByAppendingPathComponent:@"temp.zip"];
    ZipFile *file = [[ZipFile alloc] initWithFileName:zipFile mode:ZipFileModeCreate];
    for (int i = 0; i < [info count]; i++) {
        ZipWriteStream *stream = [file writeFileInZipWithName:[NSString stringWithFormat:@"file%d.jpg", i] compressionLevel:ZipCompressionLevelFastest];
        UIImage *image = [[info objectAtIndex:i] objectForKey: UIImagePickerControllerOriginalImage]; // or you can use UIImagePickerControllerEditedImage too
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        NSLog(@"File %d Data: %d", i, [data length]);
        [stream writeData:data];
        [stream finishedWriting];
    }
    [file close];
    [self linkDropboxPressed:nil];
}

- (void)showShareScreen {
    [((UILabel*)[self.view viewWithTag:4]) setText:shareLink];
    [activityIndicator stopAnimating];
    [UIView animateWithDuration:0.5 animations:^(void){
        uploadingImg.frame = CGRectMake(-320, 0, 320, 100);
        shareImg.frame = CGRectMake(0, 0, 320, 100);
        [[self.view viewWithTag:1] setAlpha:1.0];
        [[self.view viewWithTag:2] setAlpha:1.0];
        [[self.view viewWithTag:3] setAlpha:1.0];
        [[self.view viewWithTag:4] setAlpha:1.0];
        [[self.view viewWithTag:5] setAlpha:1.0];
    }];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    NSLog(@"Did cancel imagePickerController");
}

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

@end
