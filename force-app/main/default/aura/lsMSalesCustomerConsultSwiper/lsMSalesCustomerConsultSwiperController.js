({
    /**
     * swiper 처리
     * @param component
     * @param event
     * @param helper
     */
    scriptsLoaded : function(component, event, helper) {
        new Swiper('.swiper-container', {
            pagination: {
                el: '.swiper-pagination',
                type: 'fraction',
            },
            navigation: {
                nextEl: '.swiper-button-next',
                prevEl: '.swiper-button-prev',
            },
            autoplay: {
                autoplay: {
                    delay: 2000
                },
            },
            scrollbar: {
                el: '.swiper-scrollbar',
                draggable: true,
            }
        });
    },

});