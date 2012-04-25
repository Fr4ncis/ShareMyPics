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
#import <DropboxSDK/DropboxSDK.h>
#import "SHK.h"
#import "SHKFacebook.h"
#import "SHKTwitter.h"
#import "SHKMail.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)choosePicsPressed:(id)sender {
    ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName:@"ELCAlbumPickerController" bundle:[NSBundle mainBundle]];    
	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    [albumController setParent:elcPicker];
	[elcPicker setDelegate:self];
    
	[self presentModalViewController:elcPicker animated:YES];
    [elcPicker release];
    [albumController release];
}

- (IBAction)linkDropboxPressed:(id)sender {
    if (![[DBSession sharedSession] isLinked]) {
        NSLog(@"Going to link dropbox.");
		[[DBSession sharedSession] link];
    } else {
        NSLog(@"Dropbox already linked.");
    }
}

- (IBAction)unlinkDropboxPressed:(id)sender {
}

- (IBAction)uploadFilePressed:(id)sender {
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
	NSURL *url = [NSURL URLWithString:@"http://nonsenselink.com"];
	SHKItem *item = [SHKItem URL:url title:shareString];
    NSLog(@"Share EMAIL");
    [SHKMail shareItem:item];
}

- (IBAction)shareFbPressed:(id)sender {
    NSLog(@"Sharing link on Facebook");
    NSString *shareString = @"Cool event!";
    // Create the item to share (in this example, a url)
	NSURL *url = [NSURL URLWithString:@"http://nonsenselink.com"];
	SHKItem *item = [SHKItem URL:url title:shareString];
    [SHKFacebook shareItem:item];
}

- (IBAction)shareTwitterPressed:(id)sender {
    NSLog(@"Sharing link on twitter");
    NSString *shareString = @"Cool event!";
    // Create the item to share (in this example, a url)
	NSURL *url = [NSURL URLWithString:@"http://nonsenselink.com"];
	SHKItem *item = [SHKItem URL:url title:shareString];
    [SHKTwitter shareItem:item];
}


- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
    [client loadSharableLinkForFile:destPath];
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
}

- (void)restClient:(DBRestClient*)restClient loadedSharableLink:(NSString*)link 
           forFile:(NSString*)path {
    NSLog(@"Loaded sharable Link %@", link);
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    NSLog(@"Files selected: %d",[info count]);
    [self dismissModalViewControllerAnimated:YES];
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
