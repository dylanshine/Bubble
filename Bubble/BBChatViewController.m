//
//  BBChatViewController.m
//  Bubble
//
//  Created by Lukas Thoms on 7/30/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "BBChatViewController.h"
#import "BBMessage.h"
#import <JSQMessages.h>
#import <JSQMessagesBubbleImageFactory.h>
#import <Parse.h>
#import "XMPPManager.h"
#import <Masonry.h>
#import <SKPolygraph.h>
#import <AFNetworking.h>
#import <TSMessages/TSMessageView.h>


@interface BBChatViewController () <MessageDelegate,ChatOccupantDelegate>

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableDictionary *avatars;
@property (strong, nonatomic) XMPPManager *xmppManager;
@property (strong, nonatomic) JSQMessagesAvatarImage *chatAvatar;
@property (assign, nonatomic) INTULocationRequestID locationRequestID;
@property (nonatomic) BOOL pushNotificationsSent;

@end

@implementation BBChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messages = [[NSMutableArray alloc] init];
    self.avatars = [[NSMutableDictionary alloc] init];
    self.senderDisplayName = [PFUser currentUser][@"name"];
    self.senderId = [PFUser currentUser][@"facebookId"];
    self.xmppManager = [XMPPManager sharedManager];
    self.xmppManager.messageDelegate = self;
    self.xmppManager.chatOccupantDelegate = self;
    self.title = self.eventTitle;
    self.inputToolbar.hidden = YES;
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    self.friendsAtEvent = [[NSMutableArray alloc]init];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.roomID != self.xmppManager.currentRoomId) {
        [self.xmppManager.xmppRoom deactivate];
        [self.xmppManager joinOrCreateRoom:self.roomID];
    }
    
    if (![self.avatars objectForKey:[PFUser currentUser][@"facebookId"]]) {
        [self grabCurrentUserAvatar];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self finishReceivingMessageAnimated:NO];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    
    BBMessage *message =[[BBMessage alloc] initWithText:text];
    [self.xmppManager sendMessage:message];
    [self finishSendingMessageAnimated:YES];
    
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BBMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    UIColor *messageBubbleColor = [self getMessageContentColor:message];
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    if ([message.senderId isEqualToString:self.senderId]) {
        return [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];;
    }
    
    return [bubbleFactory incomingMessagesBubbleImageWithColor:messageBubbleColor];
}

-(UIColor*)getMessageContentColor:(BBMessage*)message{
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

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     //     */
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    //
    //    if ([message.senderId isEqualToString:self.senderId]) {
    //        if (![NSUserDefaults outgoingAvatarSetting]) {
    //            return nil;
    //        }
    //    }
    //    else {
    //        if (![NSUserDefaults incomingAvatarSetting]) {
    //            return nil;
    //        }
    //    }
    //
    //
    if ([self.avatars objectForKey:message.senderId]) {
        return [self.avatars objectForKey:message.senderId];
    }
    return nil;
    
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    
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

- (void)newMessageReceived:(BBMessage *)messageContent {
    [self.messages addObject:messageContent];
    [self finishReceivingMessageAnimated:YES];
}

-(void)grabCurrentUserAvatar {
    [self fetchUserProfilePictureWithFaceBookId:[PFUser currentUser][@"facebookId"] Completion:^(JSQMessagesAvatarImage *avatarImage) {
        self.avatars[[PFUser currentUser][@"facebookId"]] = avatarImage;
    }];
}

-(void)grabAvatarsForUsersInChat {
    NSArray *currentOccupants =  [(XMPPRoomMemoryStorage *)self.xmppManager.xmppRoom.xmppRoomStorage occupants];
    
    for (XMPPRoomOccupantMemoryStorageObject *occupant in currentOccupants) {
        if (![self.avatars objectForKey:occupant.nickname]) {
            [self fetchUserProfilePictureWithFaceBookId:occupant.nickname Completion:^(JSQMessagesAvatarImage *avatarImage) {
                self.avatars[occupant.nickname] = avatarImage;
            }];
        }
    }
}

-(void)currentUserConnectedToChatroom {
    NSLog(@"You have successfully connected to chat room: %@",self.roomID);
    [self grabAvatarsForUsersInChat];
    [self startLocationUpdateSubscription];
}

- (void) sendPushNotificationToEventFriends:(NSArray *)eventUsers {

    NSSet *currentUserFriends = [NSSet setWithArray:[[[PFUser currentUser] valueForKeyPath:@"friends"] valueForKeyPath:@"id"]];
    
    for (PFUser *user in eventUsers) {
        if ([currentUserFriends containsObject: user[@"facebookId"]]) {
            NSLog(@"Your friend %@ is in the chat",user[@"name"]);
            NSString *pushNotification = [NSString stringWithFormat:@"Your friend %@ is currently at the event! Maybe you should meet up?", [PFUser currentUser][@"name"]];
            [PFPush sendPushMessageToChannelInBackground:user.objectId withMessage:pushNotification];
            // send user a local push notification
            [self.friendsAtEvent addObject:user[@"name"]];
        }
    }
    if (self.friendsAtEvent.count > 0 && self.friendsAtEvent.count <= 2){
        for (NSString *friend in self.friendsAtEvent){
            [TSMessage showNotificationInViewController:self title:nil subtitle:[NSString stringWithFormat:@"Your friend %@ is currently at the event! Maybe you should meet up? ",friend ]type:TSMessageNotificationTypeMessage duration:5 canBeDismissedByUser:YES];
        }
    }
    else if(self.friendsAtEvent.count > 3){
        [TSMessage showNotificationInViewController:self title:nil subtitle:[NSString stringWithFormat:@"%lu of your friends are also at the event!",(unsigned long)self.friendsAtEvent.count ]type:TSMessageNotificationTypeMessage duration:5 canBeDismissedByUser:YES];
    }
}

-(void)newUserJoinedChatroom {
    NSLog(@"New user joined the chat room");
    [self grabAvatarsForUsersInChat];
}


-(void)fetchUserProfilePictureWithFaceBookId:(NSString *)fbID Completion:(void (^)(JSQMessagesAvatarImage *avatarImage))block{
    if (![fbID isEqualToString:@""]) {
        
        NSString *url = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", fbID];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFImageResponseSerializer serializer];
        [manager GET:url parameters:nil
         
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 
                 JSQMessagesAvatarImage *avatarImage = [JSQMessagesAvatarImageFactory
                                                        avatarImageWithImage:responseObject
                                                        diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
                 block(avatarImage);
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 
                 // Need to add placeholder image on failure
                 
                 NSLog(@"Error: %@", error);
                 
             }];
    }
}

- (void)startLocationUpdateSubscription {
    __weak __typeof(self) weakSelf = self;
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    self.locationRequestID = [locMgr subscribeToLocationUpdatesWithBlock:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        __typeof(weakSelf) strongSelf = weakSelf;
        
        if (status == INTULocationStatusSuccess) {
            CLLocationDistance distance = [currentLocation distanceFromLocation:strongSelf.eventLocation];
            if (distance >= 400.0) {
                [strongSelf currentUserOutsideOfBubble];
            } else {
                [strongSelf currentUserInsideOfBubble];
            }
        } else {
            strongSelf.locationRequestID = NSNotFound;
        }
    }];
}

-(void)currentUserOutsideOfBubble {
    self.inputToolbar.hidden = YES;
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"eventID"] = @"";
    [currentUser saveInBackground];
}

-(void)currentUserInsideOfBubble {
    self.inputToolbar.hidden = NO;
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

@end
