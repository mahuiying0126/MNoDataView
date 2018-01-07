//
//  ViewController.m
//  MDemoBase
//
//  Created by yizhilu on 2017/9/9.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import "ViewController.h"
#import "MNavigationViewController.h"
#import "MReplyCommentView.h"
#import "UIButton+MAdd.h"
#import <MJRefresh.h>
@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>


/** *按钮*/
@property (nonatomic, strong) UIButton *rightButton;
/** 评论键盘*/
@property (nonatomic, strong) MReplyCommentView *replyView;
/**
 列表
 */
@property (nonatomic, strong) UITableView *tableView;


@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view msetWhiteBackground];
    UIButton *right = [self createButtonForTitle:@"弹出键盘"];
    [right addTarget:self action:@selector(selectInputBoard) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:right];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, Screen_width, Screen_height) style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    __weak typeof(self) weakSelf = self;
    self.tableView.mj_header  = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadData];
    }];
}

- (void)loadData {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
    });
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.replyView close];
    [IQKeyboardManager sharedManager].enable = YES;
}


#pragma mark - 代理


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[UITableViewCell alloc] init];
}

#pragma mark - TableView 占位图


- (UIImage *)m_noDataViewImage{
    return [UIImage imageNamed:@"缺省_下载"];
}
- (NSString *)m_noDataViewMessage{
    return @"没有数据啦!!!!";
}

#pragma mark - 响应事件

-(void)selectInputBoard{
    [self.replyView showKeyboardType:UIKeyboardTypeDefault content:@"评论" Block:^(NSString *contentStr) {
        NSLog(@"%@",contentStr);
    }];
}

#pragma mark - 私有方法

-(UIButton *)createButtonForTitle:(NSString *)title{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 40, 25);
    button.fontM = MFONT(16);
    button.normalTitleM = title;
    button.normalColorM = White;
    return button;
}

#pragma mark - 懒加载


-(MReplyCommentView *)replyView{
    if (!_replyView) {
        _replyView = [MReplyCommentView new];
        
    }
    return _replyView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
