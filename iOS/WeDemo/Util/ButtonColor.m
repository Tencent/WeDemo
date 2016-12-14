//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import "ButtonColor.h"

@implementation UIColor (buttonColor)

+ (instancetype)loginButtonColor {
    return [UIColor colorWithRed:0.04
                           green:0.73
                            blue:0.03
                           alpha:1.00];
}

+ (instancetype)linkButtonColor {
    return [UIColor colorWithRed:0.27
                           green:0.60
                            blue:0.91
                           alpha:1.00];
}

@end
