//
//  RowTypeMessageController.h
//  EMWatchOCDemo
//
//  Created by dhc on 15/4/5.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface RowTypeMessageController : NSObject

//@property (weak, nonatomic) IBOutlet WKInterfaceButton *resendButton;

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *cellGroup;

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *contentGroup;

@property (weak, nonatomic) IBOutlet WKInterfaceImage *headerImageView;

@property (weak, nonatomic) IBOutlet WKInterfaceImage *imageView;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;

@end
