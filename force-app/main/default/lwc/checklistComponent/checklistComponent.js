import { LightningElement, api, track, wire } from 'lwc';
import guardarEvaluaciones from '@salesforce/apex/ChecklistController.guardarEvaluaciones';
import generarPDF from '@salesforce/apex/ChecklistController.generarPDF';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['CheckListProvider__c.Id'];

export default class ChecklistComponent extends LightningElement {
    @api recordId; 
    @track evaluaciones = [];
    @track showMessage = false;
    @track message = '';
    @track isModalOpen = false;
    messageDuration = 3000;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            this.initializeEvaluaciones();
        } else if (error) {
            console.error('Error al obtener el recordId:', error);
        }
    }

    initializeEvaluaciones() {
        this.evaluaciones = [...Array(32)].map((_, index) => ({
            id: `${index + 1}${this.recordId}`,
            ids: `${index + 1}`,
            criterio: this.getCriterioText(index),
            subCriterio: this.getSubCriterioText(index),
            estado: '',
            calificacion: '',
            observacionCalificacion: '',
            observacionInactivacion: '',
            mostrarObservacion: false
        }));
    }

    getCriterioText(index) {
        const criterios = [
            "La propuesta está dirigida a Colmena Seguros Riesgos Laborales y en formato exclusivo del proveedor (logo del proveedor).",
            "Nombre del proveedor (Razón Social completa y abreviada).",
            "Nit del proveedor o documento de identidad.",
            "Dirección sede física del proveedor.",
            "Datos de contacto del representante del proveedor que lidera el proyecto ante Colmena Seguros Riesgos Laborales.",
            "Nombre de la empresa afiliada a Colmena Seguros Riesgos Laborales que será beneficiaria del servicio.",
            "Nombre del Director Integral de Servicios DIS y/o Asesor por Proyecto APP Líder de cuenta.",
            "Fecha de elaboración de la propuesta.",
            "Vigencia de la propuesta.",
            "Nombre del Proyecto.",
            "Objetivos.",
            "",
            "",
            "Justificación",
            "Normatividad aplicable a las actividades que se desarrollarán en el proyecto",
            "Descripción del Proyecto",
            "",
            "",
            "",
            "Recurso Humano",
            "Costos de la Propuesta",
            "",
            "",
            "Condiciones de pago",
            "Cronograma de trabajo",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
        ];
        return criterios[index] || '';
    }

    getSubCriterioText(index) {
        const subCriterios = [
            "", // No hay subcriterio para el primer criterio
            "", 
            "", 
            "", 
            "", 
            "", 
            "", 
            "", 
            "", 
            "", 
            "", 
            "Objetivo General", 
            "Objetivos Específicos", 
            "", 
            "", 
            "", 
            "En que consiste el proyecto", 
            "Metodologia definida", 
            "Relación de centro(s) de trabajo", 
            "",
            "",
            "Costos técnicos de la propuesta",
            "Costos administrativos de la propuesta",
            "",
            "",
            "1) Hoja Información Técnica",
            "2) Hoja Información Administrativo",
            "i. Desplazamientos",
            "ii. Alimentación",
            "iii. Alquiler de equipos",
            "3) Hoja Información Indicadores",
            "4) Hoja Servicios Referencia Colmena ARL",
        ];
        return subCriterios[index] || '';
    }

    guardarEvaluacion() {
        // Verificar si hay evaluaciones con estado o calificación vacíos
        const emptyValuesExist = this.evaluaciones.some(evaluacion => (
            !evaluacion.estado || !evaluacion.calificacion
        ));

        if (emptyValuesExist) {
            this.showMessage = true;
            this.message = 'Todos los estados y calificaciones deben tener un valor antes de guardar.';
            this.isError = true; // Indicar que es un mensaje de error
            setTimeout(() => {
                this.hideMessage();
            }, this.messageDuration);
            return;
        }
        const invalidEvaluations = this.evaluaciones.filter(evaluacion => (
            evaluacion.estado === 'Inactivo' && !evaluacion.observacionInactivacion
        ));

        if (invalidEvaluations.length > 0) {
            this.showMessage = true;
            this.message = 'Debe completar las observaciones en caso de inactivación cuando el estado es Inactivo';
            this.isError = true; // Indicar que es un mensaje de error
            setTimeout(() => {
                this.hideMessage();
            }, this.messageDuration);
            return;
        }

        guardarEvaluaciones({ jsonData: JSON.stringify(this.evaluaciones), prospectoId: this.recordId })
            .then(result => {
                this.message = 'Registros guardados con éxito';
                this.showMessage = true;
                this.isError = false; // Indicar que es un mensaje de éxito
                //this.closeModal();
                setTimeout(() => {
                    this.closeModal();
                    this.hideMessage();
                }, this.messageDuration);
                return generarPDF({ prospectoId: this.recordId });
            })
            .then(pdfData => this.downloadPDF(pdfData))
            .catch(error => {
                this.message = 'Error al guardar los registros: ' + error.message;
                this.isError = true; // Indicar que es un mensaje de error
                this.showMessage = true;
                setTimeout(() => {
                    this.closeModal();
                    this.hideMessage();
                }, this.messageDuration);
            });
    }

    downloadPDF(pdfData) {
        const element = document.createElement('a');
        element.href = 'data:application/pdf;base64,' + pdfData;
        element.download = 'CheckListValidaciónPropuestaProspecto.pdf';
        document.body.appendChild(element);
        element.click();
        document.body.removeChild(element);
    }

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    handleChange(event) {
        const { id, field } = event.target.dataset;
        const value = event.target.value;
        const index = this.evaluaciones.findIndex(item => item.id === id); 
        if (index !== -1) {
            this.evaluaciones[index][field] = value;
            if (field === 'estado') {
                this.evaluaciones[index].mostrarObservacion = (value === 'Inactivo');
            }
        }
    }

    get ratingOptions() {
        return [
            { label: 'Cumple', value: 'Cumple' },
            { label: 'No Cumple', value: 'No Cumple' },
            { label: 'No Aplica', value: 'No Aplica' }
        ];
    }

    get statusOptions() {
        return [
            { label: 'Activo', value: 'Activo' },
            { label: 'Inactivo', value: 'Inactivo' }
        ];
    }
    hideMessage() {
        // Ocultar el mensaje
        this.showMessage = false;
        this.isError = false; // Restablecer el indicador de mensaje de error
    }
}