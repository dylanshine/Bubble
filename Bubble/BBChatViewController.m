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
#import "ChatDataManager.h"
#import <Masonry.h>
#import <SKPolygraph.h>
#import <TSMessages/TSMessageView.h>


@interface BBChatViewController () <MessageDelegate,ChatOccupantDelegate>

@property (strong, nonatomic) XMPPManager *xmppManager;
@property (strong, nonatomic) ChatDataManager *chatManager;
@property (strong, nonatomic) JSQMessagesAvatarImage *chatAvatar;
@property (nonatomic) BOOL pushNotificationsSent;

@end

@implementation BBChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self userCurrentLocationCheck];
    self.senderDisplayName = [PFUser currentUser][@"name"];
    self.senderId = [PFUser currentUser][@"facebookId"];
    self.xmppManager = [XMPPManager sharedManager];
    self.chatManager = [ChatDataManager sharedManager];
    self.xmppManager.messageDelegate = self;
    self.xmppManager.chatOccupantDelegate = self;
    self.title = self.eventTitle;
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    self.friendsAtEvent = [[NSMutableArray alloc]init];
    
}

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
    return [self.chatManager.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BBMessage *message = [self.chatManager.messages objectAtIndex:indexPath.item];
    
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
    JSQMessage *message = [self.chatManager.messages objectAtIndex:indexPath.item];
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
    if ([self.chatManager.avatars objectForKey:message.senderId]) {
        return [self.chatManager.avatars objectForKey:message.senderId];
    }
    return nil;
    
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.chatManager.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
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

//- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//{
//    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
//    
//    /**
//     *  iOS7-style sender name labels
//     */
//    if ([message.senderId isEqualToString:self.senderId]) {
//        return nil;
//    }
//    
//    if (indexPath.item - 1 > 0) {
//        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
//        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
//            return nil;
//        }
//    }
//    
//    /**
//     *  Don't specify attributes to use the defaults.
//     */
//    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
//}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.chatManager.messages count];
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
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}


- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
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

- (void)newMessageReceived:(BBMessage *)messageContent {
    [self.chatManager.messages addObject:messageContent];
    [self finishReceivingMessageAnimated:YES];
}

-(void)grabCurrentUserAvatar {
    [self.chatManager fetchUserProfilePictureWithFaceBookId:[PFUser currentUser][@"facebookId"] Completion:^(UIImage *profileImage) {
        [self setAvatarImage:profileImage User:[PFUser currentUser][@"facebookId"]];
    }];
}

-(void)grabAvatarsForUsersInChat {
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

-(void)setAvatarImage:(UIImage *)image User:(NSString *)user {
    JSQMessagesAvatarImage *avatarImage = [JSQMessagesAvatarImageFactory
                                           avatarImageWithImage:image
                                           diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    self.chatManager.avatars[user] = avatarImage;
}

-(void)currentUserConnectedToChatroom {
    NSLog(@"You have successfully connected to chat room: %@",self.roomID);
    [self grabAvatarsForUsersInChat];
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

-(void)userCurrentLocationCheck {
    CLLocationDistance distance = [self.currentUserLocation distanceFromLocation:self.eventLocation];
    if (distance >= 5000.0) {
        [self currentUserOutsideOfBubble];
    } else {
        [self currentUserInsideOfBubble];
    }
}

-(void)currentUserOutsideOfBubble {
    if (![[PFUser currentUser][@"eventID"] isEqualToString:@""]) {
        PFUser *currentUser = [PFUser currentUser];
        currentUser[@"eventID"] = @"";
        [currentUser saveInBackground];
    }
}

-(void)currentUserInsideOfBubble {
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

-(void)checkIfNewRoom {
    if (self.roomID != self.xmppManager.currentRoomId) {
        [self.xmppManager.xmppRoom deactivate];
        [self.xmppManager joinOrCreateRoom:self.roomID];
    }
}

@end
