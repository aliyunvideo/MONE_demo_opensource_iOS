//
//  AUILiveAnswerGameView.m
//  AlivcLivePusherTest
//
//  Created by lyz on 2018/1/22.
//  Copyright © 2018年 TripleL. All rights reserved.
//

#import "AUILiveAnswerGameView.h"
#import "AlivcLivePushViewsProtocol.h"
#import "AUILiveAnswerTableViewCell.h"
#import "AlivcLiveQuestionModel.h"
#import "AlivcLiveAnswerModel.h"

@interface AUILiveAnswerGameView()

@property (nonatomic, weak) id<AUILiveAnswerGameViewDelegate> delegate;
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSMutableArray *questionDataArray;
@property (nonatomic, strong) NSMutableArray *answerDataArray;

@end

@implementation AUILiveAnswerGameView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubView];
        [self fetchData];
    }
    return self;
}


- (void)setAnswerDelegate:(id)delegate {
    
    self.delegate = delegate;
}


- (void)setupSubView {
    
    
    self.backgroundColor = [UIColor blackColor];
    self.alpha = 0.7;
    
    self.listTableView = [[UITableView alloc] init];
    self.listTableView.frame = self.bounds;
    
    self.listTableView.backgroundColor = [UIColor clearColor];
    self.listTableView.delegate = (id)self;
    self.listTableView.dataSource = (id)self;
    self.listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.listTableView.tableFooterView = [[UIView alloc] init];
    [self.listTableView registerClass:[AUILiveAnswerTableViewCell class] forCellReuseIdentifier:@"AUILiveAnswerTableViewCellIndentifier"];
    [self addSubview:self.listTableView];
}


- (void)fetchData {
    
    self.questionDataArray = [NSMutableArray array];
    
    NSString *questionPath = AUILiveCameraPushData(@"question.json");

    NSDictionary *questionDic = [self jsonDicWithFilePath:questionPath];
    [self.questionDataArray removeAllObjects];
    for (NSDictionary *dic in questionDic[@"contents"]) {
        AlivcLiveQuestionModel *model = [[AlivcLiveQuestionModel alloc] initWithDictionary:dic];
        [self.questionDataArray addObject:model];
    }
    
    
    self.answerDataArray = [NSMutableArray array];
    
    NSString *answerPath = AUILiveCameraPushData(@"answer.json");
    
    NSDictionary *answerDic = [self jsonDicWithFilePath:answerPath];
    [self.answerDataArray removeAllObjects];
    for (NSDictionary *dic in answerDic[@"contents"]) {
        AlivcLiveAnswerModel *model = [[AlivcLiveAnswerModel alloc] initWithDictionary:dic];
        [self.answerDataArray addObject:model];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [self.listTableView reloadData];
    });
}


- (NSDictionary *)jsonDicWithFilePath:(NSString *)path {
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *error = nil;
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    return dataDic;
}


#pragma mark - TableViewdelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.questionDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AUILiveAnswerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUILiveAnswerTableViewCellIndentifier" forIndexPath:indexPath];
    cell.delegate = (id)self;
    if (indexPath.row < self.questionDataArray.count) {
        [cell setupQuestionModel:self.questionDataArray[indexPath.row]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
}

#pragma mark - AUILiveAnswerTableViewCellDelegate


- (void)onClickAnswerTableViewQuestionButton:(AUILiveAnswerTableViewCell *)cell {
    
    NSIndexPath *path = [self.listTableView indexPathForCell:cell];
    AlivcLiveQuestionModel *model = self.questionDataArray[path.row];
    
    NSString *text = [model toString];
    
    if (self.delegate) {
        [self.delegate answerGameOnSendQuestion:text questionId:model.questionId];
    }
}


- (void)onClickAnswerTableViewAnswerButton:(AUILiveAnswerTableViewCell *)cell {
    
    NSIndexPath *path = [self.listTableView indexPathForCell:cell];
    AlivcLiveAnswerModel *model = self.answerDataArray[path.row];

    NSString *text = [model toString];
    NSInteger duration = [model.showTime integerValue];
    
    if (self.delegate) {
        [self.delegate answerGameOnSendAnswer:text duration:duration];
    }
}




@end
