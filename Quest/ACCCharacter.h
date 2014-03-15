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
@property (nonatomic, assign) BOOL followingEnabled;
@property (nonatomic, assign) float currentHealth;
@property (nonatomic, assign) float maxHealth;
@property (nonatomic, assign) BOOL  hasOwnHealth;


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
-(void)followIntoPositionWithDirection:(int)direction andPlaceInLine:(int)place leaderLocation:(CGPoint)location;
-(void)attack;
-(void)rest:(int)direction andPlaceInLine:(int)place leaderLocation:(CGPoint)location;
-(void) doDamageWithAmount:(float)amount;
-(void) removeLeader;


@end

