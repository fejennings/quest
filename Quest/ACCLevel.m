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
    
    int currentLevel;
    
    SKNode* myWorld;
    ACCCharacter* leader;
    
    NSArray *characterArray;
    
    UISwipeGestureRecognizer* swipeGestureLeft;
    UISwipeGestureRecognizer* swipeGestureRight;
    UISwipeGestureRecognizer* swipeGestureUp;
    UISwipeGestureRecognizer* swipeGestureDown;
    UITapGestureRecognizer* tapOnce;
    UITapGestureRecognizer* twoFingerTap;
    UITapGestureRecognizer* threeFingerTap;
    UIRotationGestureRecognizer* rotationGR;
    
    unsigned char charactersInWorld;

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
        
        currentLevel = 0; // later on will create a singleton to hold game data that is independent of the class
        charactersInWorld = 0;
        [self setUpScene];
        [self performSelector:@selector(setUpCharacters) withObject:nil afterDelay:2.0];
        //[self performSelector:@selector(pauseScene) withObject:nil afterDelay:4.0];
        //[self performSelector:@selector(unPauseScene) withObject:nil afterDelay:6.0];
    }
    return self;
}

-(void) pauseScene {
    
    self.paused = YES;
    
}
-(void) unPauseScene {
    
    self.paused = NO;
    
}

#pragma mark Update

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    //NSLog(@" %F",currentTime);
    //0.0333359 seconds between updates   30 fps.
    
    [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
        // do something if we find a character in myWorld
        ACCCharacter* character = (ACCCharacter*)node;
        
        if (self.paused ==NO) {
            if (character==leader) {
                //do something later
            } else {
                character.idealX = leader.position.x;
                character.idealY = leader.position.y;
            }
            
            [character update];
        }
    }];

}



#pragma mark Contact Listner
-(void) didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *firstBody, *secondBody;
    
    firstBody = contact.bodyA;
    secondBody = contact.bodyB;
    
    if(firstBody.categoryBitMask == wallCategory || secondBody.categoryBitMask == wallCategory) {
        
        NSLog(@"Someone hit the wall");
    }
}




#pragma mark Gestures

-(void) didMoveToView:(SKView *)view {
    
    NSLog(@"Scene Moved To View");
    
    swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    [swipeGestureLeft setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [view addGestureRecognizer:swipeGestureLeft];
    
    swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    [swipeGestureRight setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [view addGestureRecognizer:swipeGestureRight];
    
    swipeGestureUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUp:)];
    [swipeGestureUp setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [view addGestureRecognizer:swipeGestureUp];
    
    swipeGestureDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDown:)];
    [swipeGestureDown setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [view addGestureRecognizer:swipeGestureDown];
    
    tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnce:)];
    tapOnce.numberOfTapsRequired = 1;
    tapOnce.numberOfTouchesRequired = 1;
    [view addGestureRecognizer:tapOnce];
    
    twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapToSwitchToSecond:)];
    twoFingerTap.numberOfTapsRequired = 1;
    twoFingerTap.numberOfTouchesRequired = 2;
    [view addGestureRecognizer:twoFingerTap];
    
    threeFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapToSwitchToThird:)];
    threeFingerTap.numberOfTapsRequired = 1;
    threeFingerTap.numberOfTouchesRequired = 3;
    [view addGestureRecognizer:threeFingerTap];
    
    rotationGR = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    [view addGestureRecognizer:rotationGR];
    
    

}

-(void) handleSwipeLeft:(UISwipeGestureRecognizer *) recognizer {
    NSLog(@"Left");
    __block unsigned char place=0;
    [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
        // do something if we find a character in myWorld
        ACCCharacter* character = (ACCCharacter*)node;
        
        if (self.paused ==NO) {
            if (character==leader) {
                [character moveLeftWithPlace:[NSNumber numberWithInt:0]];
            } else {
                [character performSelector:@selector(moveLeftWithPlace:) withObject:[NSNumber numberWithInt:place] afterDelay:(place*0.25)];
//                [character moveLeftWithPlace:[NSNumber numberWithInt:place]];
            }
        }
        ++place;
    }];
}

-(void) handleSwipeRight:(UISwipeGestureRecognizer *) recognizer {
    NSLog(@"Right");
    __block unsigned char place=0;
    [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
        // do something if we find a character in myWorld
        ACCCharacter* character = (ACCCharacter*)node;
        
        if (self.paused ==NO) {
            if (character==leader) {
                [character moveRightWithPlace:[NSNumber numberWithInt:0]];
            } else {
                [character performSelector:@selector(moveRightWithPlace:) withObject:[NSNumber numberWithInt:place] afterDelay:(place*0.25)];
//                [character moveRightWithPlace:[NSNumber numberWithInt:place]];
            }
        }
        ++place;
    }];
}

-(void) handleSwipeUp:(UISwipeGestureRecognizer *) recognizer {
    NSLog(@"Up");
    __block unsigned char place=0;
    [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
        // do something if we find a character in myWorld
        ACCCharacter* character = (ACCCharacter*)node;
        
        if (self.paused ==NO) {
            if (character==leader) {
                [character moveUpWithPlace:[NSNumber numberWithInt:0]];
            } else {
                [character performSelector:@selector(moveUpWithPlace:) withObject:[NSNumber numberWithInt:place] afterDelay:(place*0.25)];
//                [character moveUpWithPlace:[NSNumber numberWithInt:place]];
            }
        }
        ++place;
    }];
}

-(void) handleSwipeDown:(UISwipeGestureRecognizer *) recognizer {
    NSLog(@"Down");
    __block unsigned char place=0;
    [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
        // do something if we find a character in myWorld
        ACCCharacter* character = (ACCCharacter*)node;
        
        if (self.paused ==NO) {
            if (character==leader) {
                [character moveDownWithPlace:[NSNumber numberWithInt:0]];
            } else {
                [character performSelector:@selector(moveDownWithPlace:) withObject:[NSNumber numberWithInt:place] afterDelay:(place*0.25)];
//                [character moveDownWithPlace:[NSNumber numberWithInt:place]];
            }
        }
        ++place;
    }];
}

-(void) tappedOnce:(UISwipeGestureRecognizer *) recognizer {
    NSLog(@"One Tap");
}

-(void) tapToSwitchToSecond:(UISwipeGestureRecognizer *) recognizer {
    NSLog(@"Two Taps");
}

-(void) tapToSwitchToThird:(UISwipeGestureRecognizer *) recognizer {
    NSLog(@"Three Taps");
}

-(void) handleRotation:(UIRotationGestureRecognizer *) recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Rotation Ended");
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Rotation Began");
    }
}

-(void)willMoveFromView:(SKView *)view {
    
    NSLog(@"Scene Removed From View");
    
    [view removeGestureRecognizer:swipeGestureLeft];
    [view removeGestureRecognizer:swipeGestureRight];
    [view removeGestureRecognizer:swipeGestureUp];
    [view removeGestureRecognizer:swipeGestureDown];
    [view removeGestureRecognizer:tapOnce];
    [view removeGestureRecognizer:twoFingerTap];
    [view removeGestureRecognizer:threeFingerTap];
    [view removeGestureRecognizer:rotationGR];
    
}

#pragma mark Camera Centering
-(void)didSimulatePhysics
{
    
    [self centerOnNode: leader];
}

-(void) centerOnNode: (SKNode *) node
{
    
    CGPoint cameraPositionInSchene = [node.scene convertPoint:node.position fromNode:node.parent];
    node.parent.position = CGPointMake(node.parent.position.x - cameraPositionInSchene.x,node.parent.position.y - cameraPositionInSchene.y);
    
}

#pragma mark Setup Scene

-(void) setUpScene {
    //take care of setting up the world and bring in property file
    
    NSString *path = [[ NSBundle mainBundle] bundlePath];
    NSString *finalpath = [ path stringByAppendingPathComponent:@"GameData.plist"];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:finalpath];
    //NSLog(@"The Property List conatins: %@", plistData);
    
    NSMutableArray *levelArray = [NSMutableArray arrayWithArray:[plistData objectForKey:@"Levels"] ];
    NSDictionary *levelDict = [NSDictionary dictionaryWithDictionary:[levelArray objectAtIndex:currentLevel]];
    characterArray = [NSArray arrayWithArray:[levelDict objectForKey:@"Characters"]];
    
   // NSLog(@"The Property List contains: %@",characterArray);
    
    self.anchorPoint = CGPointMake(0.5, 0.5); // 0/0 to 1.0
    myWorld = [SKNode node];
    [self addChild:myWorld];
    
    SKSpriteNode* map = [SKSpriteNode spriteNodeWithImageNamed:[levelDict objectForKey:@"Background"]];
    map.position = CGPointMake(0, 0);
    [myWorld addChild:map];
    
    //Setup Physics Workd
    
    
    float shrinkage = [[levelDict objectForKey:@"ShrinkBackgroundBoundaryBy"]floatValue];
    
    int offsetX = (map.frame.size.width - (map.frame.size.width*shrinkage))/2;
    int offsetY = (map.frame.size.height - (map.frame.size.height*shrinkage))/2;
    CGRect mapWithSmallerRect = CGRectMake(map.frame.origin.x+offsetX, map.frame.origin.y+offsetY, map.frame.size.width*shrinkage, map.frame.size.height*shrinkage);
    
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    self.physicsWorld.contactDelegate = self;
    
    myWorld.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:mapWithSmallerRect];
    myWorld.physicsBody.categoryBitMask = wallCategory;

    if ( [[levelDict objectForKey:@"DebugBorder"] boolValue] == YES ) {
        [self debugPath:mapWithSmallerRect];
    }


}

#pragma mark Setup Characters

-(void) setUpCharacters {
    NSLog(@"setup leader");
    
    leader = [ACCCharacter node];
    [leader createWithDictionary:[characterArray objectAtIndex:0]];
    [leader makeLeader];
    
    [myWorld addChild:leader];
    
    int c = 1;
    while (c<[characterArray count]) {
        [self performSelector:@selector(createAnotherCharacter) withObject:Nil afterDelay:(0.5*c) ];
        c++;
    }
    
    
}

-(void) createAnotherCharacter {
    
    ++charactersInWorld ;
    NSLog(@"setup another characters");
    
    ACCCharacter *character = [ACCCharacter node];
    [character createWithDictionary:[characterArray objectAtIndex:charactersInWorld]];
    
    [myWorld addChild:character];
    character.zPosition = character.zPosition - charactersInWorld;

}

-(void) debugPath:(CGRect)theRect  {
 
    SKShapeNode *pathShape= [[SKShapeNode alloc] init];
    CGPathRef thePath = CGPathCreateWithRect(theRect, NULL);
    pathShape.path = thePath;
    
    pathShape.lineWidth = 1;
    pathShape.strokeColor = [SKColor greenColor];
    pathShape.position = CGPointMake(0,0);
    
    [myWorld addChild:pathShape];
    pathShape.zPosition = 1000;
    
    
}


@end
