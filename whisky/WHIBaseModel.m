//
//  SUIBaseModel.m
//  erp
//
//  Created by QiuFeng on 11/2/15.
//  Copyright © 2015 www.sui.me. All rights reserved.
//

#import "WHIBaseModel.h"
#import <objc/runtime.h>

@implementation WHIBaseModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    
    Class class = self;
    
    while (![NSStringFromClass(class) isEqualToString:NSStringFromClass([WHIBaseModel class])]) {
        unsigned count;
        objc_property_t *properties = class_copyPropertyList(class, &count);
        for (int i = 0; i < count; i++) {
            objc_property_t property = properties[i];
            const char *propertyAttributes = property_getAttributes(property);
            NSArray *attributes = [[NSString stringWithUTF8String:propertyAttributes] componentsSeparatedByString:@","];
            if ([attributes containsObject:@"R"]) {     //Ready only
                continue;
            }
            NSString *name = [NSString stringWithUTF8String:property_getName(property)];
            if (name) {
                [results setObject:name forKey:name];
            }
        }
        free(properties);
        class = [class superclass];
    }
    
    results[@"objectId"] = @"id";
    
    return results;
}

+ (NSValueTransformer *)objectIdJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^(id value, BOOL *success, NSError *__autoreleasing *error) {
        return [NSString stringWithFormat:@"%@", value];
    }];
}

+ (NSValueTransformer *)dateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        return [dateFormatter dateFromString:value];
    } reverseBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return nil;
    }];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if ([self isKindOfClass:[object class]]) {
        return [self.objectId isEqualToString:((WHIBaseModel *)object).objectId];
    } else {
        return NO;
    }
}

@end
