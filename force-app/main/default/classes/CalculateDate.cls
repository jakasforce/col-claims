/**
 * Clase Apex que contiene métodos para calcular fechas de recordatorio y fechas no convertidas.
 * Se puede acceder a estos métodos desde un flujo en Salesforce.
 */
public with sharing class CalculateDate {
    
    /**
     * Método para calcular la fecha de recordatorio y la fecha de "Fecha No Convertido" sumando un número de días a la fecha actual.
     * Se puede invocar desde un flujo.
     * @return Lista de fechas de recordatorio y "Fecha No Convertido" calculadas.
     */
    @InvocableMethod(label='Calcular Fechas' description='Calcula la fecha recordatorio y Fecha No Convertido sumando un número de días a la fecha actual')
    public static List<DateWrapper> calculateDates() {
        List<DateWrapper> result = new List<DateWrapper>();
        
        Decimal reminderDaysFromMetadata = [SELECT ReminderDay__c FROM PreventionConfigurationDays__mdt LIMIT 1].ReminderDay__c;
        Integer reminderNumberDays = (Integer) reminderDaysFromMetadata;
        Date currentDate = System.today();
        Date reminderDate = currentDate.addDays(reminderNumberDays);
        
        Decimal notConvertedDaysFromMetadata = [SELECT UnconvertedDays__c FROM PreventionConfigurationDays__mdt LIMIT 1].UnconvertedDays__c;
        Integer notConvertedNumberDays = (Integer) notConvertedDaysFromMetadata;
        Date notConvertedDate = currentDate.addDays(notConvertedNumberDays);
        
        result.add(new DateWrapper(reminderDate, notConvertedDate));
        
        return result;
    }
    
    /**
     * Clase auxiliar para envolver las fechas calculadas.
     */
    public class DateWrapper {
        @InvocableVariable(label='Fecha Recordatorio' description='Fecha calculada para el recordatorio')
        public Date reminderDate;
        @InvocableVariable(label='Fecha No Convertido' description='Fecha calculada para No Convertido')
        public Date notConvertedDate;
        
        public DateWrapper(Date reminderDate, Date notConvertedDate) {
            this.reminderDate = reminderDate;
            this.notConvertedDate = notConvertedDate;
        }
    }
}