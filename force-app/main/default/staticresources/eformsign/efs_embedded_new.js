/*embedding postMessage function*/
//storage get,set method
function storageSetItem(key, value) {
    var covert = encodeURIComponent(value);
    localStorage.setItem(key, covert);
}

function storageGetItem(key) {
    var item = localStorage.getItem(key) || null;
    if (item === 'null' || item === 'undefined' || item === null) {
        return undefined;
    }
    return decodeURIComponent(item);
}

//outside Site set param
function setStorage(data) {
	storageSetItem('access_token', data.message.access_token);
	storageSetItem('refresh_token', data.message.refresh_token);
}


//return iframe key param
function isEmbedding(iframe) {
	var messageObj = {
		fn : 'isEmbedding',
		message : {
			_id : eformsign._id,
			mode : eformsign._mode,
			company_id : storageGetItem('company_id'),
			access_token : storageGetItem('access_token'),
			refresh_token : storageGetItem('refresh_token'),
			outside_key : eformsign._outside_key,
			return_key : eformsign._return_key,
			doc_param : eformsign._set_key_value,
			mail_subject : eformsign._mail_subject,
			mail_content : eformsign._mail_content,
			mail_list : eformsign._mail_list,
			notification : eformsign._notification,
		}
	};
	var message_domain = eformsign._domain;
	if(eformsign._external_domain != null){
		message_domain = eformsign._external_domain;
	}
	iframe.postMessage(JSON.stringify(messageObj), message_domain);
}

//company is not collect.
function errorMessage(data) {
	eformsign.errorCallback(data);
	
}

//saveSuccess callback
function saveSuccess(data) {
	eformsign.successCallback(data);
}

//not found function
function notFoundFn(iframe) {
	var messageObj = {
		fn : 'notFoundFn',
		message : 'not Found Function'
	};
	iframe.postMessage(JSON.stringify(messageObj), eformSignUrlResource.getDomain());
}

/*listener event Controller*/
function messageController(message) {
	var data = JSON.parse(message.data);

	var iframe = message.source;
	switch (data.fn) {
	case 'setStorage':
		setStorage(data);
		break;
	case 'isEmbedding':
		isEmbedding(iframe);
		break;
	case 'errorMessage':
		errorMessage(data);
		break;	
	case 'saveSuccess':
		saveSuccess(data);
		break;	
	default:
		notFoundFn(iframe);
		break;
	}
}

/*iframe cross domain solution listener*/ 
window.addEventListener('message', messageController, false);

var eformsign = {	
	/*eformsign viewer*/
	viewer : "/eform/document/view_service.html",
	/*eformsign Parameter*/
	_mode : 'EMBEDDING',
	_form_id : null,
	_iframe_id : null,
	_outside_key : null,
	_return_key : [],
	_set_key_value : {},
	_external_domain :  null,
	_domain : "https://www.eformsign.com",
	_id : null,
	_mail_subject : '',
	_mail_content : '',
	_mail_list : [],
	_notification : null,
	_success_callback : null,
	_error_callback : null,
	/*eformsign Function*/
	//eformSignRun
	open : function(document_id){
		var returnData = {
			status : true,
			message : '',
		};
		// returnData.status = false;
		// returnData.message = 'viewerParam is not collect.';
		var eformSignUrl = '';
		if(this._external_domain != null){ //external Mode
			eformSignUrl = this._external_domain +'&openmode='+this._mode;
		}else{// internal Model
			eformSignUrl =  this._domain + this.viewer + '?form_id=' + this._form_id+'&openmode='+this._mode;
			if(document_id !== 'undefined' && document_id){
				eformSignUrl +='&document_id='+ document_id +'&openmode='+this._mode;
				this._mail_subject = '';
				this._mail_content = '';
				this._mail_list=[];
			}
		}
		$("#" + this._iframe_id).attr('src', eformSignUrl);
		return returnData;
	},
	viewDocument : function(document_id){
		var eformSignUrl = '';
		if(this._external_domain != null){ //external Mode
			//TODO
			
		}else{ // internal Model
			eformSignUrl =  this._domain + this.viewer + '?form_id=' + this._form_id+'&openmode='+this._mode;
		}
		if(document_id !== 'undefined' && document_id){
			eformSignUrl +='&document_id='+ document_id +'&viewFlag=true&openmode='+this._mode;
		}

		$("#" + this._iframe_id).attr('src', eformSignUrl);
	},
	//setParameter setEformSignParam
	setInit : function(type, setting_object, iframe_id){
		if( type == 'internal' ){
			storageSetItem('company_id', setting_object.company_id);
			this._form_id = setting_object.form_id;
			this._outside_key = setting_object.user_key;
		}else if( type == 'external' ){
			this._external_domain = setting_object.external_url;
		}else{
			//error message todo
		}
		this._iframe_id = iframe_id;
	},
	setToken : function(eformsignId, access_token, refresh_token){
		this._id = eformsignId;
		storageSetItem('access_token', access_token);
		storageSetItem('refresh_token', refresh_token);
	},
	setDomain : function(domain){
		this._domain = domain;
	},
	setReturnKey : function(obj){
		this._return_key.length = 0;
		$.each(obj,function(idx, val){
			eformsign._return_key.push(val);
		});
	},
	setDocumentParam : function(obj){
		this._set_key_value = obj;

	},
	setCallback : function (suucessCallback, errorCallback){
		this._success_callback = suucessCallback;
		this._error_callback = errorCallback;
	},
	setMail : function(mail){
		this._mail_subject = mail.subject;
		this._mail_content = mail.content;
		this._mail_list = mail.mail_list;
	},
	setNotification : function(notify){
		this._notification = notify;
	},
	successCallback : function(data){
		if(this._success_callback != null){
			this._success_callback(data);
		}else{
			console.log(data.fn);
			console.log(data.code);
			console.log(data.message);
			console.log(data.document_id);
			console.log(data.title);
			console.log(data.values);
		}
	},
	errorCallback : function(data){
		if(this._error_callback != null){
			this._error_callback(data);
		}
		else{
			alert(data.message);
			console.log(data.fn);
			console.log(data.code);
			console.log(data.message);
		}
	},
	tokenClear : function(){
		localStorage.removeItem('company_id');
		localStorage.removeItem('access_token');
		localStorage.removeItem('refresh_token');
		
	}
};

/*
 * ================================================================
 * aura에서 사용하기 위해 첨부된 소스
 * window에 연결시켜야 한다.
 * ================================================================
 */
window.eformsign = eformsign;