/****************************************************************************************
 * @filename      : lacComServiceController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-03-26 오후 2:04
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-03-26 오후 2:04    i2max_my.Seo           Create
 ****************************************************************************************/
({
    /**
     * Object list를 넘기면 해당하는 object의 label정보를 가져옴. (다국어 지원)
     *
     * @param component
     * @param event
     * @param helper
     */
    doGetSobjectData: function (component, event, helper) {
        const params = event.getParam('arguments');
        let callback;
        if (params) {
            callback = params.callback;
        }

        helper.apex(
            component, 'doGetSobjectData', 'getSobjectData', {'targetObjectList': params.targetObjectList}, null, true
        ).then(function ({resData, response}) {
            callback(resData);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * navigation 이동 : lightning:navigation
     * pageReference 를 이용한 페이지 이동(주로 사용할 것)
     * 관련 사이트 : https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/components_navigation_page_definitions.htm
     * @param component
     * @param event
     * @param pageReference
     */
    doNaviService : function (component, event) {
        const param = event.getParam('arguments');
        event.preventDefault();
        component.find("naviService").navigate(param.pageReference);
    },

    /**
     * Single Table excel export
     *
     * @param component
     * @param event
     */
    doExcelExport : function (component, event) {
        const params = event.getParam('arguments');

        let table = params.cmp.find(params.tableName).getElement();
        let tableContent = table.innerHTML.replace(/<(\/a|a)([^>]*)>/gi,"");

        console.log('table : ' + table);
        console.log('tableContent : ' + tableContent);

        let utf8Heading = "<meta http-equiv=\"content-type\" content=\"application/vnd.ms-excel; charset=UTF-8\">";
        let uri = 'data:application/vnd.ms-excel;base64;chartset=UTF-8,';
        let template = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40">' + utf8Heading + '<head><!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>{worksheet}</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]--></head><body><table>{table}</table></body></html>';

        let base64 = function (s) {
            return window.btoa(unescape(encodeURIComponent(s)))
        };
        let format = function (s, c) {
            return s.replace(/{(\w+)}/g, function (m, p) {
                return c[p];
            });
        };

        let ctx =  {
            worksheet: name || 'Worksheet',
            table: tableContent,
        };

        let a = document.createElement("a");
        a.href = uri + base64(format(template, ctx));
        a.download = params.fileName;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
    },

    /**
     * Multi Table Excel export
     *
     * @param component
     * @param event
     */
    doExcelMultiExport : function (component, event) {
        const params = event.getParam('arguments');

        let tableContent = '';
        params.tableNames.forEach(function(tableName){
            tableContent += '<table>'+params.cmp.find(tableName).getElement().innerHTML+'</table><br/>';
        });

        let utf8Heading = "<meta http-equiv=\"content-type\" content=\"application/vnd.ms-excel; charset=UTF-8\">";
        let uri = 'data:application/vnd.ms-excel;base64;chartset=UTF-8,';
        let template =  '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40">' + utf8Heading +
            '<head><!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>{worksheet}</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]--></head>' +
            '<body>{tables}</body></html>';

        let base64 = function (s) {
            return window.btoa(unescape(encodeURIComponent(s)))
        };
        let format = function (s, c) {
            return s.replace(/{(\w+)}/g, function (m, p) {
                return c[p];
            });
        };

        let ctx =  {
            worksheet: name || 'Worksheet',
            tables: tableContent,
        };

        let a = document.createElement("a");
        a.href = uri + base64(format(template, ctx));
        a.download = params.fileName;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
    },
})