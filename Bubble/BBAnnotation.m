//
//  BBAnnotation.m
//  Bubble
//
//  Created by Jordan Guggenheim on 7/28/15.
//  Copyright (c) 2015 Bubble. All rights reserved.
//

#import "BBAnnotation.h"

@implementation BBAnnotation

-(NSString *)getEventImageName:(EventObject *)eventName{
    
    NSSet *sportsSet = [NSSet setWithObjects:@"animal_sports", @"baseball", @"basketball", @"boxing", @"european_soccer", @"extreme_sports", @"fighting", @"football", @"golf", @"hockey", @"horse_racing", @"international_soccer", @"lpga", @"minor_league",@"minor_league_baseball", @"mlb", @"mls", @"mma", @"nba", @"nba_dleague", @"ncaa_baseball", @"ncaa_basketball", @"ncaa_football", @"ncaa_hockey", @"ncaa_soccer", @"ncaa_womens_basketball", @"nfl", @"nhl", @"olympic_sports", @"pga", @"rodeo", @"soccer", @"sports", @"tennis", @"world_cup", @"wrestling", @"wwe", nil];
    
    NSSet *performingArtsSet = [NSSet setWithObjects:@"broadway_tickets_national",@"cirque_du_soleil",@"classical",@"classical_opera",@"    classical_orchestral_instrumental",@"comedy",@"dance_performance_tour", @"family", @"film",@"literary",@"theater", nil];
    
    NSSet *concertSet = [NSSet setWithObjects:@"concert",@"music_festival", nil];
    
    NSSet *autoRacingSet = [NSSet setWithObjects:@"auto_racing",@"f1",@"indycar",@"monster_truck",@"motorcross",@"nascar", @"    nascar_nationwide", @"nascar_sprintcup", nil];
    NSSet *meetup = [NSSet setWithObjects:@"meetup", nil];
    
    
    if([meetup containsObject:eventName.eventType]){
        return @"Meetup";
    }
    else if([sportsSet containsObject:eventName.eventType]){
        return @"Sports";
    }
    else if([performingArtsSet containsObject:eventName.eventType]){
        return @"PerformingArts";
    }
    else if([concertSet containsObject:eventName.eventType]){
        return @"Concert";
    }
    else if([autoRacingSet containsObject:eventName.eventType]){
        return @"Auto";
    }
    else {
        //need to add default image or get rid of this all together!
        return  @"Uncategorizedtype";
    }
    
}

@end
