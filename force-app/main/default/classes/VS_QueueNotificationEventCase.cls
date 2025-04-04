public with sharing class VS_QueueNotificationEventCase implements Queueable, Database.AllowsCallouts {
    List<Id> events;
    Boolean is24Notification = false;
    
    // Constructor that receives the list of event ids for process
    public VS_QueueNotificationEventCase(List<Id> eventsList) {
        this.events = eventsList;
    }
    // Constructor that receives the list of event ids for process
    public VS_QueueNotificationEventCase(List<Id> eventsList, Boolean is24Notification) {
        this.events = eventsList;
        this.is24Notification = is24Notification;
    }

    // Method executed when the class is enqueued  
    public void execute(QueueableContext context) {
        // Process each event in the list
        if(events.size() > 0) {
            
            processEvent(events[0]); 
            
            events.remove(0);
            if(events.size() > 0) {
                System.enqueueJob(new VS_QueueNotificationEventCase(events));
            }
        }
    }
    
    // Method to process each individual event
    public void processEvent(Id singleEventId) {
        //Query event info
        List<Event> singleEventList = [SELECT Id, Agendamiento_SLE__c, Especialidad_SLE__c, StartDateTime, Medico_tratante_SLE__c, Location, Email_SLE__c, Phone_SLE__c, Numero_de_Caso__c,
                                       CityCall__c, CityCall__r.Name
                                     FROM Event
                                     WHERE Id = :singleEventId];
        
        if(singleEventList.size() > 0){
            Event singleEvent = singleEventList[0];

            String schedulingType = singleEvent.Agendamiento_SLE__c == 'Cirugía' ? 'cirugía' : 'cita'; 

            /*
            String textBody = '';
            textBody += 'Colmena Seguros confirma ' + schedulingType + ' ' + singleEvent.Especialidad_SLE__c +' : ' + formatDateTime(singleEvent.StartDateTime) + ' con ';
            textBody += singleEvent.Medico_tratante_SLE__c + ', ' + singleEvent.CityCall__r.Name+ ', ';
            textBody += singleEvent.Location + ' NVD000001';
            */
            String textBody = getStringEmail(singleEvent);
            String emailString = getStringEmail(singleEvent);

            // Call method to send SMS
            Boolean wasTheSMSSent = sendSMS(singleEvent, textBody);
            
            // Send email for the event
            Boolean wasTheEmailSent = sendEmail(singleEvent, emailString);

            if(wasTheEmailSent || wasTheSMSSent){
                singleEvent.VS_Reminder_Appointment_Surgery__c = true;
                if(is24Notification){
                    singleEvent.VS_Reminder_Appointment_Surgery_24h__c = true;
                }
                update singleEvent;

                
                List<CaseComment> comments = new List<CaseComment>();
                if(wasTheSMSSent){
                    CaseComment newCaseComment = new CaseComment();
                    newCaseComment.ParentId = singleEvent.Numero_de_Caso__c;
                    newCaseComment.CommentBody = 'SMS enviado a +57' + singleEvent.Phone_SLE__c + ': ' + textBody;
                    newCaseComment.IsPublished = true;
                    comments.add(newCaseComment);
                }
                if(wasTheEmailSent){
                    CaseComment newCaseComment1 = new CaseComment();
                    newCaseComment1.ParentId = singleEvent.Numero_de_Caso__c;
                    newCaseComment1.CommentBody = 'Email enviado a ' + singleEvent.Email_SLE__c + ': ' + textBody;
                    newCaseComment1.IsPublished = true;
                    comments.add(newCaseComment1);
                }

                insert comments;
            }
            
        }else{
            System.debug('Error: Event Id "' + singleEventId + '" not found');
        }
        
    }

    // Method to send SMS for a given event
    public Boolean sendSMS(Event singleEvent, String textBody){
        try {
            VS_WSMCAuthTokenSMS clsToken = VS_WSMCAuthTokenSMS.callout('sms_send');

            if(clsToken.successful){
                String messageKey = singleEvent.Id + Datetime.now().format('-dd-MM-yyyy-HH-mm');
                //VS_WSMCCreateSMS sendSMS = VS_WSMCCreateSMS.callout(clsToken.access_token, '573145601769', textBody, messageKey);
                VS_WSMCCreateSMS sendSMS = VS_WSMCCreateSMS.callout(clsToken.access_token, '57' + singleEvent.Phone_SLE__c, textBody, messageKey);
                //system.debug('@@: ' + sendSMS.successful + ', ' + sendSMS.errorcode);
                return (sendSMS.successful && sendSMS.errorcode == 0);
            }else{
                System.debug('Send SMS Error. Token failed (' + clsToken.serviceResponse.getStatusCode() + ')');
            }
        }catch (Exception e) {
            System.debug('Unexpected error when consuming SMS sending services: ' + e.getMessage());
        }
        return false;
    }
    
    public Boolean sendEmail(Event singleEvent, String textBody) {
        Map<String, Object> variables = new Map<String, Object>();

        variables.put('BodyToSend', textBody);
        variables.put('SubjectToSend', singleEvent.Agendamiento_SLE__c + ' con ' + singleEvent.Medico_tratante_SLE__c);
        variables.put('EmailToSend', singleEvent.Email_SLE__c);
    
        Flow.Interview.VS_Notify_Appointment_or_Surgery myFlow = new Flow.Interview.VS_Notify_Appointment_or_Surgery(variables);
        try {
            myFlow.start();
            
            return true;
        } catch (Exception e) {
            return false;
        }
        
    }
    // Method to send email for a given event
    /*
    public Boolean sendEmailOld(Event singleEvent, String textBody) {
        List<Messaging.SingleEmailMessage> masterListMails = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                   
        //List<String> sendTo = new List<String>{'aovargas05@gmail.com'};
        List<String> sendTo = new List<String>{singleEvent.Email_SLE__c};
        email.setToAddresses(sendTo);
        
        email.setSenderDisplayName('Colmena');
        email.setSubject( singleEvent.Agendamiento_SLE__c + ' con ' + singleEvent.Medico_tratante_SLE__c); 
        email.setPlainTextBody( textBody);
        
        masterListMails.add(email);
        List<Messaging.SendEmailResult> resultados = Messaging.sendEmail(masterListMails);
            
        for (Messaging.SendEmailResult resultado : resultados) {
            if (resultado.isSuccess()) {
                System.debug('Success email: ' + resultado);
                return true;
            } else {
                System.debug('Error in "send email": ' + resultado.getErrors()[0].getMessage());
                return false;
            }
        }
        return null;
    }
	*/
    public static String formatDateTime(Datetime dt) {
        // Get the day, month, and year
        String   day = (dt.day() < 10)   ? '0' + String.valueOf(dt.day())   : String.valueOf(dt.day());
        String month = (dt.month() < 10) ? '0' + String.valueOf(dt.month()) : String.valueOf(dt.month());
        Integer year = dt.year();
        
        // Get the hour and minute
        Integer hour = dt.hour();
        Integer minute = dt.minute();
        
        // Convert the hour to 12-hour format and determine if it's "a.m." or "p.m."
        String period = (hour < 12) ? 'a.m.' : 'p.m.';
        if (hour == 0) {
            hour = 12;
        } else if (hour > 12) {
            hour -= 12;
        }
        
        // Build the formatted date and time string
        String formattedDateTime = day+ '/' + month + '/' + String.valueOf(year);
        formattedDateTime += ', ' + String.valueOf(hour) + ':' + String.valueOf(minute) + ' ' + period;
        
        return formattedDateTime;
    }

    private static String getStringEmail(Event singleEvent) {
        String schedulingType = singleEvent.Agendamiento_SLE__c == 'Cirugía' ? 'cirugía' : 'cita';
        String textBody = '';

        textBody += 'Colmena Seguros confirma asignación de ' + schedulingType + ':\n\n';
        textBody += 'Documento: ' + '123456789\n';
        textBody += 'Usuario: ' + 'Usuario 1\n';
        textBody += 'Prestador: ' + 'Prestador\n';
        textBody += 'Especialidad: ' + singleEvent.Especialidad_SLE__c + '\n';
        textBody += 'Ciudad: ' + singleEvent.CityCall__r.Name + '\n';
        textBody += 'Dirección: ' + singleEvent.Location + '\n';
        textBody += 'Teléfono: ' + '123456789\n';
        textBody += 'Fecha - Hora: ' + formatDateTime(singleEvent.StartDateTime) + '\n';
        textBody += 'Autorización de servicio (NVD): ' + 'Autorización\n\n';

        textBody += 'Recuerde presentar al momento de la consulta: orden médica, cedula original, historia clinica, reporte de imágenes diagnósticas placa y lectura, laboratorios, estar 20 minutos antes de la hora asignada.\n\n';
        
        textBody += 'IMPORTANTE: Este correo es informativo, favor no responder a esta dirección de correo, ya que no se encuentra habilitada para recepción de mensajes.\n';
        textBody += 'Notificaciones Linea Efectiva\n';
        textBody += 'Coordinación Linea Efectiva\n\n';

        textBody += 'Este mensaje y cualquier archivo adjunto son confidenciales, por lo que la información no puede ser utilizada por personas diferentes a su destinatario,ni está autorizada so divulgación. Si usted no es la persona a la cual está dirigido este mensaje, por favor notifique inmedatamente al remitente conrespuesta a este mensaje y en tal caso, por favor destruya todas las copias del mismo y los archivos adjuntos, Cualquier uso, divulgación, copia, distribación impresión o acto derivado del conocimiento total o parcial de este mensaje sin autorización de Colmena Seguros será sancionado de acuerdo con lasnormas legales vigentes. Al destinatario de este mensaje se le considera custodio de la información contenida y debe velar por su confidencialidadintegridas y privacidad. Las opiniones contenidas en este mensaje electrónico no relacionadas con la actividad de nutstra organización, no necesariamente representan la opinión de Colmena Seguros.';
        
        return textBody;
    }
}