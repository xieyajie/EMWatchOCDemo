//
//  ChatController.m
//  EMWatchOCDemo
//
//  Created by dhc on 15/4/2.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ChatController.h"

#import "RowTypeMessageController.h"
#import "EmojiController.h"
#import "ConvertToCommonEmoticonsHelper.h"

typedef enum {
    MessageTypeText = 1,
    MessageTypeImage = 2,
    MessageTypeAudio = 5,
} MessageType;

@implementation MessageModel

//

@end

@interface ChatController()
{
    AVAudioPlayer *_player;
    
    MessageModel *_willSendModel;
}

@property (strong, nonatomic) NSString *chatter;

@property (nonatomic) BOOL isGroup;

@end


@implementation ChatController

@synthesize chatter = _chatter;
@synthesize isGroup = _isGroup;

- (void)awakeWithContext:(id)context {
    
    // Configure interface objects here.
    _chatter = [context objectForKey:@"chatter"];
    _isGroup = [[context objectForKey:@"isGroup"] boolValue];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendText:) name:@"sendTextMessage" object:nil];
    
    [super awakeWithContext:context];
    
    [_faceButton setBackgroundImage:[UIImage imageNamed:@"face"]];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    if (_willSendModel) {
        [self insertCellWithModel:_willSendModel type:@"SendTextCell" atIndex:(int)(self.dataSoure.count - 1)];
        [self.table scrollToRowAtIndex:self.table.numberOfRows - 1];
        _willSendModel = nil;
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex
{
    MessageModel *model = self.dataSoure[rowIndex];
}

#pragma mark - private

- (NSArray *)messagesToModel:(NSArray *)messages
{
    NSMutableArray *models = [NSMutableArray array];
    for (NSDictionary *dic in messages)
    {
        MessageModel *model = [[MessageModel alloc] init];
        model.messageId = [dic objectForKey:@"messageId"];
        model.isSender = [[dic objectForKey:@"isSender"] boolValue];
        model.type = [[dic objectForKey:@"type"] intValue];
        model.content = [dic objectForKey:@"content"];
        model.length = [[dic objectForKey:@"length"] intValue];
        model.thumbnailImageData = [dic objectForKey:@"thumbnailImageData"];
        model.state = [[dic objectForKey:@"state"] intValue];
        if(model.state == 1){
            model.state = 0;
        }
        
        [models addObject:model];
    }
    
    return models;
}

- (NSString *)rowTypeForMessage:(MessageModel *)message
{
    NSMutableString *rowType = [NSMutableString string];
    if (message.isSender) {
        [rowType appendString:@"Send"];
    } else {
        [rowType appendString:@"Receive"];
    }
    
    if (message.type == MessageTypeText) {
        [rowType appendString:@"TextCell"];
    } else if (message.type == MessageTypeAudio) {
        [rowType appendString:@"VoiceCell"];
    } else {
        [rowType appendString:@"ImageCell"];
    }
    return rowType;
}

#pragma mark - data

- (void)loadData
{
    int count = (int)[self.dataSoure count] + 50;
    [self.dataSoure removeAllObjects];
    [WKInterfaceController openParentApplication:@{@"action":@"fetchMessages", @"chatter":_chatter, @"isGroup":[NSNumber numberWithBool:_isGroup], @"count":[NSNumber numberWithInt:count]} reply:^(NSDictionary *replyInfo, NSError *error) {
        
        NSArray *messages = [replyInfo objectForKey:@"messages"];
        [self.dataSoure addObjectsFromArray:[self messagesToModel:messages]];
        NSInteger count = [self.dataSoure count];
        
//        //先清空预置的row
//        [self.table removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.table.numberOfRows)]];
        for (int i = 0; i < count; i++) {
            MessageModel *model = self.dataSoure[i];
            NSString *rowType = [self rowTypeForMessage:model];
            [self insertCellWithModel:model type:rowType atIndex:i];
        }
        [self.table scrollToRowAtIndex:(count - 1)];
    }];
}

- (void)insertCellWithModel:(MessageModel *)model
                       type:(NSString *)type
                    atIndex:(int)index
{
    [self.table insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withRowType:type];
    
    RowTypeMessageController *rowController = [self.table rowControllerAtIndex:index];
    if (model.type == MessageTypeText) {
        // 表情映射。
        NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
                                    convertToSystemEmoticons:model.content];
        [rowController.titleLabel setText:didReceiveText];
    }
    else if (model.type == MessageTypeAudio) {
        [rowController.titleLabel setText:[NSString stringWithFormat:@"%i", model.length]];
        [rowController .imageView setImageNamed:@"audio"];
    }
    else {
        [rowController.imageView setImageData:model.thumbnailImageData];
    }
}

#pragma mark - action

- (void)sendText:(NSNotification *)notification
{
    NSString *text = (NSString *)notification.object;
    MessageModel *model = [[MessageModel alloc] init];
    model.isSender = YES;
    model.type = MessageTypeText;
    model.content = text;
    model.state = 0;
    [self.dataSoure addObject:model];
    _willSendModel = model;
    
    [WKInterfaceController openParentApplication:@{@"action":@"sendText", @"text":text, @"to":_chatter, @"isGroup":[NSNumber numberWithBool:_isGroup]} reply:^(NSDictionary *replyInfo, NSError *error) {
        
//        _willSendModel.messageId = [replyInfo objectForKey:@"messageId"];
//        NSError *merror = [replyInfo objectForKey:@"error"];
//        _willSendModel.messageId = [replyInfo objectForKey:@"messageId"];
//        _willSendModel.state = merror ? MessageStateFailure : MessageStateSuccess;
    }];
}

- (IBAction)faceAction:(id)sender
{
    [self presentControllerWithName:@"EmojiController" context:nil];
}

@end



