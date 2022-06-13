/**************************************************************************************** 
  * File Name   : IF_KR_LWS_SE_0020_BIZ 
  * Description : IF_KR_LWS_SE_0020_BIZ list
  * Author      : ldb3100
  * Modification Log
  * =============================================================== 
  * Ver  Date         Author             Modification
  * ===============================================================
    1.0  2020.07.02   ldb3100            Create
****************************************************************************************/
public with sharing class IF_KR_LWS_SE_0020_BIZ {

    private static IF_KR_LWS_SE_0020_BIZ sInstance = null;
    public static IF_KR_LWS_SE_0020_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_LWS_SE_0020_BIZ();
        }
        return sInstance;
    }
    
    /**
     * pre logic
     */
    public IF_KR_LWS_SE_0020.InputBody pre(IF_KR_LWS_SE_0020.InputBody inputBody, IF_KR_LWS_SE_0020.OutputBody outputBody) {
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
    public IF_KR_LWS_SE_0020.OutputBody post(IF_KR_LWS_SE_0020.InputBody inputBody, IF_KR_LWS_SE_0020.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */
        /*Q
	        기대번호에 일치하는 자산이 없는 경우에는 자산 등록이 안된 기대번호 안내메시지 회신

        -------------------------------------------------------------------- 수신
        	* 데이터를 수신하면 자산(Asset) 데이터 업데이트 (기준 : IF.AssetNo = Asset.Name) : 기대번호
        1)	WtyEndDate__c		IF 더미.WtyEndDate
        */

        List<IF_KR_LWS_SE_0020.INPUT_T_DATA> inputList = inputBody.t_data;
        Integer inputSize = inputList.size();

        if(inputSize > 0) {
            Map<String, Asset> assetMap = new Map<String, Asset>();
            List<Asset> assets = new List<Asset>();
            Set<String> assetNames = new Set<String>();           // Asset Names (기대번호)

            // I/F에서 받은 데이터
            for (IF_KR_LWS_SE_0020.INPUT_T_DATA temp : inputList) {
                if(String.isNotBlank(temp.AssetNo))          assetNames.add(temp.AssetNo);
            }

            // Asset Map
            for(Asset a : [
                    SELECT  Id, Name, BatchNo__c, WtyEndDate__c
                    FROM    Asset
                    WHERE   BatchNo__c IN :assetNames
            ]) {
                if(!assetMap.containsKey(a.BatchNo__c)) {
                    assetMap.put(a.BatchNo__c, a);
                }
            }

            Asset tmpAsset;
            Boolean isExistRecord;

            for (IF_KR_LWS_SE_0020.INPUT_T_DATA temp : inputList) {
                // 데이터 확인
                tmpAsset = assetMap.get(temp.AssetNo);
                // 데이터 확인 여부
                isExistRecord = tmpAsset != null ? true : false;

                if(isExistRecord) {
                    tmpAsset.WtyEndDate__c = String.isNotBlank(temp.WtyEndDate) ? Dummy_IF_BatchUtil.getIFDate(temp.WtyEndDate) : null;
                    assets.add(tmpAsset);
                } else {
                    // todo : 안내메시지
                    System.debug(System.LoggingLevel.INFO, '::::: 안내메시지' + temp.AssetNo);
                }
            }
            System.debug(System.LoggingLevel.INFO, '::::: INFO LOG :::::'+ assets + ' ::: ' + assets.size());

            //============================================================================
            // 개발 데이터 중복발생. Id로 Map하여 values만 update 처리
            // putAll 하여 중복 제거
            //============================================================================
            if(assets.isEmpty() == false){
                //create a map that will hold the values of the list
                map<id,Asset> distinctMapForTargetUpdList = new map<id,Asset>();
                //put all the values from the list to map.
                distinctMapForTargetUpdList.putall(assets);
                update distinctMapForTargetUpdList.values();
            }

            //if(assets.size() > 0)            update assets;

            outputBody.ifAggregation    = IF_Comm.convertEmpty(inputBody.ifAggregation);
            outputBody.ifSplitCnt       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
            outputBody.ifRcvCnt         = String.valueOf(inputSize);
        }
        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        
        return outputBody;
    }
}