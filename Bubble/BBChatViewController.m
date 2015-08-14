#import "BBChatViewController.h"
#import "BBMessage.h"
#import "ChatDataManager.h"
#import "Friend.h"
#import "FriendCell.h"
#import "XMPPManager.h"
#import <JSQMessages.h>
#import <JSQMessagesBubbleImageFactory.h>
#import <Masonry.h>
#import <Parse.h>
#import <SKPolygraph.h>
#import <TSMessages/TSMessageView.h>


@interface BBChatViewController () <MessageDelegate,ChatOccupantDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *friendTV;
@property (assign, nonatomic) BOOL menuShown;
@property (strong, nonatomic) MASConstraint *rightConstraint;
@property (strong, nonatomic) XMPPManager *xmppManager;
@property (strong, nonatomic) ChatDataManager *chatManager;
@property (strong, nonatomic) JSQMessagesAvatarImage *chatAvatar;
@property (assign, nonatomic) BOOL pushNotificationsSent;
@end

@implementation BBChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self userCurrentLocationCheck];
    [self setupFriendsTableViewMenu];
    [self setupChat];
    self.title = self.eventTitle;
    self.inputToolbar.contentView.leftBarButtonItem = nil;
}

#pragma mark - Setup

-(void)setupChat {
    self.senderDisplayName = [PFUser currentUser][@"name"];
    self.senderId = [PFUser currentUser][@"facebookId"];
    self.xmppManager = [XMPPManager sharedManager];
    self.chatManager = [ChatDataManager sharedManager];
    self.xmppManager.messageDelegate = self;
    self.xmppManager.chatOccupantDelegate = self;
}

-(void)checkIfNewRoom {
    if (self.roomID != self.xmppManager.currentRoomId) {
        [self.xmppManager.xmppRoom deactivate];
        [self.xmppManager joinOrCreateRoom:self.roomID];
    }
}

#pragma mark - View Controller Lifecycle

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkIfNewRoom];

    if (![self.chatManager.avatars objectForKey:[PFUser currentUser][@"facebookId"]]) {
        [self grabCurrentUserAvatar];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self finishReceivingMessageAnimated:NO];
}

#pragma mark - IBActions

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)showFriends:(UIBarButtonItem *)sender {
    if (!self.menuShown) {
        [UIView animateWithDuration:.6 animations:^{
            self.rightConstraint.offset(100.0);
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.friendTV reloadData];
            self.menuShown = YES;
        }];
    } else {
        [UIView animateWithDuration:.6 animations:^{
            self.rightConstraint.offset(0);
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.menuShown = NO;
        }];
    }
}

#pragma mark - Sending Message

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    BBMessage *message =[[BBMessage alloc] initWithText:text];
    [self.xmppManager sendMessage:message];
    [self finishSendingMessageAnimated:YES];
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.chatManager.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    BBMessage *message = [self.chatManager.messages objectAtIndex:indexPath.item];
    
    UIColor *messageBubbleColor = [self getMessageContentColor:message];
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    if ([message.senderId isEqualToString:self.senderId]) {
        return [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];;
    }
    
    return [bubbleFactory incomingMessagesBubbleImageWithColor:messageBubbleColor];
}

- (UIColor*)getMessageContentColor:(BBMessage*)message {
    float score = [[SKPolygraph sharedInstance] analyseSentiment:message.text];
    UIColor *color;
    if (score > 0){
        color = [UIColor jsq_messageBubbleGreenColor];
    }
    else if (score == 0){
        color = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:255.0f/255.0f alpha:1.0];
    }
    else {
        color = [UIColor jsq_messageBubbleRedColor];
    }
    return color;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
 
    JSQMessage *message = [self.chatManager.messages objectAtIndex:indexPath.item];
    
    if ([self.chatManager.avatars objectForKey:message.senderId]) {
        return [self.chatManager.avatars objectForKey:message.senderId];
    }
    return nil;
    
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.chatManager.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [self.chatManager.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.chatManager.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    NSArray *splitName = [message.senderDisplayName componentsSeparatedByString:@" "];
    NSString *formattedName = [NSString stringWithFormat:@"%@ %@.", splitName[0], [(NSString*)[splitName lastObject] substringToIndex:1]];
    
    NSAttributedString *attributedName = [[NSAttributedString alloc] initWithString:formattedName];
    return attributedName;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.chatManager.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *msg = [self.chatManager.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}


- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
   
    JSQMessage *currentMessage = [self.chatManager.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.chatManager.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

#pragma mark - XMPP Protocol Methods

- (void)newMessageReceived:(BBMessage *)messageContent {
    [self.chatManager.messages addObject:messageContent];
    [self finishReceivingMessageAnimated:YES];
}

- (void)currentUserConnectedToChatroom {
    NSLog(@"You have successfully connected to chat room: %@",self.roomID);
    [self grabAvatarsForUsersInChat];
    [self.chatManager.messages removeAllObjects];
    [self.collectionView reloadData];
}

- (void)newUserJoinedChatroom {
    NSLog(@"New user joined the chat room");
    [self grabAvatarsForUsersInChat];
}

#pragma mark - Facebook Profile Pictures

- (void)grabCurrentUserAvatar {
    [self.chatManager fetchUserProfilePictureWithFaceBookId:[PFUser currentUser][@"facebookId"] Completion:^(UIImage *profileImage) {
        [self setAvatarImage:profileImage User:[PFUser currentUser][@"facebookId"]];
    }];
}

- (void)grabAvatarsForUsersInChat {
    NSArray *currentOccupants =  [(XMPPRoomMemoryStorage *)self.xmppManager.xmppRoom.xmppRoomStorage occupants];
    
    for (XMPPRoomOccupantMemoryStorageObject *occupant in currentOccupants) {
        if (![self.chatManager.avatars objectForKey:occupant.nickname]) {
            [self.chatManager fetchUserProfilePictureWithFaceBookId:occupant.nickname Completion:^(UIImage *profileImage) {
                [self setAvatarImage:profileImage User:occupant.nickname];
            }];
        }
    }
    
    for (BBMessage *message in self.chatManager.messages) {
        if (![self.chatManager.avatars objectForKey:message.senderId]) {
            [self.chatManager fetchUserProfilePictureWithFaceBookId:message.senderId Completion:^(UIImage *profileImage) {
                [self setAvatarImage:profileImage User:message.senderId];
            }];
        }
    }
}

- (void)setAvatarImage:(UIImage *)image User:(NSString *)user {
    JSQMessagesAvatarImage *avatarImage = [JSQMessagesAvatarImageFactory
                                           avatarImageWithImage:image
                                           diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    self.chatManager.avatars[user] = avatarImage;
}

#pragma mark - Sending Push Notifications

- (void) sendPushNotificationToEventFriends:(NSArray *)eventUsers {

    NSSet *currentUserFriends = [NSSet setWithArray:[[[PFUser currentUser] valueForKeyPath:@"friends"] valueForKeyPath:@"id"]];
    
    for (PFUser *user in eventUsers) {
        if ([currentUserFriends containsObject: user[@"facebookId"]]) {
            NSLog(@"Your friend %@ is in the chat",user[@"name"]);
            NSString *pushNotification = [NSString stringWithFormat:@"Your friend %@ is currently at the event! Maybe you should meet up?", [PFUser currentUser][@"name"]];
            [PFPush sendPushMessageToChannelInBackground:user.objectId withMessage:pushNotification];

            Friend *friend = [[Friend alloc] initWithName:user[@"name"] FacebookId:user[@"facebookId"]];
            [self.chatManager fetchUserProfilePictureWithFaceBookId:friend.facebookId Completion:^(UIImage *profileImage) {
                friend.image = profileImage;
            }];
            [self.friendsAtEvent addObject:friend];
        }
    }
    
    if (self.friendsAtEvent.count > 0 && self.friendsAtEvent.count <= 2){
        for (Friend *friend in self.friendsAtEvent){
            [TSMessage showNotificationInViewController:self title:nil subtitle:[NSString stringWithFormat:@"Your friend %@ is currently at the event! Maybe you should meet up? ",friend.name]type:TSMessageNotificationTypeMessage duration:5 canBeDismissedByUser:YES];
        }
    }
    else if(self.friendsAtEvent.count > 3){
        [TSMessage showNotificationInViewController:self title:nil subtitle:[NSString stringWithFormat:@"%lu of your friends are also at the event!",(unsigned long)self.friendsAtEvent.count ]type:TSMessageNotificationTypeMessage duration:5 canBeDismissedByUser:YES];
    }
}


- (void)userCurrentLocationCheck {
    CLLocationDistance distance = [self.currentUserLocation distanceFromLocation:self.eventLocation];
    if (distance >= 50000.0) {
        [self currentUserOutsideOfBubble];
    } else {
        [self currentUserInsideOfBubble];
    }
}

- (void)currentUserOutsideOfBubble {
    if (![[PFUser currentUser][@"eventID"] isEqualToString:@""]) {
        PFUser *currentUser = [PFUser currentUser];
        currentUser[@"eventID"] = @"";
        [currentUser saveInBackground];
    }
}

- (void)currentUserInsideOfBubble {
    if (self.roomID != [PFUser currentUser][@"eventID"]) {
        PFUser *currentUser = [PFUser currentUser];
        currentUser[@"eventID"] = self.roomID;
        
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if (succeeded && !self.pushNotificationsSent) {
                self.pushNotificationsSent = YES;
                
                PFQuery *query = [PFUser query];
                [query whereKey:@"eventID" equalTo:self.roomID];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        [self sendPushNotificationToEventFriends:objects];
                    } else {
                        NSLog(@"Error fetching users in event");
                    }
                }];
            }
        }];
    }
}

#pragma mark - Friends Tableview Menu

- (void)setupFriendsTableViewMenu {
    self.friendsAtEvent = [[NSMutableArray alloc]init];
    self.friendTV = [[UITableView alloc] init];
    self.friendTV.backgroundColor = [UIColor clearColor];
    self.friendTV.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.friendTV.showsVerticalScrollIndicator = NO;
    self.friendTV.showsHorizontalScrollIndicator = NO;
    self.friendTV.delegate = self;
    self.friendTV.dataSource = self;
    self.friendTV.estimatedRowHeight = 200.0;
    self.friendTV.rowHeight = UITableViewAutomaticDimension;
    
    [self.view addSubview:self.friendTV];
    [self.friendTV mas_makeConstraints:^(MASConstraintMaker *make) {
        self.rightConstraint = make.right.equalTo(self.view.mas_left);
        make.top.equalTo(self.mas_topLayoutGuide);
        make.width.equalTo(@100);
        make.bottom.equalTo(self.inputToolbar.mas_top).offset(-1.0);
    }];
    
    [self setTranslucentBackground];
}

- (void) setTranslucentBackground {
    
    UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    
    [self.view insertSubview:view belowSubview:self.friendTV];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.friendTV);
        make.top.and.left.equalTo(self.friendTV);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friendsAtEvent.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Friend *friend = self.friendsAtEvent[indexPath.row];
    
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
    
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"FriendCell" bundle:nil] forCellReuseIdentifier:@"friendCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
    }
    cell.backgroundColor = [UIColor clearColor];
    
    cell.nameLabel.text = friend.name;
    cell.friendImageView.image = friend.image;
    cell.friendImageView.layer.cornerRadius = cell.friendImageView.frame.size.width / 2;
    cell.friendImageView.clipsToBounds = YES;
    
    return cell;
}


@end
