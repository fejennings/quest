//
//  ACCCharacter.m
//  Quest
//
//  Created by Frank Jennings on 11/17/13.
//  Copyright (c) 2013 Acceltius. All rights reserved.
//

#import "ACCCharacter.h"
#import "Constants.h"

@interface ACCCharacter() {
    SKSpriteNode* character; // this will be the actual image you see of the character
    NSDictionary *characterData;
    BOOL useForCollisions;
    float collisionBodyCoversWhatPercent;
    unsigned char collisionBodyType; // 0 to 255
    unsigned char speed;
    unsigned char currentDirection;
}
@end

@implementation ACCCharacter

-(id) init {
    if (self = [super init]) {
        
        //do inititalization
        speed = 5;
        currentDirection=noDirection;
     }
    
    return self;
}

-(void)createWithDictionary:(NSDictionary *)charData {
    
    NSLog(@"Char in scene");
    
    characterData = [NSDictionary dictionaryWithDictionary:charData];
    character = [SKSpriteNode spriteNodeWithImageNamed:[characterData objectForKey:@"BaseFrame"]];
    
    self.zPosition = 100;
    self.name = @"character";
    
    self.position = CGPointFromString([characterData objectForKey:@"StartLocation"]);
    
    [self addChild:character];
    
    useForCollisions = [[characterData objectForKey:@"UseForCollisions"]  boolValue];
    
    
    if ( useForCollisions == YES) {
        [self setUpPhysics];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        self.xScale = .75;
        self.yScale = .75;
    }
    
    
}

-(void) setUpPhysics {
  
    collisionBodyCoversWhatPercent  = [[characterData objectForKey:@"CollisionBodyCoversWhatPercent"] floatValue];
    CGSize newSize = CGSizeMake( character.size.width *collisionBodyCoversWhatPercent  , character.frame.size.height * collisionBodyCoversWhatPercent);
    
    if ([[ characterData objectForKey:@"CollisionBodyType"] isEqualToString:@"square" ]) {
        collisionBodyType = squareType;
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:newSize];
    } else {
        collisionBodyType = circleType;
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:newSize.width/2];
     }
    
    if ( [[characterData objectForKey:@"DebugBody"]boolValue] == YES) {
        CGRect rect = CGRectMake(-(newSize.width/2), -(newSize.height/2), newSize.width, newSize.height);
        [self debugPath:rect bodyType:collisionBodyType];
    }

    self.physicsBody.dynamic = YES;
    self.physicsBody.restitution = 0.2;
    self.physicsBody.allowsRotation = NO;
    
    self.physicsBody.categoryBitMask = playerCategory;
    self.physicsBody.collisionBitMask = wallCategory | playerCategory;
    self.physicsBody.contactTestBitMask = wallCategory | playerCategory; // sepearate other characters with pipe | playerCategory
    
    
}



-(void) debugPath:(CGRect)theRect bodyType:(int)type {
    
    SKShapeNode *pathShape= [[SKShapeNode alloc] init];
    
    CGPathRef thePath;
    if (type == squareType) {
        
        thePath = CGPathCreateWithRect(theRect, NULL);
    } else {
        CGRect adjustedRect = CGRectMake(theRect.origin.x, theRect.origin.y, theRect.size.width, theRect.size.width);
        
        thePath = CGPathCreateWithEllipseInRect(adjustedRect, NULL);
    }
    
    pathShape.path = thePath;
    
    pathShape.lineWidth = 1;
    pathShape.strokeColor = [SKColor greenColor];
    pathShape.position = CGPointMake(0,0);
    
    [self addChild:pathShape];
    pathShape.zPosition = 1000;
    
    
}


#pragma mark Update

-(void) update  {
    //NSLog(@"Update called on character");
    switch (currentDirection) {
        case up:
            self.position = CGPointMake(self.position.x,self.position.y + speed);
            
            if (self.position.x<_idealX && _theLeader == NO){
                self.position = CGPointMake(self.position.x+1,self.position.y);
            } else if (self.position.x>_idealX && _theLeader == NO){
                self.position = CGPointMake(self.position.x-1,self.position.y);
            }

            break;
        case down:
            self.position = CGPointMake(self.position.x,self.position.y - speed);
            
            if (self.position.x<_idealX && _theLeader == NO){
                self.position = CGPointMake(self.position.x+1,self.position.y);
            } else if (self.position.x>_idealX && _theLeader == NO){
                self.position = CGPointMake(self.position.x-1,self.position.y);
            }
           
            break;
        case left:
            self.position = CGPointMake(self.position.x-speed ,self.position.y);
            
            if (self.position.y<_idealY && _theLeader == NO){
                self.position = CGPointMake(self.position.x,self.position.y+1);
            } else if (self.position.y>_idealY && _theLeader == NO){
                self.position = CGPointMake(self.position.x,self.position.y-1);
            }
            
            break;
        case right:
            self.position = CGPointMake(self.position.x+ speed,self.position.y );
            
            if (self.position.y<_idealY && _theLeader == NO){
                self.position = CGPointMake(self.position.x,self.position.y+1);
            } else if (self.position.y>_idealY && _theLeader == NO){
                self.position = CGPointMake(self.position.x,self.position.y-1);
            }
            
            break;
        case noDirection:
            //do something if you have to
            
            break;
        
        default:
            break;
    }
    
    
}

#pragma mark Handle Movement

CGFloat degreesToRadians(CGFloat degrees) {
    return degrees *M_PI / 180;
}
CGFloat radiansToDegrees(CGFloat radians) {
    return radians *180 / M_PI;
}

-(void)moveLeftWithPlace:(NSNumber*) place {
    character.zRotation = degreesToRadians(-90);
    currentDirection=left;
}
-(void)moveRightWithPlace:(NSNumber*) place{
    character.zRotation = degreesToRadians(90);
    currentDirection=right;
}
-(void)moveUpWithPlace:(NSNumber*) place{
    character.zRotation = degreesToRadians(180);
    currentDirection=up;
}
-(void)moveDownWithPlace:(NSNumber*) place{
    character.zRotation = degreesToRadians(0);
    currentDirection=down;
}

#pragma mark Leader Stuff

-(void) makeLeader {
    
    _theLeader = YES;
}

@end
