({
    // ====================================================
    // 레코드를 출력한다
    // ====================================================
    getRecords : function(component, params) {
        if(params){

            let message = params.message;
            let pageSize = component.get("v.pageSize");
            let pageNumber = component.get("v.pageNumber");
            let resultSize = component.get("v.resultSize");
            let totalSize = component.get('v.totalSize');

            let isLastData = ((pageNumber-1)*pageSize+resultSize) === totalSize;

            // 레코드 수가 페이지 수보다 작거나 같으면 마지막 페이지
            if(message.length < pageSize || isLastData){
                component.set("v.isLastPage", true);
            } else{
                component.set("v.isLastPage", false);
            }

            // 숫자 페이징
            let isNumPaging = component.get('v.number');
            if(isNumPaging){
                let totalSize = component.get('v.totalSize');
                let pageLength = component.get('v.pageLength');
                let pageNumber = component.get("v.pageNumber");

                // =====================================
                // 출력되어야 하는 페이지 수를 계산한다
                // =====================================
                let pages = Math.ceil(totalSize / pageSize);

                // 보이는 페이지
                // 데이터가 출력되어야하는 페이지 수보다 많은 경우, 출력되어야 하는 페이지만 출력
                let temp = pages > pageLength ? pageLength : pages;
                let pageView = [];

                // 초반 페이지
                let interval = Math.floor(temp / 2);        // 3

                let first = pageNumber - interval;
                let last = pageNumber + interval;

                let i;
                if(first > 0){
                    // 페이지 변경이 필요한 경우
                    if(last <= pages){
                        for(i=0; i < temp; i++){
                            pageView.push(first+i);
                        }
                    }else{
                        first = pages - temp + 1;
                        for(i=0; i < temp; i++){
                            pageView.push(first+i);
                        }
                    }
                }else if(first <= 0){
                    // 페이지 변경이 필요없는 경우
                    for(i=0; i < temp; i++){
                        pageView.push(i+1);
                    }
                }

                component.set("v.pageView", pageView);

                // 로그 출력
                this.gfn_log(component, 'lacComTableFrame.getRecords' , {
                    '메시지' : message,
                    '총 건' : totalSize,
                    '페이지 번호' : pageNumber,
                    '페이지 길이' : pageLength,
                    '페이지 사이즈' : pageSize,
                });

            }else{
                // 로그 출력
                this.gfn_log(component, 'lacComTableFrame.getRecords' , {
                    '메시지' : message,
                    '페이지 사이즈' : pageSize,
                });
            }
            // 일반 페이징
            //var pageNumber = component.get("v.pageNumber").toString();
            // 결과 사이즈를 저장
            component.set("v.resultSize", message.length);

            /*
	        message.forEach(function(row) {
	           row.Id = row.Id+'-'+pageNumber;
	        });
            */

        }else{
            console.err('Not found params');
        }
    },

    // ====================================================
    // 이벤트를 호출한다
    // c:Com의 doMove 메소드를 호출
    // ====================================================
    fireEvent :  function(component, pageNumber, searchTerm) {
        let cmpEvent = component.getEvent("tableEvent");
        let apexCallMethodName = component.get('v.apexCallMethodName');
        let params = {
            'message' : {
                'pageSize' : component.get("v.pageSize"),
                'pageNumber' : pageNumber,
                'searchTerm' : searchTerm,
                'apexCallMethodName': apexCallMethodName
            }
        };

        cmpEvent.setParams(params);

        this.gfn_log(component, 'lacComTableFrame.fireEvent -> Com.util_Move', params);

        cmpEvent.fire();
    }
})