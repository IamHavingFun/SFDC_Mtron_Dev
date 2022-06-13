({
    doScrollX : function(component, event, helper) {

        let leftCol = component.get("v.leftCol");
        const table = component.get('v.body');
        // header
        const thead = table[0].getElement();
        // body
        const tbody = table[1].getElement();
        // rows
        const headers = thead.children;
        const rows = tbody.children;

        // column
        const length = rows.length;
        let i, j, headerCols, bodyCols, colArr = [];
        const left = component.get("v.left");

        headerCols = headers[0].children;
        for(i=0; i<length; i++){
            bodyCols = rows[i].children;
            for(j=0; j<left; j++){
                colArr.push(headerCols[j]);
                colArr.push(bodyCols[j]);
            }
        }

        component.set("v.leftCol", colArr);
        leftCol = colArr;

        if(!$A.util.isEmpty(leftCol)){
            let scroll = event.currentTarget.scrollLeft;
            component.set('v.scrollLeft', scroll);

            leftCol.forEach(function(element) {
                element.style.left = scroll+'px';
                if($A.util.isEmpty(element.style.background)){
                    element.style.background ='white' ;
                }
                element.style.zIndex = 90;
            });
        }
    },

    doScrollY : function (component, event, helper) {
        // x scroll의 유무.
        let left = component.get('v.left');

        let header = component.get("v.header");
        const table = component.get('v.body');
        // header
        const thead = table[0].getElement();
        // body
        const tbody = table[1].getElement();
        // rows
        const headers = thead.children;

        // column
        let i, headerRows, rowArr= [];
        let colArr = [];

        headerRows = headers[0].children;   // header 한 행의 열 전체 7개

        const length = headerRows.length;

        for(i=0 ; i<length ; i++) {
            rowArr.push(headerRows[i]);
        }

        component.set("v.header", rowArr);
        header = rowArr;

        // 고정된 열의 header 부분 일치시키기 위한 array 정제
        if(!$A.util.isEmpty(left)) {
            for(i=0 ; i<left ; i++) {
                colArr.push(headerRows[i]);
            }
        }

        if(!$A.util.isEmpty(header)){
            let scroll = event.currentTarget.scrollTop;

            header.forEach(function(element) {
                if(!$A.util.isEmpty(colArr)) {
                    colArr.forEach(function(element) {
                        element.style.left = component.get('v.scrollLeft') + 'px';
                        element.style.zIndex = 90;
                    });
                }

                element.style.top = scroll + 'px';
                if($A.util.isEmpty(element.style.background)){
                    element.style.background = 'rgb(250, 250, 249)';
                }
                element.style.zIndex = 20;
            });
        }
    },
})