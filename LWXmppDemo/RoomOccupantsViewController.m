//
//  RoomOccupantsViewController.m
//  LWXmppDemo
//
//  Created by LaoWen on 16/6/16.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

#import "RoomOccupantsViewController.h"
#import "LWXmppManager.h"

@interface RoomOccupantsViewController ()<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong)NSFetchedResultsController *resultsController;

@end

@implementation RoomOccupantsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"群成员";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSFetchedResultsController *)resultsController {
    if (_resultsController == nil) {
        NSString *entityName = NSStringFromClass([XMPPRoomOccupantCoreDataStorageObject class]);
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:entityName];
        NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"jidStr" ascending:YES];
        request.sortDescriptors = @[sd1];
        NSManagedObjectContext *context = [LWXmppManager sharedInstance].roomStorage.mainThreadManagedObjectContext;//TODO:侧滑查看群成员(StoryBoard里能用策划吗？)
        _resultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        _resultsController.delegate = self;
        [_resultsController performFetch:nil];
    }
    return _resultsController;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.resultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.resultsController.sections[section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"occupantCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    XMPPRoomOccupantCoreDataStorageObject *occupant = [self.resultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = occupant.nickname;
    //TODO:显示头像
    
    return cell;
}

@end
