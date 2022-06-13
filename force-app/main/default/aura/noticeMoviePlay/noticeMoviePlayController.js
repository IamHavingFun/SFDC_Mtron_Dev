/**
 * Created by ms on 2020-04-08.
 */

({
    doInit: function (component, event, helper) {
console.log('>> ' + component.get('v.isPartner'));
        helper.apex(
            component, 'doInit', 'init', {
                "recordId": component.get('v.recordId'),
                "isPartner": component.get('v.isPartner')
            }
        ).then(function ({resData, response}) {

            component.set('v.isMovie', resData.isMovie);
            component.set('v.movieUrl', resData.movieUrl);
            component.set('v.movieType', resData.movieType);

        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
});