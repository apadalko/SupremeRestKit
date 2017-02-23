//
//  SRKMappingTask.h
//  Pods
//
//  Created by Alex Padalko on 2/22/17.
//
//

#import <Foundation/Foundation.h>
@class SRKObjectMapping;
@class SRKMappingScope;
@class SRKObject;
typedef void (^SRKMappingTaskComplitBlock) (NSArray<SRKObject*> * result);

@interface SRKMappingTask : NSObject




+(instancetype)taskWithMapping:(id)mapping;
+(instancetype)taskWithMapping:(id)mapping scope:(SRKMappingScope*)scope;




@property (nonatomic,retain)id mapping;
@property (nonatomic,retain)SRKMappingScope * scope;

-(void)startWithData:(NSDictionary*)data complitBlock:(void(^)(NSArray<SRKObject*>* objects))complitBlock;

@property (nonatomic,retain)dispatch_queue_t workQueue;
@end
