global class InsuranceCoveragePicklist implements omnistudio.VlocityOpenInterface {
	
    public Boolean invokeMethod(String methodName, Map < String, Object > input, Map < String, Object > outMap, Map < String, Object > options) {
        if (methodName.equals('populatePicklist')) {
            populatePicklist(input, outMap, options);
        }
        return true;
    }
    // Get All Relationship Types for Account when the Omniscript is compiled.
    public void populatePicklist(Map < String, Object > input, Map < String, Object > outMap, Map < String, Object > options) {
        List < Map < String, String >> UIoptions = new List < Map < String, String >> ();
        for (InsurancePolicyCoverage coverage: [Select CoverageName , Id FROM InsurancePolicyCoverage ]) {
            Map < String, String > tempMap = new Map < String, String > ();
            tempMap.put('name', coverage.Id);
            // Language Independent
            tempMap.put('value', coverage.CoverageName);
            // Displayed in Picklist
            UIoptions.add(tempMap);
        }
        outMap.put('options', UIoptions);
    }
}