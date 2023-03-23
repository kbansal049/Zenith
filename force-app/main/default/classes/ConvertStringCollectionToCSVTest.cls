@isTest
public class ConvertStringCollectionToCSVTest {
	@isTest
    static void ConvertStringCollectionToCSVTest(){
        List<String> str = new List<String>{'Test', 'String'};
		ConvertStringCollectionToCSV.Request rq = new ConvertStringCollectionToCSV.Request();
		rq.stringCollection = str;

		List<ConvertStringCollectionToCSV.Request> lst = new List<ConvertStringCollectionToCSV.Request>();
		lst.add(rq);
		ConvertStringCollectionToCSV.execute(lst);
	}
}