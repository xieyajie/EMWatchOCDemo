//
//  EmojiController.m
//  EMWatchOCDemo
//
//  Created by dhc on 15/4/7.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "EmojiController.h"

#import "Emoji.h"
#import "RowTypeEmojiController.h"
#import "ConvertToCommonEmoticonsHelper.h"

@interface EmojiController()<RowTypeEmojiDelegate>

@end


@implementation EmojiController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark - data

- (void)loadData
{
    [self.dataSoure removeAllObjects];
    [self.dataSoure addObjectsFromArray:[Emoji allEmoji]];
    
    int count = (int)[self.dataSoure count];
    int col = 4;
    int row = count % col == 0 ? count / col : count / col + 1;
    [self.table setNumberOfRows:row withRowType:@"RowTypeEmojiController"];
    int index = 0;
    for (int i = 0; i < row; i++) {
        RowTypeEmojiController *rowController = [self.table rowControllerAtIndex:i];
        rowController.delegate = self;
        [rowController.emojis removeAllObjects];
        
        index = i * col;
        NSString *string = @"";
        if (index < count) {
            string = [self.dataSoure objectAtIndex:index];
            [rowController.button1 setTitle:string];
            [rowController.emojis addObject:string];
        }
        else{
            [rowController.button1 setHidden:YES];
            [rowController.button2 setHidden:YES];
            [rowController.button3 setHidden:YES];
            [rowController.button4 setHidden:YES];
            break;
        }
        
        ++index;
        if (index < count) {
            string = [self.dataSoure objectAtIndex:index];
            [rowController.button2 setTitle:string];
            [rowController.emojis addObject:string];
        }
        else{
            [rowController.button2 setHidden:YES];
            [rowController.button3 setHidden:YES];
            [rowController.button4 setHidden:YES];
            break;
        }
        
        ++index;
        if (index < count) {
            string = [self.dataSoure objectAtIndex:index];
            [rowController.button3 setTitle:string];
            [rowController.emojis addObject:string];
        }
        else{
            [rowController.button3 setHidden:YES];
            [rowController.button4 setHidden:YES];
            break;
        }
        
        ++index;
        if (index < count) {
            string = [self.dataSoure objectAtIndex:index];
            [rowController.button4 setTitle:string];
            [rowController.emojis addObject:string];
        }
        else{
            [rowController.button4 setHidden:YES];
            break;
        }
    }
}

#pragma mark - RowTypeEmojiDelegate

- (void)emojiControllerSelected:(NSString *)string
{
    if ([string length] > 0) {
        NSString *willSendText = [ConvertToCommonEmoticonsHelper convertToCommonEmoticons:string];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sendTextMessage" object:willSendText];
    }
    
    [self dismissController];
}

@end



