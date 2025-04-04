/********************************************************************
Apex Class Name :   XFLS_WrapperSendaGCP
Version         :   1.0
Created Date    :   05/05/2022
Function        :   Wrappers para integraciones Senda

Modification Log
*--------------------------------------------------------------------
* Developer             Date                Description
* -------------------------------------------------------------------
* Sayra Martinez     06/05/2022         Original Version
* Jose Quevedo       09/06/2022         Reorganización y cambio de variables
*********************************************************************/
public class XFLS_WrapperSendaGCP {
    public class responseLogin{
        
        public String access_token;
        public String token_type;
        public Integer expires_in;
    }
    /*INICIO INTEGRACIÓN 1*/
    public class wrapperActividad{
        public Actividad activity;
        public ActividadTecnica technicalActivity;
        public Dis dis;
        public Compania company;
        public Producto productLine;
        public Grupo groupx;
        public Consultor consultor;// (Nombre y teléfono)
    }
    public class Actividad{
        public String activityCode;
        public String activityTypeCode;
        public String  activityType;
        public String orderServiceCode;
        public String statusCode;
        public String status;
        public String duration;
        public String timex;
        public String scheduleCode;
        public Datetime startDate;
        public Datetime endDate;
        public String madeBy;
        public String madeSite;
        public String quantity;//float
        public String cityCode;
        public Boolean isMain;
        public String isCovidContingency;
        public String totalAttendance;
        public String contactExecuter;
        public String supports; //bit
        public String adminRequirements;
        public String objetives;
        public String observations;
        public Provedor Provider; 
    }
    public class Provedor{
        public String providerFee;//float
        public String providerComments;
    }
    public class ActividadTecnica{
        public String technicalActivityCode;
        public String activityCodeSap;
        public String technicalActivity;
    }
    public class Dis{
        public String disCode;
        public String disName;
        public String personResponsible;
    }
    public class Compania{
        public String companyCode;
        public String contractNumber; //float
        public String companyName;
    }
    public class Producto{
        public Integer lineCode;
        public String lineName;
    }
    public class Grupo{
        public String groupCode;
        public String groupDescription;
        public SubGrupo subgroup;
    }
    public class SubGrupo{
        public String subgroupCode;
        public String subgroupDescription;
    }
    
    public class Consultor{
        public String Cedula;
    }
    public class responseCrearActividad{
        public String message;
        public Integer status;
    }
    /*FIN INTEGRACIÓN 1*/
    
    /*INICIO INTEGRACIÓN 2*/
    public class WrapperOrdendeServico{
        public String orderServiceCode;
        public String statusCodeOS;
        public String statusOS;
        public Datetime publicationOSDate;
        public Datetime approvalOSDate;
        public String providerComments;
        public String madeSite;
        public String duration;
        public String timex;
        public String contactExecuter;
        public String supports;
        public String adminRequirements;
        public String consultorId;
        public String objectives;
    }
    public class responseOrdenDeServico{
        public Decimal id;
        public String message;
    }
    /*FIN INTEGRACIÓN 2*/

    /*INICIO INTEGRACION 3*/
    public class WrapperSesionesdeTrabajo{
        public ActividadSesionDeTrabajo activity;
        public Entrega delivery;
    }
    public class ActividadSesionDeTrabajo{
        public String activityCode;
        public String codeOS;
        public String authorizationCode;
        public Datetime fillingDate;
        public Datetime authorizationDate;
        public String authorizedQuantity;
        public String statusCodeAuthorization;
        public String statusAuthorization;
        public String observationsActivity; 
    }
    public class Entrega{
        public Datetime startExecutionDate;
        public Datetime finalExecutionDate;
        public String nonconformingProduct;
        public String processedInterface;
        public Datetime processedInterfaceDate;
        public String interfaceCode;
        public String costingRate;
        public String authorizedProviderFee;
        public String totalAttendance;
        public String printingBatchCode;
        public Datetime providerStartExecutionDate;
        public Datetime providerFinalExecutionDate;
        public String providerExecutionObservations;
        public String authorizerUserCode;
        public String authorizerName;
    }
    public class responseSesionesDeTrabajo{
        public Decimal id;
        public String message;
    }
    
    public class resultado{
        public String id;
        public String message;
        public Integer status;
    }
    /*FIN INTEGRACIÓN 3*/
    
    /*INICIO INTEGRACION 4*/
    public class WrapperSesionesDeTrabajoAprobadas{
        public String  activityCode;
        public String codeOS;//numeric
        public Soporte support;
        public EntregaSesionesDeTrabajoAprobadas delivery;   
    }
    public class Soporte{
        public String codeSupportFile;
        public String codeSupport;
        public String codeStatusSupport;
        public String statusSupport;
        public Datetime recordSupportDate;
        public String codeSupport1;
        public String authorizationCode; //numeric
    }
    public class EntregaSesionesDeTrabajoAprobadas{
        public String deliverableName;
        public String fromx;
        public String  To;
        public String deliveryStatus;//bit
        public Datetime deliveryDate;
    }
    public class responseSesionesDeTrabajoAprobadas{
        public String message;
        public Integer status;
    }
    /*FIN INTEGRACIÓN 4*/

    /*INICIO INTEGRACION 5*/
    public class WrapperSoporteDeSesiones{
        public String supportId;
        public String authorizationCode;
        public String registrationDate;
        public String supportRoute;
    } 
    public class responseSoporteDeSesiones{
        public String id;
        public String message;
    }  
    public class responseServicioWorkOrder{
        public String actividadId;
        public String ordenDeServicioId;
        public String sesionDeTrabajoId;
        public String mensaje;
    }  
    /*FIN INTEGRACIÓN 5*/
}