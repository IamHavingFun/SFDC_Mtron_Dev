/****************************************************************************************
 * @filename      : DailyCheck_ba
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-12-16 오전 10:47
 * @group         :
 * @group-content :
 * @description   : [I/F 점검]
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-12-16 오전 10:47      SEOKHO LEE          Create
 ****************************************************************************************/

public class DailyCheck_ba extends Dummy_IF_Batch {

    // InterfaceId, DummmyObjectName, title 를 담기 위한 Map
    private static Map<String, Map<String, String>> dailyCheckMap;

    static {
        dailyCheckMap = new Map<String, Map<String, String>>{
                'IF_KR_ERP_SE_0001' => new Map<String, String>{
                        'dummyObjectName' => 'IF_KR_ERP_SE_0001__c',
                        'title' => '고객정보'
                },
                'IF_KR_ERP_SE_0002' => new Map<String, String>{
                        'dummyObjectName' => 'IF_KR_ERP_SE_0001__c',
                        'title' => '연체'
                },
                'IF_KR_ERP_SE_0003' => new Map<String, String>{
                        'dummyObjectName' => 'IF_KR_ERP_SE_0003__c',
                        'title' => '자재-가격정보'
                },
                'IF_KR_ERP_SE_0004' => new Map<String, String>{
                        'dummyObjectName' => 'IF_KR_ERP_SE_0004__c',
                        'title' => '공장재고'
                },
                'IF_KR_ERP_SE_0028' => new Map<String, String>{
                        'dummyObjectName' => 'IF_KR_ERP_SE_0003__c',
                        'title' => '자재정보'
                },
                'IF_KR_ERP_SE_0012' => new Map<String, String>{
                        'dummyObjectName' => 'IF_KR_ERP_SE_0012__c',
                        'title' => '출고현황'
                },
                'IF_KR_ERP_SE_0027' => new Map<String, String>{
                        'dummyObjectName' => 'IF_KR_ERP_SE_0001__c',
                        'title' => '고객파트너정보'
                },
                'IF_KR_ERP_SE_0034' => new Map<String, String>{
                        'dummyObjectName' => 'IF_KR_ERP_SE_0001__c',
                        'title' => '블랙리스트'
                },
                'IF_KR_ERP_SE_0036' => new Map<String, String>{
                        'dummyObjectName' => 'IF_KR_ERP_SE_0036__c',
                        'title' => '주문상태'
                },
                'IF_KR_PLM_SE_0029' => new Map<String, String>{
                        'dummyObjectName' => 'IF_KR_PLM_SE_0029__c',
                        'title' => '설계변경내역-헤더'
                },
                'IF_KR_PLM_SE_0030' => new Map<String, String>{
                        'dummyObjectName' => 'IF_KR_PLM_SE_0029__c',
                        'title' => '설계변경내역-부품목록'
                },
                'IF_KR_PLM_SE_0031' => new Map<String, String>{
                        'dummyObjectName' => 'IF_KR_PLM_SE_0029__c',
                        'title' => '설계변경내역-제품목록'
                },
                'IF_KR_ERP_SE_0014' => new Map<String, String>{
                        'dummyObjectName' => 'IF_KR_ERP_SE_0006__c',
                        'title' => '채권현황'
                },
                'IF_KR_ERP_SE_0015' => new Map<String, String>{
                        'dummyObjectName' => 'IF_KR_ERP_SE_0006__c',
                        'title' => '수금'
                },
                'IF_KR_ERP_SE_0016' => new Map<String, String>{
                        'dummyObjectName' => 'IF_KR_ERP_SE_0006__c',
                        'title' => '매출실적'
                },
                'IF_KR_ERP_SE_0006' => new Map<String, String>{
                        'dummyObjectName' => 'IF_KR_ERP_SE_0006__c',
                        'title' => '대리점 유통재고-실판매'
                }
        };
    }

    /**
        * Start
        * @param BC : BatchableContext
        *
        * @return Database.QueryLocator
        */
    public override Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
                SELECT Id
                FROM User
                WHERE Id = :UserInfo.getUserId()
        ]);
    }

    /**
       * 수행 로직 구현
       *
       * @param BC : BatchableContext
       * @param targetScope : Batch Size 실행 리스트
       */
    public override void execute(Database.BatchableContext BC, List<SObject> targetScope) {
        // 매일 08시 기준 들어온 총 Count, 에러 Count 집계하여 DailyCheck, DailyCheckItem 에 꽂기...
        // DailyCheck의 제목은 [YYYY-MM-DD] 점검 보고 형식
        // DailyCheck의 점검 상태는 에러 발생시 무조건 장애 값으로 처리
        // DailyCheckItem 오류 내용은 일단 작업 X

        DailyCheck__c dailyCheck = new DailyCheck__c(
                Status__c = '정상'
        );
        List<DailyCheckItem__c> dailyCheckItemList = new List<DailyCheckItem__c>();

        for (String key : dailyCheckMap.keySet()) {
            DailyCheckItem__c dailyCheckItem;
            dailyCheckItem = calculateCountQuery(key, dailyCheckMap.get(key).get('dummyObjectName'), dailyCheckMap.get(key).get('title'));
            if (dailyCheckItem.ErrorCount__c > 0) {
                dailyCheck.Status__c = '장애';
            }
            dailyCheckItemList.add(dailyCheckItem);
        }

        dailyCheck.Name = String.valueOf('[' + this.exeDatetime.format('yyyy-MM-dd') + ']' + ' 점검 보고');
        dailyCheck.CheckDate__c = this.exeDate;
        insert dailyCheck;

        for (DailyCheckItem__c dailyCheckItem : dailyCheckItemList) {
            dailyCheckItem.DailyCheck__c = dailyCheck.Id;
        }
        insert dailyCheckItemList;
    }

    /**
     *  카운트 쿼리 계산하기 위한 함수
     * @param dummyObjectName
     * @param interfaceId
     *
     * @return DailyCheckItem__c
     */
    private DailyCheckItem__c calculateCountQuery(final String interfaceId, final String dummyObjectName, final String title) {
        String totalCountQuery, errorCountQuery, errorContent = '';
        Integer totalCount = 0, errorCount = 0;

        totalCountQuery = 'SELECT Count()  ' +
                ' FROM ' + dummyObjectName +
                ' WHERE InterfaceId__c = \'' + interfaceId + '\'' +
                ' AND CreatedDate = TODAY' + // 운영시 사용
                ' AND isBatchCompleted__c = TRUE';
        totalCount = Database.countQuery(totalCountQuery);

        errorCountQuery = 'SELECT Count(Id) errorCount ' +  //, BatchErrorComment__c' +
                ' FROM ' + dummyObjectName +
                ' WHERE InterfaceId__c = \'' + interfaceId + '\'' +
                ' AND CreatedDate = TODAY' + // 운영시 사용
                ' AND isBatchCompleted__c = TRUE' +
                ' AND isBatchError__c = TRUE ' +
                ' GROUP BY BatchErrorComment__c';
        List<AggregateResult> errorCountResult = Database.query(errorCountQuery);

        for (AggregateResult ar : errorCountResult) {
            errorCount += ((ar.get('errorCount') != null) ? Integer.valueOf(ar.get('errorCount')) : 0);
            //errorContent += ((ar.get('BatchErrorComment__c') != null) ? String.valueOf(ar.get('BatchErrorComment__c')) + ' \n' : '');
        }

        DailyCheckItem__c dailyCheckItem = new DailyCheckItem__c();
        dailyCheckItem.Name = title;
        dailyCheckItem.IF_ID__c = interfaceId;
        dailyCheckItem.TargetCount__c = totalCount;
        dailyCheckItem.ErrorCount__c = errorCount;
        dailyCheckItem.CheckContent__c =
                'IF ID : ' + interfaceId + '\n' +
                        '처리 결과 : ' + '대상 ' + totalCount + '건, ' +
                        '오류 ' + errorCount + '건';
        //dailyCheckItem.ErrorContent__c = errorContent;
        return dailyCheckItem;
    }
}