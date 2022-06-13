/**************************************************************************************** 
  * File Name   : IF_SEMA_SFDC_0004_BIZ 
  * Description : IF_SEMA_SFDC_0004_BIZ list
  * Author      : ldb3100
  * Modification Log
  * =============================================================== 
  * Ver  Date          Author          Modification
  * ===============================================================
    1.0  2020. 05. 12  ldb3100          Create
    1.1  2020. 05. 14  i2max_shlee      Modified : 카카오 친구톡 이미지 저장 처리 : 유니크 외래키  image_url
****************************************************************************************/
public with sharing class IF_SEMA_SFDC_0004_BIZ {

    private static IF_SEMA_SFDC_0004_BIZ sInstance = null;
    public static IF_SEMA_SFDC_0004_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_SEMA_SFDC_0004_BIZ();
        }
        return sInstance;
    }
    
    /**
     * pre logic
     */
    public IF_SEMA_SFDC_0004.InputBody pre(IF_SEMA_SFDC_0004.InputBody inputBody, IF_SEMA_SFDC_0004.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작
        /*
            값할당 샘플
        */
        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        
        return inputBody;
    }
    
    /**
     * post logic
     */
    public IF_SEMA_SFDC_0004.OutputBody post(IF_SEMA_SFDC_0004.InputBody inputBody, IF_SEMA_SFDC_0004.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */

        //Validation 중복 URL 제외
        Map<String, Boolean> isDupliatedMap = new Map<String, Boolean>();
        for(IF_SEMA_SFDC_0004.INPUT_T_DATA i_data : inputBody.t_data) {
            isDupliatedMap.put(i_data.image_url, FALSE);
        }
        //imgURL 값 존재시 , 중복
        for(KakaoFriendTalkImage__c img : [
                SELECT Id, ImageURL__c FROM KakaoFriendTalkImage__c WHERE ImageURL__c IN :isDupliatedMap.keySet()
        ]) {
            if(!isDupliatedMap.containsKey(img.ImageURL__c)) continue;
            isDupliatedMap.put(img.ImageURL__c, TRUE);
        }

        //KakaoFriendTalkImage__c 저장
        List<KakaoFriendTalkImage__c> insertImgs = new List<KakaoFriendTalkImage__c>();
        KakaoFriendTalkImage__c kftImg = null;
        for(IF_SEMA_SFDC_0004.INPUT_T_DATA i_data : inputBody.t_data) {
            //Validation : 중복 이미지 URL 저장 리스트 제외
            if(isDupliatedMap.get(i_data.image_url)) continue;

            kftImg = new KakaoFriendTalkImage__c();
            kftImg.Name = i_data.image_name;
            kftImg.ImageURL__c = i_data.image_url;
            insertImgs.add(kftImg);
        }

        if(!insertImgs.isEmpty()) {
            insert insertImgs;
        }
   
        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        
        return outputBody;
    }
}