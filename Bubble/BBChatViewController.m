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
#include "SKPolygraph.h"

@interface BBChatViewController () <MessageDelegate>

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) XMPPManager *xmppManager;

@end

@implementation BBChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messages = [[NSMutableArray alloc] init];
    self.senderDisplayName = [PFUser currentUser][@"name"];
    self.senderId = [PFUser currentUser].objectId;
    self.xmppManager = [XMPPManager sharedManager];
    self.xmppManager.messageDelegate = self;
    self.title = self.eventTitle;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.xmppManager joinOrCreateRoom:self.roomID];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.xmppManager.xmppRoom deactivate];
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
//    [self.messages addObject:message];
    [self.xmppManager sendMessage:message];
    [self finishSendingMessageAnimated:YES];
    
}

- (void)didPressAccessoryButton:(UIButton *)sender {
    NSLog(@"Paperclip clicked");
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

        
        return [bubbleFactory outgoingMessagesBubbleImageWithColor:messageBubbleColor];;
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
        color = [UIColor jsq_messageBubbleLightGrayColor];
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
//    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
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
//    return [self.demoData.avatars objectForKey:message.senderId];
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


@end
