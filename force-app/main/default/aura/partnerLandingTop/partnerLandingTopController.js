/**
 * Created by ms on 2017-11-20.
 */
({
    /**
     * init 거래
     * <pre>
     * [유의]
     * javascript file loading 이후 데이터 호출은 이시점에서 하면 안된.
     * scriptsLoaded Action에서 처리해야 함.
     * 이는 thirdParty javascript 의 객체생성 에러가 발생됨은 방지함.
     * </pre>
     * @param component
     * @param event
     * @param helper
     */
    doInit : function(component, event, helper) {
        //helper.fn_getData(component, event, helper);
    },

    /**
     * swiper 처리
     * @param component
     * @param event
     * @param helper
     */
    scriptsLoaded : function(component, event, helper) {
        new Swiper('.swiper-container', {
/*            pagination: {
                el: '.swiper-pagination',
                type: 'fraction',
            },
            navigation: {
                nextEl: '.swiper-button-next',
                prevEl: '.swiper-button-prev',
            },*/
            autoplay: {
                autoplay: {
                    delay: 2000
                },
            },
/*            scrollbar: {
                el: '.swiper-scrollbar',
                draggable: true,
            }*/
        });
    },
    doRedirect : function(component, event, helper) {

        component.find('lacComService').doNaviService({
            type: "comm__loginPage",
            attributes: {
                actionName: "login"
            }
        });
    }

})