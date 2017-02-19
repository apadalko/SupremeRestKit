//
//  SRKObject.h
//  SupremeRestKit
//
//  Created by Alex Padalko on 2/18/17.
//  Copyright © 2017 apadalko. All rights reserved.
//

#import <DSObject/DSObject.h>

@interface SRKObject : DSObject

@property (nonatomic,retain)NSString * objectId;
@property (nonatomic,retain)NSString * localId;


//sync - check if have object id - use normal normal storage
//if not use local id and another storage mark bool that using local
//if failed to sync by object id try to sync by local id - if you will get object - combinde - then delete this object from another storage
//
//method storage name - should return : if object id @return normal name else return another
//method indifiter should return object id - if false - local id
//
//!! or event better to pass refernce to storage manager itself

@end
