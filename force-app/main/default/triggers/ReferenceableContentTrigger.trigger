//Added by Ayush Kangar as part of CR#4238 - Start
trigger ReferenceableContentTrigger on crwd__Evidence__c (before insert, 
                                         before update) {
        new ReferenceableContentHandler().run();
}
//Added by Ayush Kangar as part of CR#4238 - End