public class GetHierarchy {
    public static Integer hierarchylevel = 1;
    public static Set<Id> finalIds = new Set<Id>();
    public static set<Id> getHierarchyfromUltimateParent(Set<Id> parentIds, Integer maxdepth, String Objname){
        Set<Id> currentIds = new Set<Id>();
        if(hierarchylevel < maxdepth && !parentIds.isEmpty()){
            finalIds.addAll(parentIds);
            for(SObject rec: Database.query('Select Id from ' + Objname + ' where ParentId in :parentIds')){
                currentIds.add(rec.Id);
            }
        }
        if(!currentIds.isEmpty()){
            hierarchylevel++;
            getHierarchyfromUltimateParent(currentIds, maxdepth, Objname);
        }
        return finalIds;
    }
}