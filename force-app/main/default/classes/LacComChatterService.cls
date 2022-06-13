/****************************************************************************************
  * @filename      : LacComChatterService
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-07-07 오후 2:27
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LacComChatterService_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-07-07 오후 2:27     i2max_my.Seo           Create
****************************************************************************************/
public with sharing class LacComChatterService {

    /**
     * bulk subjectId가 처리
     *
     * @param communityId
     * @param subjectIds
     * @param text
     *
     * @return
     */
    public static List<ConnectApi.FeedElement> simpleChatterFeed(String communityId, Set<String> subjectIds, String text) {

        List<ConnectApi.FeedElement> feedElements = new List<ConnectApi.FeedElement>();

        for(String subjectId : subjectIds) {
            feedElements.add(simpleChatterFeed(communityId, subjectId, text));
        }

        return feedElements;
    }

    /**
     * mentions 없이 post feed
     *
     * @param communityId
     * @param subjectId
     * @param text
     *
     * @return
     */
    public static ConnectApi.FeedElement simpleChatterFeed(String communityId, String subjectId, String text) {
        return simpleChatterFeed(communityId, subjectId, text, new Set<String>());
    }

    /**
     * Chatter 발송 Method.
     *
     * @param communityId : NetworkId (Community Id)
     * @param subjectId : User, Group, Record.... targetId
     * @param text : body
     * @param mentionIds :@
     *
     * @return
     */
    public static ConnectApi.FeedElement simpleChatterFeed(String communityId, String subjectId, String text, Set<String> mentionIds) {

        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        //---------------------------------------------------------------------------
        // Public Group Id 로 mention 이 안됨. 따라서 그룹의 멤버로 각각 mention 처리
        //---------------------------------------------------------------------------
        ConnectApi.MentionSegmentInput mentionSegmentInput;
        for(String mentionId : mentionIds) {
            messageBodyInput.messageSegments.add(mentionSegmentInput = new ConnectApi.MentionSegmentInput());
            mentionSegmentInput.id = (Id)mentionId;
        }

        textSegmentInput.text = '\n' + text;
        messageBodyInput.messageSegments.add(textSegmentInput);

        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = subjectId;


        //------------------------------------------------------------------------------
        // ConnectApi Test 분리
        //------------------------------------------------------------------------------
        if(!Test.isRunningTest()) {
            return ConnectApi.ChatterFeeds.postFeedElement(communityId, feedItemInput);
        }
        else {
            return null;
        }
    }
}