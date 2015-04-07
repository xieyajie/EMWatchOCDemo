//
//  ChatController.h
//  EMWatchOCDemo
//
//  Created by dhc on 15/4/2.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "DXTableInterfaceController.h"

typedef enum{
    MessageStateSending = 0,
    MessageStateSuccess = 2,
    MessageStateFailure = 3,
}MessageState;


@interface MessageModel : NSObject

@property (strong, nonatomic) NSString *messageId;
@property (nonatomic) BOOL isSender;
@property (nonatomic) int type;
@property (nonatomic) int length;
@property (nonatomic) MessageState state;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSData *thumbnailImageData;

@end


@interface ChatController : DXTableInterfaceController

@property (strong, nonatomic) IBOutlet WKInterfaceButton *faceButton;

- (IBAction)faceAction:(id)sender;

@end
