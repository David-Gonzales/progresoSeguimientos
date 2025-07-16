public class ClimaService{
    @future(callout=true)
    public static void obtenerClima(Id seguimientoId){
        Seguimiento__c seguimiento = [SELECT Id, Ubicacion__c FROM Seguimiento__c WHERE Id = :seguimientoId LIMIT 1];

        if(String.isBlank(seguimiento.Ubicacion__c)){
            System.debug('Ubicación vacía. No se puede hacer callout.');
            return;
        }

        // Obtener configuración desde Metadata
        List<Configuracion_Clima__mdt> configuraciones = [
            SELECT API_Key__c 
            FROM Configuracion_Clima__mdt 
            WHERE DeveloperName = 'OpenWeatherConfig'
            LIMIT 1
        ];

        if (configuraciones.isEmpty()) {
            System.debug('No se encontró la configuración de clima.');
            return;
        }

        String apiKey = configuraciones[0].API_Key__c;

        //Encontramos la construcción del endpoint de la API en el Apartado de "Built-in API request by city name" en https://openweathermap.org/current. Para temperatura en Celsius utilice unidades=métricas: https://openweathermap.org/current#data

        //String apiKey = 'e4f2d41071c06df359f37147fb4f0362';

        //https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_classes_restful_encodingUtil.htm#apex_System_EncodingUtil_urlEncode
        String ciudad = EncodingUtil.urlEncode(seguimiento.Ubicacion__c, 'UTF-8');
        System.debug('API Key usada: ' + apiKey);
        
        String endpoint = 'https://api.openweathermap.org/data/2.5/weather?q=' + ciudad + '&appid=' + apiKey + '&units=metric&lang=es';

        System.debug('Haciendo callout a: ' + endpoint);

        Http http = new Http();
        HttpRequest solicitud = new HttpRequest();
        solicitud.setEndpoint(endpoint);
        solicitud.setMethod('GET');

        try{
            HttpResponse respuesta = http.send(solicitud);

            System.debug('Código de respuesta: ' + respuesta.getStatusCode());
            System.debug('Cuerpo de respuesta: ' + respuesta.getBody());

            if(respuesta.getStatusCode() == 200){
                //OK
                //Documentación para la deserialización https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_System_Json.htm#apex_System_Json_deserializeUntyped
                Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(respuesta.getBody());
                List<Object> clima = (List<Object>) body.get('weather');

                if (clima != null && !clima.isEmpty()) {
                    Map<String, Object> detallesClima = (Map<String, Object>) clima[0];
                    String descripcion = (String) detallesClima.get('description');

                    seguimiento.Clima_Actual__c = descripcion;
                    update seguimiento;

                    System.debug('Seguimiento actualizado con clima: ' + descripcion);
                }
            } else {
                System.debug('Respuesta con error: ' + respuesta.getBody());
            }

        }catch(Exception e){
            System.debug('Error en el callout: ' + e.getMessage());
        }
    }
}

