global with sharing class JsonErrorParser {
    public static void consumeObject(JSONParser parser) {
        Integer depth = 0;
        do {
            JSONToken curr = parser.getCurrentToken();
            if (curr == JSONToken.START_OBJECT || curr == JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == JSONToken.END_OBJECT || curr == JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }

    public String code { get; set; }
    public String target { get; set; }
    public List<Details> details { get; set; }

    public class Details {
        public String code { get; set; }
        public Integer numericalCode { get; set; }
        public String message { get; set; }
        public String description { get; set; }
        public String faultCode { get; set; }
        public String helpLink { get; set; }
        public String severity { get; set; }
        public Details(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'code') {
                            code = parser.getText();
                        } else if (text == 'number') {
                            numericalCode = Integer.valueOf(parser.getText());
                        } else if (text == 'message') {
                            message = parser.getText();
                        } else if (text == 'description') {
                            description = parser.getText();
                        } else if (text == 'faultCode') {
                            faultCode = parser.getText();
                        } else if (text == 'helpLink') {
                            helpLink = parser.getText();
                        } else if (text == 'severity') {
                            severity = parser.getText();
                        } else {
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public JsonErrorParser(JSONParser parser) {
        while (parser.nextToken() != JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != JSONToken.VALUE_NULL) {
                    if (text == 'code') {
                        code = parser.getText();
                    } else if (text == 'target') {
                        target = parser.getText();
                    } else if (text == 'details') {
                        details = new List<Details>();
                        while (parser.nextToken() != JSONToken.END_ARRAY) {
                            details.add(new Details(parser));
                        }
                    } else {
                        consumeObject(parser);
                    }
                }
            }
        }
    }

    public static JsonErrorParser parse(String json) {
        return new JsonErrorParser(System.JSON.createParser(json));
    }
}
