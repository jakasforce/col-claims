/********************************************************************
Apex Class Name	:	XFLS_WrapperSendaGCP2
Version			:	1.0
Created Date	:	05/05/2022
Function 		: 	Wrappers para integraciones Senda

Modification Log
*--------------------------------------------------------------------
* Developer		     	Date			   	Description
* -------------------------------------------------------------------
* Jose Quevedo       18/05/2022         Original Version
* Jose Quevedo       09/06/2022			Reorganización y cambio de variables
*********************************************************************/
global class XFLS_WrapperSendaGCP2 {
	/*INICIO INTEGRACION 6*/
    public class WrapperRadicarSesionesEjecutadas{
        //public Decimal activityCode;
        public String codeOS;
        public String sessionCode;
        public String statusCodeSession;
    }
    /*FIN INTEGRACION 6*/

    /*INICIO INTEGRACION 7*/
    public class WrapperCerradoActividad{
        //public Integer activityCode;
        public String status; // smallint
    }
	/*FIN INTEGRACION 7*/
    
    /***********************************
    Este response se utiliza para:
        WrapperRadicarSesionesEjecutadas
        WrapperCerradoActividad
    ***********************************/
    public class responseServicio{ 
        public String message;
        public Integer status;
    }
	
    /*INICIO INTEGRACION 8*/
    public class WrapperEnvioHistorialInformes{ 
        //public String activityCode;
        public String codeOS; // numeric
        public String authorizationCode; // numeric
        public String codeSupportFile;
        public String codeSupport;
        public String deliveryCode;
        public String deliveryDate;
        public String message;
        public String fromx;
        public String to;
        public String deliveryStatus; // bit
        //public Datetime FechaEnvio2;
    }
    public class responseServicio8{ 
        public String id;
        public String message;
    }
    /*FIN INTEGRACION 8*/

    /*INICIO INTEGRACION 9*/
    public class WrapperCargueConsultores{
        public String document;
    }
    
    public class responseCargueConsultores{
        public String fullName;
        public Decimal userCode;
        public String email;
        public Boolean statusCode;
        public String status;
        public String code;
    }
	/*FIN INTEGRACION 9*/
    
    /*INICIO INTEGRACION 10*/
    public class WrapperCargueClientes{
        public Double nit; // float
    }

    public class responseCargueClientes{
        public String businessName;
        public String contractId; // float
        public Decimal nit;
        public String address;
        public String phoneNumber;
        public String legalRepresentative;
        public String email;
    }
	/*FIN INTEGRACION 10*/
    
    /* INICIO INTEGRACION 11*/
    public class WrapperCargueActividades{
        public Integer Contrato;
        public String CodigoEstado;
    }
    
    public class responseCargueActividades{
        public Integer CodigoCronograma;
        public Integer CodigoEmpresa;
        public String  AnoCronograma;
        public Integer Codigo;
        public String  CodigoActividad;
        public String  descripcion;
        public String  CodigoGrupo;
        public String  DescripcionGrupo;
        public String  CodigoSubGrupo;
        public String  DescripcionSubGrupo;
        public String  TipoPrevencion;
        public String  DescripcionUnidad;
        public Decimal Cantidad;
        public Decimal TarifaTecho;
        public String  FechaInicio;
        public String  FechaFin;
        public String  CodigoCiudad;
        public String  NombreCiudad;
        public String  Responsable;
        public String  Proyecto;
        public String  Observaciones;
        public String  CodigoEstado;
        public Integer CodigoEstadoAsignacionProveedor;
        public String  DescripcionEstado;
        public String  RealizadaPor;
        public String  NitProveedor;
        public String  ObservacionesProveedor;
        public String  CodigoDisRemision;
        public String  NombreDisRemision;
        public String  SucursalDisRemision;
        public String  CentroDeCosto;
        public String  Actividad;
        public String  Negocio;
        public String  CiudadDesarrollo;
        public Integer CantidadEntregada;
        public Integer CodigoContrato;
        public String  Contacto;
        public String  Direccion;
        public String  CiudadContacto;
        public String  TelefonoFax;
        public DateTime FechaPedido;
        public String  NombreProveedor;
        public String  ResaltarActividad;
        public String  CodigoSucursalProveedor;
        public Integer NumeroInvitados;
        public String  EnviadaACoordinadorAIS;
        public Integer TotalAsistentes;
        public String  TarifaVenta;
        public String  FechaInicioMod;
        public String  FechaFinMod;
        public Integer numeroSapSolicitadas;
        public Integer CodigoPedido;
        public String CodigoTipoActividad;
        public Integer CodigoPadreActividad;
        public String  codigoCreador;
        public DateTime Fecha_FechaInicio;
        public DateTime Fecha_FechaFin;
        public Integer ProyectoColmena;
        public Integer EstadoContratacion;
        public Integer EstadoGestionContratacion;
        public String  CodigoProveedor_TipoProveedor;
        public String  NombreLinea;
        public Integer codigotipomanejoPresupuesto;
        public Integer Actividad_RealizadaPorSubTipoId;
        //public Integer ProyectoColmena;
        //public Integer EstadoContratacion;
        //public Integer EstadoGestionContratacion;
        //public String  CodigoProveedor_TipoProveedor;
        //public String  NombreLinea;
        //public Integer codigotipomanejoPresupuesto;
        //public Integer Actividad_RealizadaPorSubTipoId;
    }
    
    /* FIN INTEGRACION 11*/

    //integración #11
    
    global class CuentaWO{
        public String RTAcct; 
        public String codigoEmpresaAcct;
        public String Name;
        public String Contrato;

        /*public String Codigociudad;
        public String direccionprincipal;
        public String billingCity;        
        public String billingCountry;  
        public String BillingState;
        public String BillingPostalCode;*/
        
    }
    
    global class OrdenDeTrabajo{
        public String Codigoempresa;
        public Integer AnoCronograma;
        public String TipoPrevencion;
        public String DescripcionUnidad;
        public Decimal TarifaTecho;
        public String NombreCiudad;
        public String Responsable;
        public String Proyecto;
        public Integer CodigoEstadoAsignacionProveedor;
        public String  DescripcionEstado;
        public String  NitProveedor;
        public String  CodigoDisRemision;
        public String  NombreDisRemision;
        public String  SucursalDisRemision;
        public String  CentroDeCosto;
        public String  Actividad;
        public String  Negocio;
        public String  CiudadesDesarrollo;
        public Decimal CantidadEntregada;
        public Integer CodigoContacto;
        public String  Contacto;
        public String  CiudadContacto;
        public String  TelefonoFax;
        public Datetime  FechaPedido;
        public String  NombreProveedor;
        public Boolean  ResaltarActividad;
        public String  CodigoSucursalProveedor;
        public Integer NumeroInvitados;
        public Boolean EnviadaACoordinadorAIS;
        public String  TarifaVenta;
        public String  FechaInicioMod;
        public String  FechaFinMod;
        public Integer numeroSapSolicitadas;
        public Integer CodigoPadreActividad;
        public String  codigoCreador;
        public Datetime Fecha_FechaInicio;
        public Datetime Fecha_FechaFin;
        public Integer ProyectoColmena;
        public Integer EstadoContratacion;
        public Integer EstadoGestionContratacion;
        public String CodigoProveedor_TipoProveedor;
        public Integer codigotipomanejoPresupuesto;
        public Integer Actividad_RealizadaPorSubTipoId;
        public String Codigociudad;
        public String  direccionprincipal;
        public String  cedulaConsultor;
    }

    global class SesionDeTrabajo{
        public String CodigoCronograma;
        public String codigoArchivoSoporte;
        public String estadoSoporte;
        public Datetime FechaInicio;
        public Datetime FechaFin;
        public String Observaciones;
        public String CodigoEstado;
        public String ObservacionesProveedor;
        public Decimal TotalAsistentes;
        public String CodigoSesion;
    }
    global class OrdenDeServicio{
        public String CodigoActividad;
        public String CodigoGrupo;
        public String DescripcionGrupo;
        public String CodigoSubGrupo;
        public String DescripcionSubGrupo;
        public String RealizadaPor;
        public Double Cantidad;
        public String CodigoTipoActividad;
        public String NombreLinea;
        
    }
    
    
    /*INICIO INTEGRACION 12*/ 
    
    public class responseArchivoSoporte{
        public String id;
        public String message;
		public Integer status;
        public String archivoSoporte;
        public String pathAzure;
    }
    
    /*FIN INTEGRACIÓN 12*/
}