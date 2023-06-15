
/***												
* @author Matthieu CASASSUS					
* @date 15/11/2019									
* @description Classe de test pour la Account_SVE
* @see Account_SVE
*/
@isTest
public class Account_SVE_TST {
    /***												
    * @description Test conversion prospect/client insert/update
    * @param aucun
    * @return void
    * @exception aucune
    * @see convertToCustomer
    */
    @isTest
    public static void testConvertToCustomer(){
        Id personAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Id personAccountCustomerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccountCustomer').getRecordTypeId();
        Id personneMoraleRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Personne_Morale').getRecordTypeId();
        Id businessAccountCustomerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BusinessAccountCustomer').getRecordTypeId();
        
        List<Account> accPP = Account_TDF.createPersonAccounts(2);
        List<Account> accPM = Account_TDF.createBusinessAccounts(2);
        
        //test insert
        accPP.get(0).RecordTypeId = personAccountRT;
        accPP.get(0).Type = 'Customer';
        accPP.get(1).RecordTypeId = personAccountCustomerRT;
        accPP.get(1).Type = 'Prospect';
        
        accPM.get(0).RecordTypeId = personneMoraleRT;
        accPM.get(0).Type = 'Customer';
        accPM.get(1).RecordTypeId = businessAccountCustomerRT;
        accPM.get(1).Type = 'Prospect';
        
        insert(accPP);
        insert(accPM);
        
        List<Account> resPP = [SELECT Id, RecordTypeId FROM Account WHERE IsPersonAccount = true];
        List<Account> resPM = [SELECT Id, RecordTypeId FROM Account WHERE IsPersonAccount = false];
        
        system.assertEquals(personAccountCustomerRT, resPP.get(0).RecordTypeId);
        system.assertEquals(personAccountRT, resPP.get(1).RecordTypeId);

        system.assertEquals(businessAccountCustomerRT, resPM.get(0).RecordTypeId);
        system.assertEquals(personneMoraleRT, resPM.get(1).RecordTypeId);
        
        //test update
        accPP.get(1).Type = 'Customer';
        accPP.get(0).Type = 'Prospect';
        
        accPM.get(1).Type = 'Customer';
        accPM.get(0).Type = 'Prospect';
        
        update(accPP);
        update(accPM);
        
        List<Account> resPP2 = [SELECT Id, RecordTypeId, OptinSms__pc, OptinEmail__pc, SynchroMC__c FROM Account WHERE IsPersonAccount = true];
        List<Account> resPM2 = [SELECT Id, RecordTypeId FROM Account WHERE IsPersonAccount = false];
        
        system.assertEquals(personAccountCustomerRT, resPP2.get(1).RecordTypeId);
        system.assertEquals(personAccountRT, resPP2.get(0).RecordTypeId);
        system.assertEquals(true, resPP2.get(1).SynchroMC__c);
        system.assertEquals(true, resPP2.get(1).OptinEmail__pc);
        system.assertEquals(true, resPP2.get(1).OptinSms__pc);
        system.assertEquals(businessAccountCustomerRT, resPM2.get(1).RecordTypeId);
        system.assertEquals(personneMoraleRT, resPM2.get(0).RecordTypeId);
    }

    @isTest
    public static void testInstantCreatCMPE(){
        Test.startTest();
        List<Account> accs = Account_TDF.createPersonAccounts(2);
        Account account = accs[0];
        Account account2 = accs[1];
        account.PropertyAssets__pc = 1;
        insert accs;

        Prise_element__c pe = new Prise_element__c();
        pe.InstantCreatCM__c = date.valueOf('2020-06-20 00:00:00');
        pe.Personne__c = account.id;
        insert pe;

        account.PropertyAssets__pc = 12;
        account2.PropertyAssets__pc = 12;
        update(accs);

        Test.stopTest();

        System.assertNotEquals(datetime.valueOf('2020-06-20 00:00:00'), [SELECT Id,InstantCreatCM__c FROM Prise_element__c WHERE id = :pe.id].InstantCreatCM__c);
        List<Prise_element__c> pe2 = [SELECT Id,InstantCreatCM__c FROM Prise_element__c WHERE personne__c = :account2.id];
        System.assertNotEquals(0, pe2.size());
    }
    
    /***												
    * @description Test flag PartnerForPM insert
    * @param aucun
    * @return void
    * @exception aucune
    * @see setPartnerPM
    */
    @isTest
    public static void testSetPartnerPM(){
        SettingsObject__c s = new SettingsObject__c(
            Name = 'TEST',
            Type__c = 'NAF',
            Code__c = '7022Z'
        );
        insert(s);
        
        List<Account> accPM = Account_TDF.createBusinessAccounts(4);
        List<Account> accPP = Account_TDF.createPersonAccounts(2);
        
        accPM.get(3).NafCode__c = s.Id;
        accPM.get(2).NafCode__c = s.Id;
        insert(accPM);
        Set<Id> pmId = new Set<Id>();
        pmId.add(accPM.get(3).Id);
        pmId.add(accPM.get(2).Id);
        Account_UTL.updatePartnerPM(pmId);
        
        //test insert
        accPP.get(0).Partner__c = true;
        accPP.get(0).Profession__pc = '318';
        accPP.get(0).ParentCompanyId__c = accPM.get(3).Id;
        
        accPP.get(1).Partner__c = false;
        accPP.get(1).Profession__pc = '27';
        accPP.get(1).ParentCompanyId__c = accPM.get(1).Id;
        
        insert(accPP);
        
        List<Account> res = [SELECT Id, PartnerForPM__c FROM Account WHERE IsPersonAccount = false];
        system.assertEquals(false, res.get(0).PartnerForPM__c);
        system.assertEquals(false, res.get(1).PartnerForPM__c);
        system.assertEquals(true, res.get(2).PartnerForPM__c);
        system.assertEquals(true, res.get(3).PartnerForPM__c);       
    }

    @isTest
    public static void testSetBusinessSegment_WithoutOwnerNetworkAssignment(){
        
        // Insertion d'un utilisateur inspecteur afin d'effectuer les tests dans son contexte
        // Profil 'Administrateur système' utilisé en attendant de trouver une solution pour l'attribution du permset qui cause une Mixed DML Exception (D.ATTALI)
        User user =  User_TDF.createUsers(1,Label.UserFonctionInspector).get(0);
        update user;
        
        System.runAs(user){
            
            Test.startTest();
            insert Account_TDF.createBusinessAccounts(1)[0];
            Test.stopTest();
        }
        // Test de l'alimentation
        Account account = [SELECT Id, BusinessSegment__c, TechMDProCustomerMC__c, TechVADCustomerMC__c FROM Account LIMIT 1];
        
       // XSMDPRO-1916 - on historise dans la multipicklist BusinessSegment__c les valeurs précédentes
       // et on se base maintenant sur le champs NetworkMembership__c 
        System.assertEquals('MDPro', account.BusinessSegment__c);
        System.assertEquals(true, account.TechMDProCustomerMC__c);
        System.assertEquals(false, account.TechVADCustomerMC__c);
    }
    
    @isTest
    public static void testSetBusinessSegment_OwnerMDProWithoutReferee(){
        
        // Insertion d'un utilisateur inspecteur afin d'effectuer les tests dans son contexte
        // Profil 'Administrateur système' utilisé en attendant de trouver une solution pour l'attribution du permset qui cause une Mixed DML Exception (D.ATTALI)
        User user =  User_TDF.createUsers(1,Label.UserFonctionInspector).get(0);
        user.NetworkAssignment__c = 'MDPro';
        update user;
        
        System.runAs(user){
            
            Test.startTest();
            insert Account_TDF.createBusinessAccounts(1)[0];
            Test.stopTest();
        }
        // Test de l'alimentation
        Account account = [SELECT Id, BusinessSegment__c, TechMDProCustomerMC__c, TechVADCustomerMC__c FROM Account LIMIT 1];
        System.assertEquals('MDPro', account.BusinessSegment__c);
        System.assertEquals(true, account.TechMDProCustomerMC__c);
        System.assertEquals(false, account.TechVADCustomerMC__c);
    }
    
    @isTest
    public static void testSetBusinessSegment_OwnerVADWithoutReferee(){
        
        // Insertion d'un utilisateur inspecteur afin d'effectuer les tests dans son contexte
        // Profil 'Administrateur système' utilisé en attendant de trouver une solution pour l'attribution du permset qui cause une Mixed DML Exception (D.ATTALI)
        User user =  User_TDF.createUsers(1,Label.UserFonctionVADManager).get(0);
        user.NetworkAssignment__c = 'VAD';
        update user;
        
        System.runAs(user){
            
            Test.startTest();
            insert Account_TDF.createBusinessAccounts(1)[0];
            Test.stopTest();
        }
        // Test de l'alimentation
        Account account = [SELECT Id, BusinessSegment__c, TechMDProCustomerMC__c, TechVADCustomerMC__c FROM Account LIMIT 1];
        System.assertEquals('VAD', account.BusinessSegment__c);
        System.assertEquals(false, account.TechMDProCustomerMC__c);
        System.assertEquals(true, account.TechVADCustomerMC__c);
    }
    
    @isTest
    public static void testSetBusinessSegment_WithRefereeMDPro(){
        
        // Insertion d'un utilisateur inspecteur afin d'effectuer les tests dans son contexte

        
        User user01 =  User_TDF.createUsers(1,Label.UserFonctionVADManager).get(0);
        user01.Username = 'user01@alm.com';
        user01.NetworkAssignment__c = 'VAD';
        update user01;
        
        // Insertion d'un utilisateur inspecteur afin d'effectuer les tests dans son contexte
        User user02 =  User_TDF.createUsers(1,Label.UserFonctionInspector).get(0);
        user02.Username = 'user_test02@ag2rlamondiale.fr';
        user02.NetworkAssignment__c = 'MDPro';
        update user02;       
        
        System.runAs(user01){
            
            Test.startTest();
            Account account = Account_TDF.createBusinessAccounts(1)[0];
            account.Referee__c = user02.Id;
            insert account;
            Test.stopTest();
        }
        // Test de l'alimentation
        Account account = [SELECT Id, BusinessSegment__c, TechMDProCustomerMC__c, TechVADCustomerMC__c FROM Account LIMIT 1];
        System.assertEquals('MDPro', account.BusinessSegment__c);
        System.assertEquals(true, account.TechMDProCustomerMC__c);
        System.assertEquals(false, account.TechVADCustomerMC__c);
    }
    
    @isTest
    public static void testSetBusinessSegment_WithRefereeVAD(){
        
        // Insertion d'un utilisateur inspecteur afin d'effectuer les tests dans son contexte
        User user01 =  User_TDF.createUsers(1,Label.UserFonctionInspector).get(0);
        user01.Username = 'user_test01@ag2rlamondiale.fr';
        user01.NetworkAssignment__c = 'MDPro';
        update user01;
        
        // Insertion d'un utilisateur inspecteur afin d'effectuer les tests dans son contexte
        User user02 =  User_TDF.createUsers(1,Label.UserFonctionVADManager).get(0);
        user02.Username = 'user_test02@ag2rlamondiale.fr';
        user02.NetworkAssignment__c = 'VAD';
        update user02;
        
        System.runAs(user01){
            
            Test.startTest();
            Account account = Account_TDF.createBusinessAccounts(1)[0];
            account.Referee__c = user02.Id;
            insert account;
            Test.stopTest();
        }
        // Test de l'alimentation
        Account account = [SELECT Id, BusinessSegment__c, TechMDProCustomerMC__c, TechVADCustomerMC__c FROM Account LIMIT 1];
        System.assertEquals('VAD', account.BusinessSegment__c);
        System.assertEquals(false, account.TechMDProCustomerMC__c);
        System.assertEquals(true, account.TechVADCustomerMC__c);
    }
    
    @isTest
    public static void testSetIsBorrowPeriod(){
        
        // Insertion d'un utilisateur inspecteur afin d'effectuer les tests dans son contexte
        User user01 =  User_TDF.createUsers(1,Label.UserFonctionInspector).get(0);
        user01.Username = 'user_test01@ag2rlamondiale.fr';
        update user01;
        
        // Insertion d'un utilisateur inspecteur afin d'effectuer les tests dans son contexte
        User user02 =  User_TDF.createUsers(1,Label.UserFonctionInspector).get(0);
        user02.Username = 'user_test02@ag2rlamondiale.fr';
        update user02;
        
        System.runAs(user01){
            
            Test.startTest();
            Account account = Account_TDF.createBusinessAccounts(1)[0];
            insert account;
            account.Referee__c = user02.Id;
            update account;
            Test.stopTest();
        }
        // Test de l'alimentation de la relation commerciale
        System.assertEquals(true, [SELECT Id, TechIsBorrowPeriod__c FROM Account LIMIT 1].TechIsBorrowPeriod__c);
    }

    @isTest
    public static void setTechFieldsDate(){
        List<Account> accounts = Account_TDF.createPersonAccounts(2);
        accounts[0].FirstName = 'JEAN';
        accounts[1].FirstName = 'JEANNE';
        //Street
        accounts[0].PersonOtherStreet = 'Rue des 21 appelés morts pour la france';
        //Postal code
        accounts[0].PersonOtherPostalCode = '750011';
        //City
        accounts[0].PersonOtherCity = 'Saint-Remy-en-Bouzemont-Saint-Genest-et-';

        insert accounts;

        accounts = [SELECT Id, FirstName, PhoneDateMaj__c, PersonMobilePhoneDateMaj__c, PersonEmailDateMaj__c, PersonOtherAddressDateMaj__c, PersonMailingAddressDateMaj__c, ProfessionalEmailDateMaj__c, PersonHomePhoneDateMaj__c, AcctProEmail__c, PersonHomePhone, PersonOtherPhone FROM Account];
        system.Debug(accounts);
        /*for(Account acc: accounts){
            if(acc.FirstName == 'JEAN'){
                system.assertEquals(Date.today(), acc.PersonMobilePhoneDateMaj__c);
                system.assertEquals(Date.today(), acc.PersonEmailDateMaj__c);
                system.assertEquals(Date.today(), acc.PersonOtherAddressDateMaj__c);
                system.assertEquals(Date.today(), acc.PersonMailingAddressDateMaj__c);
                system.assertEquals(Date.today(), acc.ProfessionalEmailDateMaj__c);
                system.assertEquals(Date.today(), acc.PersonHomePhoneDateMaj__c);

                acc.AcctProEmail__c = 'TTT@ag2rlamondiale.fr';
            }else{
                system.assertEquals(Date.today(), acc.PersonMobilePhoneDateMaj__c);
                system.assertEquals(Date.today(), acc.PersonEmailDateMaj__c);
                system.assertEquals(Date.today(), acc.ProfessionalEmailDateMaj__c);
                system.assertEquals(Date.today(), acc.PersonHomePhoneDateMaj__c);
                system.assertEquals(null, acc.PhoneDateMaj__c);

                acc.PersonOtherPhone = '0111111111';
            }
        }
        update accounts;
        accounts = [SELECT Id, FirstName, PersonOtherPhoneDateMaj__c, AcctProEmailDateMaj__c FROM Account];
        for(Account acc: accounts) {
            if (acc.FirstName == 'JEAN') {
                system.assertEquals(Date.today(), acc.AcctProEmailDateMaj__c);
                system.assertEquals(null, acc.PersonOtherPhoneDateMaj__c);
            } else {
                system.assertEquals(Date.today(), acc.PersonOtherPhoneDateMaj__c);
                system.assertEquals(null, acc.AcctProEmailDateMaj__c);
            }
        }*/
    }

    
    @isTest
    public static void testflagFreeZoneAccount(){
        String ppCity = 'Paris';
        String pmCity = 'Paris';
        String ppPostalCode = '75001';
        String pmPostalCode = '75002';
        
        String ppCityUpdate = 'Levallois-Perret';
        String pmCityUpdate = 'Nanterre';
        String ppPostalCodeUpdate = '92300';
        String pmPostalCodeUpdate = '92014';
        //Create Account Sectors 
        List<AccountSectorization__c> sectorizations = new List<AccountSectorization__c>();
        sectorizations.add(new AccountSectorization__c(
            City__c = ppCity,
            Name = 'Inspecteur test',
            PostalCode__c = ppPostalCode,
            Inspector__c = UserInfo.getUserId(),
            Free_Zone__c = true
        ));
        
        sectorizations.add(new AccountSectorization__c(
            City__c = pmCity,
            Name = 'Inspecteur test',
            PostalCode__c = pmPostalCode,
            Inspector__c = UserInfo.getUserId(),
            Free_Zone__c = false
        ));
        
        sectorizations.add(new AccountSectorization__c(
            City__c = ppCityUpdate,
            Name = 'Inspecteur test',
            PostalCode__c = ppPostalCodeUpdate,
            Inspector__c = UserInfo.getUserId(),
            Free_Zone__c = false
        ));

        sectorizations.add(new AccountSectorization__c(
            City__c = pmCityUpdate,
            Name = 'Inspecteur test',
            PostalCode__c = pmPostalCodeUpdate,
            Inspector__c = UserInfo.getUserId(),
            Free_Zone__c = true
        ));        
        insert(sectorizations);
        
        //Create Personne Physique
        List<Account> listPersonAccounts = Account_TDF.createPersonAccounts(1);
        listPersonAccounts[0].PersonMailingCity = ppCity;
        listPersonAccounts[0].PersonMailingPostalCode = ppPostalCode;
        insert listPersonAccounts;
        
        //Create Personne Morale
        List<Account> listBusinessAccounts = Account_TDF.createBusinessAccounts(1);
        listBusinessAccounts[0].BillingCity = pmCity;
        listBusinessAccounts[0].BillingPostalCode = pmPostalCode;
        insert listBusinessAccounts;
        
        
        //Assert Results 
        Map<Id,Account> mapAccountsIds = new Map<Id,Account> ([SELECT Id, Name, Free_Zone__c
                                                               FROM Account 
                                                               WHERE (Id =: listPersonAccounts[0].Id OR Id =: listBusinessAccounts[0].Id)]);
        
        system.assertEquals(true,mapAccountsIds.get(listPersonAccounts[0].Id).Free_Zone__c);
        system.assertEquals(false,mapAccountsIds.get(listBusinessAccounts[0].Id).Free_Zone__c);
        
        //Update Accounts 
        //Update Personne Physique adresse
        listPersonAccounts[0].PersonMailingCity = ppCityUpdate;
        listPersonAccounts[0].PersonMailingPostalCode = ppPostalCodeUpdate;
        update listPersonAccounts;
        
        //Update Personne Morale adresse
        listBusinessAccounts[0].BillingCity = pmCityUpdate;
        listBusinessAccounts[0].BillingPostalCode = pmPostalCodeUpdate;
        update listBusinessAccounts;
        
        //Assert Results 
        Map<Id,Account> mapAccountsIdsUpdate = new Map<Id,Account> ([SELECT Id, Name, Free_Zone__c
                                                                     FROM Account 
                                                                     WHERE (Id =: listPersonAccounts[0].Id OR Id =: listBusinessAccounts[0].Id)]);
        
        system.assertEquals(false,mapAccountsIdsUpdate.get(listPersonAccounts[0].Id).Free_Zone__c);
        system.assertEquals(true,mapAccountsIdsUpdate.get(listBusinessAccounts[0].Id).Free_Zone__c);
    }

    @isTest
    public static void testsyncAccountLink(){
        //Create Personne Morale
        List<Account> listBusinessAccounts = Account_TDF.createBusinessAccounts(2);
        listBusinessAccounts[0].BillingCity = 'Paris';
        listBusinessAccounts[0].BillingPostalCode = '75015';
        insert listBusinessAccounts;
        
        //Create Personne Physique
        List<Account> listPersonAccounts = Account_TDF.createPersonAccounts(1);
        listPersonAccounts[0].PersonMailingCity = 'Paris';
        listPersonAccounts[0].PersonMailingPostalCode = '75015';


        listPersonAccounts[0].ParentCompanyId__c = listBusinessAccounts[0].Id;
        //Create Vlocity RelationType
        List<vlocity_ins__PartyRelationshiptype__c> listPartyRelationTypes = new List<vlocity_ins__PartyRelationshiptype__c>();
        vlocity_ins__PartyRelationshiptype__c typeDirigeant = new vlocity_ins__PartyRelationshiptype__c ();
        typeDirigeant.name = 'Dirigeant'; 
        typeDirigeant.vlocity_ins__SourceString__c  = Label.VlocityPartyRelationDirigeant;
        typeDirigeant.vlocity_ins__Color__c = '#e02626';
        typeDirigeant.vlocity_ins__TargetRole__c='Dirigeant';
        listPartyRelationTypes.add(typeDirigeant);
        
        vlocity_ins__PartyRelationshiptype__c typeEntreprise = new vlocity_ins__PartyRelationshiptype__c ();
        typeEntreprise.name = 'Entreprise'; 
        typeEntreprise.vlocity_ins__SourceString__c  = Label.VlocityPartyRelationEntreprise;
        typeEntreprise.vlocity_ins__Color__c = '#e02626';
        typeEntreprise.vlocity_ins__TargetRole__c='Entreprise';
        listPartyRelationTypes.add(typeEntreprise); 
        
        insert listPartyRelationTypes;
        
        test.startTest();
        VlocityPartyRelationship_VR.disableVR.put('VR_SourceAndTargetHasPartyIdFilled', true);
        //Check for Account Insert 
        insert listPersonAccounts;



        List<vlocity_ins__PartyRelationship__c> listPartyRelationshipsNewAccount = new List<vlocity_ins__PartyRelationship__c> ([Select Id, Name, vlocity_ins__RelationshipTypeId__c, vlocity_ins__RelationshipTypeId__r.name
                                                                                                                                 From vlocity_ins__PartyRelationship__c]);
        system.assertEquals(2, listPartyRelationshipsNewAccount.size());


        test.stopTest();

        system.assertEquals(true, [SELECT MassSending__c from account where id =: listPersonAccounts[0].Id].MassSending__c);
    }

    
    //XSMDPRO-1167 utilisé pour flager les Conjoints et Enfants des salariés
    @isTest
    static void testflagConjointEnfants(){        
        //Create Personne Physique        
        List<Account> listPersonAccounts = Account_TDF.createPersonAccounts(2);
        //Salarié
        listPersonAccounts[0].PersonMailingCity = 'Paris';
        listPersonAccounts[0].PersonMailingPostalCode = '75015';
        listPersonAccounts[0].FirstName = 'Test';
        listPersonAccounts[0].LastName = 'Salarie';
        listPersonAccounts[0].EmployeeOfGroup__c = true;
        //Conjoint
        listPersonAccounts[1].PersonMailingCity = 'Paris';
        listPersonAccounts[1].PersonMailingPostalCode = '75015';
        listPersonAccounts[1].FirstName = 'Test';
        listPersonAccounts[1].LastName = 'Conjoint';
        //Enfant
        Account acc = new Account ();
        acc.FirstName = 'Test';
        acc.LastName = 'Enfant';
        acc.Salutation = 'Mr.';
        acc.PersonMailingPostalCode = '75015';
        acc.PersonMailingCity = 'Paris';
        acc.PersonBirthdate = Date.newInstance(1980, 08, 14);
        acc.PersonEmail = 'testEnfant@test.com';
        listPersonAccounts.add(acc);
        
        insert listPersonAccounts;
        
        
        //Create Party 
        List<vlocity_ins__Party__c> parties = new List<vlocity_ins__Party__c>();
        vlocity_ins__Party__c party1 = new vlocity_ins__Party__c ();
        party1.name = 'Salarie';
        party1.vlocity_ins__AccountId__c = listPersonAccounts[0].Id;
        parties.add (party1);
        
        vlocity_ins__Party__c party2 = new vlocity_ins__Party__c ();
        party2.name = 'Conjoint';
        party2.vlocity_ins__AccountId__c = listPersonAccounts[1].Id;
        parties.add (party2);
        
        vlocity_ins__Party__c party4 = new vlocity_ins__Party__c ();
        party4.name = 'Enfant';
        party4.vlocity_ins__AccountId__c = listPersonAccounts[2].Id;
        parties.add (party4);
        
        insert(parties);
        
        //Create Vlocity RelationType
        List<vlocity_ins__PartyRelationshiptype__c> listPartyRelationTypes = new List<vlocity_ins__PartyRelationshiptype__c>();
        vlocity_ins__PartyRelationshiptype__c typeConjoint = new vlocity_ins__PartyRelationshiptype__c ();
        typeConjoint.name = 'Conjoint'; 
        typeConjoint.vlocity_ins__SourceString__c  = '{SOURCE} a pour conjoint {TARGET}';
        typeConjoint.vlocity_ins__Color__c = '#428200';
        typeConjoint.vlocity_ins__TargetRole__c='Conjoint';
        listPartyRelationTypes.add(typeConjoint);
        
        vlocity_ins__PartyRelationshiptype__c typeParent = new vlocity_ins__PartyRelationshiptype__c ();
        typeParent.name = 'Enfant'; 
        typeParent.vlocity_ins__SourceString__c  = '{SOURCE} est l\'enfant de {TARGET}';
        typeParent.vlocity_ins__Color__c = '#428200';
        typeParent.vlocity_ins__TargetRole__c='Parent';
        listPartyRelationTypes.add(typeParent); 
        
        insert listPartyRelationTypes;
        
        //Create Vlocity RelationType
        //Salarié Conjoint
        List<vlocity_ins__PartyRelationship__c> listPartyRelation = new List<vlocity_ins__PartyRelationship__c>();
        vlocity_ins__PartyRelationship__c relationConjoint = new vlocity_ins__PartyRelationship__c ();
        relationConjoint.vlocity_ins__RelationshipTypeId__c = typeConjoint.Id;
        relationConjoint.vlocity_ins__SourcePartyId__c = party2.Id; 
        relationConjoint.vlocity_ins__TargetPartyId__c = party1.Id;
        relationConjoint.name = 'Conjoint'; 
        listPartyRelation.add(relationConjoint);
        
        //Salarié Parent
        vlocity_ins__PartyRelationship__c relationParent = new vlocity_ins__PartyRelationship__c ();
        relationParent.vlocity_ins__RelationshipTypeId__c = typeParent.Id;
        relationParent.vlocity_ins__SourcePartyId__c = party4.Id; 
        relationParent.vlocity_ins__TargetPartyId__c = party1.Id;
        relationParent.name = 'Enfant'; 
        listPartyRelation.add(relationParent);
        
        
        insert listPartyRelation;
        
        List<Account> listAccounts = new List <Account> ([Select Id, Name, Tech_EmployeeFamily__c
                                                          From Account 
                                                          Where LastName = 'Conjoint' or LastName = 'Enfant']);
        
        system.assertEquals(true, listAccounts[0].Tech_EmployeeFamily__c);
        system.assertEquals(true, listAccounts[1].Tech_EmployeeFamily__c);
        
		Test.startTest();
        AccountTriggerHandler.triggerDisabled = false;
        listPersonAccounts[0].EmployeeOfGroup__c = false;
        update listPersonAccounts;
        
        Test.stopTest();
        
        //Assert Results
        List<Account> listAccountsAfter = new List <Account> ([Select Id, Name, Tech_EmployeeFamily__c
                                                          From Account 
                                                          Where LastName = 'Conjoint' or LastName = 'Enfant']);
        system.assertEquals(false, listAccountsAfter[0].Tech_EmployeeFamily__c);
        system.assertEquals(false, listAccountsAfter[1].Tech_EmployeeFamily__c);
    }


    @isTest
    public static void testChangeOwner(){
        //Create Inspector
        User oManager = User_TDF.createUsers(1,Label.UserFonctionInspector).get(0);
        oManager.Username = 'inspector@ag2rlamondiale.fr';
        update oManager;
        User assist = User_TDF.createUsers(1,Label.UserFonctionCommercialAssistant).get(0);

        System.runAs(oManager){
            //Create Account Sectors
            AccountSectorization__c secto = new AccountSectorization__c(
                    City__c = 'Paris',
                    Name = 'Inspecteur test',
                    PostalCode__c = '75001',
                    Inspector__c = oManager.Id
            );
            insert secto;
        }

        System.runAs(assist){
            //Create Personne Physique
            List<Account> listPersonAccounts = Account_TDF.createPersonAccounts(1);
            listPersonAccounts[0].PersonMailingCity = 'Paris';
            listPersonAccounts[0].PersonMailingPostalCode = '75001';
            listPersonAccounts[0].OwnerId = assist.Id;
            insert listPersonAccounts;
        }


        System.runAs(oManager){
            system.assertEquals(oManager.Id,[SELECT Id, OwnerId FROM Account].OwnerId);
        }
    }


    //XSMDPRO-1376    
    @isTest
    public static void testshareAccountstoVAD(){
        //Create Inspector
        User oManager = User_TDF.createUsers(1,Label.UserFonctionRegionDirector).get(0);
        oManager.Username = 'inspector@ag2rlamondiale.fr';
        update oManager;
        User VADmanager = User_TDF.createUsers(1,Label.UserFonctionVADManager).get(0);
        System.runAs(oManager){


            //Create Personne Physique
            List<Account> listPersonAccounts = Account_TDF.createPersonAccounts(1);
            listPersonAccounts[0].PersonMailingCity = 'Paris';
            listPersonAccounts[0].PersonMailingPostalCode = '75001';


            listPersonAccounts[0].Referee__c = null;
            insert listPersonAccounts;
        }
        
        Account acc = [Select Id,TechShareVAD__c
                       From Account];
        system.assertEquals(true, acc.TechShareVAD__c);
        
        System.runAs(oManager){
            acc.Referee__c = VADmanager.Id;
            update acc;
        }
        
        Account accUpdated = [Select Id,TechShareVAD__c
                              From Account];
        
        system.assertEquals(false, accUpdated.TechShareVAD__c);

    }
    //XSMDPRO-1509    
    @isTest
    public static void testbypassVRConfiage(){
        User user01 =  User_TDF.createUsers(1,Label.UserFonctionVADManager).get(0);
        user01.Username = 'user_test01@ag2rlamondiale.fr';
        user01.NetworkAssignment__c = 'VAD';
        update user01;
        
        // Insertion d'un utilisateur inspecteur afin d'effectuer les tests dans son contexte
        User user02 =  User_TDF.createUsers(1,Label.UserFonctionInspector).get(0);
        user02.Username = 'user_test02@ag2rlamondiale.fr';
        user02.NetworkAssignment__c = 'MDPro';
        update user02; 
        
        // Insertion d'un utilisateur inspecteur afin d'effectuer les tests dans son contexte
        User user03 =  User_TDF.createUsers(1,Label.UserFonctionInspector).get(0);
        user03.Username = 'user_test03@ag2rlamondiale.fr';
        user03.NetworkAssignment__c = 'MDPro';
        update user03; 
        
        System.runAs(user01){
            
            Test.startTest();
            List<Account> listAccounts = Account_TDF.createBusinessAccounts(10);
            for(Account acc : listAccounts){
                acc.Referee__c = user02.Id;
            }
            
            insert listAccounts;
            
            //Update Referee (Confiage)
            for(Account acc : listAccounts){
                acc.Referee__c = user03.Id;
            }
            
            update listAccounts;
                
            Test.stopTest();
        }
    }
    
    //XESO-410/XESO-412
    @isTest
    public static void testSetConsentEmailByMkgCloud(){
        List<Account> accounts = Account_TDF.createPersonAccounts(1);
        insert(accounts);
        Test.startTest();
        //Creating individual record to link with account
        Individual oIndividual = new Individual();
        oIndividual.Salutation = accounts[0].Salutation;
        oIndividual.FirstName = accounts[0].FirstName;
        oIndividual.LastName = accounts[0].LastName;
        oIndividual.Phone__c = accounts[0].PersonMobilePhone;
        oIndividual.Email__c = accounts[0].PersonEmail;
        oIndividual.BirthDate = accounts[0].PersonBirthdate;
        oIndividual.PostalCode__c = accounts[0].PersonMailingPostalCode;
        insert oIndividual;
        
        accounts[0].PersonIndividualId = oIndividual.Id;
        accounts[0].PersonHasOptedOutOfEmail = false;
        update accounts[0];
        String consentementTousGamme = 'GLB';
        String consentementTousAssureur = '0';
        // Create consent to update later
        ContactPointTypeConsent consentMC = new ContactPointTypeConsent();
        consentMC.PartyId = accounts[0].PersonIndividualId;
        consentMC.Name = 'Adresse e-mail - TOUS / GLOBAL - TOUS / GLOBAL';
        consentMC.Range__c = consentementTousGamme;
        consentMC.Insurer__c = consentementTousAssureur;
        consentMC.CaptureSource = System.Label.Marketing_Cloud;
        consentMC.CaptureDate = Datetime.now().addDays(-5);
        consentMC.EffectiveFrom = consentMC.CaptureDate;
        consentMC.ContactPointType = 'Email';
        consentMC.ConsentForPhoneCall__c = 'Yes';
        consentMC.PrivacyConsentStatus = 'OptIn';
        insert consentMC;

        User userMC = [SELECT Id FROM User WHERE FirstName =: Label.Marketing_Cloud_Connector AND LastName='CT'];
        System.runAs(userMC) {
            accounts[0].PersonHasOptedOutOfEmail = true;
            update accounts[0];
        }  
        Test.stopTest();
        
        Account a = [SELECT Id, PersonIndividualId, OptinEmail__pc, UpdateOptinEmailDate__pc FROM Account WHERE Id=:accounts[0].Id];
        System.assert(a.PersonIndividualId!=null);
        System.assertEquals(false, a.OptinEmail__pc);
        System.assertEquals(Date.today(), a.UpdateOptinEmailDate__pc);
        List<ContactPointTypeConsent> consentements = [SELECT Id, PartyId, Name, ConsentForPhoneCall__c, CaptureDate, CaptureSource, EffectiveTo, EffectiveFrom
                                                                  FROM ContactPointTypeConsent
                                                                  WHERE PartyId =:a.PersonIndividualId
                                                                  AND CaptureSource = 'Marketing Cloud'
                                                                  AND ContactPointType = 'Email'];
        System.assert(consentements.size()>0);
        System.assertEquals('No', consentements[0].ConsentForPhoneCall__c);
    }
	 
    //XET-670 - setLinkAccountHeadquatersAfterInser
    @isTest
    public static void testsetLinkAccountHeadquatersAfterInsert(){
         //Creation des données de test
		 List<Account> accs = Account_TDF.createBusinessAccounts(3);
        //Creation d'un PM siège Unique accs[0] 
         accs[0].headquarters__c = true ;
        // Creation de PM non siège de même siren que accs[0] 
         accs[1].SIRETnumber__c = '01234567890124';
        //Creation d'une PM non siège d'une autre siren
         accs[2].SIRETnumber__c = '01334567890124';
         accs[2].headquarters__c = false;
        //Cas de l'insertion
        Test.startTest();
        insert accs;
        Test.stopTest();
        //Cas 1 : Unique PM siège pour une PM secondaire
        Account a1 = [SELECT parentId FROM Account WHERE parentId !=null limit 1];
        System.assert(a1.parentId!=null,'la PM siège est bien rattachée à la PM secondaire');
        //Cas 2 : Deux PM sièges pour une PM secondaire
        Account a2 = [SELECT parentId FROM Account WHERE Id =:accs[2].Id];
        System.assert(a2.parentId==null,'Le parentId de la PM secondaire est null car deux PM sièges');
    }
     //XET-670 - setLinkAccountHeadquatersAfterUpdate
   @isTest
  public static void testsetLinkAccountHeadquatersAfterUpdate(){
       //Creation des données de test
		List<Account> accs = Account_TDF.createBusinessAccounts(5);
        // Creation accs[0] et accs[1] PM non sièges avec le siren 014345678
         accs[0].SIRETnumber__c = '01434567890124';
         accs[0].headquarters__c = false;
         accs[1].SIRETnumber__c = '01434567890125';
         accs[1].headquarters__c = false;
      	//Creation accs[3] PM siège et accs[4] PM secondaire avec le siren 015345678 
         accs[2].SIRETnumber__c = '01534567890124';
         accs[2].headquarters__c = true;
         accs[3].SIRETnumber__c = '01534567890125';
         accs[3].headquarters__c = false;
         accs[4].SIRETnumber__c = '01634567890125';
         accs[4].headquarters__c = true;
         insert accs;
         //Cas 1: PM secondaire à PM siège Unique 
         accs[1].headquarters__c = true;
        //Cas 2: PM sièges à PM secondaires de siren differente 
         accs[2].headquarters__c = false;
         accs[4].headquarters__c = false;
      	AccountTriggerHandler.mapSirenToListIdAccountSiege.clear();
        Test.startTest();
          Update  accs;
        Test.stopTest();
       //Cas 1 : Unique PM siège pour une PM secondaire
        Account a1 = [SELECT parentId FROM Account WHERE Id =: accs[0].Id];
        System.assert(a1.parentId!=null,'la PM siège est bien rattachée à la PM secondaire');
        //Cas 2 : Deux PM sièges pour une PM secondaire
        Account a2 = [SELECT Id,Name,parentId FROM Account WHERE Id =: accs[4].Id];
      	System.debug('a2 '+a2);
       System.assert(a2.parentId==null,'Le parentId de la PM secondaire est null car deux PM sièges');
  }  
}