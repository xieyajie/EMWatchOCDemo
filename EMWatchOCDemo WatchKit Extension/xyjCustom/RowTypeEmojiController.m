//
//  RowTypeEmojiController.m
//  EMWatchOCDemo
//
//  Created by dhc on 15/4/7.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "RowTypeEmojiController.h"

@implementation RowTypeEmojiController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _emojis = [NSMutableArray array];
    }
    
    return self;
}

- (void)buttonActionAtIndex:(int)index
{
    if(_delegate && [_delegate respondsToSelector:@selector(emojiControllerSelected:)])
    {
        [_delegate emojiControllerSelected:[_emojis objectAtIndex:index]];
    }
}

- (IBAction)button1Action:(id)sender
{
    [self buttonActionAtIndex:0];
}

- (IBAction)button2Action:(id)sender
{
    [self buttonActionAtIndex:1];
}

- (IBAction)button3Action:(id)sender
{
    [self buttonActionAtIndex:2];
}

- (IBAction)button4Action:(id)sender
{
    [self buttonActionAtIndex:3];
}

@end
