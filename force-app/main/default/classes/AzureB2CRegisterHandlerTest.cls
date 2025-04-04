/**
 * @description       : 
 * @author            : diego.jacanamijoy@oc.vasscompany.com
 * @group             : 
 * @last modified on  : 02-26-2025
 * @last modified by  : diego.jacanamijoy@oc.vasscompany.com
**/
@IsTest
public with sharing class AzureB2CRegisterHandlerTest {

    @TestSetup
    static void makeData(){
        
        //Create user with standat profile
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' OR Name = 'Usuario estándar' LIMIT 1];
        //create user
        User u = new User();
        u.username = 'tjones@example.com';
        u.email = 'tjones@example.com';
        u.lastName = 'Thomas';
        u.firstName = 'Jones-Drew';
        String alias = u.firstName + u.lastName;
        
        //Alias must be 8 characters or less
        if(alias.length() > 8) {
            alias = alias.substring(0, 8);
        }
        u.alias = alias;
        u.languagelocalekey = UserInfo.getLanguage();
        u.localesidkey = UserInfo.getLocale();
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'America/Bogota';
        u.ProfileId = profile.Id; 
        
        insert u;
    }
    
    @Istest
    static void testCanCreateUser() {
        AzureB2CRegisterHandler handler = new AzureB2CRegisterHandler();
        Auth.UserData data = createUser('test@example.com','John','Adams');
        
        System.Assert(handler.canCreateUser(data),'Handler should be able to create this user');
    }
     
    @IsTest
    static void testCanCreateUserNegative() {
        AzureB2CRegisterHandler handler = new AzureB2CRegisterHandler();
        Auth.UserData data = createUser(null,'Thomas','Jones-Drew');
        
        System.Assert(!handler.canCreateUser(data),'Handler should not be able to create user with missing email');
    }
    
    @IsTest
    static void testCreateInternalUser() {
        AzureB2CRegisterHandler handler = new AzureB2CRegisterHandler();
        
        Auth.UserData data = createUser('tjones@example.com','Thomas','Jones-Drew');
        
        Test.startTest();
            User theUser = handler.createUser(null, data);
        Test.stopTest();
        
        validate(theUser,data); 
    }
    
    @IsTest
    static void testCreateInternalUserNegative() {
        AzureB2CRegisterHandler handler = new AzureB2CRegisterHandler();
        
        Auth.UserData data = createUser(null,'Thomas','Jones-Drew');
                
        Test.startTest();
        User theUser = handler.createUser(null, data);
        Test.stopTest();
        
        System.Assert(theUser==null,'User should be null for negative case');
    }
    
    @IsTest
    static void testUpdateUser() {
        AzureB2CRegisterHandler handler = new AzureB2CRegisterHandler();
        
        Auth.UserData data = createUser('tjones@example.com','Thomas','Jones-Drew');
        
        User theUser = handler.createUser(null, data);
        //insert theUser;
        
        Test.startTest();
        
        validate(theUser,data);
        
        data.firstName='Tom';
        handler.updateUser(theUser.id, null, data);
        
        User theUpdatedUser = [SELECT Id,firstName,Email,LastName 
                                 from User 
                                Where Id = :theUser.id];
        
        validate(theUpdatedUser,data);
        
        Test.stopTest();

    }
    
    /**
     * Helper method to Validate the the User we've created
     * 
     * @param theUser - the User that we created
     * @param data - the original AuthData supplied by FaceBook
     **/ 
    private static void validate(User theUser, Auth.UserData data) {
        System.Assert(theUser!=null,'User must not be null');
        System.AssertEquals(theUser.email,data.email,'Email address must be the same');
        System.AssertEquals(theUser.FirstName,data.FirstName,'First name must match');
        System.AssertEquals(theUser.LastName,data.LastName,'Last name must match');
    }

    
    /**
     * Helper method to instantiate the handler UserData
     * 
     * @param email
     * @param lastName
     * @param firstName
     * @return Auth.UserData that looks like what we expect from FaceBook
     **/ 
    private static Auth.UserData createUser(String email,String lastName, String firstName) {
         Map<String, String> attributeMap = new Map<String,String>();
         String identifier = lastName+System.currentTimeMillis();
         String locale = 'en_US';
         return new Auth.UserData( identifier,
               firstName,
               lastName,
              '', // fullname
               email,
               '', // link
               '', // userName
               locale,
               '', // provider
               '', // siteLoginUrl
               attributeMap);       
    }
}