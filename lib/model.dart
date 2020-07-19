//enum EnvelopeDefaultsUniqueRecipientSelectorType {
//
//}

enum RecipientType {
  recipientTypeNotSet,
  recipientTypeAgent,
  recipientTypeCC,
  recipientTypeCertifiedDelivery,
  recipientTypeEditor,
  recipientTypeIntermediary,
  recipientTypeInPersonSigner,
  recipientTypeSigner,
}

class CustomFields {

}

class RecipientDefault {
  String inPersonSignerName;
  String recipientEmail;
  String recipientId;
  String recipientName;
  String recipientRoleName;
//  String recipientSelectorType;
  RecipientType recipientType;
  bool removeRecipient;

  RecipientDefault({ this.inPersonSignerName, this.recipientEmail, this.recipientId, this.recipientName, this.recipientRoleName, this.recipientType, this.removeRecipient = false });

  toMap() {
    return {
      "inPersonSignerName": inPersonSignerName,
      "recipientEmail": recipientEmail,
      "recipientId": recipientId,
      "recipientName": recipientName,
      "recipientRoleName": recipientRoleName,
      "recipientType": recipientType.index,
      "removeRecipient": removeRecipient,
    };
  }
}

class EnvelopeDefaults {
  String emailBlurb;
  String emailSubject;
  String envelopeTitle;
  List<RecipientDefault> recipientDefaults;
  Map<String, String> tabValueDefaults;

  EnvelopeDefaults({ this.emailBlurb, this.emailSubject, this.envelopeTitle, this.recipientDefaults, this.tabValueDefaults });

  toMap() {
    return {
      "emailBlurb": emailBlurb,
      "emailSubject": emailSubject,
      "envelopeTitle": envelopeTitle,
      "recipientDefaults": recipientDefaults?.map((recip) {
        return recip.toMap();
      })?.toList(),
      "tabValueDefaults": tabValueDefaults,
    };
  }
}

