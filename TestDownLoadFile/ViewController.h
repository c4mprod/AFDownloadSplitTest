//
//  ViewController.h
//  TestDownLoadFile
//
//  Created by Xavier on 18/03/13.
//  Copyright (c) 2013 C4MProd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPClient.h"

@interface ViewController : UIViewController
{
    IBOutlet UILabel*        mLabel;
    
    int                     mImageSize;
    int                     mBytesLimit;
    int                     mPartInt;
    int                     mNbPartNeededToComplete;
    
    NSMutableData*          mFileData;
    
    NSString*               mFileName;
    
    AFHTTPClient*           mClient;
}

- (IBAction) getFile;

@end
