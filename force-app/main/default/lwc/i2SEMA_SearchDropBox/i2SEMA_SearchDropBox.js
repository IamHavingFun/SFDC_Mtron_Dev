/****************************************************************************************
 * @filename       : i2SEMA_SearchDropBox
 * @projectname    : i2SEMA Core
 * @author         : i2max_byeon.jw
 * @date           : 2020-04-14 오전 10:19
 * @group          :
 * @group-content  :
 * @description    :
 * @copyright      : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                author              description
 * ===============================================================
 0.1     2020-04-14 오전 10:19     i2max_byeon.jw       Create
 ****************************************************************************************/
import {LightningElement,api,track} from 'lwc';
import util from 'c/i2SEMA_LwcUtil';

export default class I2SemaSearchDropBox extends LightningElement {
    /*--------------------------------------------------
     * Property (Getter & Setter 분리)
     --------------------------------------------------*/
    @track _disabled;           // Disable 여부
    @track _dropBoxItems;       // DropBox 전체 항목 (항목별 Label,Value 속성 필수)
    @track _dropBoxLabel;       // DropBox Label
    @track _dropBoxApi;         // DropBox API
    @track _dropBoxValue;       // DropBox 에서 선택된 항목의 Value 속성값
    @track _inputValue;         // 검색 키워드
    @track _filteredItems;      // 검색 키워드에 필터된 DropBox 항목
    @track _renderCondition;    // DropBox 목록 렌더 여부
    /*--------------------------------------------------
     * Getter & Setter
     --------------------------------------------------*/
    @api
    get disabled(){
        return this._disabled != null ? this._disabled : false;
    }
    set disabled(value){
        this._disabled = value;
    }
    @api
    get dropBoxItems(){
        return this._dropBoxItems;
    }
    set dropBoxItems(value){
        let setTarget;

        if( this.dropBoxItems == null || this.dropBoxItems.length === 0 || value == null ){
            setTarget = true;
        }else {
            const originItemString   = this.dropBoxItems ? JSON.stringify(this.dropBoxItems) : JSON.stringify([]);
            const compareItemString  = value ? JSON.stringify(util.toArray(value)) : JSON.stringify([]);

            if( originItemString !== compareItemString ){
                setTarget = true;
            }
        }
        if( setTarget ){
            this._dropBoxItems  = util.toArray(value);
            this.filteredItems  = this._dropBoxItems;
            // Render
            this.componentRender();
        }
    }
    @api
    get dropBoxLabel(){
        return this._dropBoxLabel;
    }
    set dropBoxLabel(value){
        this._dropBoxLabel = value;
    }
    @api
    get dropBoxApi(){
        return this._dropBoxApi;
    }
    set dropBoxApi(value){
        this._dropBoxApi = value;
    }
    @api
    get dropBoxValue(){
        return this._dropBoxValue;
    }
    set dropBoxValue(value){
        if( this.dropBoxValue != value){
            this._dropBoxValue = value;
            // Render
            this.componentRender();
        }
    }
    get inputValue(){
        return this._inputValue;
    }
    set inputValue(value){
        this._inputValue = value;
    }
    get filteredItems(){
        return this._filteredItems;
    }
    set filteredItems(value){
        this._filteredItems = value;
    }
    get renderCondition(){
        return this._renderCondition;
    }
    set renderCondition(value){
        this._renderCondition = value && this.filteredItems != null && this.filteredItems.length > 0;
    }
    /**
     * @Description Connected Callback
     *   Data Type Casting & Validation
     */
    connectedCallback(){
        // Event Listener 추가
        this.template.addEventListener('focusin', e => { this.renderCondition = true;});
        this.template.addEventListener('focusout',e => { this.renderCondition = false;});
    }
    /**
     * @description 유효성 확인
     *   Label 및 Value 속성이 포함된 항목 처리
     */
    DropBoxValidation(){
        let validity = this.dropBoxItems.reduce((accumulator,item) => {
            let validity = item.hasOwnProperty('label') && item.hasOwnProperty('value');
            return accumulator && validity;
        } , true);

        if( !validity ){
            util.toastError('DropBox Error','items must have label and value property',this);
        }
    }
    /**
     * @description 검색항목 조회
     *   Rendering 반복수행 방지를 위해 @track 속성에 반영하지 않음
     */
    search(event){
        // Value 가 지정되어 있는 상태에서 변경하면 Value = Null 처리 후 Filtering
        if( this.dropBoxValue != null ){
            this.dropBoxValue = null;
            this.fireDropBoxEvent();
        }

        let value = event.target.value; // 입력값
        this.filtering(value);          // 필터링
    }
    /**
     * @description DropBox 항목 필터
     *   대소문자 표현하지 않음
     *   결과를 Label 순으로 정렬
     */
    filtering(value){
        this.filteredItems = this.dropBoxItems
            .filter(item=>{
                // 대소문자 구분하지 않고 Label 일치시 반환
                return new RegExp(value,'i').test(item.label);
            })
            .sort((a,b)=>{
                return a.label - b.label
            });
    }
    /**
     * @description DropBox 항목선택
     *   Click 이벤트 발생 전에 Focus Out 되므로 Mouse Down 시 처리
     */
    itemSelect(event){
        let value = event.currentTarget.dataset.item;
        this.setDropBoxValue(value);
    }
    /**
     * @description DropBox Value 설정
     *   DropBox Select 이벤트 Dispatch (DropBox Name & Value 포함)
     */
    setDropBoxValue(value){
        let itemIndex = this.dropBoxItems.map(item => {
            return item.value;
        }).indexOf(value);

        // Value 에 일치하는 Item 을 찾을경우 Event 발생
        if( itemIndex !== -1 ){
            // Setter 로 인한 반복수행 방지를 위해 값 비교
            if( this.dropBoxValue != value){
                this._dropBoxValue   = this.dropBoxItems[itemIndex].value;
            }

            this.inputValue     = this.dropBoxItems[itemIndex].label;
            this.filtering(this.inputValue);
        }
        // Value 에 일치하는 Item 을 찾지못할경우 Value 초기화
        else{
            // Setter 로 인한 반복수행 방지를 위해 값 비교
            if( this.dropBoxValue != value){
                this._dropBoxValue   = null;
            }
            this.inputValue     = null;
        }
        // Event
        this.fireDropBoxEvent();
    }
    // DropBox Item 이 생성,변경되는 경우 기본값 설정 (컴포넌트 선언시 정의하는 Property 의 순서에 따라 Setter 가 수행되므로 초기 Render 시와 Item 변경시 둘다 수행)
    componentRender(){
        if( util.isNotEmpty(this.dropBoxItems) && util.isNotEmpty(this.dropBoxValue)){
            this.setDropBoxValue(this.dropBoxValue);
        }
    }

    // Fire DropBox Event
    fireDropBoxEvent(){
        // Custom Event
        let param = { 'api' : this.dropBoxApi , 'value' : this.dropBoxValue };
        console.log('DropBox Event (' + this.dropBoxApi + ') >> ' + this.dropBoxValue);

        let dropBoxEvent = new CustomEvent('dropboxselect',{detail : param});
        this.dispatchEvent(dropBoxEvent);
    }

    // Item 비교를 위해
    arrayCompare(array1,array2){

    }
}