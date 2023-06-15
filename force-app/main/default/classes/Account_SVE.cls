Ajout Mamadou de ligne 720 à 782
/***
* @author Matthieu CASASSUS
* @date 15/11/2019
* @description Classe de service pour le trigger lié au comptes
*               contient la refacto des PB PB_ACCT_MAIN et PB_ACCT_MAIN_2
*/

public class Account_SVE {
    public static final List<String> listFunctions = (Label.FunctionManagerOrDirector).split(',');
    public static final String MDPRO = 'MDPro NP';
    public static final String ACA = 'ACA';
    /***
* @description Convertis le RecordType d'un compte en fonction de son type dans un trigger before insert/update
* @param a : compte issus de Trigger.new
* @return void
* @exception aucune
*/
    public static void convertToCustomer(Account a, Account oldAcc){
        if(oldAcc != null && a.Type == oldAcc.Type && a.RecordTypeId == oldAcc.RecordTypeId){
            return;
        }
        if(a.IsPersonAccount){
            if(a.Type == AccountMain_UTL.CUSTOMERTYPE && a.RecordTypeId == AccountMain_UTL.ppProspectRT){
                a.RecordTypeId = AccountMain_UTL.ppClientRT;
            }else if(a.Type == AccountMain_UTL.PROSPECTTYPE && a.RecordTypeId == AccountMain_UTL.ppClientRT){
                a.RecordTypeId = AccountMain_UTL.ppProspectRT;
            }
        }else{
            if(a.Type == AccountMain_UTL.CUSTOMERTYPE && a.RecordTypeId == AccountMain_UTL.pmProspectRT){
                a.RecordTypeId = AccountMain_UTL.pmClientRT;
            }else if(a.Type == AccountMain_UTL.PROSPECTTYPE && a.RecordTypeId == AccountMain_UTL.pmClientRT){
                a.RecordTypeId = AccountMain_UTL.pmProspectRT;
            }
        }
    }
    /***
* @description Convertis le RecordType d'un compte en fonction de son type dans un trigger before insert/update
* @param List<Account> accounts : liste des comptes issus de Trigger.new
* @return List<Account>
*/
    public static List<Account> convertToCustomer(List<Account> accounts){
        Id personAccountRT = AccountMain_UTL.ppProspectRT;
        Id personAccountCustomerRT = AccountMain_UTL.ppClientRT;
        Id personneMoraleRT = AccountMain_UTL.pmProspectRT;
        Id businessAccountCustomerRT = AccountMain_UTL.pmClientRT;
        for(Account a : accounts){
            if(a.IsPersonAccount){
                if(a.Type == 'Customer' && a.RecordTypeId == personAccountRT){
                    a.RecordTypeId = personAccountCustomerRT;
                }else if(a.Type == 'Prospect' && a.RecordTypeId == personAccountCustomerRT){
                    a.RecordTypeId = personAccountRT;
                }
            }else{
                if(a.Type == 'Customer' && a.RecordTypeId == personneMoraleRT){
                    a.RecordTypeId = businessAccountCustomerRT;
                }else if(a.Type == 'Prospect' && a.RecordTypeId == businessAccountCustomerRT){
                    a.RecordTypeId = personneMoraleRT;
                }
            }
        }
        return accounts;
    }
    
    /***
* @description Renseigne les dates de modifications à destination de REPERE pour un compte dans un trigger before insert
* @param a : comptes issus de Trigger.new
*/
    public static void setModifiedDateBeforeInsert(Account a){
        Datetime now = Datetime.now();
        a.LastModifDateAdr__c = now;
        
        if(String.isNotBlank(a.PersonMobilePhone) || String.isNotBlank(a.PersonHomePhone) || String.isNotBlank(a.PersonOtherPhone) || String.isNotBlank(a.AcctMobilePhone__c) || String.isNotBlank(a.AcctProMobilePhone__c) || String.isNotBlank(a.Fax) || String.isNotBlank(a.Phone)){
            a.LastModifDatePhone__c = now;
        }
        if(String.isNotBlank(a.PersonEmail) || String.isNotBlank(a.ProfessionalEmail__pc) || String.isNotBlank(a.vlocity_ins__Email__c) || String.isNotBlank(a.ProfessionalEmail__pc) || String.isNotBlank(a.AcctProEmail__c)){
            a.LastModifDateEmail__c = now;
        }
    }
    
    /***

* @description Renseigne les dates de modification à destination de REPERE pour un compte dans un trigger before update
* @param List<Account> accounts : liste des comptes issus de Trigger.new
*        Map<Id, Account> oldAccountMap : map des comptes issus de Trigger.oldMap
* @return void
* @exception aucune
*/
    public static void setModifiedDateBeforeUpdate(Account acc, Account oldAcc){
        Datetime now = Datetime.now();
        if(acc.LastName != oldAcc.LastName
           || acc.FirstName != oldAcc.FirstName
           || acc.FloorApptPerson__pc != oldAcc.FloorApptPerson__pc
           || acc.BuildingEntOtherAdress__pc != oldAcc.BuildingEntOtherAdress__pc
           || acc.PersonMailingStreet != oldAcc.PersonMailingStreet
           || acc.PlacedCalledPersonAdress__pc != oldAcc.PlacedCalledPersonAdress__pc
           || acc.PersonMailingCity != oldAcc.PersonMailingCity
           || acc.PersonMailingState != oldAcc.PersonMailingState
           || acc.PersonOtherState != oldAcc.PersonOtherState
           || acc.BillingState != oldAcc.BillingState
           || acc.ShippingState != oldAcc.ShippingState
           || acc.PersonMailingCountryCode != oldAcc.PersonMailingCountryCode
           || acc.PNDPersonMailing__pc != oldAcc.PNDPersonMailing__pc
           || acc.InseePMailingCountryC__pc != oldAcc.InseePMailingCountryC__pc
           || acc.RNVPPersonMailingControl__pc != oldAcc.RNVPPersonMailingControl__pc
           || acc.RNVPControlDatePMailing__pc != oldAcc.RNVPControlDatePMailing__pc
           || acc.Name != oldAcc.Name
           || acc.FloorAptBilling__c != oldAcc.FloorAptBilling__c
           || acc.BuildingEntBilling__c != oldAcc.BuildingEntBilling__c
           || acc.BillingStreet != oldAcc.BillingStreet
           || acc.PlacedCalledBilling__c != oldAcc.PlacedCalledBilling__c
           || acc.BillingPostalCode != oldAcc.BillingPostalCode
           || acc.BillingCity != oldAcc.BillingCity
           || acc.BillingCountryCode != oldAcc.BillingCountryCode
           || acc.PNDBilling__c != oldAcc.PNDBilling__c
           || acc.InseeBillingCode__c != oldAcc.InseeBillingCode__c
           || acc.BillingPostalCode != oldAcc.BillingPostalCode
           || acc.InseeBillingCountryCode__c != oldAcc.InseeBillingCountryCode__c
           || acc.RNVPBillingControl__c != oldAcc.RNVPBillingControl__c
           || acc.RNVPControlDateBilling__c != oldAcc.RNVPControlDateBilling__c
           || acc.BuildingEntShipping__c != oldAcc.BuildingEntShipping__c
           || acc.BuildingEntPersonAdresse__pc != oldAcc.BuildingEntPersonAdresse__pc
           || acc.FloorAptShipping__c != oldAcc.FloorAptShipping__c
           || acc.FloorApptOtheradress__pc != oldAcc.FloorApptOtheradress__pc
           || acc.PlaceCalledShipping__c != oldAcc.PlaceCalledShipping__c
           || acc.PlaceCalledOtherAdress__pc != oldAcc.PlaceCalledOtherAdress__pc){
               acc.LastModifDateAdr__c = now;
           }
        
        if(acc.PersonMobilePhone != oldAcc.PersonMobilePhone
           || acc.PersonHomePhone != oldAcc.PersonHomePhone
           || acc.PersonOtherPhone != oldAcc.PersonOtherPhone
           || acc.AcctMobilePhone__c != oldAcc.AcctMobilePhone__c
           || acc.AcctProMobilePhone__c != oldAcc.AcctProMobilePhone__c
           || acc.Fax != oldAcc.Fax
           || acc.Phone != oldAcc.Phone){
               acc.LastModifDatePhone__c = now;
           }
        
        if(acc.PersonEmail != oldAcc.PersonEmail
           || acc.ProfessionalEmail__pc != oldAcc.ProfessionalEmail__pc
           || acc.vlocity_ins__Email__c != oldAcc.vlocity_ins__Email__c
           || acc.AcctProEmail__c != oldAcc.AcctProEmail__c){
               acc.LastModifDateEmail__c = now;
           }
    }
    
    /***
* @description Flag la notion de partner d'un Businesses Account dans le cas du code NAF "6920Z" dans un trigger before insert/update
* @param a : compte issus de Trigger.new
*/
    public static void setPartnerPM(Account a){
        if(!a.PartnerForPM__c && String.isNotBlank(a.NafCode__c) && NAF_UTL.getNafCode(a.NafCode__c) == '6920Z' && !a.PartnerForPM__c){
            a.PartnerForPM__c = true;
        }
    }
    
    /***
* @description Flag la notion de partner d'un Businesses Account dans un trigger after insert
* @param List<Account> accounts : liste des comptes issus de Trigger.new
* @return void
* @exception aucune
*/
    public static Map<Id, Account> setPartnerPMAfterInsert(Account acc, Map<Id, Account> accountToUpdate){
        if(accountToUpdate.get(acc.ParentCompanyId__c) != null){
            accountToUpdate.get(acc.ParentCompanyId__c).PartnerForPM__c = true;
        }else{
            accountToUpdate.put(acc.ParentCompanyId__c, new Account(Id = acc.ParentCompanyId__c, PartnerForPM__c = true));
        }
        return accountToUpdate;
    }
    
    /***
* @description Flag la notion de partner d'un Businesses Account dans un trigger after update
* @param List<Account> newAccounts : liste des comptes issus de Trigger.new
*        Map<Id, Account> oldAccountMap : map des comptes issus de Trigger.oldMap
* @return void
* @exception aucune
*/
    public static Map<Id, Account> setParnterPMAfterUpdate(Account acc, Account oldAcc, Map<Id, Account> accountToUpdate){
        Set<Id> pmIds = new Set<Id>();
        if(acc.ParentCompanyId__c != oldAcc.ParentCompanyId__c){
            pmIds.add(acc.ParentCompanyId__c);
            pmIds.add(oldAcc.ParentCompanyId__c);
        }else if(!oldAcc.Partner__c){
            pmIds.add(acc.ParentCompanyId__c);
        }
        if (pmIds.size() > 0) {
            for(Id pmId: pmIds){
                //XES-511 ne pas prendre en compte les pmID à null
                if (pmId != null) {
                    if(accountToUpdate.get(pmId) != null ){
                        accountToUpdate.get(pmId).PartnerForPM__c = true;
                    }else{
                        accountToUpdate.put(pmId, new Account(Id = pmId, PartnerForPM__c = true));
                    }
                }
            }
        }
        return accountToUpdate;
    }
    /***
* @description Mise à jour de la relation commerciale du compte
* @param List<Account> accounts Liste de compte
* @return void
*/
    public static void setBusinessSegment(Account account, Map<Id, User> userMap){
        String ownerNetworkMembership = '';
        String refereeNetworkMembership = '';
        
        Set<String> valuesToAddSegment = new Set<String>();
        Set<String> valuesToRemoveSegment = new Set<String>();
        if(userMap.get(account.OwnerId) != null){
            ownerNetworkMembership = userMap.get(account.OwnerId).NetworkMembership__c;
        } else {
            ownerNetworkMembership = '';
        }
        
        if(userMap.get(account.Referee__c) != null){
            refereeNetworkMembership = userMap.get(account.Referee__c).NetworkMembership__c;
        } else {
            refereeNetworkMembership = '';
        }
        
        if(account.Referee__c == null){
            if(ownerNetworkMembership == 'RESEAU'){
                account.TechMDProCustomerMC__c = true;
                valuesToAddSegment.add('MDPro');
                account.TechVADCustomerMC__c = false;
            } else if(ownerNetworkMembership == 'VAD'){
                account.TechVADCustomerMC__c = true;
                valuesToAddSegment.add('VAD');
                account.TechMDProCustomerMC__c = false;
            }
        } else {
            if(refereeNetworkMembership == 'RESEAU'){
                account.TechMDProCustomerMC__c = true;
                valuesToAddSegment.add('MDPro');
                account.TechVADCustomerMC__c = false;
            } else if(refereeNetworkMembership == 'VAD'){
                account.TechVADCustomerMC__c = true;
                valuesToAddSegment.add('VAD');
                account.TechMDProCustomerMC__c = false;
            }
        }
        
        String segment = Multipicklist_UTL.addValues(account.BusinessSegment__c, valuesToAddSegment);
        // XSMDPRO-1916 - on historise dans la multipicklist BusinessSegment__c les valeurs précédentes
        // et on se base maintenant sur le champs NetworkMembership__c
        account.BusinessSegment__c = segment;
        account.CRC_TECH_Business_Segment__c = segment;
    }
    public static void setBusinessSegment(List<Account> accounts, Map<Id, User> userMap){
        String ownerNetworkMembership = '';
        String refereeNetworkMembership = '';
        for(Account account : accounts){
            Set<String> valuesToAddSegment = new Set<String>();
            Set<String> valuesToRemoveSegment = new Set<String>();
            if(userMap.get(account.OwnerId) != null){
                ownerNetworkMembership = userMap.get(account.OwnerId).NetworkMembership__c;
            } else {
                ownerNetworkMembership = '';
            }
            
            if(userMap.get(account.Referee__c) != null){
                refereeNetworkMembership = userMap.get(account.Referee__c).NetworkMembership__c;
            } else {
                refereeNetworkMembership = '';
            }
            
            if(account.Referee__c == null){
                if(ownerNetworkMembership == 'RESEAU'){
                    account.TechMDProCustomerMC__c = true;
                    valuesToAddSegment.add('MDPro');
                    account.TechVADCustomerMC__c = false;
                } else if(ownerNetworkMembership == 'VAD'){
                    account.TechVADCustomerMC__c = true;
                    valuesToAddSegment.add('VAD');
                    account.TechMDProCustomerMC__c = false;
                }
            } else {
                if(refereeNetworkMembership == 'RESEAU'){
                    account.TechMDProCustomerMC__c = true;
                    valuesToAddSegment.add('MDPro');
                    account.TechVADCustomerMC__c = false;
                } else if(refereeNetworkMembership == 'VAD'){
                    account.TechVADCustomerMC__c = true;
                    valuesToAddSegment.add('VAD');
                    account.TechMDProCustomerMC__c = false;
                }
            }
            
            String segment = Multipicklist_UTL.addValues(account.BusinessSegment__c, valuesToAddSegment);
            // XSMDPRO-1916 - on historise dans la multipicklist BusinessSegment__c les valeurs précédentes
            // et on se base maintenant sur le champs NetworkMembership__c
            account.BusinessSegment__c = segment;
            account.CRC_TECH_Business_Segment__c = segment;
        }
    }
    /**
* @description SCX-2583 update instanCreatCM on Prise_Element__c,
* @param Map<Id, Account> old, Map<Id, Account> new
* @return void
**/
    public static void updateInstantCreatCMforPE(Datetime local, Set<Id> listAcc){
        if(listAcc.size() > 0){
            List<Prise_element__c> listPEtoUpdate = (List<Prise_element__c>)[SELECT id, instantCreatCM__c,personne__c FROM Prise_element__c where personne__c IN :listAcc];
            if(listPEtoUpdate.size() > 0){
                for(Prise_element__c pe : listPEtoUpdate){
                    listAcc.remove(pe.personne__c);
                    pe.instantCreatCM__c = local;
                    System.debug('date instantCreatCM : '+ pe.instantCreatCM__c);
                }
                try{
                    update(listPEtoUpdate);
                }catch (Exception e){
                    system.debug('Error when upserting instantCreatCM__c on Prise_Element');
                }
                
            }
            List<Prise_element__c> listPEtoInsert = new List<Prise_element__c> ();
            for (Id accountId : listAcc) {
                Prise_element__c pe = new Prise_element__c();
                pe.instantCreatCM__c = local;
                pe.personne__c = accountId;
                listPEtoInsert.add(pe);
            }
            if (listPEtoInsert.size() > 0) {
                insert listPEtoInsert;
            }
        } // end of if listIdAccount
    }
    
    /** XSMDPRO-601, XSMDPRO-1208 Assign accounts to users based on secto table, limit the scope to the accounts without ownerId or created by technical users Or the CMN, CMR, CRC and assistant
* @param acc*/
    public static void setDefaultOwnerAccounts(Account acc){
        /** Get UserId of technical users*/
        System.debug('before secto'+acc.OwnerId);
        if(acc.OwnerId == null || AccountTriggerHandler.hasSectorisationPermission){
            setDefaultOwner(acc);
            System.debug('after secto'+acc.OwnerId + ' '+'owner Name' +acc.Owner.Name);
        }
    }
    public static void setDefaultOwner(Account acc){
        if(AccountTriggerHandler.postalCityToUserId.size() > 0){
            Id userId;
            if(acc.PersonMailingPostalCode != null){
                userid = AccountTriggerHandler.postalCityToUserId?.get(acc.PersonMailingPostalCode);
            }
            if(userid == null && acc.BillingPostalCode != null){
                userid = AccountTriggerHandler.postalCityToUserId?.get(acc.BillingPostalCode);
            }
            if(userid == null){
                return;
            }
            acc.OwnerId = userid;
            acc.IsReassigned__c = false;
            
        }
    }
    /** This method is used for account reassignment and its used in trigger (before insert) and in the batch treatment*/
    /** XSMDPRO-1208 on se base seulement sur le postal code vu que meme si on a deux villes avec le meme code postal on aura le meme manager rattaché*/
    public static List<Account> setDefaultOwner(List<Account> newAccounts){
        system.Debug('#### Account_SVE | setDefaultOwner() => list of accounts to reassign: '+newAccounts);
        Set<String> postalCodes = new Set<String>();
        
        for(Account a : newAccounts){
            if(a.IsPersonAccount || (a.PersonMailingPostalCode != null && a.PersonMailingCity != null)){
                if(String.isNotBlank(a.PersonMailingPostalCode)){
                    postalCodes.add(a.PersonMailingPostalCode);
                }
            }else {
                if (String.isNotBlank(a.BillingPostalCode)) {
                    postalCodes.add(a.BillingPostalCode);
                }
            }
        }
        
        List<AccountSectorization__c> sectorisations = [SELECT Id, PostalCode__c, Inspector__c, Inspector__r.IsActive, City__c
                                                        FROM AccountSectorization__c
                                                        WHERE PostalCode__c IN : postalCodes];
        
        system.Debug('#### Account_SVE | setDefaultOwner() => Sectorisation list: '+sectorisations);
        Map<String, Id> postalCityToUserId = new Map<String, Id>();
        if(sectorisations.size() > 0){
            for(AccountSectorization__c sec: sectorisations){
                if (sec.Inspector__r.IsActive) {
                    postalCityToUserId.put(sec.PostalCode__c, sec.Inspector__c);
                }
            }
            
            if(postalCityToUserId.size() > 0){
                for(Account a : newAccounts){
                    Id userId;
                    if(a.PersonMailingPostalCode != null){
                        userid = postalCityToUserId.get(a.PersonMailingPostalCode);
                    }
                    if(userid == null && a.BillingPostalCode != null){
                        userid = postalCityToUserId.get(a.BillingPostalCode);
                    }
                    if(userid == null){
                        continue;
                    }
                    a.OwnerId = userid;
                    a.IsReassigned__c = false;
                }
            }
        }
        system.Debug('#### Account_SVE | setDefaultOwner() => list of accounts to reassign: '+newAccounts);
        return newAccounts;
    }
    /***
* @description XSMDPRO-109/ XSMDPRO-947 utilisé pour mettre à jour le champ Compte Zone Franche sur les PP et PM pour raison de filtrage

* @param Map<Id, Account> newAccounts : Nouveaux comptes provenant de Trigger.newMap, Map<Id, Account> oldAccounts : Anciens comptes provenant de Trigger.oldMap
* @return void
* @exception aucune
*/
    public static void flagFreeZoneAccount(Account acc, Account oldAcc, Boolean isNew){
        //Handling Personne Morale
        if (!acc.IsPersonAccount && (isNew || (oldAcc != null && (oldAcc.BillingPostalCode != acc.BillingPostalCode || oldAcc.BillingCity != acc.BillingCity)))
            && AccountTriggerHandler.postalCityBySecto?.containsKey(String.ValueOf(acc.BillingPostalCode + acc.BillingCity).toLowercase())
            && AccountTriggerHandler.postalCityBySecto?.get(String.ValueOf(acc.BillingPostalCode + acc.BillingCity).toLowercase()) != null){
                acc.Free_Zone__c = AccountTriggerHandler.postalCityBySecto?.get(String.ValueOf(acc.BillingPostalCode + acc.BillingCity).toLowercase()).Free_Zone__c;
                //Handling Personne Physique
            }else if (acc.IsPersonAccount && (isNew || (oldAcc != null && (oldAcc.PersonMailingPostalCode != acc.PersonMailingPostalCode || oldAcc.PersonMailingCity != acc.PersonMailingCity)))
                      && AccountTriggerHandler.postalCityBySecto?.containsKey(String.ValueOf(acc.PersonMailingPostalCode + acc.PersonMailingCity).toLowercase())
                      && AccountTriggerHandler.postalCityBySecto?.get(String.ValueOf(acc.PersonMailingPostalCode + acc.PersonMailingCity).toLowercase()) != null){
                          acc.Free_Zone__c = AccountTriggerHandler.postalCityBySecto?.get(String.ValueOf(acc.PersonMailingPostalCode + acc.PersonMailingCity).toLowercase()).Free_Zone__c;
                      }else{//No Sector Found
                          acc.Free_Zone__c = false;
                      }
    }
    
    /**
* @description XSMDPRO-132 utilisé pour synchroniser ParentCompanyId__c et les liens Vlocity Party RelationShip
* @param Map<Id, Account> newAccounts : Nouveaux comptes provenant de Trigger.newMap, Map<Id, Account> oldAccounts : Anciens comptes provenant de Trigger.oldMap
* @return void
* @exception aucune
*/
    public static void syncAccountLink(Set<Id> setAccountIds){
        //Bypass vlocity_ins__PartyRelationship__c Trigger
        VlocityPartyRelationshipTriggerHandler.triggerDisabled = true;
        
        //Insert new Vlocity Party Relation Links
        if (setAccountIds.size() > 0){
            List<vlocity_ins__PartyRelationship__c> ListVlocityPartyRelationToInset = listPartyRelationToInsert(setAccountIds);
            
            system.Debug('Party relationship to create: '+ListVlocityPartyRelationToInset);
            Set<Id> relationsInserted = new Set<Id>();
            
            if (ListVlocityPartyRelationToInset.size() > 0){
                Database.SaveResult[] srList = Database.insert(ListVlocityPartyRelationToInset, false);
                for(Database.SaveResult sr : srList){
                    if(!sr.isSuccess()){
                        for(Database.Error err: sr.getErrors()){
                            system.debug('Account_SVE|syncAccountLink => error during the insert of Vlocity Party Relation Link: ' +err.getMessage());
                            Log.error(err.getMessage(), 'Account_SVE|syncAccountLink' , 'Insert of Vlocity Party Relation Link', sr.getId());
                        }
                        
                    }else{
                        relationsInserted.add(sr.getId());
                    }
                }
                Log.flush();
                
                ListVlocityPartyRelationToInset = [SELECT Id, vlocity_ins__TargetPartyId__r.vlocity_ins__AccountId__c, vlocity_ins__SourcePartyId__r.vlocity_ins__AccountId__c FROM vlocity_ins__PartyRelationship__c WHERE Id IN: relationsInserted];
                Map<Id, Account> accountToUpdate = new Map<Id, Account>();
                for(vlocity_ins__PartyRelationship__c relation: ListVlocityPartyRelationToInset){
                    if(relation.vlocity_ins__SourcePartyId__c != null && relation.vlocity_ins__SourcePartyId__r.vlocity_ins__AccountId__c != null){
                        accountToUpdate.put(relation.vlocity_ins__SourcePartyId__r.vlocity_ins__AccountId__c, new Account(Id = relation.vlocity_ins__SourcePartyId__r.vlocity_ins__AccountId__c, MassSending__c = True));
                    }
                    if(relation.vlocity_ins__TargetPartyId__c != null && relation.vlocity_ins__TargetPartyId__r.vlocity_ins__AccountId__c != null){
                        accountToUpdate.put(relation.vlocity_ins__TargetPartyId__r.vlocity_ins__AccountId__c, new Account(Id = relation.vlocity_ins__TargetPartyId__r.vlocity_ins__AccountId__c, MassSending__c = True));
                    }
                }
                //We are in after insert/update context, so we cant update the current record, we should do it asynchronously
                System.enqueueJob(new SaveRecords_QUE(accountToUpdate.values(), 'UPDATE'));
            }
        }
        
        //Remove Bypass vlocity_ins__PartyRelationship__c Trigger
        VlocityPartyRelationshipTriggerHandler.triggerDisabled = false;
    }
    
    /***
* @description XSMDPRO-132 utilisé pour la creation des nouveau liens Vlocity Party Relationship
* @param Set<Id> setAccountIds : Nouveaux comptes et comptes modifiés, pourlequel il faut créer de nouveaux liens Vlocity Party Relationship
* @return List des nouveaux liens Vlocity Party Relationship à créer
* @exception aucune
*/
    public static List<vlocity_ins__PartyRelationship__c> listPartyRelationToInsert (Set<Id> setAccountIds){
        
        
        List<Account>listAccounts = new List<Account> ([Select Id, Name, ParentCompanyId__c, ParentCompanyId__r.vlocity_ins__PartyId__c, Vlocity_ins__PartyId__pc, vlocity_ins__PartyId__c
                                                        
                                                        From Account
                                                        Where Id IN: setAccountIds]);
        
        //Get VlocityPartyRelationshipTypes
        List<vlocity_ins__PartyRelationshiptype__c> listVPrelationType = new List<vlocity_ins__PartyRelationshiptype__c>([Select Id, Name, vlocity_ins__SourceString__c
                                                                                                                          From vlocity_ins__PartyRelationshiptype__c
                                                                                                                          Where (vlocity_ins__SourceString__c=: Label.VlocityPartyRelationDirigeant
                                                                                                                                 Or vlocity_ins__SourceString__c=: Label.VlocityPartyRelationEntreprise)]);
        Map<String,Id> mapVPRelatiobType = new Map<String,Id>();
        for(vlocity_ins__PartyRelationshiptype__c VPRelationType :listVPrelationType){
            if (!mapVPRelatiobType.containsKey(VPRelationType.vlocity_ins__SourceString__c)){
                mapVPRelatiobType.put(VPRelationType.vlocity_ins__SourceString__c,VPRelationType.Id);
            }
        }
        
        List<vlocity_ins__PartyRelationship__c> listPartyRelationToInsert = new List <vlocity_ins__PartyRelationship__c> ();
        //Create VlocityPartyRelation Links
        for(Account acc :listAccounts){
            //Create Dirigeant Link
            vlocity_ins__PartyRelationship__c partyRelationshipDirigeant = new vlocity_ins__PartyRelationship__c ();
            
            partyRelationshipDirigeant.vlocity_ins__PrimaryRole__c = Label.VlocityPrimaryRoleEntreprise;
            partyRelationshipDirigeant.vlocity_ins__TargetRole__c  = Label.VlocityPrimaryRoleDirigeant;
            partyRelationshipDirigeant.vlocity_ins__SourcePartyId__c = acc.vlocity_ins__PartyId__c;
            partyRelationshipDirigeant.vlocity_ins__TargetPartyId__c  = acc.parentCompanyId__r.vlocity_ins__PartyId__c;
            
            partyRelationshipDirigeant.vlocity_ins__RelationshipTypeId__c = mapVPRelatiobType.get(Label.VlocityPartyRelationDirigeant);
            listPartyRelationToInsert.add(partyRelationshipDirigeant);
            
            //Create Entreprise Link
            vlocity_ins__PartyRelationship__c partyRelationshipEntreprise = new vlocity_ins__PartyRelationship__c ();
            
            partyRelationshipEntreprise.vlocity_ins__PrimaryRole__c = Label.VlocityPrimaryRoleDirigeant;
            partyRelationshipEntreprise.vlocity_ins__TargetRole__c  = Label.VlocityPrimaryRoleEntreprise;
            partyRelationshipEntreprise.vlocity_ins__SourcePartyId__c = acc.parentCompanyId__r.vlocity_ins__PartyId__c;
            partyRelationshipEntreprise.vlocity_ins__TargetPartyId__c  = acc.vlocity_ins__PartyId__c;
            partyRelationshipEntreprise.vlocity_ins__RelationshipTypeId__c = mapVPRelatiobType.get(Label.VlocityPartyRelationEntreprise);
            listPartyRelationToInsert.add(partyRelationshipEntreprise);
        }
        
        return listPartyRelationToInsert;
    }
    
    
    /***
* @description XSMDPRO-1167 utilisé pour flager les Conjoints et Enfants des salariés
* @param Map<Id, Account> newAccounts : Nouveaux comptes provenant de Trigger.newMap, Map<Id, Account> oldAccounts : Anciens comptes provenant de Trigger.oldMap
* @return void
* @exception aucune
*/
    public static Map<Id, Account> flagConjointEnfants(Map<Id, Account> accountToUpdateMap, List<vlocity_ins__PartyRelationship__c> relationshipList){
        if(relationshipList.size() > 0){
            for (vlocity_ins__PartyRelationship__c partyRelationship :relationshipList){
                if(accountToUpdateMap.get(partyRelationship?.vlocity_ins__SourcePartyId__r?.vlocity_ins__AccountId__c) != null) {
                    accountToUpdateMap.get(partyRelationship.vlocity_ins__SourcePartyId__r.vlocity_ins__AccountId__c).Tech_EmployeeFamily__c = partyRelationship.vlocity_ins__TargetPartyId__r.vlocity_ins__AccountId__r.EmployeeOfGroup__c;
                }else {
                    Account acc = new Account ();
                    acc.Tech_EmployeeFamily__c = partyRelationship.vlocity_ins__TargetPartyId__r.vlocity_ins__AccountId__r.EmployeeOfGroup__c;
                    acc.Id = partyRelationship.vlocity_ins__SourcePartyId__r.vlocity_ins__AccountId__c;
                    accountToUpdateMap.put(acc.Id, acc);
                }
            }
        }
        return accountToUpdateMap;
    }
    
    /***
* @description XSMDPRO-1376 Partage des comptes National et de Défense
* @param Map<Id, Account> newAccounts : Nouveaux comptes provenant de Trigger.newMap, Map<Id, Account> oldAccounts : Anciens comptes provenant de Trigger.oldMap
* @return void
* @exception aucune
*/
    public static void shareAccountstoVAD(Account acc, Account oldAcc, Map<Id,User> mapUserIds){
        Boolean isValide = false;
        //Insert with Referee__c = null
        if(Trigger.isInsert && acc.Referee__c == null){
            isValide = true;
        }//Update with Referee__c or Owner changed
        else if (!Trigger.isInsert && oldAcc != null && oldAcc != null && ((acc.OwnerId != oldAcc.OwnerId) || (acc.Referee__c != oldAcc.Referee__c))){
            isValide = true;
        }
        
        if (isValide){
            if (acc.Referee__c == null && mapUserIds.containsKey(acc.OwnerId)
                && mapUserIds.get(acc.OwnerId)!= null && mapUserIds.get(acc.OwnerId).Fonction__c!= null
                && listFunctions.contains(mapUserIds.get(acc.OwnerId).Fonction__c)){
                    acc.TechShareVAD__c = true;
                }else{
                    acc.TechShareVAD__c = false;
                }
        }
    }
    
    /** @description XSMDPRO--1767 synchro marketing si le compte est ACA ou MDPRO
* @param acc: account modifié*/
    public static void setSynchroMC(Account acc, Account oldAcc, Map<Id, Boolean> hasCustomPermissionMap){
        Set<String> businessSegmentValues = new Set<String>();
        if(oldAcc.Referee__c != acc.Referee__c && acc.BusinessSegment__c != null){
            businessSegmentValues.addAll(acc.BusinessSegment__c.split(';'));
            if (hasCustomPermissionMap.get(acc.OwnerId) && !hasCustomPermissionMap.get(acc.Referee__c) && (businessSegmentValues.contains(MDPRO) || businessSegmentValues.contains(ACA))){
                acc.SynchroMC__c = True;
            }
        }
    }
    
    /** @description XESO-410 consentement email captés par Marketing Cloud
*  @param acc: account modifié*/
    public static void setConsentEmailByMkgCloud(Account acc, Account oldAcc){
        if (oldAcc.PersonHasOptedOutOfEmail != acc.PersonHasOptedOutOfEmail && UserInfo.getFirstName()==System.Label.Marketing_Cloud_Connector) {
            System.debug(LoggingLevel.INFO, 'Consentement maj par le marketing cloud : START');
            acc.UpdateOptinEmailDate__pc = Date.today();
            if (acc.PersonHasOptedOutOfEmail==true) {
                acc.OptinEmail__pc = false;   
            } else {
                acc.OptinEmail__pc = true;
            }
            if (acc.PersonIndividualId==null) {
                AccountTriggerHandler.mapAccountIdToIndividual.put(acc.Id, IndividualMain_UTL.createIndividualFromAccount(acc));
            } else {
                AccountTriggerHandler.mapIndividualIdToAccountId.put(acc.PersonIndividualId, acc.Id);
            }
            String consentementTousGamme = 'GLB';
            String consentementTousAssureur = '0';
            ContactPointTypeConsent oContactPointTypeConsent = new ContactPointTypeConsent();
            
            oContactPointTypeConsent.PartyId = acc.PersonIndividualId;
            oContactPointTypeConsent.Name = getNameConsent('Email', consentementTousGamme, consentementTousAssureur);
            oContactPointTypeConsent.Range__c = consentementTousGamme;
            oContactPointTypeConsent.Insurer__c = consentementTousAssureur;
            oContactPointTypeConsent.CaptureSource = System.Label.Marketing_Cloud;
            oContactPointTypeConsent.CaptureDate = Datetime.now();
            oContactPointTypeConsent.EffectiveFrom = oContactPointTypeConsent.CaptureDate;
            oContactPointTypeConsent.ContactPointType = 'Email';
            if (acc.OptinEmail__pc) {
                oContactPointTypeConsent.ConsentForPhoneCall__c = 'Yes';
                oContactPointTypeConsent.PrivacyConsentStatus = 'OptIn';
            } else {
                oContactPointTypeConsent.ConsentForPhoneCall__c = 'No';
                oContactPointTypeConsent.PrivacyConsentStatus = 'OptOut';
            }
            System.debug(LoggingLevel.INFO, 'Consentement réçu : '+oContactPointTypeConsent);
            AccountTriggerHandler.mapAccountToMarketingEmailConsent.put(acc.Id, oContactPointTypeConsent);
            System.debug(LoggingLevel.INFO, 'Consentement maj par le marketing cloud : END');
        }
    }
    
    /**
* @description Méthode permettant de retourner le nom du consentement
* @return String // Nom du consentement composé de la concatenation de plusieurs champs
*/
    private static String getNameConsent(String contactPointType, String gamme, String assureur) {
        String sNameConsent;
        Schema.DescribeFieldResult fieldResult1 = ContactPointTypeConsent.ContactPointType.getDescribe();
        Schema.DescribeFieldResult fieldResult2 = ContactPointTypeConsent.Range__c.getDescribe();
        Schema.DescribeFieldResult fieldResult3 = ContactPointTypeConsent.Insurer__c.getDescribe();
        
        sNameConsent = getPickListLabelValuesByApiName(fieldResult1, contactPointType);
        sNameConsent += ' - ' + getPickListLabelValuesByApiName(fieldResult2, gamme);
        sNameConsent += ' - ' + getPickListLabelValuesByApiName(fieldResult3, assureur);
        
        return sNameConsent;
    }
    
    /**
* @description Méthode permettant de retourner le label d'une valeur de picklist à partir de son apiName
* @param fieldResult
* @param sPicklistValueApiName       
* @return String            
*/
    public static String getPickListLabelValuesByApiName(Schema.DescribeFieldResult fieldResult, String sPicklistValueApiName) {
        String fieldValue;
        if (fieldResult.isAccessible()) {
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry pickListVal : ple) {
                if(pickListVal.getValue() == sPicklistValueApiName) {
                    fieldValue = pickListVal.getLabel();
                }
            }
        } 
        return fieldValue;
    }
    /***
	* @description XET-670 Lier une PM siège(headquarters__c=true) avec ses PM secondaires(headquarters__c=false) via le parentAccount(parentId) en after insert
	* @param List<Account> accounts : liste des comptes issus de Trigger.new
	* @return Map<Id, Account> accountToUpdate :  Map des Ids des comptes à mettre à jour 
	* @exception aucune
	*/
    public static Map<Id, Account> setLinkAccountHeadquatersAfterInsert(Account acc,Map<Id, Account> accountToUpdate){
        //Récupere la liste des ids des comptes  PM sièges 
        List<Id> listIdsSieges = AccountTriggerHandler.mapSirenToListIdAccountSiege.get(acc.siren__c);
        //Cas : Account PM siège insérée
        if(acc.headquarters__c == true && (acc.ActivityCessation__c==null || acc.ActivityCessation__c > System.TODAY())){
            //Récuperer la liste des comptes secondaires de meme siren que le compte PM siège  en cours d'insertion 
            list<account> lstAcc = AccountTriggerHandler.mapSirenToAccountSecondaire.get(acc.siren__c);
            System.debug('#Parent Headqueters size TRUE # '+listIdsSieges.size());
            //On vérifie que la PM siège est unique et ouverte, si cela on le rattache à tous les comptes PM secondaires de même siren
            if(listIdsSieges !=null && listIdsSieges.size()==1 && lstAcc!=null){
                for(account acsec : lstAcc){
                    if(acsec.Id !=acc.Id){
                        if(accountToUpdate.get(acsec.Id)!=null){
                            accountToUpdate.put(accountToUpdate.get(acsec.Id).Id,new account(Id = accountToUpdate.get(acsec.Id).Id,ParentId = acc.Id));
                        }else{
                            accountToUpdate.put(acsec.Id,new account(Id = acsec.Id,ParentId = acc.Id));
                        }
                    }
                }
            }
            //Si on deux PM sièges ouvertes, on fait rien(pas de reparente des Pm secondaires ) 
        }
        //Cas : Account PM secondaire(filiale) insérée PM avec headquaters=false
        else{
            //On vérifie que nous avons une PM siège unique et ouverte de même siren que la PM secondaire en cours d'insertion, si cela on le rattache 
            if(listIdsSieges !=null && listIdsSieges.size()==1){ 
                if(accountToUpdate.get(acc.Id)!=null){
                    accountToUpdate.put(accountToUpdate.get(acc.Id).Id,new account(Id = accountToUpdate.get(acc.Id).Id,ParentId =listIdsSieges[0]));
                }else{
                    accountToUpdate.put(acc.Id, new account(Id=acc.Id,ParentId=listIdsSieges[0]));
                } 
            } 
            //Si on deux PM sièges ouvertes, on fait rien(pas de reparente des Pm secondaires) 
        }
        System.debug('accountToInsert_SVE'+accountToUpdate); 
        return accountToUpdate;
    } 
    /***
	* @description XET-670 Lier une PM siège(headquarters__c=true) avec ses PM secondaires(headquarters__c=false) via le parentAccount(parentId) en after update
	* @param List<Account> accounts : liste des comptes issus de Trigger.new
	* @return Map<Id, Account> accountToUpdate :  Map des Ids des comptes à mettre à jour 
	* @exception aucune
	*/
    public static Map<Id, Account> setLinkAccountHeadquatersAfterUpdate(Account acc,Account oldAcc, Map<Id, Account> accountToUpdate){
        //Récuperer la liste des Ids sièges ayant le même siren avec  le compte en cours de mise à jour 
        List<Id> listIdsSieges = AccountTriggerHandler.mapSirenToListIdAccountSiege.get(acc.siren__c);
        //Récuperer la liste des comptes secondaires ayant le même siren avec le compte en cours de mise à jour  
        list<account> lstAcc = AccountTriggerHandler.mapSirenToAccountSecondaire.get(acc.siren__c);
        if(oldAcc !=null && oldAcc.headquarters__c!= acc.headquarters__c){
            //Cas : Account PM secondaire(headquarters__c=false) mise à jour à PM siège(headquarters__c=true) ouverte
            if(acc.headquarters__c == true && (acc.ActivityCessation__c==null || acc.ActivityCessation__c > System.TODAY())){
                //Mise à jour à null du parentId de la PM secondaire qui est modifiée pour passer à une PM siège
                if(accountToUpdate.get(acc.Id)!=null){
                    accountToUpdate.put(accountToUpdate.get(acc.Id).Id,new account(Id = accountToUpdate.get(acc.Id).Id,ParentId = null));
                }else{
                    accountToUpdate.put(acc.Id,new account(Id = acc.Id,ParentId = null)); }
                //On vérifie que la PM siège est unique et ouverte, si cela on le rattache à tous les comptes PM secondaires de même siren
                System.debug('#Parent Headqueters size Update to true size #  '+listIdsSieges.size());
                if(listIdsSieges !=null && listIdsSieges.size()==1 && lstAcc!=null){
                    for(account acsec : lstAcc){
                        System.debug('\n#MDB#Siege:'+' acc.Id: ' +acc.Id+'acc.SIRETnumber__c : ' +acc.SIRETnumber__c);
                        System.debug('\n#MDB#Secondaire:'+' acsec.Id:  ' +acsec.Id+ 'acsec.SIRETnumber__c : ' +acsec.SIRETnumber__c);
                        if(acsec.Id !=acc.Id){
                            if(accountToUpdate.get(acsec.Id) !=null){
                                accountToUpdate.put(accountToUpdate.get(acsec.Id).Id,new account(Id = accountToUpdate.get(acsec.Id).Id,ParentId = acc.Id));
                            }
                            else {accountToUpdate.put(acsec.Id,new account(Id = acsec.Id,ParentId = acc.Id));}
                        }
                    }
                }
                
            }
            //Cas : Account PM siège(headquarters__c=true) mise à jour à PM secondaire(headquarters__c=false) 
            else{
                System.debug('\n#MDB#SiegeAfterUpdate:'+' acc.: ' +acc.Id+' acc.siren__c : ' +acc.siren__c +'  siret '+acc.SIRETnumber__c+'  Headquaters '+acc.headquarters__c);
                //Vérifier s'il existe une PM siège unique et rattacher les PM secondaires 
                if(listIdsSieges !=null && listIdsSieges.size()==1){
                    for(account acsec : lstAcc){
                        System.debug('\n#MDB#Secondaire:'+' acsec.Id:  ' +acsec.Id+ 'acsec.SIRETnumber__c : ' +acsec.SIRETnumber__c);
                        if(acsec.Id!=listIdsSieges[0]){
                            if(accountToUpdate.get(acsec.Id)!=null){
                                accountToUpdate.put(accountToUpdate.get(acsec.Id).Id,new account(Id = accountToUpdate.get(acsec.Id).Id,ParentId =listIdsSieges[0]));
                            }else{accountToUpdate.put(acsec.Id,new account(Id = acsec.Id,ParentId =listIdsSieges[0]));}
                        }
                    }   
                }
                //Sinon deux PM sièges(headquaters=true) donc mise à jour à null du parentID pour les PM secondaires(headquaters=false) 
                else{
                    for(account acsec : lstAcc){
                        System.debug('\n#MDB#Secondaire:'+' acsec.Id:  ' +acsec.Id+ 'acsec.SIRETnumber__c : ' +acsec.SIRETnumber__c);
                        if(accountToUpdate.get(acsec.Id)!=null){
                            accountToUpdate.put(accountToUpdate.get(acsec.Id).Id,new account(Id = accountToUpdate.get(acsec.Id).Id,ParentId =null));
                        }else{accountToUpdate.put(acsec.Id,new account(Id = acsec.Id,ParentId =null));}
                    }
                }
            }
        }
        System.debug('#MDB#accountoUpdate_SVE'+accountToUpdate); 
        return accountToUpdate;
    } 
    /***
* @description XSMDPRO-1509 Bypass des VR lors du confiage
* @param Map<Id, Account> newAccounts : Nouveaux comptes provenant de Trigger.newMap, Map<Id, Account> oldAccounts : Anciens comptes provenant de Trigger.oldMap
* @return void
* @exception aucune
*/
    public static void bypassVRConfiage(Account acc, Account oldAcc){
        if (acc.Referee__c != null && oldAcc != null && acc.Referee__c != oldAcc.Referee__c){
            //Bypass Validation Rules
            ApexVRSwitch_UTL.enforcedByPass  = new Set <String>{'VR_Account_01_4ChiffreMin', 'VR_ACCT_PACC_03_OwnerChangesApproval', 'VR_ACCT_PACC_05_PostalCodeMandatory',
                'VR_PACC_02_SalutationMandatory', 'VR_PACC_03_FirstNameMandatory',
                'VR_PACC_15_IfOtherSpecify_Profession', 'VR_PACC_16_IfVIPFilled_VipMotif', 'VR_PACC_17_If_Profession', 'VR_PACC_18_Profession_SIC',
                'VR_PACC_19_PostalCodeFormat', 'VR_PACC_22_CommuneNaissanceValide', 'VR_PACCT_12_PersonBirthdateToday', 'VR_PACC_23_CountryOfBirthNotFrance',
                'VR_PACCT_20_EmailFormat', 'VR_PACCT_21_AnnualIncome', 'VR_ACCT_06_PostalCodeMandatory',
                'VR_ACCT_07_PostalCodeFormat', 'VR_ACCT_08_Phone10Digits', 'VR_ACCT_09_PersonHomePhone10Digits', 'VR_ACCT_10_PersonMobileHomePhone10Digit',
                'VR_ACCT_11_SIRET14Number', 'VR_ACCT_12_PersonOtherPhone', 'VR_ACCT_13_LockSpecialCar_FirstName', 'VR_ACCT_14_LockSpecialCar_LastName',
                'VR_ACCT_20_FaxFormat', 'VR_ACCT_21_AnnualRevenue', 'VR_ACCT_22_SumRevenuePercentage', 'VR_ACCT_23_ChildrenNumber',
                'VR_ACCT_24_MobilePhone10or14Digits', 'VR_ACCT_25_OtherPhone10or14Digits', 'VR_ACCT_PACC_02_OwnerChanged', 'VR_ACCT_PACC_04_OwnerChangedReason',
                'VR_ACCT_18_If_NafCode', 'VR_ACCT_19_ChangeAccountName', 'VR_ACCT_PACC_08_AssistantOwner',
                'VR_ACC_BlockChangeOwner', 'VR_PACC_04_ContactInfoMandatory', 'VR_ACCT_05_ComptetInfoMandatory'};
                    }
    }
}