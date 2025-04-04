/*****************************************************************************************************************************
 * Apex Class Name  :   CreateCaseBCS
 * Version          :   1.0
 * Created Date     :   18/06/2024
 * Created By       :   VASS COMPANY
 * Function         :   Clase con el servicio para crear un caso de StarServices. (Este servicio lo consume Mulesoft y crea los casos que obtiene de StarServices)
 * Test Class       :   CreateCaseBCSTest
 *----------------------------------------------------------------------------------------------------------------------------
 *                     MODIFICATION LOG
 *----------------------------------------------------------------------------------------------------------------------------
 * Developer                Date                Description
 * ---------------------------------------------------------------------------------------------------------------------------
 * Fernando Torres        18/06/2024         Original Version
 *****************************************************************************************************************************/


@RestResource(urlMapping='/CreateCaseBCS/*')
global with sharing class CreateCaseBCS {
    
    //***************************************************************************************************************************//
    //-------------------------------------------Metodo principal para crear el Caso---------------------------------------------//
    @httpPost
    global static void doGPost() {
        RestResponse response = RestContext.response;
        System.debug('@@@1');
        RestRequest requestContext = RestContext.request;
        String IdCasoLog = '';
        try{
            Blob body = requestContext.requestBody;
            String requestBody = body.toString();
            Boolean esReplica = False;
            Case casoPadre;
            // Deserializar el JSON
            Wrapper wrapper = (Wrapper) JSON.deserialize(requestBody, Wrapper.class);
            System.debug('@@@--'+wrapper);
            
            System.debug('@@@123');
            // Validar estado
            System.debug('@@@----yy'+wrapper.caso.Estado);
            if (wrapper.caso.Estado != '3') {
                response.statusCode = 400;
                response.responseBody = Blob.valueOf('{"error": "El estado debe ser 3"}');
                System.debug('@@@2222');
                return;
            }
            System.debug('@@@2-1');
            // Validar enlace si el tipo enalce es 01 o 04 es una replica 
            if (wrapper.caso.Enlace != null && (wrapper.caso.TipoEnlace == '01' || wrapper.caso.TipoEnlace == '04')) {
                System.debug('@@@2 replica');
                esReplica = True;
                casoPadre = buscarCasoPadre(wrapper.caso.Enlace);
            }
            System.debug('@@@2-2');
            // Buscar o crear cuenta
            Account cuenta = buscarCuenta(wrapper.cuenta);
            // crear el contacto
            System.debug('@@@2-3');
            crearContacto(cuenta,wrapper.cuenta.NombreContacto,wrapper.cuenta.TipoIdentificacionContacto,wrapper.cuenta.NumeroIdentificacionContacto,wrapper.cuenta.CorreoElectronicoContacto);
            System.debug('@@@2-4');
            ConfiguracionStartService__mdt metadatoCaso = ConfiguracionStartService__mdt.getInstance('TipoRegistroCaso');
            Id recordTypeIdCaso = Schema.SObjectType.Case.getRecordTypeInfosByName().get(metadatoCaso.value__c).getRecordTypeId();
            
            System.debug('@@@3');
            ConfiguracionStartService__mdt metadatoEtapaInicial = ConfiguracionStartService__mdt.getInstance('EstapaInicialCaso');
            ConfiguracionStartService__mdt metadatoEtapaReplica = ConfiguracionStartService__mdt.getInstance('EstapaReplica');
            ConfiguracionStartService__mdt metadatoEntidad = ConfiguracionStartService__mdt.getInstance('EntidadDefecto');
            // Crear caso nuevo
            Case nuevoCaso = new Case(
                //CaseType__c = wrapper.caso.Motivo.startsWith('P2') ? 'Solicitud' : 'Reclamo',
                ParentId = casoPadre != null ? casoPadre.Id : null,
                Status = esReplica? metadatoEtapaReplica.value__c : metadatoEtapaInicial.value__c,
                CS_Replica__c = wrapper.caso.Replica,
                CS_ArgumentoReplica__c = wrapper.caso.ArgumentoReplica,
                AccountId = cuenta!= null?cuenta.id : null,
                Subject = wrapper.caso.Asunto,
                CS_Subtipo__c = metadatoEntidad.Value__c,
                Description = wrapper.caso.Descripcion,
                CS_Fecha_de_radicacion_en_la_Compania__c = wrapper.caso.FechaRadicacionEnLaCompania,
                enteReceptionDate__c = wrapper.caso.FechaRecepcionEnte,
                CS_FechaTentativaDeCierre__c = wrapper.caso.FechaTentativaCierre,
                Origin = wrapper.caso.PuntoDeRecepcion,
                CS_Canal__c = wrapper.caso.Canal,
                CS_Pais__c = wrapper.caso.PaisDeIncidencia,
                CS_Departamento__c = wrapper.caso.DepartamentoDeIncidencia,
                //CS_Municipio__c = wrapper.caso.MunicipioDeIncidencia,
                CS_CodigoQueja__c = wrapper.caso.CodigoQueja,
                CS_MacroMotivo__c = wrapper.caso.Motivo,
                CS_Submotivo__c = wrapper.caso.Submotivo,
                CS_QuejaExpres__c = wrapper.caso.QuejaExpres,
                RecordTypeId = recordTypeIdCaso
            );
            System.debug('@@@4');
            insert nuevoCaso;
            IdCasoLog = nuevoCaso.Id;
            System.debug('@@@5');
            // Crear documentos
            if (wrapper.listAttachments != null && !wrapper.listAttachments.isEmpty()) {
                for (Attachment attachment : wrapper.listAttachments) {
                    CS_DocumentoCaso__c documento = new CS_DocumentoCaso__c(
                        Name = attachment.fileName,
                        FileExtension__c = attachment.extensionFile,
                        //FileCode__c = attachment.idActivity,
                        CS_Caso__c = nuevoCaso.Id
                    );
                    insert documento;
                }
            } else {
                System.debug('No hay documentos');
            }
            System.debug('@@@6');
            response.statusCode = 200;
            response.responseBody = Blob.valueOf('{"message": "Caso creado exitosamente"}');
            return;
        }catch(Exception e){
            System.debug('@Exception '+e);
            response.statusCode = 400;
            response.responseBody = Blob.valueOf('{"error": "'+e+'"}');
            System.debug('@@@2222');
            if(IdCasoLog != ''){
                CS_Log_Helper.createLogSFInternalError('Integracion StarServices crear Caso (FALLIDO)','CreateCaseBCS.doGPost',e , IdCasoLog);
            }else{
                CS_Log_Helper.createLogSFInternalError('Integracion StarServices crear Caso (FALLIDO)', 'CreateCaseBCS.doGPost', e);
            }
            return;
        }
    }

    
    //**********************************************************************************************************************//
    //----------------------------------------Metodo que busca el caos padre de las replicas--------------------------------//
    private static Case buscarCasoPadre(String codigoDeQueja){
        Case casoPadre;
        for(Case caso: [SELECT id from Case WHERE CS_CodigoQueja__c =: codigoDeQueja LIMIT 1]){
            casoPadre = caso;
            return casoPadre;
        }

        return casoPadre;

    }
    
    //**********************************************************************************************************************//
    //-------------------------------Metodo para crear contacto con la informcaion entregada--------------------------------//
    
    private static void crearContacto(Account cuenta,String nombre,String tipo, String numero, String correo){
        Try{
            if(!String.isEmpty(cuenta.Id)  &&  !String.isEmpty(nombre) &&  !String.isEmpty(tipo) &&  !String.isEmpty(numero)  &&  !String.isEmpty(correo)){
                String[] partes = nombre.split(' ');
                String n1, n2, a1, a2;
                
                switch on partes.size() {
                    when 1 {
                        n1 = partes[0];
                        a1 = partes[0];
                    }   
                    when 2 {
                        n1 = partes[0];
                        a1 = partes[1];
                    }
                    when 3 {
                        n1 = partes[0];
                        a1 = partes[1];
                        a2 = partes[2];
                    }
                    when 4 {
                        n1 = partes[0];
                        n2 = partes[1];
                        a1 = partes[2];
                        a2 = partes[3];
                    }
                }
                
                Contact contactoNuevo = new Contact(FirstName = n1,
                                                    LastName = a1,
                                                    MiddleName = n2,
                                                    Suffix = a2,
                                                    Email = correo,
                                                    CS_TipoIdentificacionCP__c = tipo,
                                                    CS_NumeroIdentificacionCP__c = numero,
                                                    AccountId = cuenta.Id);
                insert contactoNuevo;
                System.debug('contacto creado con exito');
                }
        }catch(Exception e){
            System.debug('error al crear contacto'+e);
        }
        }
    

    //**********************************************************************************************************************//
    //-------------------------Metodo que busca si existe una cuenta de lo contrario la crea--------------------------------//
    
    private static Account buscarCuenta(Cuenta cuenta) {

        Account cuentaCreada;
        Schema.Location ciudadEncontrada = buscarLocation(cuenta.Ciudad);

        if(!String.isEmpty(cuenta.TipoIdentificacionJuridica)  &&  !String.isEmpty(cuenta.NumeroIdentificacionJuridica)){

            for(Account accountJuridica : [SELECT Id FROM Account WHERE CS_TipoIdentificacion__c = : cuenta.TipoIdentificacionJuridica AND CS_NumeroIdentificacion__c = : cuenta.NumeroIdentificacionJuridica LIMIT 1]){
                return accountJuridica;
            }
            ConfiguracionStartService__mdt metadatoJuridica = ConfiguracionStartService__mdt.getInstance('TipoRegistroCuentaJuridica');
            Id recordTypeIdJuridica = Schema.SObjectType.Account.getRecordTypeInfosByName().get(metadatoJuridica.value__c).getRecordTypeId();
            cuentaCreada = new Account(
                
                    Name = cuenta.NombreDeLaCuenta,
                    CS_TipoIdentificacion__c = cuenta.TipoIdentificacionJuridica,
                    CS_NumeroIdentificacion__c = cuenta.NumeroIdentificacionJuridica,
                    Phone = cuenta.Telefono,
                    CC_Ciudad__c = ciudadEncontrada != null? ciudadEncontrada.Id : null,
                    RecordTypeId = recordTypeIdJuridica
                );
            insert cuentaCreada;
            return cuentaCreada;

        } else{
            for(Account accountNatural : [SELECT Id FROM Account WHERE CS_TipoIdentificacionCP__pc = : cuenta.TipoIdentificacionNatural AND CS_NumeroIdentificacionCP__pc = : cuenta.NumeroIdentificacionNatural LIMIT 1]){
                return accountNatural;
            }
            ConfiguracionStartService__mdt metadatoPersonal = ConfiguracionStartService__mdt.getInstance('TipoRegistroCuentaPersonal');
            Id recordTypeIdPersonal = Schema.SObjectType.Account.getRecordTypeInfosByName().get(metadatoPersonal.value__c).getRecordTypeId();
            cuentaCreada = new Account(
                    FirstName = cuenta.PrimerNombre,
                    LastName = cuenta.PrimerApellido,
                    MiddleName = cuenta.SegundoNombre,
                    Suffix = cuenta.SegundoApellido,
                    PersonEmail = cuenta.CorreoElectronico,
                    CS_TipoIdentificacionCP__pc = cuenta.TipoIdentificacionNatural,
                    CS_NumeroIdentificacionCP__pc = cuenta.NumeroIdentificacionNatural,
                    Phone = cuenta.Telefono,
                    CS_Sexo__pc = cuenta.Sexo,
                    CC_Ciudad__c = ciudadEncontrada != null? ciudadEncontrada.Id : null,
                    RecordTypeId = recordTypeIdPersonal
                );
            insert cuentaCreada;
            return cuentaCreada;
        }
    }

    
    private static Schema.Location buscarLocation(String codigoCiudad){
        Schema.Location ciudadCuenta; // Inicializa la variable para evitar posibles errores de null pointer
        for(Schema.Location ciudadd: [SELECT id from Location WHERE Codigo_Ciudad__c =: codigoCiudad LIMIT 1]){
            ciudadCuenta = ciudadd;
            return ciudadCuenta;
        }

        return ciudadCuenta;
    }
    
    public class Wrapper {

        public Cuenta cuenta;
        public Caso caso;
        public List<Attachment> listAttachments;

    }

    public class Cuenta {
        
        public String NumeroIdentificacionContacto;
        public String TipoIdentificacionContacto;
        public String NombreContacto;
        public String CorreoElectronicoContacto;
        public String TipoIdentificacionNatural;
        public String NumeroIdentificacionNatural;
        public String TipoIdentificacionJuridica;
        public String NumeroIdentificacionJuridica;
        public String PrimerNombre;
        public String PrimerApellido;
        public String SegundoNombre;
        public String SegundoApellido;
        public String NombreDeLaCuenta;
        public String CorreoElectronico;
        public String Sexo;
        public String Ciudad;
        public String Telefono;

    }

    public class Caso {

        public String CodigoQueja;
        public Date FechaRadicacionEnLaCompania;
        public Date FechaRecepcionEnte;
        public Date FechaTentativaCierre;
        public String Descripcion;
        public String Asunto;
        public String Estado;
        public String PuntoDeRecepcion;
        public String Canal;
        public String PaisDeIncidencia;
        public String DepartamentoDeIncidencia;
        public String MunicipioDeIncidencia;
        public String Motivo;
        public String Submotivo;
        public String QuejaExpres;
        public String Enlace;
        public String TipoEnlace;
        public Boolean Replica;
        public String ArgumentoReplica;
        

    }

    public class Attachment {

        public String comments;
        public String extensionFile;
        public String fileName;
        public String pathSourceFile;
        public String sourceFileType;
        public String confirmationCode;
        public String idActivity;

    }

}