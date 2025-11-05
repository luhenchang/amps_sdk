//
//  AdScopeTimer.h
//  AdScopeFoundation
//
//  Created by Cookie on 2022/11/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdScopeTimer : NSObject

+ (AdScopeTimer *)adScopeScheduledWeakTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector repeats:(BOOL)yesOrNo;

+ (AdScopeTimer *)adScopeScheduledWeakTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector temp:(NSString *)temp repeats:(BOOL)yesOrNo;

@property (readonly) BOOL repeats;
@property (readonly) NSTimeInterval timeInterval;
@property (readonly, getter=isValid) BOOL valid;

@property (readonly, nonatomic) NSString *temp;

- (void)invalidate;

- (void)fire;

@end

NS_ASSUME_NONNULL_END
