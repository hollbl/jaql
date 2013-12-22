@isTest
public class jaqlTests{
    public static String myJSON = '{"pojo":['
								+ '{"f1":"3","f2":"A"}'
								+',{"f1":"1","f2":"A"}'
								+',{"f1":"2","f2":"B"}'
								+',{"f1":"2","f2":"A"}'
								+',{"f1":"1","f2":"B"}'
								+']}';

    public static testMethod void it_should_do_something(){
        List<Object> results = jaql.jFrom(myJSON)
            						.jSelect(pojo.class);
        system.assertEquals(5,results.size());
    }
    
    public static testMethod void it_should_do_find_the_objects_where_f1_equals_one(){
        List<Object> results = jaql.jFrom(myJSON)
            						.jWhere('f1',jaql.Operator.Equals,'1')
        							.jSelect(pojo.class);
        
        system.assertEquals(2,results.size());
    }
    
    public static testMethod void it_should_do_find_the_objects_where_f1_not_equal_to_one(){
        List<Object> results = jaql.jFrom(myJSON)
            						.jWhere('f1',jaql.Operator.NotEqualTo,'1')
        							.jSelect(pojo.class);
        
        system.assertEquals(3,results.size());
    }
    
    public static testMethod void it_should_do_find_the_objects_where_f1_not_equal_to_one_and_f2_equals_B(){
        List<Object> results = jaql.jFrom(myJSON)
            						.jWhere('f1',jaql.Operator.NotEqualTo,'1')
            						.jWhere('f2',jaql.Operator.Equals,'B')
        							.jSelect(pojo.class);
        
        pojo x = (pojo)results[0];
        system.assertEquals(1,results.size(),results);
        system.assertEquals(2,x.f1);
        system.assertEquals('B',x.f2);
    }
    
    public static testMethod void it_should_order_the_results_by_f1(){
        List<Object> results = jaql.jFrom(myJSON)
            						.jOrderBy('f1',Integer.class)
            						.jSelect(pojo.class);
        pojo first = (pojo)results[0];
        pojo last = (pojo)results[4];
        system.assertEquals(1,first.f1);
        system.assertEquals(3,last.f1);
    }
    
    public static testMethod void it_should_order_the_results_by_f1_and_f2(){
        List<Object> results = jaql.jFrom(myJSON)
            						.jOrderBy('f1',Integer.class)
            						.jOrderBy('f2',String.class)
            						.jSelect(pojo.class);
        pojo first = (pojo)results[0];
        pojo last = (pojo)results[4];
        system.assertEquals(1,first.f1);
        system.assertEquals('A',last.f2);
    }
    
    private class pojo{
    	public Integer f1 {get;set;}
    	public String f2 {get;set;}
    	public String f3 {get;set;}
	}
}