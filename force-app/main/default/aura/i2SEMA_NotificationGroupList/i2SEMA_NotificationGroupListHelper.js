/****************************************************************************************
 * @filename       : i2SEMA_NotificationGroupListHelper.js
 * @projectname    : i2SEMA Core
 * @author         : i2max_byeon.jw
 * @date           : 2020-05-07 오후 4:42
 * @group          :
 * @group-content  :
 * @description    :
 * @copyright      : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                author              description
 * ===============================================================
 0.1     2020-05-07 오후 4:42     i2max_byeon.jw       Create
 ****************************************************************************************/
({
    doSearch : function(component,event,helper){
        helper.apex(component,'doSearch','getNotificationGroups'
                        , {
                            recordId    : component.get('v.recordId'),
                            pageNumber  : component.get('v.pageNumber'),
                            dataSize    : component.get('v.dataSize')
                        }
                    )
            .then((returnData,response)=>{
                let searchResult = returnData.data.searchResult;

                // 조회내용 반영
                component.set('v.totalCount',searchResult.totalCount);
                component.set('v.notificationGroups',searchResult.notificationGroups);

                // 화면에 표현되는 페이지 목록설정
                let pageBlockSize   = component.get('v.pageBlockSize');     // 페이지 블록 크기 (한번에 보여주는 페이지 개수)
                let pageNumber      = component.get('v.pageNumber');        // 현재 페이지 번호
                let totalPage       = Math.ceil(searchResult.totalCount / pageBlockSize);   // 전체 페이지 개수
                component.set('v.totalPage', totalPage );

                console.log('Total Page : ' + totalPage);
                console.log('PageBlockSize : ' + pageBlockSize);
                console.log('Page Number : ' + pageNumber);

                let previousPageBlockSize       = Math.ceil(pageNumber / pageBlockSize) - 1;        // 현재 페이지 블록 이전의 블록개수
                let currentPageBlockStartNumber = (previousPageBlockSize * pageBlockSize) + 1;      // 현재 페이지 블록의 시작 번호
                let currentPageBlockEndNumber   = currentPageBlockStartNumber + (pageBlockSize - 1) <= totalPage ?
                                                    currentPageBlockStartNumber + (pageBlockSize - 1) : totalPage;  // ex) 현재 페이지 블록의 마지막 번호

                console.log('Prev Block Size : ' + previousPageBlockSize);
                console.log('Current Start Number : ' + currentPageBlockStartNumber);
                console.log('Current End Number : ' + currentPageBlockEndNumber);

                let pages = []; // 현재 페이지 블록의 모든 번호
                for( currentPageBlockStartNumber; currentPageBlockStartNumber <= currentPageBlockEndNumber; currentPageBlockStartNumber ++ ){
                    pages.push(currentPageBlockStartNumber);
                }
                component.set('v.pages',pages);

                console.log('Pages : ' + pages);

            })
            .catch((error,response)=>{
                helper.gfn_ApexErrorHandle(error,response);
            });
    }
});