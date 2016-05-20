//
//  ViewController.m
//  FSHudVew
//
//  Created by 四维图新 on 16/5/20.
//  Copyright © 2016年 四维图新. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Hud.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) NSArray *datas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITableView *tableView = [[UITableView alloc] init];
    
    self.tableView = tableView;
    
    tableView.delegate = self;
    
    tableView.dataSource = self;
    
    tableView.frame = self.view.bounds;
    
    [self.view addSubview:tableView];
    
    tableView.tableFooterView = [UIView new];
    
    [self.tableView setHudEdgeInsets:self.tableView.contentInset];
    
    [self.tableView setHudState:FSHudStateLoding];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.tableView setHudState:FSHudStateError];
        
    });
    
    __weak typeof(self) weakSelf = self;
    
    [self.tableView setHudViewTapBlock:^(FSHudState state) {
        
        [weakSelf.tableView setHudState:FSHudStateLoding];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [weakSelf.tableView setHudState:FSHudStateRemove];
            
            NSMutableArray *arrayM = [NSMutableArray array];
            
            for (int i = 0; i < 30; i++)
            {
                [arrayM addObject:@(i)];
            }
            
            weakSelf.datas = arrayM;
            
            [weakSelf.tableView reloadData];
        });
        
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:0 reuseIdentifier:@"cell"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = [NSString stringWithFormat:@"fs - %ld",indexPath.row];
}


@end
