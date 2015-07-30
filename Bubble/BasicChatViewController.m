//
//  BasicChatViewController.m
//  Bubble
//
//  Created by Lukas Thoms on 7/30/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "BasicChatViewController.h"
#import "XMPPManager.h"
#import <Parse.h>

@interface BasicChatViewController () <UITableViewDelegate,UITableViewDataSource,MessageDelegate>
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) XMPPManager *xmppManager;
@property (nonatomic) NSMutableArray *messages;
@end

@implementation BasicChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.xmppManager = [XMPPManager sharedManager];
//    self.xmppManager.messageDelegate = self;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.messages = [[NSMutableArray alloc] init];
    [self.messageField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendMessage:(id)sender {
    NSString *messageString = self.messageField.text;
    
    if([messageString length] > 0) {
        
        XMPPMessage *message = [[XMPPMessage alloc] init];
        [message addAttributeWithName:@"senderId" stringValue:[PFUser currentUser].objectId];
        [message addAttributeWithName:@"displayName" stringValue:[PFUser currentUser][@"name"]];
        [message addBody:messageString];
        [self.xmppManager.xmppRoom sendMessage:message];
        self.messageField.text = @"";
    }
    
    [self.messageField resignFirstResponder];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *messagesDict = (NSDictionary *)self.messages[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [messagesDict objectForKey:@"msg"];
    cell.detailTextLabel.text = [messagesDict objectForKey:@"sender"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = NO;
    
    return cell;
    
}

-(void)newMessageReceived:(NSMutableDictionary *)messageContent {
    [self.messages addObject:messageContent];
    [self.tableView reloadData];
    
    NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:self.messages.count-1
                                                   inSection:0];
    
    [self.tableView scrollToRowAtIndexPath:topIndexPath
                          atScrollPosition:UITableViewScrollPositionMiddle
                                  animated:YES];
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}




@end
