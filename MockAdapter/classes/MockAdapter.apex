global virtual class MockAdapter implements commercetax.TaxEngineAdapter {
    global commercetax.TaxEngineResponse processRequest(commercetax.TaxEngineContext taxEngineContext) {
        commercetax.RequestType requestType = taxEngineContext.getRequestType();

        // Map of tax field name to the value of the corresponding entity field (EntityFieldName) at header level
        Map<String, Object> customTaxAttributeHeaderLevelMap = new Map<String, Object>();
        // Map of tax field name to the value of the corresponding entity field (EntityFieldName) at line level
        Map<String, Object> customTaxAttributeLineLevelMap = new Map<String, Object>();
        // Map of tax field name to the value of the corresponding entity field (EntityFieldName) at line tax level
        Map<String, Object> customTaxAttributeLineTaxLevelMap = new Map<String, Object>();

        commercetax.CustomTaxAttributesResponse customTaxAttributeHeaderLevelResponse = new commercetax.CustomTaxAttributesResponse();
        commercetax.CustomTaxAttributesResponse customTaxAttributeLineLevelResponse = new commercetax.CustomTaxAttributesResponse();
        commercetax.CustomTaxAttributesResponse customTaxAttributeLineTaxLevelResponse = new commercetax.CustomTaxAttributesResponse();

        customTaxAttributeHeaderLevelResponse.setData(customTaxAttributeHeaderLevelMap);
        customTaxAttributeLineLevelResponse.setData(customTaxAttributeLineLevelMap);
        customTaxAttributeLineTaxLevelResponse.setData(customTaxAttributeLineTaxLevelMap);

        commercetax.CalculateTaxRequest request = (commercetax.CalculateTaxRequest) taxEngineContext.getRequest();
        if (request.documentCode == null) {
            return new commercetax.ErrorResponse(commercetax.resultcode.TaxEngineError, '404', 'documentCode  is mandatory');
        }
        if (request.documentCode == 'TaxEngineError') {
            return new commercetax.ErrorResponse(commercetax.resultcode.TaxEngineError, '504', 'documentCode  - not supported');
        }
        if (request.documentCode == 'simulateUnhandledExceptionInAdapter') {
            Integer foo = 5 / 0;
        }
        if (request.documentCode == 'simulateValidationFailureInAdapter') {
            return new commercetax.ErrorResponse(
                commercetax.resultcode.TaxEngineError,
                '400',
                'validations for documentCode failed in adapter'
            );
        }
        if (request.documentCode == 'simulateMalformedErrorInAdapter') {
            return new commercetax.ErrorResponse(commercetax.resultcode.TaxEngineError, null, 'malformed adapter error response');
        }
        if (request.documentCode == 'simulateTaxEngineProcessFailure') {
            return new commercetax.ErrorResponse(commercetax.resultcode.TaxEngineError, '500', 'Tax Engine couldnt process your request');
        }
        if (request.documentCode == 'simulateReferenceDocumentCodeMissing') {
            return new commercetax.ErrorResponse(commercetax.resultcode.ReferenceDocumentCodeMissing, '400', 'Ref Document Code not found');
        }

        if (requestType == commercetax.RequestType.CalculateTax) {
            commercetax.calculatetaxtype type = request.taxtype;
            String docCode = '';
            if (request.DocumentCode == 'simulateEmptyDocumentCode')
                docCode = '';
            else if (request.DocumentCode != null)
                docCode = request.DocumentCode;
            else if (request.ReferenceEntityId != null)
                docCode = request.ReferenceEntityId;
            else
                docCode = String.valueOf(getRandomInteger(0, 2147483647));
            commercetax.CalculateTaxResponse response = new commercetax.CalculateTaxResponse();
            response.setCustomTaxAttributes(customTaxAttributeHeaderLevelResponse);
            if (request.isCommit == true) {
                response.setStatus(commercetax.TaxTransactionStatus.Committed);
            } else {
                response.setStatus(commercetax.TaxTransactionStatus.Uncommitted);
            }

            if (request.shouldVoidTax) {
                if (request.documentCode.startsWith('simulateCalculateWhenRefDocIsLocked')) {
                    response.setDocumentCode(docCode);
                    response.setReferenceDocumentCode(request.referenceDocumentCode);
                    if (request.taxTransactionType == null) {
                        response.setTaxTransactionType(commercetax.TaxTransactionType.Debit);
                    } else {
                        response.setTaxTransactionType(request.taxTransactionType);
                    }
                } else if (request.documentCode.startsWith('simulateRandomRefDocumentCode')) {
                    response.setDocumentCode(docCode);
                    response.setReferenceDocumentCode('simulateRandomRefDocumentCode2');
                    response.setTaxTransactionType(request.taxTransactionType);
                } else if (request.documentCode.startsWith('simulateRandomCode')) {
                    response.setDocumentCode('simulateRandomCode2');
                    response.setReferenceDocumentCode(null);
                    response.setTaxTransactionType(commercetax.TaxTransactionType.Void);
                } else {
                    response.setDocumentCode(request.referenceDocumentCode);
                    response.setReferenceDocumentCode(null);
                    response.setTaxTransactionType(commercetax.TaxTransactionType.Void);
                }
            } else {
                response.setDocumentCode(docCode);
                response.setReferenceDocumentCode(request.referenceDocumentCode);

                if (request.taxTransactionType == null) {
                    response.setTaxTransactionType(commercetax.TaxTransactionType.Debit);
                } else {
                    response.setTaxTransactionType(request.taxTransactionType);
                }
            }

            response.setTaxType(type);
            response.setStatusDescription('statusDescription');
            if (request.sellerDetails.code == 'testSellerCode') {
                response.setDescription('SellerCode fetched from TaxEngine entity');
            } else {
                response.setDescription('description');
            }
            response.setEffectiveDate(system.now());
            if (request.transactionDate == null) {
                response.setTransactionDate(system.now());
            } else {
                response.setTransactionDate(request.transactionDate);
            }

            if (request.currencyIsoCode == null || request.currencyIsoCode == '') {
                response.setCurrencyIsoCode('USD');
            } else {
                response.setCurrencyIsoCode(request.currencyIsoCode);
            }
            response.setReferenceEntityId(request.ReferenceEntityId);
            Double totalTax = 0.0;
            Double totalAmount = 0.0;
            List<commercetax.LineItemResponse> lineItemResponses = new List<commercetax.LineItemResponse>();
            for (Commercetax.TaxLineItemRequest lineItem : request.lineItems) {
                commercetax.AddressesResponse addressesRes = new commercetax.AddressesResponse();
                if (request.DocumentCode == 'SetsNullForResponseWithoutException') {
                    addressesRes.setShipFrom(null);
                    addressesRes.setShipTO(null);
                    addressesRes.setSoldTo(null);
                } else {
                    setAddresses(addressesRes, lineItem);
                    //System.debug('Line item addresses: ' + addressesRes);
                }
                //System.debug('ProductSKU: ' + lineItem.productSKU);
                //System.debug('ReferenceDocumentCode: ' + lineItem.referenceDocumentCode);
                commercetax.LineItemResponse lineItemResponse = new commercetax.LineItemResponse();
                lineItemResponse.setCustomTaxAttributes(customTaxAttributeLineLevelResponse);
                Double totalLineTax = 0;
                List<commercetax.TaxDetailsResponse> taxDetailsResponses = new List<commercetax.TaxDetailsResponse>();
                for (integer i = 0; i < 1; i++) {
                    Integer rate = 1;
                    Double taxableAmount = lineItem.amount;
                    commercetax.TaxDetailsResponse taxDetailsResponse = new commercetax.TaxDetailsResponse();
                    taxDetailsResponse.setRate(Double.valueOf(rate));
                    taxDetailsResponse.setTaxableAmount(taxableAmount);
                    Double tax = taxableAmount * rate;
                    totalLineTax += tax;
                    taxDetailsResponse.setTax(taxableAmount * rate);
                    taxDetailsResponse.setExemptAmount(0);
                    taxDetailsResponse.setExemptReason('exemptReason');
                    taxDetailsResponse.setTaxRegionId('taxRegionId');
                    taxDetailsResponse.setTaxId(String.valueOf(getRandomInteger(0, 2323233)));
                    taxDetailsResponse.setSerCode('serCode');
                    taxDetailsResponse.setCustomTaxAttributes(customTaxAttributeLineTaxLevelResponse);
                    taxDetailsResponse.setTaxAuthorityTypeId('taxAuthorityTypeId');
                    if (request.DocumentCode == 'SetsNullForResponseWithoutException') {
                        taxDetailsResponse.setImposition(null);
                    } else {
                        commercetax.ImpositionResponse imposition = new commercetax.ImpositionResponse();
                        imposition.setSubType('subtype');
                        imposition.setType('type');
                        taxDetailsResponse.setImposition(imposition);
                    }

                    if (request.DocumentCode == 'SetsNullForResponseWithoutException') {
                        taxDetailsResponse.setJurisdiction(null);
                    } else {
                        commercetax.JurisdictionResponse jurisdiction = new commercetax.JurisdictionResponse();
                        jurisdiction.setCountry('country');
                        jurisdiction.setRegion('region');
                        jurisdiction.setName('name');
                        jurisdiction.setStateAssignedNumber('stateAssignedNo');
                        jurisdiction.setId('id');
                        jurisdiction.setLevel('level');
                        taxDetailsResponse.setJurisdiction(jurisdiction);
                    }

                    taxDetailsResponses.add(taxDetailsResponse);
                }
                lineItemResponse.setTaxes(taxDetailsResponses);
                totalTax += totalLineTax;
                totalAmount += lineItem.amount;

                if (request.DocumentCode == 'SetsNullForResponseWithException') {
                    lineItemResponse.setAmountDetails(null);
                } else {
                    commercetax.AmountDetailsResponse amountResponse = new commercetax.AmountDetailsResponse();
                    amountResponse.setTotalAmountWithTax(totalTax + totalAmount);
                    amountResponse.setExemptAmount(0);
                    amountResponse.setTotalAmount(totalAmount);
                    amountResponse.setTaxAmount(totalTax);
                    lineItemResponse.setAmountDetails(amountResponse);
                }
                lineItemResponse.setEffectiveDate(system.now());
                lineItemResponse.setTaxCode(lineItem.taxCode);
                lineItemResponse.setProductCode(lineItem.ProductCode);
                lineItemResponse.setLineNumber(lineItem.linenumber);
                lineItemResponse.setIsTaxable(true);
                lineItemResponse.setQuantity(lineItem.quantity);
                if (request.DocumentCode == 'SetsNullForResponseWithoutException') {
                    lineItemResponse.setAddresses(null);
                } else {
                    lineItemResponse.setAddresses(addressesRes);
                }
                lineItemResponses.add(lineItemResponse);
            }
            if (request.DocumentCode == 'SetsNullForResponseWithException') {
                lineItemResponses.add(null);
            }
            if (request.documentCode == 'nolines') {
                // logic to skip adding lines to response
            } else {
                response.setLineItems(lineItemResponses);
            }
            if (request.DocumentCode == 'SetsNullForResponseWithException') {
                response.setAmountDetails(null);
            } else {
                commercetax.AmountDetailsResponse headerAmountResponse = new commercetax.AmountDetailsResponse();
                headerAmountResponse.setTotalAmountWithTax(totalTax + totalAmount);
                headerAmountResponse.setExemptAmount(0);
                headerAmountResponse.setTotalAmount(totalAmount);
                headerAmountResponse.setTaxAmount(totalTax);
                response.setAmountDetails(headerAmountResponse);
            }
            commercetax.AddressesResponse addressesRes = new commercetax.AddressesResponse();
            commercetax.AddressResponse addRes = new commercetax.AddressResponse();
            addRes.setLocationCode('street, city, state, country, postalCode');
            addressesRes.setShipFrom(addRes);
            addressesRes.setShipTO(addRes);
            addressesRes.setSoldTo(addRes);
            response.setAddresses(addressesRes);
            return response;
        } else
            return null;
    }

    public static Integer getRandomInteger(Integer min, Integer max) {
        return min + (Integer.valueOf(Math.random()) * (max - min));
    }

    private void setAddresses(commercetax.AddressesResponse addressesRes, Commercetax.TaxLineItemRequest lineItem) {
        commercetax.LineTaxAddressesRequest addressesReq = lineItem.addresses;
        if (addressesReq == null) {
            return;
        }
        addressesRes.setShipFrom(getShipFromAddressRes(addressesReq));
        addressesRes.setShipTo(getShipToAddressRes(addressesReq));
        addressesRes.setSoldTo(getSoldToAddressRes(addressesReq));
    }

    private commercetax.AddressResponse getShipFromAddressRes(commercetax.LineTaxAddressesRequest addressesReq) {
        return getAddressRes(addressesReq.shipFrom);
    }

    private commercetax.AddressResponse getShipToAddressRes(commercetax.LineTaxAddressesRequest addressesReq) {
        return getAddressRes(addressesReq.shipTo);
    }

    private commercetax.AddressResponse getSoldToAddressRes(commercetax.LineTaxAddressesRequest addressesReq) {
        if (addressesReq.soldTo != null) {
            return getAddressRes(addressesReq.soldTo);
        } else {
            return getAddressRes(addressesReq.billTo);
        }
    }

    private commercetax.AddressResponse getAddressRes(commercetax.TaxAddressRequest addressReq) {
        if (addressReq == null) {
            return null;
        }

        commercetax.AddressResponse addressRes = new commercetax.AddressResponse();

        List<String> addressEle = new List<String>();
        if (addressReq.street != null)
            addressEle.add(addressReq.street);
        if (addressReq.city != null)
            addressEle.add(addressReq.city);
        if (addressReq.state != null)
            addressEle.add(addressReq.state);
        if (addressReq.country != null)
            addressEle.add(addressReq.country);
        if (addressReq.postalCode != null)
            addressEle.add(addressReq.postalCode);

        addressRes.setLocationCode(String.join(addressEle, ', '));
        return addressRes;
    }
}
