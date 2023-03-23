@isTest
public class ConvertFlowStringToCollectionTest {
	@isTest
    static void ConvertFlowStringToCollectionTest(){
		ConvertFlowStringToCollection.Request rq = new ConvertFlowStringToCollection.Request();
		rq.csvString = 'Test,String';
		List<ConvertFlowStringToCollection.Request> lst = new List<ConvertFlowStringToCollection.Request>();
		lst.add(rq);
		ConvertFlowStringToCollection.execute(lst);
	}
}