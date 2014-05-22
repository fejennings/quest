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
#import "ACCStartMenu.h"
#import "ACCCoins.h"
#import "ACCWalls.h"

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
    UITapGestureRecognizer* doubleTap;
    NSNumber* maxFollowers;
    
    unsigned char charactersInWorld;
    
    float followDelay;
    float levelBorderCausesDamageBy;
    bool useDelayedFollow;
    BOOL gameHasBegun;

}



@end
@implementation ACCLevel

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {

        
        currentLevel = 0; // later on will create a singleton to hold game data that is independent of the class
        charactersInWorld = 0;
        gameHasBegun = NO;
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
    
    __block BOOL anyNonLeaderFoundInPLay = NO;
    __block BOOL leaderFound = NO;
    
    [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
        // do something if we find a character in myWorld
        ACCCharacter* character = (ACCCharacter*)node;
        
        if (self.paused ==NO) {
            if (character==leader) {
                if (leader.isDying==NO) {
                        leaderFound = YES;
                }
                //do something later
            } else {
                if (character.followingEnabled == YES) {
                    anyNonLeaderFoundInPLay = YES;
                    character.idealX = leader.position.x;
                    character.idealY = leader.position.y;
                }
            }
            
            [character update];
        }
    }];
    //outside of enumeration block we test for a leader or a follower
    
    if (leaderFound == NO && gameHasBegun == YES) {
        
        
        if (anyNonLeaderFoundInPLay==YES) {
            NSLog(@"assigning new leader");
            [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
                ACCCharacter* character = (ACCCharacter*)node;
              
                if (character.followingEnabled==YES) {
                    leader=character;
                    [leader makeLeader];
// maybe do not reinsert leader  character is already in myWorld
                    [myWorld insertChild:leader atIndex:0];
                }
                
            }];
        } else {
            NSLog((@"Game Over"));
            gameHasBegun = NO;
            [self gameOver];
        }
        
        
    }

}



#pragma mark Contact Listner
-(void) didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *firstBody, *secondBody;
    
    firstBody = contact.bodyA;
    secondBody = contact.bodyB;
    
    if(firstBody.categoryBitMask == wallCategory || secondBody.categoryBitMask == wallCategory) {
        
        NSLog(@"Someone hit the wall");
        if (firstBody.categoryBitMask == playerCategory) {
            ACCCharacter* character = (ACCCharacter*) firstBody.node;
            [self stopAllPlayersFromCollision:character];
            [character doDamageWithAmount:levelBorderCausesDamageBy];
            
        } else if (secondBody.categoryBitMask == playerCategory) {
            ACCCharacter* character = (ACCCharacter*) secondBody.node;
            [self stopAllPlayersFromCollision:character];
            [character doDamageWithAmount:levelBorderCausesDamageBy];
          
        }

    }
    
    if(firstBody.categoryBitMask == obstacleCategory || secondBody.categoryBitMask == obstacleCategory) {
        
        NSLog(@"Someone hit an obstacle");
        if (firstBody.categoryBitMask == playerCategory) {
            ACCCharacter* character = (ACCCharacter*) firstBody.node;
            [self stopAllPlayersFromCollision:character];
            [character doDamageWithAmount:levelBorderCausesDamageBy];
            
        } else if (secondBody.categoryBitMask == playerCategory) {
            ACCCharacter* character = (ACCCharacter*) secondBody.node;
            [self stopAllPlayersFromCollision:character];
            [character doDamageWithAmount:levelBorderCausesDamageBy];
            
        }
        
    }

    
    if(firstBody.categoryBitMask == coinCategory || secondBody.categoryBitMask == coinCategory) {
        
        NSLog(@"Someone got a coin");
        if (firstBody.categoryBitMask == coinCategory) {
            ACCCoins* coin = (ACCCoins*) firstBody.node;
            [coin removeFromParent];
            
        } else if (secondBody.categoryBitMask == coinCategory) {
            ACCCoins* coin = (ACCCoins*) secondBody.node;
            [coin removeFromParent];
            
        }
        
    }

    if(firstBody.categoryBitMask == playerCategory && secondBody.categoryBitMask == playerCategory) {
        
        ACCCharacter* character1 = (ACCCharacter*) firstBody.node;
        ACCCharacter* character2 = (ACCCharacter*) secondBody.node;
        
        if (character1 == leader) {
            if (character2.followingEnabled == NO) {
                character2.followingEnabled = YES;
                [character2 followIntoPositionWithDirection:[leader returnDirection] andPlaceInLine:1 leaderLocation:leader.position];
            }
            
        } else if (character2 == leader) {
            
            if (character1.followingEnabled == NO) {
                character1.followingEnabled = YES;
                [character1 followIntoPositionWithDirection:[leader returnDirection] andPlaceInLine:1 leaderLocation:leader.position];
            }
           
        }
        
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
    
    doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [view addGestureRecognizer:doubleTap];
    [tapOnce requireGestureRecognizerToFail:doubleTap];

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
        int prevState = character.charState;
        gameHasBegun = YES;
        if (self.paused ==NO) {
            character.charState = isMoving;
            if (character==leader) {
                [character moveLeftWithPlace:[NSNumber numberWithInt:0]];
            } else {
                place ++;

                [character performSelector:@selector(moveLeftWithPlace:) withObject:[NSNumber numberWithInt:place] afterDelay:((prevState!=isStopped)*followDelay)];
            }
        }
    }];
}

-(void) handleSwipeRight:(UISwipeGestureRecognizer *) recognizer {
    NSLog(@"Right");
    __block unsigned char place=0;
    [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
        // do something if we find a character in myWorld
        ACCCharacter* character = (ACCCharacter*)node;
        int prevState = character.charState;
        gameHasBegun = YES;
        
        if (self.paused ==NO) {
            character.charState = isMoving;
            if (character==leader) {
                [character moveRightWithPlace:[NSNumber numberWithInt:0]];
            } else {
                place ++;

                [character performSelector:@selector(moveRightWithPlace:) withObject:[NSNumber numberWithInt:place] afterDelay:((prevState!=isStopped)*followDelay)];
            }
        }
      
    }];
}

-(void) handleSwipeUp:(UISwipeGestureRecognizer *) recognizer {
    NSLog(@"Up");
    __block unsigned char place=0;
    [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
        // do something if we find a character in myWorld
        ACCCharacter* character = (ACCCharacter*)node;
        int prevState = character.charState;
        gameHasBegun = YES;
        
        if (self.paused ==NO) {
            character.charState = isMoving;
            if (character==leader) {
                [character moveUpWithPlace:[NSNumber numberWithInt:0]];
            } else {
                place ++;

                [character performSelector:@selector(moveUpWithPlace:) withObject:[NSNumber numberWithInt:place] afterDelay:((prevState!=isStopped)*followDelay)];
            }
        }
    }];
}

-(void) handleSwipeDown:(UISwipeGestureRecognizer *) recognizer {
    NSLog(@"Down");
    __block unsigned char place=0;
    [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
        // do something if we find a character in myWorld
        ACCCharacter* character = (ACCCharacter*)node;
        int prevState = character.charState;
        gameHasBegun = YES;
        
        if (self.paused ==NO) {
            character.charState = isMoving;
            if (character==leader) {
                [character moveDownWithPlace:[NSNumber numberWithInt:0]];
            } else {
                place ++;
                [character performSelector:@selector(moveDownWithPlace:) withObject:[NSNumber numberWithInt:place] afterDelay:((prevState!=isStopped)*followDelay)];
            }
        }
    }];
}


-(void) tappedOnce:(UITapGestureRecognizer *) recognizer {
    NSLog(@"One Tap");
    [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
        // do something if we find a character in myWorld
        ACCCharacter* character = (ACCCharacter*)node;
        gameHasBegun = YES;
        [character attack];
        
     }];

}

-(void) doubleTap:(UITapGestureRecognizer *) recognizer {
    NSLog(@"Double Tap");
    
    if(recognizer.state == UIGestureRecognizerStateEnded) {
        
        CGPoint touchLocation;
        BOOL touchableNodeFound=NO;

        touchLocation = [recognizer locationInView:recognizer.view];
        NSLog(@"View Location %f , %f",touchLocation.x,touchLocation.y);
        touchLocation = [self convertPointFromView:touchLocation];
    
        //SKNode *touchedNode;// = (SKSpriteNode *)[self nodeAtPoint:touchLocation];
        NSArray*touchedNodes = (NSArray *)[self nodesAtPoint:touchLocation];
        NSLog(@"Scene Location %f , %f",touchLocation.x,touchLocation.y);
        NSLog(@"Node %@",touchedNodes);
        for (id object in touchedNodes) {
            //SKSpriteNode *touchedNode = id;
            if ([object isMemberOfClass:[ACCCharacter class]])  {
                //SKNode* touchedNode = object;
                //NSLog(@"Name %@", touchedNode.name);
                //if ([touchedNode.name  isEqual: @"character"]) {
        
                    ACCCharacter* touchedNode = object;
                
                    if ([touchedNode isTouchable]) {
                        touchableNodeFound=YES;
                        if ([touchedNode isEqual:leader]) {
                            [self stopAllPlayers];
                        }
                        [touchedNode touched];
                    }
                //}
            }
        }
    }
    
}
-(void) tapToSwitchToSecond:(UITapGestureRecognizer *) recognizer {
    NSLog(@"Two Taps");
    gameHasBegun = YES;

    [self swithOrder:2];

}

-(void) tapToSwitchToThird:(UITapGestureRecognizer *) recognizer {
    NSLog(@"Three Taps");
    gameHasBegun = YES;

    [self swithOrder:3];
    
}

-(void) handleRotation:(UIRotationGestureRecognizer *) recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Rotation Ended");
        [self stopAllPlayersAndPutIntoLine];    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        gameHasBegun = YES;
        NSLog(@"Rotation Began");

    }
}

#pragma mark Switch Leader

-(void)swithOrder:(int) cycle {
    __block int i = 1;
    
    [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
        ACCCharacter* character = (ACCCharacter*)node;
        
        if (character !=leader && i < cycle) {
            
        /*
         IF its not the leader and following then bump up i
         If i=cycle then do the following
         
         
         */
            if(character.followingEnabled==YES) {
                NSLog(@"assigning new leader");
                i++;
                if (i==cycle) {
                    
                    //[myWorld indexOfObject:character];
                    leader.followingEnabled =YES;
                    [leader removeLeader];
                
                    [character makeLeader];
                    leader=character;
                
                    }


                }
            }
       
    }];


}

#pragma  mark STOP ALL CHARACTERS

-(void)stopAllPlayersFromCollision:(SKNode*) damagedNode {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
        // do something if we find a character in myWorld
        ACCCharacter* character = (ACCCharacter*)node;
        
        int leaderDirection=[leader returnDirection];

        if (character == damagedNode) {
            
//fej            [character removeAllActions];
            [character stopMovingFromWallHit];
            [character rest:leaderDirection];
            
        } else {
//fej            [character removeAllActions];
            [character stopMoving];
            [character rest:leaderDirection];
       }
    }];
    
  
}
-(void)stopAllPlayers {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
        // do something if we find a character in myWorld
        ACCCharacter* character = (ACCCharacter*)node;
        
        int leaderDirection=[leader returnDirection];
        
            //fej            [character removeAllActions];
        [character stopMoving];
        [character rest:leaderDirection];
    }];
    
    
}
-(void)stopAllPlayersAndPutIntoLine {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    __block unsigned char leaderDirection=[leader returnDirection];
    __block unsigned char place=1;
    
    [myWorld enumerateChildNodesWithName:@"character" usingBlock:^(SKNode *node, BOOL *stop) {
        // do something if we find a character in myWorld
        ACCCharacter* character = (ACCCharacter*)node;
        
            if (character==leader) {
                
                [leader stopMoving];
                [leader rest:leaderDirection];
                
            } else {
                
                
                character.charState = isLiningUp;
                [character stopInFormation:leaderDirection andPlaceInLine:place leaderLocation:leader.position];
                place ++;
           }
    }];
    
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
    
    SKNode* instructionNode = [SKNode node];
    instructionNode.name = @"instructions";
    [myWorld addChild:instructionNode];
    instructionNode.position = CGPointMake(0,0);
    instructionNode.zPosition = 50;
    
    SKLabelNode* label1 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    label1.fontSize = 22;
    label1.position = CGPointMake(0, 50);
    label1.text = @"Swipe to Move, Rotate to Stop";
    
    SKLabelNode* label2 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    label2.fontSize = 22;
    label2.position = CGPointMake(0, -50);
    label2.text = @"Touch 2 or 3 fingers to Swap Leaders";
    
    [instructionNode addChild:label1];
    [instructionNode addChild:label2];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        label1.fontSize = 15;
        label2.fontSize = 15;
    }

    
    
    useDelayedFollow = [[levelDict objectForKey:@"UseDelayedFollow"]boolValue];
    followDelay = [[levelDict objectForKey:@"FollowDelay"]floatValue];
    levelBorderCausesDamageBy = [[levelDict objectForKey:@"LevelBorderCausesDamageBy"]floatValue];
    if (useDelayedFollow == NO) {
        followDelay =0.0;
    }
    
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
    
    NSArray* coinArray = [NSArray arrayWithArray:[levelDict objectForKey:@"Coins"]];
    [self setupCoins:coinArray];
    
    NSArray* wallArray = [NSArray arrayWithArray:[levelDict objectForKey:@"Walls"]];
    [self setupWalls:wallArray];
    


}

-(void)fadeToDeath:(SKNode*) node  {
    SKAction* fade = [SKAction fadeAlphaTo:0 duration:10];
    SKAction* remove= [SKAction performSelector:@selector(removeFromParent) onTarget:node];
    SKAction* sequence = [SKAction sequence:@[fade,remove]];
    [node runAction:sequence];
    
}

#pragma mark Setup Characters

-(void) setUpCharacters {
    NSLog(@"setup leader");
    
    [self fadeToDeath:[myWorld childNodeWithName:@"instructions"]];
     
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
#pragma mark Setup Coins
-(void) setupCoins:(NSArray *)theArray {
    
    int c = 0;
    while (c<[theArray count]) {
        ACCCoins* newCoin= [ACCCoins node];
        NSDictionary* coinDict = [NSDictionary dictionaryWithDictionary:[theArray objectAtIndex:c]];
        NSString* baseString = [NSString stringWithString:[coinDict objectForKey:@"BaseFrame"]];
        CGPoint coinLocation = CGPointFromString([coinDict objectForKey:@"StartLocation"]);
        
        [newCoin createWithBaseImage:baseString andLocation:coinLocation ];
        [myWorld addChild:newCoin];
        c++;
    }
    
    
}
#pragma mark Setup Walls
-(void) setupWalls:(NSArray *)theArray {
    
    int c = 0;
    while (c<[theArray count]) {
        ACCWalls* newWall= [ACCWalls node];
        NSDictionary* wallDict = [NSDictionary dictionaryWithDictionary:[theArray objectAtIndex:c]];
        NSString* baseString = [NSString stringWithString:[wallDict objectForKey:@"BaseFrame"]];
        CGPoint wallLocation = CGPointFromString([wallDict objectForKey:@"StartLocation"]);
        float wallRotation = [[wallDict objectForKey:@"Rotation"] floatValue];

        [newWall createWithBaseImage:baseString andLocation:wallLocation andRotation:wallRotation ];
        [myWorld addChild:newWall];
        c++;
    }
    
    
}


#pragma mark Game Over Man

-(void)gameOver {
    [myWorld enumerateChildNodesWithName:@"*" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    [myWorld removeFromParent];
    SKScene* nextScene = [[ACCStartMenu alloc] initWithSize:self.size];
    SKTransition* fade = [SKTransition fadeWithColor:[SKColor blackColor] duration:1.5];
    [self.view presentScene:nextScene transition:fade];

}

@end
