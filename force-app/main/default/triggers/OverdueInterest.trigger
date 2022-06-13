/****************************************************************************************
  * @filename      : OverdueInterest
  * @author        : I2MAX
  * @date          : 2021-03-11
  * @group         : 
  * @group-content : 
  * @description   : 
  * @reference     : 
  * @release       : v1.0.0
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author         description
  * ===============================================================
    1.0     2021-03-11          I2MAX            Create
****************************************************************************************/
trigger OverdueInterest on OverdueInterest__c (before insert, before update) {
    new OverdueInterest_tr().run();
}