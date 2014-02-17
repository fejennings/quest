//
//  ACCCharacter.h
//  Quest
//
//  Created by Frank Jennings on 11/17/13.
//  Copyright (c) 2013 Acceltius. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


@interface ACCCharacter : SKNode

@property (nonatomic, assign) int idealX;
@property (nonatomic, assign) int idealY;
@property (nonatomic, assign) BOOL theLeader;


-(void)createWithDictionary: (NSDictionary*) charData;
-(void)update;
-(void)moveLeftWithPlace:(NSNumber*) place;
-(void)moveRightWithPlace:(NSNumber*) place;
-(void)moveUpWithPlace:(NSNumber*) place;
-(void)moveDownWithPlace:(NSNumber*) place;
-(void)makeLeader;
-(int)returnDirection;
-(void)stopMoving;
-(void)stopInFormation:(int)direction andPlaceInLine:(int)place leaderLocation:(CGPoint)location;


@end

