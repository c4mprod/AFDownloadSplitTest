//
//  ViewController.m
//  TestDownLoadFile
//
//  Created by Xavier on 18/03/13.
//  Copyright (c) 2013 C4MProd. All rights reserved.
//

#import "ViewController.h"
#import "AFJSONRequestOperation.h"

#define kUrl    @"http://s3.amazonaws.com/staging-media-tekken-site/webplayer"
#define kFile   @"Cards_Image.unity3d"

// 5 Mo
#define kBytesLimit    5242880

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mFileData = [[NSMutableData alloc] init];
    
    mBytesLimit = kBytesLimit;
    
    mNbPartNeededToComplete = 0;
    mPartInt = 0;
    
    mFileName = [kFile retain];
    
    NSURL* lUrl = [NSURL URLWithString:kUrl];
    
    mClient = [[AFHTTPClient alloc] initWithBaseURL:lUrl];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (IBAction) getFileSize
{
    mLabel.text = @"Chargement en cours";
    
    [mClient getPath:mFileName
         parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"operation.response.allHeaderFields : %@", operation.response.allHeaderFields);
         
         mImageSize = [[operation.response.allHeaderFields objectForKey:@"Content-Length"] intValue];
         
         NSLog(@"mImageSize : %d", mImageSize);
         
         if (mBytesLimit >= mImageSize)
         {
             mBytesLimit = mImageSize;
             
             mNbPartNeededToComplete = 1;
         }
         else
         {
             mNbPartNeededToComplete = abs(mImageSize/mBytesLimit) +1;
         }
         
         NSLog(@"mNbPartNeededToComplete : %d", mNbPartNeededToComplete);
         
         [self getFile];
         
     }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"error : %@", error);
         
         mLabel.text = error.description;
     }
     ];
}


- (IBAction) getFile
{
    int lRangeMin = mPartInt*mBytesLimit;
    
    int lRangeMax;
    
    if (mPartInt == mNbPartNeededToComplete - 1)
    {
        lRangeMax = (mImageSize - mPartInt*mBytesLimit + lRangeMin) - 1;
    }
    else
    {
        lRangeMax = ((mPartInt+1)*mBytesLimit) - 1;
    }
    
    NSString* lRange = [NSString stringWithFormat:@"bytes=%d-%d",lRangeMin, lRangeMax];
    
    NSLog(@"Range : %@", lRange);
    
    [mClient setDefaultHeader:@"Range" value:lRange];
    
    [mClient getPath:mFileName
            parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject)
            {             
                mPartInt++;
                NSLog(@"success / mPartInt : %d", mPartInt);
                
                //NSLog(@"responseObject : %@", responseObject);
                
                [mFileData appendData:responseObject];
                
                 NSLog(@"mFileData : %d", mFileData.length);
                
                if (mPartInt == mNbPartNeededToComplete)
                {
                    [self writeDateToDisk];
                    
                    mLabel.text = [NSString stringWithFormat:@"Fichier téléchargé / taille : %d Ko", mImageSize];
                }
                else
                {
                    [self getFile];
                }
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
            {
                NSLog(@"error : %@", error);
                
                mLabel.text = error.description;
            }
     ];
}


- (void) writeDateToDisk
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentDirectory = [paths objectAtIndex:0];
	NSString* pdfDirectory = [documentDirectory stringByAppendingPathComponent:kFile];
    
    [mFileData writeToFile:pdfDirectory atomically:NO];
}


- (void)dealloc
{
    [mLabel release];
    [mFileData release];
    [mFileName release];
    [mClient release];
    
    [super dealloc];
}


@end
