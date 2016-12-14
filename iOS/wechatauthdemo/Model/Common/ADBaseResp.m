//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "ADBaseResp.h"


NSString *const kADBaseRespErrcode = @"errcode";
NSString *const kADBaseRespErrmsg = @"errmsg";


@interface ADBaseResp ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation ADBaseResp

@synthesize errcode = _errcode;
@synthesize errmsg = _errmsg;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.errcode = [[self objectOrNilForKey:kADBaseRespErrcode fromDictionary:dict] intValue];
            self.errmsg = [self objectOrNilForKey:kADBaseRespErrmsg fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithInt:self.errcode] forKey:kADBaseRespErrcode];
    [mutableDict setValue:self.errmsg forKey:kADBaseRespErrmsg];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.errcode = [aDecoder decodeDoubleForKey:kADBaseRespErrcode];
    self.errmsg = [aDecoder decodeObjectForKey:kADBaseRespErrmsg];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_errcode forKey:kADBaseRespErrcode];
    [aCoder encodeObject:_errmsg forKey:kADBaseRespErrmsg];
}

- (id)copyWithZone:(NSZone *)zone
{
    ADBaseResp *copy = [[ADBaseResp alloc] init];
    
    if (copy) {

        copy.errcode = self.errcode;
        copy.errmsg = [self.errmsg copyWithZone:zone];
    }
    
    return copy;
}


@end
