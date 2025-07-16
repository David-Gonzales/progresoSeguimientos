public with sharing class SeguimientoController {
    @AuraEnabled(cacheable=true)
    public static List<Seguimiento__c> getSeguimientos(Id contactoId) {
        return [
            SELECT Id, Name, Etapa__c
            FROM Seguimiento__c
            WHERE Contacto__c = :contactoId
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getResumenSeguimientos(Id contactoId) {
        Map<String, Object> resultado = new Map<String, Object>();

        List<Seguimiento__c> seguimientos = [
            SELECT Id, Name, Etapa__c, Clima_Actual__c, CreatedDate
            FROM Seguimiento__c
            WHERE Contacto__c = :contactoId
            ORDER BY CreatedDate DESC
        ];

        Integer pendientes = 0;
        Integer enProceso = 0;
        Integer completados = 0;

        for (Seguimiento__c s : seguimientos) {
            if (s.Etapa__c == 'Pendiente') pendientes++;
            else if (s.Etapa__c == 'En Proceso') enProceso++;
            else if (s.Etapa__c == 'Completado') completados++;
        }

        String nombreReciente = seguimientos.isEmpty() ? null : seguimientos[0].Name;
        String climaReciente = seguimientos.isEmpty() ? null : seguimientos[0].Clima_Actual__c;

        resultado.put('seguimientoReciente', nombreReciente);
        resultado.put('climaActual', climaReciente);
        resultado.put('pendientes', pendientes);
        resultado.put('enProceso', enProceso);
        resultado.put('completados', completados);

        return resultado;
    }

}