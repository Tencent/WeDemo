//Tencent is pleased to support the open source community by making WeDemo available.
//Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
//Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//http://opensource.org/licenses/MIT
//Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

#import <Foundation/Foundation.h>
#import "BaseNetworkEngine.h"

@class ADGetCommentListResp;
@class ADGetReplyListResp;
@class ADAddCommentResp;
@class ADAddReplyResp;

typedef void(^GetCommentListCallBack)(ADGetCommentListResp *resp);
typedef void(^GetReplyListCallBack)(ADGetReplyListResp *resp);
typedef void(^AddCommentCallBack)(ADAddCommentResp *resp);
typedef void(^AddReplyCallBack)(ADAddReplyResp *resp);

@interface ADNetworkEngine : BaseNetworkEngine

/**
 *  获取某个startId之后的留言板的留言。
 *
 *  @restrict 可以在临时或正式安全通道里进行.
 *  
 *  @param uin 正式Uin
 *  @param startId 开始的留言Id，nil则为从头开始
 *  @param completion 获取完成的回调，参数包括留言列表，留言个数，每页的最多数量。
 */
- (void)getCommentListForUin:(UInt32)uin
                        From:(NSString *)startId
              WithCompletion:(GetCommentListCallBack)completion;

/**
 *  获取某个留言下的评论。
 *  
 *  @restrict 可以在临时或正式安全通道里进行.
 *
 *  @param uin 正式Uin
 *  @param commentId 该留言的Id
 *  @param completion 获取完成的回调.
 */
- (void)getReplyListForUin:(UInt32)uin
                 OfComment:(NSString *)commentId
            WithCompletion:(GetReplyListCallBack)completion;

/**
 *  发布一条留言
 *  
 *  @restrict 必须在正式安全通道里进行.
 *
 *  @param content 留言的文字
 *  @param uin 正式uin
 *  @param loginTicket 用户的登录票据
 *  @param completion 发布完成的回调
 *
 */
- (void)addCommentContent:(NSString *)content
                   ForUin:(UInt32)uin
              LoginTicket:(NSString *)loginTicket
           WithCompletion:(AddCommentCallBack)completion;

/**
 *  发布一条评论
 *
 *  @restrict 必须在正式安全通道里进行.
 *
 *  @param content 回复的内容
 *  @param commentId 留言的Id
 *  @param replyId  回复的Id
 *  @param uin 正式Uin
 *  @param loginTicket 用户的登录票据
 *  @param completion 发布完成的回调
 */
- (void)addReplyContent:(NSString *)content
              ToComment:(NSString *)commentId
              OrToReply:(NSString *)replyId
                 ForUin:(UInt32)uin
            LoginTicket:(NSString *)loginTicket
         WithCompletion:(AddReplyCallBack)completion;
@end
