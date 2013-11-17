//
//  ACCLevel.m
//  Quest
//
//  Created by Frank Jennings on 11/17/13.
//  Copyright (c) 2013 Acceltius. All rights reserved.
//

#import "ACCLevel.h"
#import "Constants.h"
#import "ACCCharacter.h"

@interface ACCLevel () {
    
    SKNode* myWorld;
    ACCCharacter* leader;

}



@end
@implementation ACCLevel

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        
        myLabel.text = @"Hello, Level";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        
        [self addChild:myLabel];
         */
        [self setUpScene];
        [self performSelector:@selector(setUpCharacters) withObject:nil afterDelay:4.0];
    }
    return self;
}

-(void) didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *firstBody, *secondBody;
    
    firstBody = contact.bodyA;
    secondBody = contact.bodyB;
    
    if(firstBody.categoryBitMask == wallCategory || secondBody.categoryBitMask == wallCategory) {
        
        NSLog(@"Someone hit the wall");
    }
}


-(void) setUpCharacters {
    NSLog(@"setup characters");
    
    leader = [ACCCharacter node];
    [myWorld addChild:leader];
    
    
}

-(void)didSimulatePhysics
{
    
    [self centerOnNode: leader];
}

-(void) centerOnNode: (SKNode *) node
{
    
    CGPoint cameraPositionInSchene = [node.scene convertPoint:node.position fromNode:node.parent];
    node.parent.position = CGPointMake(node.parent.position.x - cameraPositionInSchene.x,node.parent.position.y - cameraPositionInSchene.y);
    
}

-(void) setUpScene {
    //take care of setting up the world and bring in property file
    
    self.anchorPoint = CGPointMake(0.5, 0.5); // 0/0 to 1.0
    myWorld = [SKNode node];
    [self addChild:myWorld];
    
    SKSpriteNode* map = [SKSpriteNode spriteNodeWithImageNamed:@"level_map1"];
    map.position = CGPointMake(0, 0);
    [myWorld addChild:map];
    
    //Setup Physics Workd
    self.physicsWorld.gravity = CGVectorMake(0.5, -0.9);
    self.physicsWorld.contactDelegate = self;
    
    myWorld.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:map.frame];
    myWorld.physicsBody.categoryBitMask = wallCategory;

    


}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
