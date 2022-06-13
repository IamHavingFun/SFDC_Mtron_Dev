/****************************************************************************************
 * @filename      : LsMSalesWarrantyClaimDetail
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-06-19 오후 3:01
 * @group         :
 * @group-content :
 * @description   : [모바일] LWS 클레임 상세 조회
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
   0.1     2020-06-19 오후 03:01        SEOKHO LEE          Create
   0.2     2020-07-09 오후 11:02        i2max_park          init 로직, WrapperClass 추가
   0.3     2020-07-17 오후 10:56        i2max_park          init 로직 추가
 ****************************************************************************************/

public without sharing class LsMSalesWarrantyClaimDetail {

    /**
     * init
     * @param recordId
     * @return
     *
     */
    @AuraEnabled
    public static DetailData init(final String recordId) {
        DetailData detailData = new DetailData();
        detailData.warrantyClaim = [
                SELECT  Id,
                        Name,
                        ClaimNo__c,
                        AssetId__c,
                        Customer__r.Name,
                        Customer__r.fm_Mobile__c,
                        AssetId__r.Name,
                        fm_ProductType__c,
                        fm_ProductCode__c,
                        ProductId__r.ProductType__c,
                        ProductId__r.Name,
                        AssetId__r.WtyStartDate__c,
                        AssetId__r.WtyEndDate__c,
                        (SELECT Id, ContentDocumentId, Title, FileExtension FROM AttachedContentDocuments)
                FROM WarrantyClaim__c
                WHERE Id = :recordId
        ];

        // 2020-07-09 오후 11:02 추가분 -----------------------------------------------------------------------------------------------------------------------------------------------------
        List<Id> ContentDocumentIdList = new List<Id>();
        for(AttachedContentDocument acd : detailData.warrantyClaim.AttachedContentDocuments) {
            ContentDocumentIdList.add(acd.ContentDocumentId);
        }
        detailData.contentVersions = [SELECT Id, ContentDocumentId, LWSImageType__c, Title
                                      FROM ContentVersion
                                      WHERE ContentDocumentId IN :ContentDocumentIdList AND IsLatest = TRUE];
        // 2020-07-09 오후 11:02 추가분 -----------------------------------------------------------------------------------------------------------------------------------------------------

        // 2020-07-17 오후 10:56 추가분 -----------------------------------------------------------------------------------------------------------------------------------------------------
        List<String> typeList = new List<String>{'기대정보', '계기판 사용시간', '고장부품 탈거 전', '고장부품 탈거 후', '고장에 대한 다각도 사진1', '고장에 대한 다각도 사진2', '고장에 대한 다각도 사진3', '고장에 대한 다각도 사진4'};
        List<ContentVersion> orderedContentVersions = new List<ContentVersion>(typeList.size());
        Integer index = 0;
        for(String type : typeList) {
            for(ContentVersion cv : detailData.contentVersions) {
                if (cv.LWSImageType__c == type) {
                    orderedContentVersions[index] = cv;
                }
            }
            index++;
        }

        for(Integer i = 0; i < typeList.size(); i++) {
            if(orderedContentVersions[i] == null) {
                orderedContentVersions[i] = new ContentVersion(LWSImageType__c = typeList[i]);
            }
        }

        detailData.contentVersions = orderedContentVersions;
        // 2020-07-17 오후 10:56 추가분 -----------------------------------------------------------------------------------------------------------------------------------------------------

        System.debug(JSON.serialize(detailData));
        return detailData;
    }
    /**
     * sava
     *
     * @param detailData
     *
     * @return
     */
    @AuraEnabled
    public static DetailData save(DetailData detailData) {

        if(detailData.warrantyClaim != null) {
            update detailData.warrantyClaim;
        }
        return detailData;
    }

    @AuraEnabled
    public static ContentVersion updateContentVersionItems(String recordId,String n_documentId,String o_documentId,String lWSImageType) {
        System.debug('----> ' + recordId);
        System.debug('n_documentId ----> ' + n_documentId);
        System.debug('o_documentId ----> ' + o_documentId);
        System.debug('lWSImageType ----> ' + lWSImageType);
        if(String.isNotBlank(o_documentId)){
            deleteContentVersionItems(o_documentId);
        }
        ContentVersion n_cv = [SELECT Id, ContentDocumentId, LWSImageType__c, Title FROM ContentVersion WHERE ContentDocumentId = :n_documentId];
        n_cv.LWSImageType__c = lWSImageType;
        update n_cv;

        return n_cv;
    }

    /**
	 * Warranty 청구 등록 : IF_KR_SE_LWS_0022
	 * 사진 정보 전송
	 *
	 * @param assetName
	 * @param claimNo
	 * @param contentVersionId
	 * @param seq
	 *
	 * @return
	 */
    @AuraEnabled
    public static Map<String, String> callLWS0022(String assetName, String claimNo, String contentVersionId, String seq) {
        Map<String, String> returnMap = new Map<String, String>();
        returnMap = LwsService.IF_KR_SE_LWS_0022(assetName, claimNo, contentVersionId, seq);
        if(returnMap.get('STATUS') == 'N') {
            throw new AuraHandledException('[LWS : 사진전송오류]\n'+returnMap.get('MESSAGE'));
        }
        /*
            TODO : 사진정보 정상 처리 되면 상태값 업데이트 처리 필요.....
         */
        return returnMap;
    }

    @AuraEnabled
    public static void deleteContentVersionItems(String o_documentId) {
        ContentDocument d_cv = [SELECT Id FROM ContentDocument WHERE Id = :o_documentId];
        delete d_cv;
    }

    /**
    * WrapperClass
    *
    */
    public class DetailData {
        @AuraEnabled public WarrantyClaim__c  warrantyClaim { get; set; }
        @AuraEnabled public List<ContentVersion> contentVersions { get; set; } // 2020-07-09 오후 11:02 추가분
    }

}