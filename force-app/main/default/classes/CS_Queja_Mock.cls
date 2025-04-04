@istest
public class CS_Queja_Mock implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
        final HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json'); 
		system.debug(req.getEndpoint());
		switch on req.getEndpoint() {
			when 'callout:SmartSupervision/login/' {
                res.setBody('{"refresh":"refresh","access":"access"}');
				res.setStatusCode(200);
			}
			when 'https://qasmart.superfinanciera.gov.co/api/queja/142500103452/' {
                res.setBody('{"data": "data"}');
				res.setStatusCode(200);
			}
            when 'https://qasmart.superfinanciera.gov.co/api/complaint/ack'{
                res.setBody('{"data": "data"}');
				res.setStatusCode(200);
            }
			when else {
                system.debug('req get body ELSE--->'+req);
			}
		}
		return res;
	}

}