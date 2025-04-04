@IsTest
public class CalculateDateTest {
    @IsTest
    static void testCalculateDates() {
        // Start the test
        Test.startTest();
        List<CalculateDate.DateWrapper> result = CalculateDate.calculateDates();
        Test.stopTest();
        
        // Verify the results
        System.assertEquals(1, result.size(), 'Expected one DateWrapper object in the result.');
        
        CalculateDate.DateWrapper dateWrapper = result[0];
        
        // Fetch the metadata values to calculate the expected dates
        PreventionConfigurationDays__mdt config = [SELECT ReminderDay__c, UnconvertedDays__c FROM PreventionConfigurationDays__mdt LIMIT 1];
        
        Date expectedReminderDate = System.today().addDays((Integer)config.ReminderDay__c);
        Date expectedNotConvertedDate = System.today().addDays((Integer)config.UnconvertedDays__c);
        
        System.assertEquals(expectedReminderDate, dateWrapper.reminderDate, 'Reminder date does not match expected value.');
        System.assertEquals(expectedNotConvertedDate, dateWrapper.notConvertedDate, 'Not Converted date does not match expected value.');
    }
}