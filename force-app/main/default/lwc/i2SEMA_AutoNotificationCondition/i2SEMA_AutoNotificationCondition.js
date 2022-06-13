/****************************************************************************************
 * @filename       : i2SEMA_AutoNotificationCondition
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
import {LightningElement , api , track } from 'lwc';
import { isEmpty, isNotEmpty, toArray} from 'c/i2SEMA_LwcUtil';

// Additional JS
import {SUPPORTED_TYPES, COMPARE_OPERATOR , STANDALONE_OPERATORS } from "./constant";

export default class I2SemaAutoNotificationCondition extends LightningElement {
    /*
         * Component APIs
         */
    @api objectType;                    // 오브젝트 타입
    @api fields;                        // 전체 필드목록
    @api fieldTypes;                    // 필드 타입목록
    @api originCondition;               // NotificationFieldCondition__c 레코드
    /*
     * 조건부 처리를 위한 Tracking
     */
    @track condition;                   // 수정된 NotificationFieldCondition__c 레코드
    @track operationOptions;            // 비교 연산자 목록
    @track compareFields;               // 동일한 타입의 비교필드 목록
    @track compareFieldRender;          // 비교 필드 선택 목록 Render Flag
    @track valueRender;                 // 자체값 Input Render Flag
    /*
     * 조건값 처리를 위한 Input Render Flag
     */
    @track BOOLEAN_Render;              // BOOLEAN__c
    @track CURRENCY_Render;             // CURRENCY__c
    @track DATETIME_Render;             // DATETIME__c
    @track DATE_Render;                 // DATE__c
    @track TIME_Render;                 // TIME__c
    @track EMAIL_Render;                // EMAIL__c
    @track DOUBLE_Render;               // DOUBLE__c
    @track LONG_Render;                 // LONG__c
    @track INTEGER_Render;              // INTEGER__c
    @track PERCENT_Render;              // PERCENT__c
    @track PHONE_Render;                // PHONE__c
    @track REFERENCE_Render;            // REFERENCE__c
    @track PICKLIST_Render;             // PICKLIST__c
    @track STRING_Render;               // STRING__c

    /* --------------------------------------------------------------------------------------------------------
     * Rendering Flag
    -------------------------------------------------------------------------------------------------------- */
    get emptyFields(){
        return this.fields == null || this.fields.length < 1;
    }

    /**
     * Connected Callback
     */
    connectedCallback(){
        // API 속성값으로 전달된 데이터를 Track 속성값으로 전달
        if( this.originCondition != null ){
            this.condition = JSON.parse(JSON.stringify(this.originCondition));
        }
        // condition 의 속성값을 초기화한다.
        if(this.condition == null){
            this.condition = {
                NotificationAutomaticSetting__c     : null,
                Field__c                            : null,
                CompareWith__c                      : null,
                CompareField__c                     : null,
                Operator__c                         : null,
            };
        }
        else{
            this.componentRender();
        }
    }
    /**
     * Component Render
     *  > 저장된 값을 불러들이는 과정 또는 신규 조건을 생성,수정하는 과정에 수행
     */
    componentRender(){
        // Input UI Rendering
        if( isNotEmpty(this.condition.Field__c)){
            // 조건 Field 의 Type 획득
            let fieldType   = this.fieldTypes[this.condition.Field__c];

            // 비교대상
            let compareWith = this.condition.CompareWith__c;
            //  연산자
            let operator    = this.condition.Operator__c;

            // Field Type 설정
            this.condition.FieldType__c = fieldType;

            // 관련 항목 Rendering
            this.renderInputUI(fieldType);
            this.renderOperators(fieldType,compareWith);
            this.renderValueInput(fieldType,operator,compareWith);
        }
    }
    /**
     * 조건필드 타입에 일치하는 Input UI 설정
     */
    renderInputUI(fieldType){
        this.BOOLEAN_Render          = SUPPORTED_TYPES.BOOLEAN === fieldType;
        this.CURRENCY_Render         = SUPPORTED_TYPES.CURRENCY === fieldType;
        this.DATETIME_Render         = SUPPORTED_TYPES.DATETIME === fieldType;
        this.DATE_Render             = SUPPORTED_TYPES.DATE === fieldType;
        this.TIME_Render             = SUPPORTED_TYPES.TIME === fieldType;
        this.EMAIL_Render            = SUPPORTED_TYPES.EMAIL === fieldType;
        this.DOUBLE_Render           = SUPPORTED_TYPES.DOUBLE === fieldType;
        this.LONG_Render             = SUPPORTED_TYPES.LONG === fieldType;
        this.INTEGER_Render          = SUPPORTED_TYPES.INTEGER === fieldType;
        this.PERCENT_Render          = SUPPORTED_TYPES.PERCENT === fieldType;
        this.PHONE_Render            = SUPPORTED_TYPES.PHONE === fieldType;
        this.REFERENCE_Render        = SUPPORTED_TYPES.REFERENCE === fieldType;
        this.PICKLIST_Render         = SUPPORTED_TYPES.PICKLIST === fieldType;
        this.STRING_Render           = SUPPORTED_TYPES.STRING === fieldType;
    }
    /**
     * 조건필드 타입에 일치하는 Operator Option 설정
     */
    renderOperators(fieldType,compareWith){
        if(isEmpty(compareWith) || compareWith === 'it-self' ){
            this.operationOptions = COMPARE_OPERATOR.SELF_COMPARE[fieldType];
        }else if( compareWith === 'other field'){
            this.operationOptions = COMPARE_OPERATOR.OTHER_COMPARE[fieldType];
        }
    }
    /**
     * 비교값 Render 처리
     */
    renderValueInput(fieldType, operator, compareWith){
        console.log('Render Input Value ' + fieldType + ' / ' + operator + ' / ' + compareWith);
        if(isEmpty(fieldType) || isEmpty(operator) || isEmpty(compareWith)){
            return;
        }
        // 독립수행 연산자 여부 확인
        let isStandaloneOperator = STANDALONE_OPERATORS.map( standAloneOperator => {
            return standAloneOperator.value;
        }).includes(operator);

        console.log('isStandalone Operator ? ' +  isStandaloneOperator);

        // 입력값 Render 여부 (자신 비교이며, 독립 수행 연산자가 아닌경우)
        this.valueRender        = compareWith === 'it-self' && !isStandaloneOperator;

        // 비교필드 Render 여부 (타 필드와 비교하며, 현재 필드와 타입이 같은경우)
        this.compareFieldRender = compareWith === 'other field';
        this.compareFields      = toArray(this.fields).filter( field => {
            return this.fieldTypes[field.value] === fieldType
        });
    }
    // 필드,비교필드 선택
    handleDropBoxEvent(event){
        let args = event.detail;
        if( args != null && args.api != null && this.condition[args.api] !== args.value){
            this.condition[args.api] = args.value;
        }

        this.componentRender();
        this.fireChangeEvent();
    }
    // 연산자 선택
    handleOperatorChange(event){
        this.condition.Operator__c  = event.target.value;
        this.componentRender();
        this.fireChangeEvent();
    }
    // 비교대상 선택
    handleCompareChange(event){
        this.condition.CompareWith__c   = event.target.value;
        this.componentRender();
        this.fireChangeEvent();
    }
    // 필드값 변경
    handleFieldValue(event){
        if( event.target.name === 'BOOLEAN__c'){
            this.condition[event.target.name] = event.target.checked;
        }
        else{
            this.condition[event.target.name] = event.target.value;
        }
        this.fireChangeEvent();
    }
    // 변경 Event
    fireChangeEvent(){
        // console.log(JSON.parse(JSON.stringify(this.fieldCondition)));
        let param = { alias : this.condition.Alias__c , condition : this.condition };
        let changeEvent = new CustomEvent('changecondition',{detail:param});
        this.dispatchEvent(changeEvent);
    }
    // 조건 삭제
    removeCondition(event){
        let param = { alias : this.condition.Alias__c };
        let removeEvent = new CustomEvent('removecondition',{detail:param});
        this.dispatchEvent(removeEvent);
    }
    // Picklist Option
    get compareWithOptions(){
        return [
            {label:'it-self', value:'it-self'},
            {label:'other field',value:'other field'}
        ];
    }
}