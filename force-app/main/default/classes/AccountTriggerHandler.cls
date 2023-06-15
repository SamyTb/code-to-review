Ajout Mamadou de ligne 764 à 821
en after insert  :  de 472 à 476 , de 491 à 519  et de 536 à 541
en after update  : de 647 à 651 , de 669 à 694  de 736 à 742
/***
* @author Attali David
* @date 21/11/2018
* @description Handler de trigger pour l'objet compte (Account)
*/
public class AccountTriggerHandler implements ITriggerHandler, IValidable {
    public static Boolean triggerDisabled = false;
    public static Map<Id, User> ownerRefereeDataMap = new Map<Id, User>();
    public static Map<Id, AccountSectorization__c> sectorisationsMap = new Map<Id, AccountSectorization__c>();
    public static Map<String, Id> postalCityToUserId = new Map<String, Id>();
    public static Map<String, AccountSectorization__c> postalCityBySecto = new Map<String, AccountSectorization__c>();
    public static Boolean hasSectorisationPermission;
    public static Map<Id, Account> parentCompanyMap = new Map<Id, Account>();

    public static Map<Id, Task> mapTaskIdToTaskToBeUpdated = new Map<Id, Task>();

    public static Map<Id, Boolean> userByBusinessSegmentCustomPermission = new Map<Id, Boolean>();

    public static List<Task> tasksToInsert = new List<Task>();
    public static List<Event> eventsToUpdate = new List<Event>();

    public static Map<Id, Account> mapAccountIdToAccountForReferee = new Map<Id, Account>();
    public static Map<Id, Account> mapAccountIdToAccountForOwner = new Map<Id, Account>();
    public static Map<Id, Account> mapAccountIdToAccountForIsEmployee = new Map<Id, Account>();
    //XESO-412
    // Map pour stocker des instances individus à créer
    public static Map<Id, Individual> mapAccountIdToIndividual = new Map<Id, Individual>();
    // Map pour stocker du compte qui correspond à individu
    public static Map<Id, Id> mapIndividualIdToAccountId = new Map<Id, Id>();
    // Map pour stocker le consentement récupéré
    public static Map<Id, ContactPointTypeConsent> mapAccountToMarketingEmailConsent = new Map<Id, ContactPointTypeConsent>();
    //Mamadou
    //XET-670 Trigger PM to PM
    //Map pour stocker les sirens des comptes PM crées ou modifiées
    public static Set<String> sirensSet = new Set<String>(); 
    //Map pour stocker les Ids des comptes PM sièges par siren
    public static Map<String,List<Id>> mapSirenToListIdAccountSiege = new Map<String,List<Id>>();
    //Map pour stocker les comptes PM non sièges par siren
    public static Map<String,List<Account>> mapSirenToAccountSecondaire = new Map<String,List<Account>>();

    public static Set<String> inseesSet = new Set<String>();
    public static Set<String> zipcodesSet = new Set<String>();
    public static Set<String> communeIdsSet = new Set<String>();
 
    public static final Set<String> statusList = new Set<String>{Label.DuplicateAccountInProgressStatus, Label.DuplicateAccountToBeDoneStatus};

    public static final List<PermissionSetAssignment> listPermSet = [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE Assignee.Id = :UserInfo.getUserId() AND PermissionSet.Name = 'STAMBIA_ALM'];

    public Boolean isDisabled() {
        return (triggerDisabled || TriggerSwitch_UTL.isTriggerDisabled(this.getTriggerName())) ? true : false;
    }

    public List<SObject> ValidateInsert (List<sObject> triggerNew) {
        return Account_VR.ValidateInsert(triggerNew);
    }

    public Map<Id, SObject> ValidateUpdate (Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        return Account_VR.ValidateUpdate(newItems, oldItems);
    }
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public void beforeInsert(List<SObject> newItems) {
        /** To avoid CPU limit the Update trigger should be bypassed*/
        TriggerSwitch_UTL.enforcedByPass.add('AccountTriggerBEFORE_UPDATE');
        TriggerSwitch_UTL.enforcedByPass.add('AccountTriggerAFTER_UPDATE');
        System.debug(LoggingLevel.INFO, '#### CPU LIMIT Before insert START: '+Limits.getCpuTime());
        List<Account> accountsList = (List<Account>)newItems;
        Set<String> userIds = new Set<String> ();
        List<Account> mdproAccounts = new List<Account>();
        Set<String> postalCodes = new Set<String>();
        Set<String> setCity = new Set <String>();

        Set<String> communeTempIdsSet = new Set <String>();
        Set<String> inseesTempSet = new Set <String>();
        Set<String> zipcodesTempSet = new Set <String>();

        /** Check if the user has custom permission for sectorisation*/
        if(hasSectorisationPermission == null){
            System.debug('before secto'+ hasSectorisationPermission);
            hasSectorisationPermission = ApexCustomPermissionSwitch_UTL.hasCustomPermission('Sectorisation_CP');
            System.debug('after secto'+ hasSectorisationPermission);
        }

        /** This first loop retrieve all the related records/data and store them in a map */
        for(Account acc: accountsList){
            /** filter in mdpro recordTypes*/
            if(AccountMain_UTL.isMDProRecord(acc.RecordTypeId)){
                mdproAccounts.add(acc);
                String communeOfBirth = acc.CommuneOfBirth__pc;
                String inseeBirthPlace = acc.InseeBirthPlace__pc;
                String zipCodePlaceOfBirth = acc.ZipCodePlaceOfBirth__pc;
                Boolean isPP = acc.IsPersonAccount;
                String personMailingPostalCode = acc.PersonMailingPostalCode;
                String personMailingCity = acc.PersonMailingCity;
                String billingPostalCode = acc.BillingPostalCode;
                String billingCity = acc.BillingCity;
                /** Retrieve Commune, Zipcode and insee code*/
                if (communeOfBirth != null && !communeIdsSet.contains(communeOfBirth)) {
                    communeIdsSet.add(communeOfBirth);
                    communeTempIdsSet.add(communeOfBirth);
                }
                //XSMDPRO-1045
                if (inseeBirthPlace != null && !inseesSet.contains(inseeBirthPlace)){
                    inseesSet.add(inseeBirthPlace);
                    inseesTempSet.add(inseeBirthPlace);
                }
                if(zipCodePlaceOfBirth != null && !zipcodesSet.contains(zipCodePlaceOfBirth)) {
                    zipcodesSet.add(zipCodePlaceOfBirth);
                    zipcodesTempSet.add(zipCodePlaceOfBirth);
                }

                /** Retrieve postal codes */
                if(isPP && String.isNotBlank(personMailingPostalCode) && postalCityBySecto.get(String.ValueOf(personMailingPostalCode + personMailingCity)) == null){
                    postalCodes.add(personMailingPostalCode);
                }else if(!isPP && String.isNotBlank(billingPostalCode) && postalCityBySecto.get(String.ValueOf(billingPostalCode + billingCity)) == null){
                    postalCodes.add(billingPostalCode);
                }
                /** Retrieve cities*/
                if(isPP && String.isNotBlank(personMailingCity) && postalCityBySecto.get(String.ValueOf(personMailingPostalCode + personMailingCity)) == null){
                    setCity.add(personMailingCity);
                }else if(!isPP && String.isNotBlank(billingCity) && postalCityBySecto.get(String.ValueOf(billingPostalCode + billingCity)) == null){
                    setCity.add(billingCity);
                }
            }
        }

        /** Create maps with commune, country to use them after in the loop*/
        if(communeTempIdsSet.size() > 0 || inseesTempSet.size() > 0 || zipcodesTempSet.size() > 0){
            Account_SVE_Normalization.getCountriesAndCommunes(communeTempIdsSet, inseesTempSet, zipcodesTempSet);
        }

        /** Retrieve sectorisation*/
        if(postalCodes.size() > 0 || setCity.size() > 0){
            sectorisationsMap.putAll(new Map<Id, AccountSectorization__c>([SELECT Id, PostalCode__c, Inspector__c, Inspector__r.IsActive, City__c, Free_Zone__c FROM AccountSectorization__c WHERE PostalCode__c IN : postalCodes OR City__c IN: setCity]));
            for(AccountSectorization__c sec: sectorisationsMap.values()){
                if (sec.Inspector__r.IsActive) {
                    /** Used for the methods Account_SVE.setDefaultOwner()*/
                    postalCityToUserId.put(sec.PostalCode__c, sec.Inspector__c);
                }
                /** Used for the methods Account_SVE.flagFreeZoneAccount()*/
                postalCityBySecto.put(String.ValueOf(sec.PostalCode__c + sec.City__c).toLowercase(), sec);
            }
        }

        for(Account acc: mdproAccounts) {
            /** XSMDPRO-601 Reassign accounts to avoid to have accounts assigned to technical users
             * XES-212 this method should be launched first to get the new owner */
            Account_SVE.setDefaultOwnerAccounts(acc);

            /** Retrieve users data if its not already done*/
            if(String.isNotBlank(acc.OwnerId) && ownerRefereeDataMap.get(acc.OwnerId) == null) {
                userIds.add(acc.OwnerId);
            }
            if(String.isNotBlank(acc.Referee__c) && ownerRefereeDataMap.get(acc.Referee__c) == null) {
                userIds.add(acc.Referee__c);
            }
        }
        /** This map will be used in the next loop*/
        Map<Id, User> userMap = new Map<Id, User> ();
        if (userIds.size() > 0) {
            userMap = new Map<Id, User>([SELECT Id, Fonction__c, NetworkAssignment__c, NetworkMembership__c, FirstName, Accompanist__c,AccompanistRights__c, FreezeDate__c FROM User WHERE Id IN :userIds]);
            ownerRefereeDataMap.putAll(userMap);
        }

        /** This second loop manage the business logic*/
        for(Account acc: mdproAccounts){
            if(acc.IsPersonAccount){
                Account_SVE_FieldUpdate.setGender(acc); //refacto PB_ACCT_SUB_01_UpdateGender
                Account_SVE_FieldUpdate.setPartner(acc); //refacto PB_ACCT_SUB_02_UpdatePartnerForPerson
                Account_SVE_FieldUpdate.setMarketingAttributes(acc, 'CustomerEquipment__pc', AccountMain_UTL.EQUIPEMENTMAPPP); //refacto PB_ACCT_SUB_10_MarketingAttributUpdate & PB_ACCT_SUB_11_MarketingBusinessAttributUpdate
                Account_SVE_FieldUpdate.setIncomeRange(acc);
                Account_SVE_FieldUpdate.setPatrimonyRange(acc);
                Account_SVE_FieldUpdate.resetMatrimonialRegime(acc);
                Account_SVE_FieldUpdate.setPhoneCheck(acc, null);
                Account_SVE_FieldUpdate.setTaxResidence(acc);

            }else{
                Account_SVE_FieldUpdate.setMarketingAttributes(acc, 'EquipementBusinessCustomer__c', AccountMain_UTL.EQUIPEMENTMAPPM); //refacto PB_ACCT_SUB_10_MarketingAttributUpdate & PB_ACCT_SUB_11_MarketingBusinessAttributUpdate
                Account_SVE_FieldUpdate.setRevenueRange(acc);
                Account_SVE_FieldUpdate.setEmployeeNumberRange(acc);
                Account_SVE.setPartnerPM(acc);
            }
            Account_SVE_FieldUpdate.setOwnerChangesApprovalFields(acc);
            Account_SVE_Borrow.clearCommonPotEntryDate(acc, ownerRefereeDataMap); //refacto PB_ACCT_SUB_09_ClearCommonPotDate
            Account_SVE_FieldUpdate.setEmailCheck(acc, null); //refacto PB_ACCT_SUB_14_EmailChange
            Account_SVE_Normalization.normalizeNameBeforeInsert(acc); //refacto PB_ACCT_SUB_13_AccountNameUpperCase
            Account_SVE.convertToCustomer(acc, null); //refacto PB_ACCT_SUB_15_SwitchRecordTypeCustomer
            Account_SVE_FieldUpdate.setOwnerFunctionBeforeInsert(acc, ownerRefereeDataMap);
            Account_SVE.setModifiedDateBeforeInsert(acc);
            LeadToAccountFieldRemapping_SVE.fieldRemapping(acc);
            Account_SVE_Normalization.setInseeBirthPlace(acc, null);
            Account_SVE.setBusinessSegment(acc, ownerRefereeDataMap);
            Account_SVE_Borrow.setIsBorrowPeriod(acc);
            Account_SVE_FieldUpdate.setTechBirthDate(acc);
            Account_SVE_Normalization.normalizeAdress(acc);

            Account_SVE_FieldUpdate.updateHasOpportunity(acc);
            Account_SVE_FieldUpdate.updateMarketingSynchro(acc);
            Account_SVE_FieldUpdate.updateFonction(acc);
            Account_SVE_Normalization.truncateAdresse(acc);
            Account_SVE_FieldUpdate.copyCSPListBeforeInsert(acc);
            Account_SVE_FieldUpdate.setCommunicationDateForRepere(acc, null);
            Account_SVE.flagFreeZoneAccount(acc, null, true);
            if(!system.isBatch() && !system.isFuture()){
                /** Essayer de faire un queuable sur la collection à la fin*/
                Account_SVE_FieldUpdate.runAccountNormalisation(acc);
            }
            Account_SVE.shareAccountstoVAD(acc,null,ownerRefereeDataMap);

        }
        system.Debug(LoggingLevel.INFO, '#### AccountTriggerHandler | beforeinsert() => list of accounts to insert Before: '+newItems);
        System.debug(LoggingLevel.INFO, '#### CPU LIMIT Before insert END: '+Limits.getCpuTime());
    }

    @SuppressWarnings('PMD.AvoidDebugStatements')
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        System.debug(LoggingLevel.INFO, '#### CPU LIMIT Before update START: '+Limits.getCpuTime());
        Map<Id, Account> mdproNewAccountsMap = new Map<Id, Account>();
        Map<Id, Account> mdproOldAccountsMap = new Map<Id, Account>();
        Map<Id, Account> oldAccounts = (Map<Id, Account>)oldItems;
        Set<Id> userIdsSet = new Set<Id>();
        List<Account> accountsWithRefereeOrOwnerChanged = new List<Account> ();
        List<Account> accountsWithOwnerChangedIdsList = new List<Account> ();
        Set<String> postalCodes = new Set<String>();
        Set<String> setCity = new Set <String>();

        Set<String> communeTempIdsSet = new Set <String>();
        Set<String> inseesTempSet = new Set <String>();
        Set<String> zipcodesTempSet = new Set <String>();

        /** This first loop retrieve all the related records/data and store them in a map */
        for(Account acc: ((Map<Id, Account>)newItems).values()){
            /** filter in mdpro recordTypes*/
            if(AccountMain_UTL.isMDProRecord(acc.RecordTypeId)){
                Account oldAcc = oldAccounts.get(acc.Id);
                mdproNewAccountsMap.put(acc.Id, acc);
                mdproOldAccountsMap.put(acc.Id, oldAcc);

                Id newOwnerId = acc.OwnerId;
                Id oldOwnerId = oldAcc.OwnerId;
                Id newRefereeId = acc.Referee__c;
                Id oldRefereeId = oldAcc.Referee__c;

                String communeOfBirth = acc.CommuneOfBirth__pc;
                String inseeBirthPlace = acc.InseeBirthPlace__pc;
                String zipCodePlaceOfBirth = acc.ZipCodePlaceOfBirth__pc;
                Boolean isPP = acc.IsPersonAccount;
                String personMailingPostalCode = acc.PersonMailingPostalCode;
                String personMailingCity = acc.PersonMailingCity;
                String billingPostalCode = acc.BillingPostalCode;
                String billingCity = acc.BillingCity;
                /** get the owner/referee*/
                if(userByBusinessSegmentCustomPermission.get(newOwnerId) == null){
                    userIdsSet.add(newOwnerId);
                }
                if (userByBusinessSegmentCustomPermission.get(oldOwnerId) == null) {
                    userIdsSet.add(oldOwnerId);
                }
                if(newRefereeId != null && userByBusinessSegmentCustomPermission.get(newRefereeId) == null){
                    userIdsSet.add(newRefereeId);
                }
                if (String.isNotBlank(newRefereeId) && userByBusinessSegmentCustomPermission.get(newRefereeId) == null && (oldRefereeId != newRefereeId || oldAcc.NoAutoUnborrow__c != acc.NoAutoUnborrow__c)) {
                    userIdsSet.add(newRefereeId);
                }
                /** Check if the owner/referee was changed*/
                if (oldOwnerId != newOwnerId  || oldRefereeId != newRefereeId) {
                    accountsWithRefereeOrOwnerChanged.add(acc);
                }
                if(oldOwnerId != newOwnerId){
                    accountsWithOwnerChangedIdsList.add(acc);
                }
                /** Retrieve Commune, Zipcode and insee code*/
                if (communeOfBirth != null && !communeIdsSet.contains(communeOfBirth)) {
                    communeIdsSet.add(communeOfBirth);
                    communeTempIdsSet.add(communeOfBirth);
                }
                //XSMDPRO-1045
                if (inseeBirthPlace != null && !inseesSet.contains(inseeBirthPlace)){
                    inseesSet.add(inseeBirthPlace);
                    inseesTempSet.add(inseeBirthPlace);
                }
                if(zipCodePlaceOfBirth != null && !zipcodesSet.contains(zipCodePlaceOfBirth)) {
                    zipcodesSet.add(zipCodePlaceOfBirth);
                    zipcodesTempSet.add(zipCodePlaceOfBirth);
                }
                /** Retrieve postal codes */
                if(isPP && String.isNotBlank(personMailingPostalCode) && postalCityBySecto.get(String.ValueOf(personMailingPostalCode + personMailingCity)) == null){
                    postalCodes.add(personMailingPostalCode);
                }else if(!isPP && String.isNotBlank(billingPostalCode) && postalCityBySecto.get(String.ValueOf(billingPostalCode + billingCity)) == null){
                    postalCodes.add(billingPostalCode);
                }
                /** Retrieve cities*/
                if(isPP && String.isNotBlank(personMailingCity) && postalCityBySecto.get(String.ValueOf(personMailingPostalCode + personMailingCity)) == null){
                    setCity.add(personMailingCity);
                }else if(!isPP && String.isNotBlank(billingCity) && postalCityBySecto.get(String.ValueOf(billingPostalCode + billingCity)) == null){
                    setCity.add(billingCity);
                }
            }
        }
        Map<Id, Id> accountByApprobationProcessMap = new Map<Id, Id>();
        List<AccountMergeHistory__c> pendingMergeAccounts = [SELECT Id, MasterAccount__c, DuplicatedAccount__c FROM AccountMergeHistory__c WHERE (MasterAccount__c IN: mdproNewAccountsMap.keySet() OR DuplicatedAccount__c IN: mdproNewAccountsMap.keySet()) AND Status__c IN: statusList];
        for(AccountMergeHistory__c approb: pendingMergeAccounts){
            accountByApprobationProcessMap.put(approb.MasterAccount__c, approb.Id);
            accountByApprobationProcessMap.put(approb.DuplicatedAccount__c, approb.Id);
        }

        /** Create maps with commune, country to use them after in the loop*/
        if(communeTempIdsSet.size() > 0 || inseesTempSet.size() > 0 || zipcodesTempSet.size() > 0){
            Account_SVE_Normalization.getCountriesAndCommunes(communeTempIdsSet, inseesTempSet, zipcodesTempSet);
        }

        /** check if the owner/referee has a custom permission */
        if(userIdsSet.size() > 0){
            Map<String, Set<Id>> permissionByUsersMap = User_UTL.getUsersWithCustomPermissions(userIdsSet, new List<String>{ResourceAttributes_CST.CUSTOMPERMISSIONNAME_CRC_DESACTIVER_PROSPECTABILITE});
            for(Id userId: userIdsSet){
                userByBusinessSegmentCustomPermission.put(userId, permissionByUsersMap.get(ResourceAttributes_CST.CUSTOMPERMISSIONNAME_CRC_DESACTIVER_PROSPECTABILITE).contains(userId));
            }
        }

        /** Get user info + current user*/
        if(ownerRefereeDataMap?.get(UserInfo.getUserId()) == null){
            userIdsSet.add(UserInfo.getUserId());
        }
        if(userIdsSet.size() > 0){
            Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Fonction__c, NetworkAssignment__c, NetworkMembership__c, FirstName, Accompanist__c,AccompanistRights__c, FreezeDate__c FROM User WHERE Id IN: userIdsSet]);
            ownerRefereeDataMap.putAll(userMap);
        }

        /** Retrieve sectorisation*/
        if(postalCodes.size() > 0){
            sectorisationsMap.putAll(new Map<Id, AccountSectorization__c>([SELECT Id, PostalCode__c, Inspector__c, Inspector__r.IsActive, City__c, Free_Zone__c FROM AccountSectorization__c WHERE PostalCode__c IN : postalCodes OR City__c IN: setCity]));
            for(AccountSectorization__c sec: sectorisationsMap.values()){
                if (sec.Inspector__r.IsActive) {
                    /** Used for the methods Account_SVE.setDefaultOwner()*/
                    postalCityToUserId.put(sec.PostalCode__c, sec.Inspector__c);
                }
                /** Used for the methods Account_SVE.flagFreeZoneAccount()*/
                postalCityBySecto.put(String.ValueOf(sec.PostalCode__c + sec.City__c).toLowercase(), sec);
            }
        }

        User currentUserInfo = ownerRefereeDataMap.get(UserInfo.getUserId());

        /** Get related opportunities, event, tasks info*/
        Map<Id, Account> accountWithRelatedRecordsMap = new Map<Id, Account>();
        if(accountsWithRefereeOrOwnerChanged.size() > 0){
            if (accountsWithRefereeOrOwnerChanged.size() > 0) {
                accountWithRelatedRecordsMap = new Map<Id, Account>([SELECT Id, Type, (SELECT Id, StageName, AccountId, Owner.Fonction__c, RecordTypeId, IsClosed, OwnerId FROM Opportunities WHERE StageName IN (:Label.StageOPPOpened, :Label.StageDiscovery,
                        :Label.StageOCInProgress, :Label.StageOCOpened, :Label.StagePCInProgress, :Label.StageSignature, :Label.StageManaged, :Label.StageContracted)),
                (SELECT Id, OwnerId, CreationChannel__c, RecordTypeId, Status FROM Tasks WHERE Status IN ('Not Started', 'In Progress')), (SELECT Id, OwnerId FROM Events WHERE ActivityDate > TODAY AND EventType__c = 'AdministrationMeeting')
                FROM Account
                WHERE Id IN :accountsWithRefereeOrOwnerChanged]);
            }
        }

        /** Get current Account team member */
        Map<Id, List<AccountTeamMember>> accountByAccountTeamMember = new Map<Id, List<AccountTeamMember>>();
        if(accountsWithOwnerChangedIdsList.size() > 0){
            List<AccountTeamMember> accTeamMemberList = [SELECT Id, AccountId, UserId, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel FROM AccountTeamMember WHERE (TeamMemberRole = 'Referee' OR TeamMemberRole = 'Adviser') AND AccountId IN :accountsWithOwnerChangedIdsList];
            for(AccountTeamMember acm: accTeamMemberList){
                if(accountByAccountTeamMember.get(acm.AccountId) == null){
                    accountByAccountTeamMember.put(acm.AccountId, new List<AccountTeamMember>());
                }
                accountByAccountTeamMember.get(acm.AccountId).add(acm);
            }
        }
        //XES-435
        AccountTriggerHandler.eventsToUpdate = new List<Event>();
        AccountTriggerHandler.tasksToInsert = new List<Task>();
        for(Account acc: mdproNewAccountsMap.values()){
            /** XSMDPRO-1457 bloquer la modifications du comptes s'il est en cours de processus de fusion */
            if(!MDPRO_DuplicatesAccounts_CTL.bypassTriggerBlock && accountByApprobationProcessMap != null && accountByApprobationProcessMap.get(acc.Id) != null){
                acc.addError(Label.DuplicateAccountCantUpdateAccount);
            }
            Account oldAcc = mdproOldAccountsMap.get(acc.Id);
            if(acc.IsPersonAccount){
                Account_SVE_FieldUpdate.setGender(acc);
                Account_SVE_FieldUpdate.setPartner(acc);
                Account_SVE_FieldUpdate.setMarketingAttributes(acc, 'CustomerEquipment__pc', AccountMain_UTL.EQUIPEMENTMAPPP);
            }else{
                Account_SVE_FieldUpdate.setMarketingAttributes(acc, 'EquipementBusinessCustomer__c', AccountMain_UTL.EQUIPEMENTMAPPM);
                Account_SVE.setPartnerPM(acc);
            }
            Account_SVE.setSynchroMC(acc, oldAcc, userByBusinessSegmentCustomPermission);
            Account_SVE_Borrow.clearCommonPotEntryDate(acc, ownerRefereeDataMap);
            Account_SVE_FieldUpdate.setEmailCheck(acc, oldAcc);
            Account_SVE_Normalization.normalizeNameBeforeUpdate(acc, oldAcc);
            Account_SVE.convertToCustomer(acc, oldAcc);
            Account_SVE_FieldUpdate.setRangeBeforeUpdate(acc, oldAcc);
            Account_SVE_FieldUpdate.setOwnerFunctionBeforeUpdate(acc, oldAcc, ownerRefereeDataMap);
            if(!system.isBatch() && !system.isFuture()){
                Account_SVE_FieldUpdate.runAccountNormalisation(acc, oldAcc);
            }
            Account_SVE.setModifiedDateBeforeUpdate(acc, oldAcc);
            Account_SVE_Normalization.setInseeBirthPlaceBeforeUpdate(acc, oldAcc);
            Account_SVE_Borrow.ownerChangeRules(acc, oldAcc, ownerRefereeDataMap, accountWithRelatedRecordsMap.get(acc.Id), mapTaskIdToTaskToBeUpdated);

            Account_SVE_Borrow.blockOwnerChanges(acc, oldAcc, accountWithRelatedRecordsMap.get(acc.Id)?.Opportunities);
            Account_SVE_Borrow.stopBorrowProcess(acc, oldAcc, accountWithRelatedRecordsMap.get(acc.Id)?.Opportunities);
            Account_SVE_Borrow.stopUnborrowProcess(acc, oldAcc, accountWithRelatedRecordsMap.get(acc.Id)?.Opportunities);

            Account_SVE_Borrow.borrowProcess(acc, oldAcc, ownerRefereeDataMap, accountWithRelatedRecordsMap.get(acc.Id)?.Tasks, accountWithRelatedRecordsMap.get(acc.Id)?.Events, mapTaskIdToTaskToBeUpdated);
            if(acc.OwnerId != oldAcc.OwnerId || acc.Referee__c != oldAcc.Referee__c){
                Account_SVE.setBusinessSegment(acc, ownerRefereeDataMap);
            }
            if(acc.Referee__c != oldAcc.Referee__c){
                Account_SVE_Borrow.setIsBorrowPeriod(acc);
            }
            Account_SVE_FieldUpdate.setTechBirthDate(acc);
            //XEC-580 suppression condition sur PersonMailingCountryCode
            Account_SVE_FieldUpdate.setMassSendingTrue(acc, oldAcc, currentUserInfo);

            Account_SVE_FieldUpdate.setOwnerChangesApprovalFields(acc);
            Account_SVE_FieldUpdate.updateHasOpportunity(acc);
            Account_SVE_FieldUpdate.updateMarketingSynchro(acc);
            Account_SVE_FieldUpdate.updateFonction(acc);
            Account_SVE_FieldUpdate.manageProspect(acc, oldAcc);

            Account_SVE_FieldUpdate.resetMatrimonialRegime(acc);
            Account_SVE_FieldUpdate.setPhoneCheck(acc, oldAcc);
            Account_SVE_FieldUpdate.setTaxResidence(acc, oldAcc);

            Account_SVE_Normalization.truncateAdresseUpdate(acc);
            Account_SVE_FieldUpdate.copyCSPListBeforeUpdate(acc, oldAcc);

            Account_SVE_FieldUpdate.setCommunicationDateForRepere(acc, oldAcc);
            Account_SVE.flagFreeZoneAccount(acc, oldAcc, false);
            Account_SVE.shareAccountstoVAD(acc, oldAcc, ownerRefereeDataMap);
            Account_SVE.bypassVRConfiage(acc, oldAcc);
            //XESO-410/XESO-412
            Account_SVE.setConsentEmailByMkgCloud(acc, oldAcc);

            if(acc.OwnerId != oldAcc.OwnerId && accountByAccountTeamMember != null && accountByAccountTeamMember.get(acc.Id) != null){
                Account_SVE_Sharing.createAccountTeamMemberWhenOwnerChange(accountByAccountTeamMember.get(acc.Id));
            }
        }
        system.debug(LoggingLevel.INFO, '##### AccountTriggerHandler => accounts to owner/referee changed: '+ accountsWithRefereeOrOwnerChanged);
        System.debug(LoggingLevel.INFO, '#### CPU LIMIT Before update END: '+Limits.getCpuTime());
    }


    public void beforeDelete(Map<Id, SObject> oldItems) {
        DeletedObject_SVE.addObjectToDeletedObject((List<Account>)oldItems.values());
    }

    public void afterInsert(Map<Id, SObject> newItems) {
        System.debug(LoggingLevel.INFO, '#### CPU LIMIT After insert START: '+Limits.getCpuTime());
        List<Account> mdproAccounts = new List<Account>();
        Set<Id> parentAccountSet = new Set<Id>();
        Set<Id> ppWithParentSet = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        Set<Id> ownerAndRefereeIds = new Set<Id>();
        for(Account acc: (List<Account>)newItems.values()){
            /** filter in mdpro recordTypes*/
            if(AccountMain_UTL.isMDProRecord(acc.RecordTypeId)) {
                mdproAccounts.add(acc);
                String parentCompany = acc.ParentCompanyId__c;
                /** Get the list of parentCompany*/
                if (acc.IsPersonAccount && acc.Partner__c && String.isNotBlank(parentCompany) && parentCompanyMap.get(parentCompany) == null) {
                    parentAccountSet.add(parentCompany);
                }
                /** Generate VlocityPartyRelationship*/
                if(acc.IsPersonAccount && parentCompany != null){
                    ppWithParentSet.add(acc.Id);
                }
                if (String.isNotBlank(acc.OwnerId) && ownerRefereeDataMap.get(acc.OwnerId) == null) {
                    userIds.add(acc.OwnerId);
                    ownerAndRefereeIds.add(acc.OwnerId);
                }
                if(acc.Referee__c != null && ownerRefereeDataMap.get(acc.Referee__c) == null){
                    ownerAndRefereeIds.add(acc.Referee__c);
                }
                //Mamadou 
                //XET-670 Trigger lien PM PM
                if(acc.SIRETnumber__c!=null){
                    sirensSet.add(acc.SIRETnumber__c.left(9));
                }
            }
        }

        /** This map will be used in the next loop*/
        Map<Id, User> userMap = new Map<Id, User> ();
        if (userIds.size() > 0) {
            userMap = new Map<Id, User>([SELECT Id, Fonction__c, NetworkAssignment__c, NetworkMembership__c, FirstName, Accompanist__c,AccompanistRights__c, FreezeDate__c FROM User WHERE Id IN :userIds]);
            ownerRefereeDataMap.putAll(userMap);
        }

        /** Get list of PM */
        if(parentAccountSet.size() > 0){
            parentCompanyMap = new Map<Id, Account>([SELECT Id, PartnerForPM__c, NafCode__c FROM Account WHERE Id IN :parentAccountSet AND PartnerForPM__c = false AND IsPersonAccount = false]);
        }
        //Mamadou 
        //XET-670 Trigger lien PM PM ---- debut -----
        /** Get list of PM to link Headquaters with childs */
        List<Account> listAccountsPM = new List<Account>();
        listAccountsPM = [SELECT Id,Siren__c,SIRETnumber__c,headquarters__c,parentID,ActivityCessation__c FROM Account WHERE Siren__c in :sirensSet AND IsPersonAccount=false];
        System.debug('sirensSet.size() '+sirensSet.size());
        if(sirensSet.size() > 0){
            for(account a :listAccountsPM){
                if(a.headquarters__c == true && (a.ActivityCessation__c==null || a.ActivityCessation__c > System.TODAY())){
                    
                    if(mapSirenToListIdAccountSiege.containsKey(a.siren__c)){
                        mapSirenToListIdAccountSiege.get(a.siren__c).add(a.Id);
                    }else{
                        mapSirenToListIdAccountSiege.put(a.siren__c, new List<Id>{a.Id});
                    }
                }
                if(a.headquarters__c == false){
                    List<Account> oSecondaryAccounts = mapSirenToAccountSecondaire.get(a.siren__c);
                    if (oSecondaryAccounts == null) {
                        oSecondaryAccounts = new List<Account>();
                        mapSirenToAccountSecondaire.put(a.siren__c, oSecondaryAccounts);
                    }
                    oSecondaryAccounts.add(a); 
                    System.debug('oSecondaryAccounts '+oSecondaryAccounts);
                }
            }
            
        }
        //XET-670 Trigger lien PM PM ---- fin -----
        Map<Id, Account> accountToUpdate = new Map<Id, Account>();
        Map<Id,String> accIdRequestMap = new Map<Id,String>();
        List<AccountTeamMember> accountTeamMeberToInsert = new List<AccountTeamMember>();
        Integer accountListSize = mdproAccounts.size();
        for(Account acc: mdproAccounts){
            if(acc.IsPersonAccount){
                String parentCompany = acc.ParentCompanyId__c;
                accountToUpdate.putAll(Account_SVE_FieldUpdate.setFreelanceAfter(acc, null, accountToUpdate));
                if(parentCompanyMap.get(parentCompany) != null && String.isNotBlank(parentCompanyMap.get(parentCompany).NafCode__c) 
                    && (NAF_UTL.getNafCode(parentCompanyMap.get(parentCompany).NafCode__c) == '6920Z' || 
                        NAF_UTL.getNafCode(parentCompanyMap.get(parentCompany).NafCode__c) == '6910Z' || 
                        NAF_UTL.getNafCode(parentCompanyMap.get(parentCompany).NafCode__c) == '7022Z')) {
                    accountToUpdate.putAll(Account_SVE.setPartnerPMAfterInsert(acc, accountToUpdate));
                }
            }
            //Mamadou 
            //XET-670 Trigger lien PM to PM
            //Call Method from setLinkAccountHeadquatersAfterInser Account_SVE to insert accounts PM
            if(!acc.IsPersonAccount){
                accountToUpdate.putAll(Account_SVE.setLinkAccountHeadquatersAfterInsert(acc,accountToUpdate));
               system.debug('\n#MDB#accountToInsert '+accountToUpdate.values());
           }
            if(!system.isBatch() && accountListSize < 50 && !system.isFuture() && listPermSet.size() == 0){
                NormAdr_NewAndUpdateObject_SVE normaliseAdressInsert = new NormAdr_NewAndUpdateObject_SVE();
                accIdRequestMap.putAll(normaliseAdressInsert.normaliserAdresseForNewAccount(acc));
            }

            /** Create account team members*/
            accountTeamMeberToInsert.addAll(Account_SVE_Sharing.createAccountTeamMembers(acc, ownerRefereeDataMap));
        }

        AccountTriggerHandler.triggerDisabled = true;
        /** Call the api to normalize the addresses*/
        if(!Test.isRunningTest() && accIdRequestMap.size()>0){
            NormAdr_RNVPAddress_OUT.setAdressRNVP(accIdRequestMap);
        }

        /** Create AccountTeamMembers, if the list contain more than 10 records, the dml will be in asynchronous mode*/
        if(accountTeamMeberToInsert.size() > 0 && (accountTeamMeberToInsert.size() <= 10 || Test.isRunningTest())){
            insert accountTeamMeberToInsert;
        }else if(accountTeamMeberToInsert.size() != 0){
            System.enqueueJob(new SaveRecords_QUE(accountTeamMeberToInsert, 'INSERT'));
        }

        /** Update attached PM*/
        if(accountToUpdate.size() > 0){
            update accountToUpdate.values();
        }

        /** Create vlocity party relationship
        XSMDPRO-132 Vlocity Party Relationship*/
        if(ppWithParentSet.size() > 0){
            Account_SVE.syncAccountLink(ppWithParentSet);
        }

        Account_SVE_Sharing.createTeamMemberBasedOnInspections(new Map<Id, Account>(mdproAccounts), ownerRefereeDataMap.keySet());

        AccountTriggerHandler.triggerDisabled = false;
        Log.flush();
        System.debug(LoggingLevel.INFO, '#### CPU LIMIT After insert END: '+Limits.getCpuTime());
        for(String operation: TriggerSwitch_UTL.enforcedByPass){
            if(operation == 'AccountTriggerBEFORE_UPDATE' || operation == 'AccountTriggerAFTER_UPDATE'){
                TriggerSwitch_UTL.enforcedByPass.remove(operation);
            }
        }
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        System.debug(LoggingLevel.INFO, '#### CPU LIMIT After Update START: '+Limits.getCpuTime());
        List<Account> mdproAccountsNew = new List<Account>();
        List<Account> mdproAccountsOld = new List<Account>();
        Set<Id> listIdAccountWithPriseElement = new Set<Id>();
        Map<Id, Account> oldAccountsMap = (Map<Id, Account>)oldItems;
        Set<Id> parentAccountSet = new Set<Id>();
        Set<Id> ppWithParentSet = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        Set<Id> ownerAndRefereeIds = new Set<Id>();
        mapAccountIdToAccountForReferee = new Map<Id, Account>();
        mapAccountIdToAccountForOwner = new Map<Id, Account>();
        mapAccountIdToAccountForIsEmployee = new Map<Id, Account>();

        Map<Id, Account> accountToUpdate = new Map<Id, Account>();
        Map<Id,String> accIdRequestMap = new Map<Id,String>();
        List<AccountTeamMember> accountTeamMeberToInsert = new List<AccountTeamMember>();
        Account_SVE_Sharing.wrap = new Account_SVE_Sharing.TeamMemberReassignmentClass();
        Account_SVE_Sharing.wrap.newAccounts = new Map<Id, Account>();
        Account_SVE_Sharing.wrap.users = new Set<Id>();

        Set<Id> setAccountIdsForConjoint = new Set<Id>();
        List<vlocity_ins__PartyRelationship__c> listpartyRelationToHandle = new List<vlocity_ins__PartyRelationship__c>();
        Map<Id, List<vlocity_ins__PartyRelationship__c>> accountByPartyRelationshipMap = new Map<Id, List<vlocity_ins__PartyRelationship__c>>();
        
        for(Account acc: (List<Account>)newItems.values()){
            /** filter in mdpro recordTypes*/
            if(AccountMain_UTL.isMDProRecord(acc.RecordTypeId)) {
                mdproAccountsNew.add(acc);
                mdproAccountsOld.add(oldAccountsMap.get(acc.Id));
                Account oldAcc = oldAccountsMap.get(acc.Id);
                String parentCompany = acc.ParentCompanyId__c;
                /** Get the list of parentCompany*/
                if (acc.IsPersonAccount && acc.Partner__c && String.isNotBlank(parentCompany) && parentCompanyMap.get(parentCompany) == null) {
                    parentAccountSet.add(parentCompany);
                }
                /**Add old parentCompany in list*/
                if (acc.IsPersonAccount && acc.Partner__c && String.isNotBlank(parentCompany) && String.isNotBlank(oldAcc.ParentCompanyId__c) 
                    && parentCompany != oldAcc.ParentCompanyId__c && parentCompanyMap.get(oldAcc.ParentCompanyId__c) == null) {
                        parentAccountSet.add(oldAcc.ParentCompanyId__c);
                    }
                /** Generate VlocityPartyRelationship*/
                if(acc.IsPersonAccount && String.isNotBlank(parentCompany) && parentCompany != oldAcc.ParentCompanyId__c){
                    ppWithParentSet.add(acc.Id);
                }
                if (String.isNotBlank(acc.OwnerId) && ownerRefereeDataMap.get(acc.OwnerId) == null) {
                    userIds.add(acc.OwnerId);
                    ownerAndRefereeIds.add(acc.OwnerId);
                }
                if(acc.Referee__c != null){
                    ownerAndRefereeIds.add(acc.Referee__c);
                }
                if((acc.FinancialAssets__pc != oldAcc.FinancialAssets__pc) || (acc.OtherPatrimony__pc != oldAcc.OtherPatrimony__pc) || (acc.ProfessionalPatrimony__pc != oldAcc.ProfessionalPatrimony__pc) || (acc.PropertyAssets__pc != oldAcc.PropertyAssets__pc) ||
                    (acc.vlocity_ins__AnnualIncome__pc != oldAcc.vlocity_ins__AnnualIncome__pc) || (acc.ISFDeclaration__pc != oldAcc.ISFDeclaration__pc) || (acc.besoinLiquidite__c != oldAcc.besoinLiquidite__c) || (acc.indIFI__c != oldAcc.indIFI__c) || (acc.savingcapacity__pc != oldAcc.savingcapacity__pc)){
                    listIdAccountWithPriseElement.add(acc.Id);
                }

                if(acc.EmployeeOfGroup__c != oldAcc.EmployeeOfGroup__c){
                    setAccountIdsForConjoint.add(acc.Id);
                }
                 //Mamadou 
                 //XET-670 - Trigger lien PM to PM
                if(acc.SIRETnumber__c!=null){
                    sirensSet.add(acc.SIRETnumber__c.left(9));
                }
            }
        }

        /** This map will be used in the next loop*/
        Map<Id, User> userMap = new Map<Id, User> ();
        if (userIds.size() > 0) {
            userMap = new Map<Id, User>([SELECT Id, Fonction__c, NetworkAssignment__c, NetworkMembership__c, FirstName, Accompanist__c,AccompanistRights__c, FreezeDate__c FROM User WHERE Id IN :userIds]);
            ownerRefereeDataMap.putAll(userMap);
        }

        /** Get list of PM */
        if(parentAccountSet.size() > 0){
            parentCompanyMap = new Map<Id, Account>([SELECT Id, PartnerForPM__c, NafCode__c FROM Account WHERE Id IN :parentAccountSet AND PartnerForPM__c = false AND IsPersonAccount = false]);
        }
         //Mamadou 
         //XET-670 - Trigger lien PM to PM------- debut ---------
         /** Get list of PM to link Headquaters with childs */
        List<Account>  listAccountPM = new List<Account>();
        System.debug('sirensSet.size() '+sirensSet.size());
        listAccountPM = [SELECT Id,Siren__c,SIRETnumber__c,headquarters__c,parentID,ActivityCessation__c FROM Account WHERE Siren__c in :sirensSet AND IsPersonAccount=false];
        if(sirensSet.size() > 0){
            for(account a :listAccountPM){
                if(a.headquarters__c == true && (a.ActivityCessation__c==null || a.ActivityCessation__c > System.TODAY())){
                    
                    if(mapSirenToListIdAccountSiege.containsKey(a.siren__c)){
                        mapSirenToListIdAccountSiege.get(a.siren__c).add(a.Id);
                    }else{
                        mapSirenToListIdAccountSiege.put(a.siren__c, new List<Id>{a.Id});
                    }
                }
                else{
                    List<Account> oSecondaryAccounts = mapSirenToAccountSecondaire.get(a.siren__c);
                    if (oSecondaryAccounts == null) {
                        oSecondaryAccounts = new List<Account>();
                        mapSirenToAccountSecondaire.put(a.siren__c, oSecondaryAccounts);
                    }
                    oSecondaryAccounts.add(a); 
                    System.debug('oSecondaryAccounts '+oSecondaryAccounts);
                }
            }
            
        }
        //XET-670 - Trigger lien PM to PM------- fin ---------
        /** Get the list of party relationship*/
        if(setAccountIdsForConjoint.size() > 0){
            Set<String> setCategories = new Set<String>{'Famille Salarié'};

            List<String> relationshipCategoryList = ApplicationSetting_UTL.getApplicationSettingsByCategories(setCategories)?.get('Famille Salarié')?.values();
            if(relationshipCategoryList != null){
                listpartyRelationToHandle = ([Select Id, vlocity_ins__RelationshipTypeId__r.Name, vlocity_ins__SourcePartyId__c,vlocity_ins__SourcePartyId__r.vlocity_ins__AccountId__c,
                                                        vlocity_ins__TargetPartyId__r.vlocity_ins__AccountId__r.EmployeeOfGroup__c
                                                From vlocity_ins__PartyRelationship__c
                                                Where vlocity_ins__RelationshipTypeId__r.Name
                                                        IN: relationshipCategoryList
                                                And vlocity_ins__TargetPartyId__r.vlocity_ins__AccountId__c IN: setAccountIdsForConjoint
                                                And
                                                ((vlocity_ins__SourcePartyId__r.vlocity_ins__AccountId__r.Tech_EmployeeFamily__c = false //Enfant/Conjoint pas flagé
                                                And vlocity_ins__SourcePartyId__r.vlocity_ins__AccountId__r.EmployeeOfGroup__c = false //Enfant/Conjoint pas salariés
                                                And vlocity_ins__TargetPartyId__r.vlocity_ins__AccountId__r.EmployeeOfGroup__c = true) //Salarié est flagé
                                                OR
                                                (vlocity_ins__SourcePartyId__r.vlocity_ins__AccountId__r.Tech_EmployeeFamily__c = true //Enfant/Conjoint flagés
                                                And vlocity_ins__SourcePartyId__r.vlocity_ins__AccountId__r.EmployeeOfGroup__c = false //Enfant/Conjoint pas salariés
                                                And vlocity_ins__TargetPartyId__r.vlocity_ins__AccountId__r.EmployeeOfGroup__c = false))]); //n'est plus Salarié
                for(vlocity_ins__PartyRelationship__c rel: listpartyRelationToHandle){
                    if(accountByPartyRelationshipMap.get(rel.vlocity_ins__TargetPartyId__r.vlocity_ins__AccountId__c) == null){
                        accountByPartyRelationshipMap.put(rel.vlocity_ins__TargetPartyId__r.vlocity_ins__AccountId__c, new List<vlocity_ins__PartyRelationship__c>());
                    }
                    accountByPartyRelationshipMap.get(rel.vlocity_ins__TargetPartyId__r.vlocity_ins__AccountId__c).add(rel);
                }
            }
        }
        Integer accountListSize = mdproAccountsNew.size();
        for(Account acc: mdproAccountsNew){
            Account oldAcc = oldAccountsMap.get(acc.Id);
            if(acc.IsPersonAccount){
                String parentCompany = acc.ParentCompanyId__c;
                accountToUpdate.putAll(Account_SVE_FieldUpdate.setFreelanceAfter(acc, oldAccountsMap, accountToUpdate));
                if(parentCompany!=null && (String.isNotBlank(parentCompanyMap.get(parentCompany)?.NafCode__c) 
                    && (NAF_UTL.getNafCode(parentCompanyMap.get(parentCompany).NafCode__c) == '6920Z' || 
                        NAF_UTL.getNafCode(parentCompanyMap.get(parentCompany).NafCode__c) == '6910Z' || 
                        NAF_UTL.getNafCode(parentCompanyMap.get(parentCompany).NafCode__c) == '7022Z'))){
                    accountToUpdate.putAll(Account_SVE.setParnterPMAfterUpdate(acc, oldAcc, accountToUpdate));
                } 
            }
             //XET-670 Trigger lien PM to PM
             //Call Method setLinkAccountHeadquatersAfterUpdate from Account_SVE to update PM 
             //--debut--
            if(!acc.IsPersonAccount){
                accountToUpdate.putAll(Account_SVE.setLinkAccountHeadquatersAfterUpdate(acc,oldAcc,accountToUpdate));
               system.debug('#afterUpdateMDB#accountToUpdate  '+accountToUpdate.values());
            }
			 //--fin--
            if(!system.isBatch() && accountListSize < 50 && !system.isFuture() && listPermSet.size() == 0){
                NormAdr_NewAndUpdateObject_SVE normaliseAdressInsert = new NormAdr_NewAndUpdateObject_SVE();
                accIdRequestMap.putAll(normaliseAdressInsert.normaliserAdresseForUpdateAccount(acc, oldAcc));
            }

            /** Update/Create account team members*/
            accountTeamMeberToInsert.addAll(Account_SVE_Sharing.createAccountTeamMemberAfterUpdate(acc, oldAcc, ownerRefereeDataMap));

            /** XSMDPRO-1167 Flag Conjoints Enfants des Salariés*/
            if(accountByPartyRelationshipMap.size() > 0 && accountByPartyRelationshipMap.get(acc.Id) != null){
                accountToUpdate.putAll(Account_SVE.flagConjointEnfants(accountToUpdate, accountByPartyRelationshipMap.get(acc.Id)));
            }
        }

        AccountTriggerHandler.triggerDisabled = true;
        Account_VR.validationDisabled = true;
        Map<Id, Account> mdproAccountsNewMap = new Map<Id, Account>(mdproAccountsNew);
        /** Call the api to normalize the addresses*/
        if(!Test.isRunningTest() && accIdRequestMap.size()>0){
            NormAdr_RNVPAddress_OUT.setAdressRNVP(accIdRequestMap);
        }

        /** Delete account team members*/
        Account_SVE_Sharing.deleteAccountTeamMembers();
        /** Create AccountTeamMembers, if the list contain more than 10 records, the dml will be in asynchronous mode*/
        if(accountTeamMeberToInsert.size() > 0 && accountTeamMeberToInsert.size() <= 10){
            insert accountTeamMeberToInsert;
        }else if(accountTeamMeberToInsert.size() != 0){
            System.enqueueJob(new SaveRecords_QUE(accountTeamMeberToInsert, 'INSERT'));
        }

        Account_SVE_Sharing.createTeamMemberBasedOnInspections(mdproAccountsNewMap, ownerRefereeDataMap.keySet());

        /** SCX-2046 Calculer la visibilité sur les campagnes*/
        if(!system.isBatch() && !system.isFuture()){
            Account_SVE_Sharing.recalculateCampaignSharing(oldAccountsMap, mdproAccountsNewMap);
        }

        Datetime local = User_UTL.getDatetimeWithoffSet(Datetime.now());
        Account_SVE.updateInstantCreatCMforPE(local, listIdAccountWithPriseElement);

        /** Create vlocity party relationship
        XSMDPRO-132 Vlocity Party Relationship*/
        if(ppWithParentSet.size() > 0){
            Account_SVE.syncAccountLink(ppWithParentSet);
        }
        /** XES-412 Create individual to link with account for those accounts which do not have corresponding individual*/
        if (mapAccountIdToIndividual.size()>0) {
            Database.SaveResult[] results = Database.insert(mapAccountIdToIndividual.values(), false);
            for (Database.SaveResult sr : results) {
                for (Id idAccount : mapAccountIdToIndividual.keySet()) {
                    if (sr.isSuccess()) {
                        mapIndividualIdToAccountId.put(sr.getId(), idAccount);
                        if (accountToUpdate.get(idAccount)!=null) {
                            accountToUpdate.get(idAccount).PersonIndividualId = sr.getId(); 
                        } else {
                            Account a = new Account();
                            a.Id=idAccount;
                            a.PersonIndividualId=sr.getId();
                            accountToUpdate.put(idAccount, a);
                        }      
                    }
                }
            }
        }
        if (mapIndividualIdToAccountId.size()>0) {
            IndividualMain_UTL.updateConsentsOfAccsFromMC(mapIndividualIdToAccountId, mapAccountToMarketingEmailConsent);
        }
        /** Insert/Update Task + update events from the BorrowProcess method*/
        List<Task> tasksToUpsert = new List<Task>();
        if(tasksToInsert.size() > 0){
            tasksToUpsert.addAll(tasksToInsert);
        }
        if(mapTaskIdToTaskToBeUpdated.values() != null && mapTaskIdToTaskToBeUpdated.values().size() > 0){
            tasksToUpsert.addAll(mapTaskIdToTaskToBeUpdated.values());
        }
        if(tasksToUpsert.size() > 0){
            upsert tasksToUpsert;
        }
        if(eventsToUpdate.size() > 0){
            update eventsToUpdate;
        }

        /** Update attached PM*/
        if(accountToUpdate.size() > 0){
            update accountToUpdate.values();
        }

        AccountTriggerHandler.triggerDisabled = false;
        Account_VR.validationDisabled = false;
        Log.flush();
        System.debug(LoggingLevel.INFO, '#### CPU LIMIT After update END: '+Limits.getCpuTime());
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
        CampaignTriggerHandler.triggerDisabled = true;

        // XET-66 Callout to delete Account in REPERE - Future method
        // Get the first element of list because REPERE API doesn't support BULK
        List<Account> listAccount = (List<Account>)oldItems.values();
        AccountDeletedWrapper accountWrapper = new AccountDeletedWrapper();
        accountWrapper.personNumber = listAccount.get(0).PersonNumber__c;
        accountWrapper.isPersonAccount = listAccount.get(0).IsPersonAccount;
        accountWrapper.lastModifiedDate = listAccount.get(0).lastModifiedDate;
        CreateEventEditPersonInformation_SVC.createEventEditPersInfo(JSON.serialize(accountWrapper));
        CampaignTriggerHandler.triggerDisabled = false;
    }

    public void afterUndelete(Map<Id, SObject> newItems) {
        DeletedObject_SVE.addErrorOnDeletedObjectRestored(newItems);
    }

    public String getTriggerName() {
        return 'AccountTrigger';
    }
}