//
//  MyvCardViewController.m
//  LWXmppDemo
//
//  Created by LaoWen on 16/6/15.
//  Copyright © 2016年 LaoWen. All rights reserved.
//

#import "MyvCardViewController.h"
#import "LWXmppManager.h"

@interface MyvCardViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UITextField *nickName;
@property (weak, nonatomic) IBOutlet UITextField *familyName;
@property (weak, nonatomic) IBOutlet UITextField *givenName;

@end

@implementation MyvCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializeUIFromMyCard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//显示我的个人信息（名片）
- (void)initializeUIFromMyCard {
    XMPPvCardTemp *myvCard = [LWXmppManager sharedInstance].vCardTempModule.myvCardTemp;
    _headImageView.image = [UIImage imageWithData:myvCard.photo];
    _familyName.text = myvCard.familyName;
    _givenName.text = myvCard.givenName;
    _nickName.text = myvCard.nickname;
}

//选择头像
- (IBAction)onBtnHeadImageClicked:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    _headImageView.image = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//TODO:检查输入合法性
- (BOOL)checkInput {
    return YES;
}

//保存个人信息（名片）
- (IBAction)onBtnOKClicked:(id)sender {
    if (![self checkInput]) {
        return;
    }
    //XMPPvCardTemp *temp = [[XMPPvCardTemp alloc]init];//这种方式会创建失败
    XMPPvCardTemp *temp = [LWXmppManager sharedInstance].vCardTempModule.myvCardTemp;
    UIImage *photoImage = _headImageView.image;
    temp.photo = UIImagePNGRepresentation(photoImage);
    temp.nickname = _nickName.text;
    temp.familyName = _familyName.text;
    temp.givenName = _givenName.text;
    
    [[LWXmppManager sharedInstance].vCardTempModule updateMyvCardTemp:temp];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
