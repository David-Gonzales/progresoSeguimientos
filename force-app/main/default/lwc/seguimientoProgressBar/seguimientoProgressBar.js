import { LightningElement, api, wire } from 'lwc';
import getSeguimientos from '@salesforce/apex/SeguimientoController.getSeguimientos';
import getResumenSeguimientos from '@salesforce/apex/SeguimientoController.getResumenSeguimientos';

export default class SeguimientoProgressBar extends LightningElement {
    
    @api recordId;
    
    total = 0;
    completados = 0;
    resumen = {};
    hayResumen = false;

    get porcentaje() {
        return this.total > 0 ? Math.round((this.completados / this.total) * 100) : 0;
    }

    get haySeguimientos() {
        return this.total > 0;
    }
    
    @wire(getSeguimientos, { contactoId: '$recordId' })
    wiredSeguimientos({ error, data }) {
        if (data) {
            this.total = data.length;
            this.completados = data.filter(seg => seg.Etapa__c === 'Completado').length;
        } else if (error) {
            console.error('Error al obtener seguimientos:', error);
        }
    }

    @wire(getResumenSeguimientos, { contactoId: '$recordId' })
    wiredResumen({ error, data }) {
        if (data) {
            this.resumen = data;
            this.hayResumen = true;
        } else if (error) {
            console.error('Error al obtener el resumen de seguimientos:', error);
            this.hayResumen = false;
        }
    }
}