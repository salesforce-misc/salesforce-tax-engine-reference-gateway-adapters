public with sharing class AvalaraJSONBuilder {
    private static AvalaraJSONBuilder avalaraJSONBuilderInstance;

    public static AvalaraJSONBuilder getInstance() {
        if (null == avalaraJSONBuilderInstance) {
            avalaraJSONBuilderInstance = new AvalaraJSONBuilder();
        }
        return avalaraJSONBuilderInstance;
    }

    public String frameJsonForGetTaxOrderItem(commercetax.CalculateTaxRequest calculateTaxRequest) {
        try {
            Id accountid = null;
            if (
                calculateTaxRequest.CustomerDetails.AccountId != null &&
                calculateTaxRequest.CustomerDetails.AccountId != ''
            )
                accountid = Id.valueof(calculateTaxRequest.CustomerDetails.AccountId);
            JSONGenerator jsonGeneratorInstance = JSON.createGenerator(true);
            jsonGeneratorInstance.writeStartObject();
            String type = null;
            if (calculateTaxRequest.taxtype == commercetax.CalculateTaxType.Actual)
                type = 'SalesInvoice';
            else
                type = 'SalesOrder';
            jsonGeneratorInstance.writeStringField('type', type);
            if (calculateTaxRequest.SellerDetails != null)
                jsonGeneratorInstance.writeStringField('companyCode', calculateTaxRequest.SellerDetails.code);
            else
                jsonGeneratorInstance.writeStringField('companyCode', 'billing2');
            if (calculateTaxRequest.isCommit != null) {
                jsonGeneratorInstance.writeBooleanField('commit', calculateTaxRequest.isCommit);
            }
            if (calculateTaxRequest.documentcode != null) {
                jsonGeneratorInstance.writeStringField('code', calculateTaxRequest.documentcode);
            } else if (calculateTaxRequest.referenceEntityId != null) {
                jsonGeneratorInstance.writeStringField('code', calculateTaxRequest.referenceEntityId);
            }
            if (calculateTaxRequest.CustomerDetails.code == null && accountid != null) {
                Account acc = [SELECT id, name FROM account WHERE id = :accountid];
                jsonGeneratorInstance.writeStringField('customerCode', acc.name);
            } else {
                jsonGeneratorInstance.writeStringField('customerCode', calculateTaxRequest.CustomerDetails.code);
            }
            if (calculateTaxRequest.EffectiveDate == null)
                jsonGeneratorInstance.writeDateField('date', system.today());
            else
                jsonGeneratorInstance.writeDateTimeField('date', calculateTaxRequest.EffectiveDate);

            jsonGeneratorInstance.writeFieldName('lines');
            jsonGeneratorInstance.writeStartArray();
            for (integer i = 0; i < 1; i++) {
                for (Commercetax.TaxLineItemRequest lineItem : calculateTaxRequest.LineItems) {
                    jsonGeneratorInstance.writeStartObject();
                    if (lineItem.linenumber != null) {
                        jsonGeneratorInstance.writeStringField('number', lineItem.linenumber);
                    }
                    jsonGeneratorInstance.writeNumberField('quantity', lineItem.Quantity);
                    jsonGeneratorInstance.writeNumberField('amount', (lineItem.Amount));
                    jsonGeneratorInstance.writeStringField('taxCode', lineItem.taxCode);
                    jsonGeneratorInstance.writeStringField('productSKU', lineItem.productSKU);

                    jsonGeneratorInstance.writeFieldName('addresses');
                    jsonGeneratorInstance.writeStartObject();
                    jsonGeneratorInstance.writeFieldName('ShipFrom');
                    jsonGeneratorInstance.writeStartObject();
                    jsonGeneratorInstance.writeStringField('line1', lineItem.addresses.shipfrom.street);
                    jsonGeneratorInstance.writeStringField('line2', lineItem.addresses.shipfrom.street);
                    jsonGeneratorInstance.writeStringField('city', lineItem.addresses.shipfrom.city);
                    jsonGeneratorInstance.writeStringField('region', lineItem.addresses.shipfrom.state);
                    jsonGeneratorInstance.writeStringField('country', lineItem.addresses.shipfrom.country);
                    jsonGeneratorInstance.writeStringField('postalCode', lineItem.addresses.shipfrom.postalcode);
                    jsonGeneratorInstance.writeEndObject();

                    jsonGeneratorInstance.writeFieldName('ShipTo');
                    jsonGeneratorInstance.writeStartObject();
                    jsonGeneratorInstance.writeStringField('line1', lineItem.addresses.shipto.street);
                    jsonGeneratorInstance.writeStringField('line2', lineItem.addresses.shipto.street);
                    jsonGeneratorInstance.writeStringField('city', lineItem.addresses.shipto.city);
                    jsonGeneratorInstance.writeStringField('region', lineItem.addresses.shipto.state);
                    jsonGeneratorInstance.writeStringField('country', lineItem.addresses.shipto.country);
                    jsonGeneratorInstance.writeStringField('postalCode', lineItem.addresses.shipto.postalcode);
                    jsonGeneratorInstance.writeEndObject();

                    jsonGeneratorInstance.writeFieldName('pointOfOrderOrigin');
                    jsonGeneratorInstance.writeStartObject();
                    jsonGeneratorInstance.writeStringField('line1', lineItem.addresses.soldto.street);
                    jsonGeneratorInstance.writeStringField('line2', lineItem.addresses.soldto.street);
                    jsonGeneratorInstance.writeStringField('city', lineItem.addresses.soldto.city);
                    jsonGeneratorInstance.writeStringField('region', lineItem.addresses.soldto.state);
                    jsonGeneratorInstance.writeStringField('country', lineItem.addresses.soldto.country);
                    jsonGeneratorInstance.writeStringField('postalCode', lineItem.addresses.soldto.postalcode);
                    jsonGeneratorInstance.writeEndObject();

                    if (lineItem.effectiveDate != null) {
                        jsonGeneratorInstance.writeFieldName('taxOverride');
                        jsonGeneratorInstance.writeStartObject();
                        jsonGeneratorInstance.writeDateTimeField('taxDate', lineItem.effectiveDate);
                        jsonGeneratorInstance.writeEndObject();
                    }
                    jsonGeneratorInstance.writeEndObject();
                    jsonGeneratorInstance.writeEndObject();
                }
            }
            jsonGeneratorInstance.writeEndArray();
            jsonGeneratorInstance.writeEndObject();
            return jsonGeneratorInstance.getAsString();
        } catch (Exception e) {
            throw e;
        }
    }

    public String frameJsonForVoidTaxOrderItem(commercetax.CalculateTaxRequest calculateTaxRequest) {
        try {
            JSONGenerator jsonGeneratorInstance = JSON.createGenerator(true);
            jsonGeneratorInstance.writeStartObject();
            jsonGeneratorInstance.writeStringField('code', 'DocVoided');
            jsonGeneratorInstance.writeEndObject();
            return jsonGeneratorInstance.getAsString();
        } catch (Exception e) {
            throw e;
        }
    }

    public commercetax.CalculateTaxResponse buildCalculateTaxResponse(
        String responseString,
        commercetax.CalculateTaxRequest request,
        commercetax.CalculateTaxType requestType,
        String referenceEntity,
        boolean isVoidTax
    ) {
        commercetax.CalculateTaxResponse response = new commercetax.CalculateTaxResponse();
        JsonSuccessParser jsonSuccessParserClass = JsonSuccessParser.parse(responseString);
        if (isVoidTax) {
            response.setTaxTransactionType(commercetax.TaxTransactionType.Void);
        } else {
            response.setTaxTransactionType(request.taxTransactionType);
        }
        response.setDocumentCode(jsonSuccessParserClass.code);
        response.setReferenceDocumentCode(jsonSuccessParserClass.referenceCode);
        if (jsonSuccessParserClass.status == 'Temporary') {
            response.setStatus(commercetax.TaxTransactionStatus.Uncommitted);
        }
        if (jsonSuccessParserClass.status == 'Committed') {
            response.setStatus(commercetax.TaxTransactionStatus.Committed);
        }
        response.setTaxType(requestType);
        commercetax.AmountDetailsResponse headerAmountResponse = new commercetax.AmountDetailsResponse();
        headerAmountResponse.setTotalAmountWithTax(
            jsonSuccessParserClass.totalAmount + jsonSuccessParserClass.totaltax
        );
        headerAmountResponse.setExemptAmount(jsonSuccessParserClass.totalExempt);
        headerAmountResponse.setTotalAmount(jsonSuccessParserClass.totalAmount);
        headerAmountResponse.setTaxAmount(jsonSuccessParserClass.totalTax);
        response.setAmountDetails(headerAmountResponse);
        response.setStatusDescription(jsonSuccessParserClass.adjustmentReason);
        response.setEffectiveDate(date.valueof(jsonSuccessParserClass.taxDate));
        response.setTransactionDate(date.valueof(jsonSuccessParserClass.transactionDate));
        response.setReferenceEntityId(referenceEntity);
        response.setTaxTransactionId(jsonSuccessParserClass.id);
        response.setCurrencyIsoCode(request.currencyIsoCode);
        List<commercetax.LineItemResponse> lineItemResponses = new List<commercetax.LineItemResponse>();
        for (JsonSuccessParser.Lines linesToProcess : jsonSuccessParserClass.lines) {
            commercetax.LineItemResponse lineItemResponse = new commercetax.LineItemResponse();
            Double rateCalculated = 0.0;
            List<commercetax.TaxDetailsResponse> taxDetailsResponses = new List<commercetax.TaxDetailsResponse>();
            for (JsonSuccessParser.details linesDetails : linesToProcess.details) {
                commercetax.TaxDetailsResponse taxDetailsResponse = new commercetax.TaxDetailsResponse();
                if (linesDetails.exemptAmount != 0) {
                    taxDetailsResponse.setExemptAmount(linesDetails.exemptAmount);
                    taxDetailsResponse.setExemptReason('Some reason we dont know');
                }
                commercetax.ImpositionResponse imposition = new commercetax.ImpositionResponse();
                imposition.setSubType(linesDetails.taxName);
                imposition.setType(linesDetails.ratetype);
                imposition.setSubType(linesDetails.taxName);
                taxDetailsResponse.setImposition(imposition);
                commercetax.JurisdictionResponse jurisdiction = new commercetax.JurisdictionResponse();
                jurisdiction.setCountry(linesDetails.country);
                jurisdiction.setRegion(linesDetails.region);
                jurisdiction.setName(linesDetails.jurisName);
                jurisdiction.setStateAssignedNumber(linesDetails.stateAssignedNo);
                jurisdiction.setId(linesDetails.jurisCode);
                jurisdiction.setLevel(linesDetails.jurisType);
                taxDetailsResponse.setJurisdiction(jurisdiction);
                rateCalculated += linesDetails.rate;
                taxDetailsResponse.setRate(rateCalculated);
                taxDetailsResponse.setTax(linesDetails.taxCalculated);
                taxDetailsResponse.setTaxableAmount(linesDetails.taxableAmount);
                taxDetailsResponse.setTaxAuthorityTypeId(String.valueOf(linesDetails.taxAuthorityTypeId));
                taxDetailsResponse.setTaxId(linesDetails.id);
                taxDetailsResponse.setTaxRegionId(linesDetails.region);
                taxDetailsResponses.add(taxDetailsResponse);
            }
            lineItemResponse.setTaxes(taxDetailsResponses);
            lineItemResponse.setEffectiveDate(date.valueof(linesToProcess.taxDate));
            commercetax.AmountDetailsResponse amountResponse = new commercetax.AmountDetailsResponse();
            amountResponse.setTaxAmount(linesToProcess.taxCalculated);
            amountResponse.setTotalAmount(linesToProcess.lineAmount);
            amountResponse.setTotalAmountWithTax(linesToProcess.lineAmount + linesToProcess.taxCalculated);
            amountResponse.setExemptAmount(linesToProcess.exemptAmount);
            lineItemResponse.setAmountDetails(amountResponse);
            lineItemResponse.setIsTaxable(linesToProcess.isItemTaxable);
            lineItemResponse.setProductCode(linesToProcess.itemCode);
            lineItemResponse.setTaxCode(linesToProcess.taxCode);
            lineItemResponse.setLineNumber(linesToProcess.lineNumber);
            lineItemResponse.setQuantity(linesToProcess.quantity);
            lineItemResponses.add(lineItemResponse);
        }
        response.setLineItems(lineItemResponses);
        return response;
    }
}
