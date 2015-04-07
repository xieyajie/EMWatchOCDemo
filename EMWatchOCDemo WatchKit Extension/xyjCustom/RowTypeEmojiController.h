//
//  RowTypeEmojiController.h
//  EMWatchOCDemo
//
//  Created by dhc on 15/4/7.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@protocol RowTypeEmojiDelegate <NSObject>

- (void)emojiControllerSelected:(NSString *)string;

@end

@interface RowTypeEmojiController : NSObject

@property (weak, nonatomic) IBOutlet id<RowTypeEmojiDelegate> delegate;

@property (strong, nonatomic) NSMutableArray *emojis;

@property (weak, nonatomic) IBOutlet WKInterfaceButton *button1;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *button2;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *button3;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *button4;

- (IBAction)button1Action:(id)sender;
- (IBAction)button2Action:(id)sender;
- (IBAction)button3Action:(id)sender;
- (IBAction)button4Action:(id)sender;

@end
