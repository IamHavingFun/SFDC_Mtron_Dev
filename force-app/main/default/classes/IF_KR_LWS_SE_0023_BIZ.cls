/**************************************************************************************** 
  * File Name   : IF_KR_LWS_SE_0023_BIZ 
  * Description : IF_KR_LWS_SE_0023_BIZ list
  * Author      : ldb3100
  * Modification Log
  * =============================================================== 
  * Ver  Date         Author             Modification
  * ===============================================================
    1.0  2020.07.02   ldb3100            Create
****************************************************************************************/
public with sharing class IF_KR_LWS_SE_0023_BIZ {

    private static IF_KR_LWS_SE_0023_BIZ sInstance = null;
    public static IF_KR_LWS_SE_0023_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_KR_LWS_SE_0023_BIZ();
        }
        return sInstance;
    }
    
    /**
     * pre logic
     */
    public IF_KR_LWS_SE_0023.InputBody pre(IF_KR_LWS_SE_0023.InputBody inputBody, IF_KR_LWS_SE_0023.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작
        /*
            값할당 샘플
        */          
        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        
        return inputBody;
    }

    private static Map<String, String> lwsClaimStatus {get;set;}

    /*static {
        IF_KR_LWS_SE_0023_BIZ.lwsClaimStatus = new Map<String, String> {
                '0' => '저장',
                '1' => '청구',
                '3' => '법인승인',
                '4' => '법인종료',
                '5' => '본사청구',
                '6' => '본사승인',
                '7' => '인보이스',
                '8' => '이의제기',
                '9' => '재청구'
        };
    }*/

    // 요건 변경 (20.07.10)
    static {
        IF_KR_LWS_SE_0023_BIZ.lwsClaimStatus = new Map<String, String> {
                '0'   => '0.저장',
                '1'   => '1.청구',
                '2'   => '2.영업소기각',
                '5'   => '5.검토중',
                '6'   => '6.기각',
                '7'   => '7.승인',
                'A'   => 'A.반려'
        };
    }


    /**
     * post logic
     */
    public IF_KR_LWS_SE_0023.OutputBody post(IF_KR_LWS_SE_0023.InputBody inputBody, IF_KR_LWS_SE_0023.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */
        /*
        -------------------------------------------------------------------- 수신
        	* 데이터 수신하면 워런티 클레임(WarrantyClaim__c) 데이터 업데이트
                클레임번호(IF.ClaimNo) & 기대번호(IF.Asset) 일치하는 건을 대상으로 업데이트
            1)	ClaimStatus__c		IF 더미.ClaimStatus__c
            2)	ClaimResult__c		IF 더미.ClaimResult__c
         */
        List<IF_KR_LWS_SE_0023.INPUT_T_DATA> inputList = inputBody.t_data;
        Integer inputSize = inputList.size();

        if(inputSize > 0) {
            Map<String, WarrantyClaim__c> warrantyclaimMap = new Map<String, WarrantyClaim__c>();
            List<WarrantyClaim__c> warrantyClaims = new List<WarrantyClaim__c>();
            Set<String> warrantyClaimAssetIds = new Set<String>();  // Externalkey__c : ClaimNo__c, Asset__c

            // I/F에서 받은 데이터
            for (IF_KR_LWS_SE_0023.INPUT_T_DATA temp : inputList) {
                warrantyClaimAssetIds.add(temp.ClaimNo+'|'+temp.AssetNo);
            }

            // WarrantyClaim__c Map
            for(WarrantyClaim__c warrantyClaim : [
                    SELECT  Id, ClaimNo__c, ClaimStatus__c, ClaimResult__c, Externalkey__c
                    FROM    WarrantyClaim__c
                    WHERE   Externalkey__c IN :warrantyClaimAssetIds
            ]) {
                if(!warrantyclaimMap.containsKey(warrantyClaim.Externalkey__c)) {
                    warrantyclaimMap.put(warrantyClaim.Externalkey__c, warrantyClaim);
                }
            }

            WarrantyClaim__c tmpWarrantyClaim;
            Boolean isExistRecord;

            for (IF_KR_LWS_SE_0023.INPUT_T_DATA temp : inputList) {
                // 데이터 확인
                tmpWarrantyClaim = warrantyclaimMap.get(temp.ClaimNo+'|'+temp.AssetNo);
                // 데이터 확인 여부
                isExistRecord = tmpWarrantyClaim != null ? true : false;

                if(isExistRecord) {
                    tmpWarrantyClaim.ClaimStatus__c = IF_KR_LWS_SE_0023_BIZ.lwsClaimStatus.get(temp.ClaimStatus);
                    tmpWarrantyClaim.ClaimResult__c = temp.ClaimResult;

                    warrantyClaims.add(tmpWarrantyClaim);
                } else {

                }
            }
            System.debug('### warrantyClaims : '+warrantyClaims + ' ::: ' + warrantyClaims.size());

            //============================================================================
            // 개발 데이터 중복발생. Id로 Map하여 values만 update 처리
            // putAll 하여 중복 제거
            //============================================================================
            if(warrantyClaims.isEmpty() == false){
                //create a map that will hold the values of the list
                map<id,WarrantyClaim__c> distinctMapForTargetUpdList = new map<id,WarrantyClaim__c>();
                //put all the values from the list to map.
                distinctMapForTargetUpdList.putall(warrantyClaims);
                update distinctMapForTargetUpdList.values();
            }

            //if(warrantyClaims.size() > 0)            update warrantyClaims;

            outputBody.ifAggregation    = IF_Comm.convertEmpty(inputBody.ifAggregation);
            outputBody.ifSplitCnt       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
            outputBody.ifRcvCnt         = String.valueOf(inputSize);
        }
      
        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        
        return outputBody;
    }
}