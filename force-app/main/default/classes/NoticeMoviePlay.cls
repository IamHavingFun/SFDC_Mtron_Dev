/****************************************************************************************
  * @filename      : NoticeMoviePlay
  * @author        : i2max_my.Seo
  * @date          : 2020-11-19 오후 12:46
  * @group         :
  * @group-content :
  * @description   : 공지사항용 - 동영상 플레이이
  * @tester        : NoticeMoviePlay_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-11-19 오후 12:46     i2max_my.Seo           Create
****************************************************************************************/
public without sharing class NoticeMoviePlay {

	/**
	 * Wrapper class for InitData
	 */
	public class InitData extends I2ComClass.InitData {
		@AuraEnabled
		public Boolean isMovie {get;private set;}
		@AuraEnabled
		public String movieType {get;private set;}
		@AuraEnabled
		public String movieUrl {get;private set;}
	}

	/**
	 * Init method
	 *
	 * @return I2ComClass.InitData
	 */
	@AuraEnabled
	public static I2ComClass.InitData init(final String recordId, final Boolean isPartner) {
		InitData initData = new InitData();
		System.debug(recordId + ' : ' + isPartner);
		NoticeBoard__c board = [
				SELECT Id, MovieType__c, MovieURL__c,
				(SELECT ContentDocumentId, FileExtension, FileType FROM AttachedContentDocuments)
				FROM NoticeBoard__c WHERE Id = :recordId
		];
		initData.isMovie = false;
		if(String.isEmpty(board.MovieType__c) == false) {
			initData.isMovie = true;
			initData.movieType = board.MovieType__c;
			if(board.MovieType__c == '링크') {
				initData.movieUrl = board.MovieURL__c;
			} else {
				Set<String> checkMovies = new Set<String>{
					'mkv', 'avi', 'mp4', 'mpg', 'flv', 'wmv', 'asf', 'asx', 'ogm', 'ogv', 'mov'
				};
				for(AttachedContentDocument file  : board.AttachedContentDocuments) {
					if(checkMovies.contains(file.FileType.toLowerCase())) {
						initData.movieUrl = '/sfc/servlet.shepherd/document/download/'+ file.ContentDocumentId+'?asPdf=false&operationContext=CHATTER';
						///view
						if(isPartner) {
							initData.movieUrl = '/Partner' + initData.movieUrl;
						}
					}
				}
			}

			if(String.isEmpty(initData.movieUrl)) initData.isMovie = false;
		}
		return initData;
	}

}