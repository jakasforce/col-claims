/*****************************************************************************************************************************
* Apex Class Name	:	CS_WrapperSmartSupervision
* Version			:	1.0
* Created Date	    :	19/05/2022
* Function 		    : 	Clase que contiene las definiciones de las clases que serviran como envoltorio de las peticiones y 
                        respuestas de los servicios de la clase CS_SmartSupervision_WS
* Test Class		:	CS_SmartSupervision_Test
*----------------------------------------------------------------------------------------------------------------------------
*                                                MODIFICATION LOG
*----------------------------------------------------------------------------------------------------------------------------
* Developer		     	Date			   	Description
* ---------------------------------------------------------------------------------------------------------------------------
* Angel Cabezas 	 19/05/2022			Original Version
* Lidia Guerrero     19/05/2022         Cambios en métodos de Momento 1
*****************************************************************************************************************************/
public class CS_WrapperSmartSupervision {
	//?-----------------------------------------------------------------------------------------------//
	//?                                              GENERAL                                          //
	//?-----------------------------------------------------------------------------------------------//

	public class LoginRequestType {
		public String shortDescription;
		public String caseEntity;
		public Id caseId;
	}

	public class LoginResponseType {
		public String refresh;
		public String access;
	}

	//?-----------------------------------------------------------------------------------------------//
	//?                                            MOMENTO 1                                          //
	//?-----------------------------------------------------------------------------------------------//

	//* OBTENER QUEJAS

	public class GetComplainsRequestType {
		public String token;
		public String caseEntity;
	}

	public class GetComplainsResponseType {
		public Integer count;
		public Integer pages;
		public Integer current_page;
		public String next;
		public String previous;
		public List<GetComplainResponseType> results;
	}

	public class GetComplainResponseType {
		public integer tipo_entidad;
		public integer entidad_cod;
		public String fecha_creacion;
		public string codigo_queja;
		public String codigo_pais;
		public String departamento_cod;
		public String municipio_cod;
		public String nombres;
		public Integer tipo_id_CF;
		public String numero_id_CF;
		public String telefono;
		public String correo;
		public String direccion;
		public Integer tipo_persona;
		public Integer sexo;
		public Integer lgbtiq;
		public Integer canal_cod;
		public Integer condicion_especial;
		public Integer producto_cod;
		public String producto_nombre;
		public Integer macro_motivo_cod;
		public String texto_queja;
		public Boolean anexo_queja;
		public Integer tutela;
		public Integer ente_control;
		public Integer escalamiento_DCF;
		public Integer replica;
		public String argumento_replica;
		public Integer desistimiento_queja;
		public Integer queja_expres;
	}

	//* TRANSFERENCIA DE ARCHIVOS

	public class GetComplainFilesRequestType {
		public String token;
		public String caseCode;
		public String caseEntity;
		public Id caseId;
	}

	public class GetComplainFilesResponseType {
		public Integer count;
		public Integer pages;
		public Integer current_page;
		public String next;
		public String previous;
		public List<ComplainFileResponseType> results;
	}

	public class ComplainFileResponseType {
		public Integer id;
		public String file;
		public String type;
		public Integer state;
		public Integer reference;
		public String codigo_queja;
	}

	public class GetFileResponseType {
		public Blob blobFile;
	}

	public class GetFileRequestType {
		public String link;
		public Id caseId;
	}

	//* ACK

	public class ACKRequestType {
		public String token;
		public String caseEntity;
		public List<Id> caseIds;
		public List<String> caseCodes;
	}

	public class ACKResponseType {
		public String message;
		public List<String> pqrs_error;
	}

	//?-----------------------------------------------------------------------------------------------//
	//?                                            MOMENTO 2                                          //
	//?-----------------------------------------------------------------------------------------------//

	public class CreateComplainRequestType {
		public String token;
		public String caseEntity;
		public Id caseId;
		public ComplainRequestType complain;
	}

	public class ComplainRequestType {
		//* Campos obligatorios
		public String nombres;
		public Integer tipo_id_CF;
		public String numero_id_CF;
		public Integer tipo_persona;
		public String codigo_queja;
		public String codigo_pais;
		public Integer canal_cod;
		public Integer producto_cod;
		public Integer macro_motivo_cod;
		public Integer insta_recepcion;
		public Integer punto_recepcion;
		public Integer admision;
		public String texto_queja;
		//* Campos no obligatorios pero necesarios en ciertos contextos
		public String departamento_cod;
		public String municipio_cod;
		public String fecha_creacion;
		public Boolean anexo_queja;
		//* Campos opcionales
		public Integer ente_control;
	}

	public class CreateComplainResponseType {
		public Integer tipo_entidad;
		public Integer entidad_cod;
		public String codigo_queja;
		public String codigo_pais;
		public String departamento_cod;
		public String municipio_cod;
		public Integer canal_cod;
		public Integer producto_cod;
		public Integer macro_motivo_cod;
		public String fecha_creacion;
		public String nombres;
		public Integer tipo_id_CF;
		public String numero_id_CF;
		public Integer tipo_persona;
		public Integer insta_recepcion;
		public Integer punto_recepcion;
		public Integer admision;
		public String texto_queja;
		public Boolean anexo_queja;
		public Integer ente_control;
	}

	//?-----------------------------------------------------------------------------------------------//
	//?                                            MOMENTO 3                                          //
	//?-----------------------------------------------------------------------------------------------//

	public class UpdateComplainRequestType {
		public String token;
		public String caseEntity;
		public String caseCode;
		public Id caseId;
		public ComplainChangesRequestType complainChanges;
	}

	public class ComplainChangesRequestType {
		//* Campos obligatorios
		public Integer producto_cod;
		public Integer macro_motivo_cod;
		public Integer estado_cod;
		public Integer producto_digital;
		public Integer aceptacion_queja;
		public Integer rectificacion_queja;
		public Integer admision;
		public Boolean documentacion_rta_final;
		public Boolean anexo_queja;
		//* Campos opcionales
		public Integer sexo;
		public Integer lgbtiq;
		public Integer condicion_especial;
		public Integer canal_cod;
		public String fecha_actualizacion;
		public Integer a_favor_de;
		public Integer desistimiento_queja;
		public Integer prorroga_queja;
		public String fecha_cierre;
		public Integer tutela;
		public Integer ente_control;
		public Integer marcacion;
		public Integer queja_expres;
		public Integer replica;
		public String argumento_replica;
	}

	public class UpdateComplainResponseType {
		public string codigo_queja;
		public Integer sexo;
		public Integer lgbtiq;
		public Integer condicion_especial;
		public Integer canal_cod;
		public Integer producto_cod;
		public Integer macro_motivo_cod;
		public Integer estado_cod;
		public DateTime fecha_actualizacion;
		public Integer producto_digital;
		public Integer a_favor_de;
		public Integer aceptacion_queja;
		public Integer rectificacion_queja;
		public Integer desistimiento_queja;
		public Integer prorroga_queja;
		public Integer admision;
		public String documentacion_rta_final;
		public String anexo_queja;
		public DateTime fecha_cierre;
		public Integer tutela;
		public Integer ente_control;
		public Integer marcacion;
		public Integer queja_expres;
	}

	public class AddFileRequestType {
		public String token;
		public String caseEntity;
		public String caseCode;
		public Id caseId;
		public ContentVersion file;
	}

	public class AddFileResponseType {
		public Integer id;
		public String file;
		public String type;
		public Integer state;
	}
    
    //?-----------------------------------------------------------------------------------------------//
	//?                                            MOMENTO 4                                          //
	//?-----------------------------------------------------------------------------------------------//

	//* OBTENER USUARIOS ACTUALIZAR

	public class GetUsersRequestType {
		public String token;        
		public String caseEntity;
	}

	public class GetUsersResponseType {
		public Integer count;
		public Integer pages;
		public Integer current_page;
		public String next;
		public String previous;
		public List<GetUserResponseType> results;
	}

	public class GetUserResponseType {
		public String numero_id_CF;
		public String tipo_id_CF;
		public String nombre;
		public string apellido;
		public String fecha_nacimiento;
		public String correo;
		public String telefono;
		public String razon_social;
		public String direccion;
		public String departamento_cod;
		public String municipio_cod;
	}
    
    //* ACK

	public class ACKUserRequestType {
		public String token;
		public String caseEntity;
		public List<String> numero_id_CF;
	}

	public class ACKUserResponseType {
		public String message;
		public List<String> numero_id_CF_error;
	}

}