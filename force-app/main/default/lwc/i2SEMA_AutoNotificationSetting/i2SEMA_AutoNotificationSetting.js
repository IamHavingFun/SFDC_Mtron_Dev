/****************************************************************************************
 * @filename       : i2SEMA_AutoNotificationSetting
 * @projectname    : i2SEMA Core
 * @author         : i2max_byeon.jw
 * @date           : 2020-04-14 오전 10:18
 * @group          :
 * @group-content  :
 * @description    :
 * @copyright      : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                author              description
 * ===============================================================
 0.1     2020-04-14 오전 10:18     i2max_byeon.jw       Create
 ****************************************************************************************/
import {LightningElement , track , api } from 'lwc';
// [Utility]
import { isEmpty, isNotEmpty, toArray, toastSuccess, toastError } from 'c/i2SEMA_LwcUtil';
// [Apex Method]
import fn_initialize from '@salesforce/apex/i2SEMA_AutoNotificationSetting.initialize';
import fn_saveNotificationSetting from '@salesforce/apex/i2SEMA_AutoNotificationSetting.doSaveNotificationSetting';
import fn_getFieldData from '@salesforce/apex/i2SEMA_AutoNotificationSetting.getFieldData';
import fn_getRecipientFieldData from '@salesforce/apex/i2SEMA_AutoNotificationSetting.getRecipientFields';
import fn_getTemplateDetail from '@salesforce/apex/i2SEMA_AutoNotificationSetting.getTemplateData';
import fn_toggleActivate from '@salesforce/apex/i2SEMA_AutoNotificationSetting.toggleActivateNotificationSetting';

export default class I2SemaAutoNotificationSetting extends LightningElement {
    /* --------------------------------------------------------------------------------------------------------
         * Record / Reference Data
        -------------------------------------------------------------------------------------------------------- */
    @api recordId;                  // UI 에서 획득하는 Record ID
    @track notificationSetting;     // Notification Setting 레코드 > 전체 이벤트 정보
    @track fieldConditions;         // Notification Field Condition 레코드 > 이벤트 발동 필드조건
    @track notificationTemplate;    // Notification Template 레코드 > ID 를 통해 Label 사용여부 및 Contents 획득
    @track scheduleBaseOptions;     // 선택 가능한 Schedule 기준 목록
    @track scheduleBaseFields;      // Schedule 기준으로 사용 가능한 DateTime 필드
    @track objects;                 // Org 전체 Object 목록 > Event Target Object 설정에 사용
    @track fields;                  // 선택한 Object 에 포함되는 전체 Field 목록 > Template Label & Field Condition 설정에 사용
    @track fieldTypes;              // 선택한 Object 에 포함되는 전체 Field 타입 > Template Label & Field Condition 설정에 사용
    @track recipientFields;         // Event Target Object 에 속한 Account/Contact/Lead Reference 필드 목록 > 수신자 설정에 사용

    set notificationSetting(value){
        this.notificationSetting = value;
    }

    /* --------------------------------------------------------------------------------------------------------
     * Rendering Flag
        : Loading 여부, Read/Edit 화면 구분, 변경되는 버튼 Label 및 Template Label 표현여부, Disable 여부 등
    -------------------------------------------------------------------------------------------------------- */
    @track loading          = false;

    get activateLabel(){
        return this.notificationSetting != null ? (this.notificationSetting.IsActive__c ? 'Deactivate' : 'Activate') : null;
    }
    get activateVariant(){
        return this.notificationSetting != null ? (this.notificationSetting.IsActive__c ? 'destructive' : 'brand') : null;
    }
    get label1Render(){
        return this.notificationTemplate != null && this.notificationTemplate.LABEL1__c;
    }
    get label2Render(){
        return this.notificationTemplate != null && this.notificationTemplate.LABEL2__c;
    }
    get label3Render(){
        return this.notificationTemplate != null && this.notificationTemplate.LABEL3__c;
    }
    get label4Render(){
        return this.notificationTemplate != null && this.notificationTemplate.LABEL4__c;
    }
    get label5Render(){
        return this.notificationTemplate != null && this.notificationTemplate.LABEL5__c;
    }
    get templateContentRender(){
        return this.notificationTemplate != null && this.notificationTemplate.Content__c != null;
    }
    get expressionRender(){
        return this.fieldConditions != null && this.fieldConditions.length > 0;
    }
    get recipientDisabled(){
        return isEmpty(this.recipientFields);
    }
    get executeDisabled(){
        return this.notificationSetting == null || isEmpty(this.notificationSetting.ObjectType__c);
    }
    get labelDisabled(){
        return isEmpty(this.fields);
    }
    get hasConditions(){
        return this.fieldConditions != null && this.fieldConditions.length > 0;
    }
    get scheduleBaseFieldRender(){
        return this.scheduleBaseFields != null && this.notificationSetting.ScheduleBasedOn__c === 'Record Datetime Field';
    }
    get scheduleDisabled(){
        return this.notificationSetting == null || this.notificationSetting.IsSchedule__c != true;
    }

    /* --------------------------------------------------------------------------------------------------------
     * Life Cycle
    -------------------------------------------------------------------------------------------------------- */
    connectedCallback() {
        this.loading                = true;
        this.notificationSetting    = {};
        this.fieldConditions        = [];
        this.notificationTemplate   = {};

        // 초기정보 조회
        fn_initialize({recordId : this.recordId})
            .then( resp => {
                // Schedule Base 옵션
                this.scheduleBaseOptions    = resp.data.scheduleBaseOptions;
                this.scheduleBaseFields     = resp.data.scheduleBaseFields;

                // Object,Field 참조값 반영
                this.objects                = resp.data.objects;
                this.fields                 = resp.data.fields;
                this.fieldTypes             = resp.data.fieldTypes;
                this.recipientFields        = resp.data.recipientFields;

                // Setting,FieldCondition 반영 (참조값 반영 이후)
                this.notificationSetting    = resp.data.notificationSetting;
                this.fieldConditions        = resp.data.fieldConditions;

                // Template Render
                this.notificationTemplate   = resp.data.template;

                // Spinner Off
                this.loading                = false;
            })
            .catch( err => {
                toastError('Error','Error Occurred');
            });
    }
    /*---------------------------------------------
     * UI Event
     ---------------------------------------------*/
    // DropBox 변경 Event Handle
    dropBoxEventHandle(event){
        let param = event.detail;
        if( param != null && param.api != null ){
            // 이벤트 값이 현재 값과 다른경우에만 후속처리
            if( this.notificationSetting[param.api] !== param.value ){
                this.notificationSetting[param.api] = param.value;

                // Object 가 변경된 경우, 기존 Field 목록,수신자 필드 목록 제거
                if( param.api === 'ObjectType__c') {
                    // 관련값 초기화
                    this.notificationSetting.ExecuteOn__c       = null;
                    this.notificationSetting.RecipientField__c  = null;
                    this.notificationSetting.FieldForSchedule__c   = null;
                    this.notificationSetting.Label1FieldAPI__c  = null;
                    this.notificationSetting.Label2FieldAPI__c  = null;
                    this.notificationSetting.Label3FieldAPI__c  = null;
                    this.notificationSetting.Label4FieldAPI__c  = null;
                    this.notificationSetting.Label5FieldAPI__c  = null;
                    this.fields             = null;
                    this.fieldTypes         = null;
                    this.recipientFields    = null;
                    this.scheduleBaseFields = null;
                    this.removeAllCondition();

                    if( isNotEmpty(param.value)){
                        this.loading = true;
                        // 필드 및 수신자 목록 조회
                        let fieldPromise        = this.getFieldData(param.api);
                        let recipientPromise    = this.getRecipientFieldData(param.api);

                        Promise.all([fieldPromise,recipientPromise])
                            .then(()=>{this.loading = false});
                    }
                }
            }
        }
    }
    // 템플릿 변경 Event Handle
    templateChangeHandle(event){
        // 기존 설정정보 초기화
        this.notificationSetting.NotificationTemplate__c    = null;
        this.notificationSetting.Label1FieldAPI__c          = null;
        this.notificationSetting.Label2FieldAPI__c          = null;
        this.notificationSetting.Label3FieldAPI__c          = null;
        this.notificationSetting.Label4FieldAPI__c          = null;
        this.notificationSetting.Label5FieldAPI__c          = null;

        this.notificationTemplate   = null;

        // Template 조회
        this.notificationSetting[event.target.name] = event.target.value;

        if( event.target.value != null && event.target.value !== '' ){
            this.loading = true;
            let templatePromise = this.getTemplateData(this.notificationSetting.NotificationTemplate__c);

            Promise.all([templatePromise])
                .then(()=>{
                    this.loading = false;
                });
        }
    }
    // 설정값 반영
    setNotificationSettingValue(event){
        // CheckBox 옵션 ( event.target.value || event.target.checked 사용시 Checkbox 가 아닌 필드값 false 이 됨)
        if( event.target.name === 'IsSchedule__c'){
            this.notificationSetting[event.target.name] = event.target.checked;
        }
        else{
            this.notificationSetting[event.target.name] = event.target.value;
        }
        console.log(JSON.parse(JSON.stringify(this.notificationSetting)));
    }
    // Field Condition 추가
    addCondition(event){
        // Condition 의 Alias 가 더 클경우 Max Char 로 설정 ( 'A'.charCodeAt(0) : 65  , 'B'.charCodeAt(0) : 66 )
        let maxChar = this.fieldConditions.reduce( (maxValue,condition) => {
            return (maxValue == null || maxValue.charCodeAt(0) < condition.Alias__c.charCodeAt(0)) ? condition.Alias__c : maxValue;
        } , null);

        // Max Char 가 초기값 Null 그대로인경우에는 시작값 'A' 로 설정, 그외의 경우에는 Max Char 의 다음 문자코드 사용
        let nextChar = maxChar == null ? 'A' : String.fromCharCode(maxChar.charCodeAt(0) +1);
        this.fieldConditions.push({Alias__c : nextChar});
    }
    // Field Condition 변경 Event Handle
    changeCondition(event){
        let param = event.detail;
        if( param != null && param.alias != null ){
            let changeIndex = this.fieldConditions.map(condition=>{ return condition.Alias__c; }).indexOf(param.alias);
            if( changeIndex !== -1 ){
                this.fieldConditions[changeIndex] = param.condition;
            }
        }
    }
    // Field Condition 제거 Event Handle
    removeCondition(event){
        let param = event.detail;
        if( param != null && param.alias != null){
            let newConditions = this.fieldConditions.filter(condition=>{
                return condition.Alias__c !== param.alias;
            });
            this.fieldConditions = newConditions;
        }
    }
    // 전체 Field Condition 제거
    removeAllCondition(){
        this.fieldConditions = [];
    }
    /*---------------------------------------------
     * Apex Call
     ---------------------------------------------*/
    // 필드 목록 조회
    getFieldData(value){
        return fn_getFieldData({objectType: this.notificationSetting[value]})
            .then( resp => {
                let data = resp.data;
                // fields
                this.fields     = data.fields;
                this.fieldTypes = data.fieldTypes;
                this.scheduleBaseFields = data.scheduleBaseFields;
            })
            .catch( err => {
                toastError('Error','Error Occurred',this);
            });
    }
    // 수신자 필드 조회
    getRecipientFieldData(value){
        return fn_getRecipientFieldData({objectType: this.notificationSetting[value]})
            .then( resp => {
                // 수신자 fields
                this.recipientFields    = resp.data.recipientFields;
            })
            .catch( err => {
                toastError('Error','Error Occurred',this);
            })
    }
    // 템플릿 정보 조회
    getTemplateData(value){
        return fn_getTemplateDetail({templateId: value})
            .then( resp => {
                this.notificationTemplate = resp.data.template;
            })
            .catch( err => {
                toastError('Error','Error Occurred',this);
            })
    }
    // Notification Setting 저장
    saveNotificationSetting() {
        this.loading = true;

        let param = {
            notificationSetting : this.notificationSetting,
            fieldConditions     : this.fieldConditions
        }
        fn_saveNotificationSetting({param : param})
            .then( resp => {
                toastSuccess('Success','Success',this);

                this.loading = false;
            })
            .catch( err => {
                toastError('Error','Error Occurred',this);
            })
    }
    // Active 여부 변경
    toggleActivate(){
        this.loading = true;

        let param = {
            notificationSetting : this.notificationSetting
        }
        fn_toggleActivate({param : param})
            .then( resp => {
                let updateSetting = resp.data.notificationSetting;
                this.notificationSetting.IsActive__c = updateSetting.IsActive__c;

                this.loading = false;
                toastSuccess('Success','Success',this);
                eval("$A.get('e.force:refreshView').fire();");
            })
            .catch( err => {
                toastError('Error','Error Occurred',this);
            })
    }
    /*---------------------------------------------
     * Picklist Option
     ---------------------------------------------*/
    get executeOptions(){
        return [
            { label : 'Insert' , value : 'Insert'}
            , { label : 'Update' , value : 'Update'}
            , { label : 'Insert or Update' , value : 'Insert or Update'}
            // , { label : 'Delete' , value : 'Delete'}     // 수신자 정보 Mapping (전화번호,Label 등) 작업이 Queueable 에서 발생. Delete 시 처리불가
        ];
    }
}