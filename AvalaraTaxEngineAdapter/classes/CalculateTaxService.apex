global class CalculateTaxService {
    // ============================================================================
    // CONSTANT
    // ============================================================================
    private static final String AVALARA_ENDPOINT_URL_SANDBOX = 'https://sandbox-rest.avatax.com/api/v2';
    // Avalara Endpoint URL Production
    private static final String AVALARA_ENDPOINT_URL_PRODUCTION = 'https://rest.avatax.com/api/v2';
    private static final String TEST_REQUEST_BODY = '{  "id": -1,  "code": "00000131",  "companyId": -1,  "date": "2017-02-03T00:00:00",  "taxDate": "2017-02-03T00:00:00",  "status": "Temporary",  "type": "SalesOrder",  "reconciled": false,  "totalAmount": 4000,  "totalExempt": 0,  "totalTax": 290,  "totalTaxable": 4000,  "totalTaxCalculated": 290,  "adjustmentReason": "NotAdjusted",  "locked": false,  "version": 1,  "modifiedDate": "2017-02-03T12:18:18.7347388Z",  "modifiedUserId": 53894,  "lines": [    {      "id": -1,      "transactionId": -1,      "lineNumber": "80241000000jNDCAA2",      "discountAmount": 0,      "exemptAmount": 0,      "exemptCertId": 0,      "isItemTaxable": true,      "lineAmount": 1000,      "reportingDate": "2017-02-03T00:00:00",      "tax": 72.5,      "taxableAmount": 1000,      "taxCalculated": 72.5,      "taxCode": "P0000000",      "taxDate": "2017-02-03T00:00:00",      "taxIncluded": false,      "details": [        {          "id": -1,          "transactionLineId": -1,          "transactionId": -1,          "country": "US",          "region": "CA",          "exemptAmount": 0,          "jurisCode": "06",          "jurisName": "CALIFORNIA",          "stateAssignedNo": "",          "jurisType": "STA",          "nonTaxableAmount": 0,          "rate": 0.06,          "tax": 60,          "taxableAmount": 1000,          "taxType": "Sales",          "taxName": "CA STATE TAX",          "taxAuthorityTypeId": 45,          "taxCalculated": 60,          "rateType": "General"        },        {          "id": -1,          "transactionLineId": -1,          "transactionId": -1,          "country": "US",          "region": "CA",          "exemptAmount": 0,          "jurisCode": "075",          "jurisName": "SAN FRANCISCO",          "stateAssignedNo": "",          "jurisType": "CTY",          "nonTaxableAmount": 0,          "rate": 0.0025,          "tax": 2.5,          "taxableAmount": 1000,          "taxType": "Sales",          "taxName": "CA COUNTY TAX",          "taxAuthorityTypeId": 45,          "taxCalculated": 2.5,          "rateType": "General"        },        {          "id": -1,          "transactionLineId": -1,          "transactionId": -1,          "country": "US",          "region": "CA",          "exemptAmount": 0,          "jurisCode": "EMTV0",          "jurisName": "SAN FRANCISCO CO LOCAL TAX SL",          "stateAssignedNo": "38",          "jurisType": "STJ",          "nonTaxableAmount": 0,          "rate": 0.01,          "tax": 10,          "taxableAmount": 1000,          "taxType": "Sales",          "taxName": "CA SPECIAL TAX",          "taxAuthorityTypeId": 45,          "taxCalculated": 10,          "rateType": "General"        }      ]    }  ]}';

    private static String getTestResponseString() {
        List<String> jsonResponse = new List<String>{
            '"id": 0',
            '"code": "testDocCode1231245984"',
            '"companyId": 468039',
            '"date": "2020-07-15"',
            '"paymentDate": "2020-07-15"',
            '"status": "Temporary"',
            '"type": "SalesOrder"',
            '"customerVendorCode": "testDocCode1234"',
            '"customerCode": "testDocCode1234"',
            '"reconciled": false',
            '"totalAmount": 232',
            '"totalExempt": 0',
            '"totalDiscount": 0',
            '"totalTax": 23.43',
            '"totalTaxable": 232',
            '"totalTaxCalculated": 23.43',
            '"adjustmentReason": "NotAdjusted"',
            '"locked": false',
            '"version": 1',
            '"exchangeRateEffectiveDate": "2020-07-15"',
            '"exchangeRate": 1',
            '"modifiedDate": "2020-08-13T11:19:20.4836636Z"',
            '"modifiedUserId": 53894',
            '"taxDate": "2020-07-15T00:00:00"',
            '"lines": [{"id": 0,"transactionId": 0,"lineNumber": "1","discountAmount": 0,"exemptAmount": 0,"exemptCertId": 0,"isItemTaxable": true,"itemCode": "","lineAmount": 232,"quantity": 1,"reportingDate": "2020-07-15","tax": 23.43,"taxableAmount": 232,"taxCalculated": 23.43,"taxCode": "P0000000","taxCodeId": 8087,"taxDate": "2020-07-15","taxOverrideType": "None","taxOverrideAmount": 0,"taxIncluded": false,"details": [{"id": 0,"transactionLineId": 0,"transactionId": 0,"country": "US","region": "WA","exemptAmount": 0,"jurisCode": "53","jurisName": "WASHINGTON","stateAssignedNo": "","jurisType": "STA","jurisdictionType": "State","nonTaxableAmount": 0,"rate": 0.065,"tax": 15.08,"taxableAmount": 232,"taxType": "Sales","taxSubTypeId": "S","taxName": "WA STATE TAX","taxAuthorityTypeId": 45,"taxCalculated": 15.08,"rateType": "General","rateTypeCode": "G","unitOfBasis": "PerCurrencyUnit","isNonPassThru": false,"isFee": false},{"id": 0,"transactionLineId": 0,"transactionId": 0,"country": "US","region": "WA","exemptAmount": 0,"jurisCode": "033","jurisName": "KING","stateAssignedNo": "1700","jurisType": "CTY","jurisdictionType": "County","nonTaxableAmount": 0,"rate": 0,"tax": 0,"taxableAmount": 232,"taxType": "Sales","taxSubTypeId": "S","taxName": "WA COUNTY TAX","taxAuthorityTypeId": 45,"taxCalculated": 0,"rateType": "General","rateTypeCode": "G","unitOfBasis": "PerCurrencyUnit","isNonPassThru": false,"isFee": false}],"nonPassthroughDetails": [],"hsCode": "","costInsuranceFreight": 0,"vatCode": "","vatNumberTypeId": 0}]',
            '"addresses": [{"id": 0,"transactionId": 0,"boundaryLevel": "Address","line1": "255 S. King Street","line2": "","line3": "","city": "Seattle","region": "WA","postalCode": "98104","country": "US","taxRegionId": 2109700,"latitude": "47.59821","longitude": "-122.33108"}]',
            '"summary": [{"country": "US","region": "WA","jurisType": "State","jurisCode": "53","jurisName": "WASHINGTON","taxAuthorityType": 45,"stateAssignedNo": "","taxType": "Sales","taxSubType": "S","taxName": "WA STATE TAX","rateType": "General","taxable": 232,"rate": 0.065,"tax": 15.08,"taxCalculated": 15.08,"nonTaxable": 0,"exemption": 0},{"country": "US","region": "WA","jurisType": "County","jurisCode": "033","jurisName": "KING","taxAuthorityType": 45,"stateAssignedNo": "1700","taxType": "Sales","taxSubType": "S","taxName": "WA COUNTY TAX","rateType": "General","taxable": 232,"rate": 0,"tax": 0,"taxCalculated": 0,"nonTaxable": 0,"exemption": 0}]'
        };
        return '{' + String.join(jsonResponse, ',') + '}';
    }

    public static commercetax.TaxEngineResponse getTax(commercetax.TaxEngineContext taxEngineContext) {
        commercetax.CalculateTaxRequest request = (commercetax.CalculateTaxRequest) taxEngineContext.getRequest();
        commercetax.calculatetaxtype requestType = request.taxtype;
        string referenceEntity = request.ReferenceEntityId;
        try {
            List<commercetax.TaxLineItemRequest> listOfLines = request.lineItems;
            if (!listOfLines.isEmpty()) {
                HttpService sendHttpRequest = new HttpService();
                sendHttpRequest.addHeader('Content-type', 'application/json');

                if (request.shouldVoidTax) {
                    commercetax.TaxEngineResponse response = voidDoc(request);
                    if (response instanceof commercetax.ErrorResponse) {
                        return (commercetax.ErrorResponse) response;
                    }

                    if (response != null) {
                        return response;
                    }
                }

                String requestBody = AvalaraJSONBuilder.getInstance().frameJsonForGetTaxOrderItem(request);
                sendHttpRequest.post('/transactions/create', requestBody);
                //system.debug('Request '+requestBody);
                String responseString = '';
                if (Test.isRunningTest()) {
                    responseString = getTestResponseString();
                } else {
                    responseString = sendHttpRequest.getResponse().getBody();
                }
                //system.debug(sendHttpRequest.getResponse());
                //system.debug('response'+responseString);
                //responseString = TEST_REQUEST_BODY;
                system.debug('Heap size used ' + Limits.getHeapSize());

                if (!responseString.contains('error')) {
                    commercetax.CalculateTaxResponse response = AvalaraJSONBuilder.getInstance()
                        .buildCalculateTaxResponse(responseString, request, requestType, referenceEntity, false);
                    return response;
                } else {
                    JsonErrorParser jsonErrorParserClass = JsonErrorParser.parse(responseString);
                    String message = getErrorMessage(jsonErrorParserClass);
                    return new commercetax.ErrorResponse(commercetax.resultcode.TaxEngineError, '501', message);
                }
            } else
                return null;
        } catch (Exception e) {
            throw e;
        }
    }

    private static String getErrorMessage(JsonErrorParser error) {
        if (error != null) {
            if (error.details != null) {
                String errorMessage = '';
                for (JsonErrorParser.Details messageString : error.details) {
                    if (String.isNotBlank(messageString.message)) {
                        errorMessage = messageString.message;
                    }
                }
                if (String.isNotBlank(errorMessage)) {
                    return errorMessage;
                }
            }
        }
        return 'Tax Engine Error';
    }

    private static String getNumericalCode(JsonErrorParser error) {
        if (error != null) {
            if (error.details != null) {
                String numericalCode = '';
                for (JsonErrorParser.Details messageString : error.details) {
                    if (messageString.numericalCode != null) {
                        numericalCode = String.valueOf(messageString.numericalCode);
                    }
                }
                if (String.isNotBlank(numericalCode)) {
                    return numericalCode;
                }
            }
        }
        return '501';
    }

    public static commercetax.TaxEngineResponse voidDoc(commercetax.CalculateTaxRequest request) {
        HttpService sendHttpRequest = new HttpService();
        sendHttpRequest.addHeader('Content-type', 'application/json');

        String companyCode = request.SellerDetails.code;
        String transactionCode = request.referenceDocumentCode;
        String url = '/companies/' + companyCode + '/transactions/' + transactionCode + '/void';
        String requestBody = AvalaraJSONBuilder.getInstance().frameJsonForVoidTaxOrderItem(request);
        sendHttpRequest.post(url, requestBody);

        String responseString = '';
        if (Test.isRunningTest()) {
            responseString = getTestResponseString();
        } else {
            responseString = sendHttpRequest.getResponse().getBody();
        }

        if (responseString.contains('error')) {
            JsonErrorParser jsonErrorParserClass = JsonErrorParser.parse(responseString);
            if (jsonErrorParserClass != null && jsonErrorParserClass.code == 'EntityNotFoundError') {
                return new commercetax.ErrorResponse(
                    commercetax.resultcode.ReferenceDocumentCodeMissing,
                    getNumericalCode(jsonErrorParserClass),
                    getErrorMessage(jsonErrorParserClass)
                );
            }
            return new commercetax.ErrorResponse(
                commercetax.resultcode.TaxEngineError,
                getNumericalCode(jsonErrorParserClass),
                getErrorMessage(jsonErrorParserClass)
            );
        }

        JsonSuccessParser jsonSuccessParserClass = JsonSuccessParser.parse(responseString);
        if (jsonSuccessParserClass.locked) {
            return null;
        }

        commercetax.calculatetaxtype requestType = request.taxtype;
        String referenceEntity = request.ReferenceEntityId;
        return AvalaraJSONBuilder.getInstance()
            .buildCalculateTaxResponse(responseString, request, requestType, referenceEntity, true);
    }
}
