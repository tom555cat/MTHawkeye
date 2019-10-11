//
// Copyright (c) 2008-present, Meitu, Inc.
// All rights reserved.
//
// This source code is licensed under the license found in the LICENSE file in
// the root directory of this source tree.
//
// Created on: 2019/9/29
// Created by: tongleiming
//


#import "XCActionEventViewCell.h"
#import "Masonry.h"
#import "XCActionTraceModel.h"

NSString *const XCActionEventViewCellIdentifier = @"kXCActionEventViewCellIdentifier";

@interface XCActionEventViewCell ()

@property (nonatomic, strong) UIButton *detailBtnView;

@property (nonatomic, strong) UILabel *actionTitleLabel;

@end

@implementation XCActionEventViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        self.detailBtnView = [[UIButton alloc] init];
        UIImage *bgImage = [self _imageFromColor:[UIColor colorWithWhite:0.8 alpha:0.1f]];
        [self.detailBtnView setBackgroundImage:bgImage forState:UIControlStateNormal];
        [self.detailBtnView addTarget:self action:@selector(detailBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.detailBtnView];
        
        self.actionTitleLabel = [[UILabel alloc] init];
        self.actionTitleLabel.font = [UIFont systemFontOfSize:10.f];
        self.actionTitleLabel.textColor = [UIColor colorWithWhite:0.0667 alpha:1];
        [self.contentView addSubview:self.actionTitleLabel];
        
        [self constructConstraints];
    }
    
    return self;
}

- (void)constructConstraints {
    
    [self.detailBtnView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(47.f);
        make.height.centerY.right.mas_equalTo(self);
    }];
    
    [self.actionTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView.mas_left).offset(10);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width - 47 - 10);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIImage *)_imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 4, 4);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)setActionTraceModel:(XCActionTraceModel *)actionTraceModel {
    _actionTraceModel = actionTraceModel;
    
    self.actionTitleLabel.text = actionTraceModel.actionTitle;
}

- (void)detailBtnTapped {
    if ([self.delegate respondsToSelector:@selector(xc_actionEventCellDidTappedDetail:)]) {
        [self.delegate xc_actionEventCellDidTappedDetail:self];
    }
}

@end
