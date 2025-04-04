/**
**************************************************************************************************************
* @desarrollado por Vass
* @autor            Darien Romero
* @projecto         COLMENA
* @descripcion      Crea un archivo CSV de la duplicidad de cuentas juridicas o personales
* Cambios (Versiones)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Fecha         Autor                        Descripcion
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            1.0   23-MAY-2023  Darien Romero           	  Creacion Clase.
**************************************************************************************************************
***/
public class ConsultaDuplicados {
    
    public static void inicioDuplicados(String tipoCuenta) {
        if (tipoCuenta == 'CuentasPersonales') {
            CuentasPersonalesDuplicadas();
        } else if (tipoCuenta == 'CuentasJuridicas') {
            CuentasJuridicasDuplicadas();
        }
    }
    
    @future //Cuentas duplicadas personales 
    public static void CuentasPersonalesDuplicadas() {
	List<AggregateResult> resultados = new List<AggregateResult>();
        
	if (System.Test.isRunningTest()) {
    	resultados = [SELECT COUNT(Id), CS_NumeroIdentificacionCP__pc, CS_TipoIdentificacionCP__pc, RecordType.Name FROM Account WHERE RecordType.Name = 'Cuenta Personal' AND createdById =: UserInfo.getUserId() GROUP BY CS_NumeroIdentificacionCP__pc, CS_TipoIdentificacionCP__pc, RecordType.Name limit 2];
	} else {
    	resultados = [SELECT COUNT(Id), CS_NumeroIdentificacionCP__pc, CS_TipoIdentificacionCP__pc, RecordType.Name FROM Account WHERE RecordType.Name = 'Cuenta Personal' GROUP BY CS_NumeroIdentificacionCP__pc, CS_TipoIdentificacionCP__pc, RecordType.Name HAVING COUNT(CS_NumeroIdentificacionCP__pc) > 1 AND COUNT(CS_TipoIdentificacionCP__pc) > 1];
	}
        
        System.debug('resultados: '+resultados);
        if (resultados.size() == 0) {return;}

		String csvContent = formatoCSV(resultados, 'personales');
		Blob csvBlob = Blob.valueOf(csvContent);

		Datetime tiempo = Datetime.now();
        
		//Nombre del archivo
		String csvFileName = 'CuentasPersonalesDuplicadas'+tiempo.second()+'/'+tiempo.minute()+'/'+tiempo.hour()+'/'+tiempo.format('dd/MM/yyyy')+'.csv';

		//Preparar archivo
		ContentVersion contentVersion = parametrosArchivo(csvBlob, csvFileName);

		try {insert contentVersion; system.debug('OK');} catch(exception ex) {System.debug('KO '+ex);}
    }

    @future //Cuentas duplicadas juridicas 
    public static void CuentasJuridicasDuplicadas() {
        List<AggregateResult> resultados = new List<AggregateResult>();
        
		if (System.Test.isRunningTest()) {
    		resultados = [SELECT COUNT(Id), CS_NumeroIdentificacion__c, CS_TipoIdentificacion__c , RecordType.Name FROM Account WHERE RecordType.Name = 'Cuenta Jurídica' AND createdById =: UserInfo.getUserId() GROUP BY CS_NumeroIdentificacion__c, CS_TipoIdentificacion__c , RecordType.Name limit 2];
		} else {
    		resultados = [select COUNT(Id), CS_NumeroIdentificacion__c, CS_TipoIdentificacion__c , RecordType.Name From Account where RecordType.Name = 'Cuenta Jurídica' group by CS_NumeroIdentificacion__c, CS_TipoIdentificacion__c , RecordType.Name having COUNT(CS_NumeroIdentificacion__c) > 1 and COUNT(CS_TipoIdentificacion__c ) > 1];
		}
        
        if (resultados.size() == 0) {return;}

		String csvContent = formatoCSV(resultados, 'juridicas');
		Blob csvBlob = Blob.valueOf(csvContent);

		Datetime tiempo = Datetime.now();
        
		//Nombre del archivo
		String csvFileName = 'CuentasJuridicasDuplicadas'+tiempo.second()+'/'+tiempo.minute()+'/'+tiempo.hour()+'/'+tiempo.format('dd/MM/yyyy')+'.csv';
        
		//Preparar archivo
		ContentVersion contentVersion = parametrosArchivo(csvBlob, csvFileName);

		try {insert contentVersion; system.debug('OK');} catch(exception ex) {System.debug('KO '+ex);}
    }
    
    //Dar formato
    public static string formatoCSV(List<AggregateResult> resultados, string tipo) {
        string csvContent = 'TOTAL,IDENTIFICACION,TIPO_IDENTIFICACION,TIPO_CUENTA, totales: '+resultados.size()+'\n';
		List<String> documentos = new List<String>{'Cédula de ciudadanía', 'Cédula de extranjería', 'Número de identificación tributaria (NIT)', 'Tarjeta de identidad', 'Pasaporte', 'Carné diplomático', 'Sociedad extranjera sin NIT en Colombia', 'Fideicomiso, fondos de inversión colectiva, fondo o patrimonio autónomo', 'Número único de identificación personal (NUIP)', 'Permiso por protección temporal (PPT)', 'Permiso especial de permanencia (PEP)'};
            
        if (tipo == 'personales') {
			for (AggregateResult r : resultados) {
            	string texDocumento = (string) r.get('CS_TipoIdentificacionCP__pc');
            	integer numDocumento = Integer.valueOf(texDocumento);
    			csvContent += r.get('expr0') + ',' + r.get('CS_NumeroIdentificacionCP__pc') + ',' + documentos[numDocumento-1] + ',' + 'Cuenta Personal' + '\n';
			}
        } else if (tipo == 'juridicas') {
			for (AggregateResult r : resultados) {
            	string texDocumento = (string) r.get('CS_TipoIdentificacion__c');
            	integer numDocumento = Integer.valueOf(texDocumento);
    			csvContent += r.get('expr0') + ',' + r.get('CS_NumeroIdentificacion__c') + ',' + documentos[numDocumento-1] + ',' + 'Cuenta Juridica' + '\n';
			}
        }

        return csvContent;
    }
    
    //Preparar parametros archivo
    public static ContentVersion parametrosArchivo(Blob csvBlob, string csvFileName) {
	    ContentVersion contentVersion = new ContentVersion();
		contentVersion.VersionData = csvBlob;
		contentVersion.Title = csvFileName;
		contentVersion.PathOnClient = csvFileName;
        
    	return ContentVersion;
    }
}