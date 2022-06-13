/**
 * Created by MS on 2020-07-04.
 */

trigger ContentDocumentLink on ContentDocumentLink (before insert) {
	new ContentDocumentLink_tr().run();
}