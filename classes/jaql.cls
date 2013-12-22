public class jaql{
    public Enum Operator{Equals,NotEqualTo}
    private String m_jsonString;
    private String m_objectName;
    private List<Object> m_fieldMapList;
    private List<Criterion> m_criteria;
    private List<OrderBy> m_orderBy;
    private Sorter m_sorter;
    
    private jaql(String jsonString){
        m_jsonString = jsonString;
        m_criteria = new List<Criterion>();
        m_orderBy = new List<OrderBy>();
        initialize();
    }
    
    public static jaql jFrom(String jsonString){
      	return new jaql(jsonString);
    }
  
    public jaql jWhere(String property, Operator operator, String value){
        m_criteria.add(new Criterion(property,operator,value));
        return this;
    }
    
    public jaql jOrderBy(String property, Type classType){
    	m_orderBy.add(new OrderBy(property,classType));
        return this;
    }
    
    public jaql jOrderBy(String property, String direction, Type classType){
    	m_orderBy.add(new OrderBy(property,direction,classType));
        return this;
    }
    
    public List<Object> jSelect(Type classType){
        return deserialize(selectAsJSON(), classType);
    }
    
    /////////////////////////////////////////////////////////
    
    private List<Map<String,Object>> selectAndSort(){
        List<Map<String,Object>> selected = new List<Map<String,Object>>();
        for(Object fields : m_fieldMapList){
        	Map<String, Object> fieldMap = (Map<String,Object>)fields;
            
            Boolean bOK = true;
            for(Criterion c : m_criteria){
                String property = string.valueOf(fieldMap.get(c.property));
                if(c.operator == Operator.Equals){
                    if(property != c.value){bOK=false;}
                }else if(c.operator == Operator.NotEqualTo){
                    if(property == c.value){bOK=false;}
                }
            }
            if(bOK){selected.add(fieldMap);}
        }
        return sorted(selected);
    }
    
    private List<Map<String,Object>> sorted(List<Map<String,Object>> fieldMapList){
        for(Integer obIndex = m_OrderBy.size()-1; obIndex >= 0; obIndex--){
        	OrderBy thisOrderBy = m_OrderBy[obIndex];
            fieldMapList = sortBy(fieldMapList, thisOrderBy);
        }
        return fieldMapList;
    }
    
    private List<Map<String,Object>> sortBy(List<Map<String,Object>> fieldMapList, OrderBy ob){
        for(Integer i=0; i < fieldMapList.size(); i++){
            for(Integer j=i; j > 0; j--){
            	Map<String,Object> map1 = fieldMapList[j-1];
                Map<String,Object> map2 = fieldMapList[j];
                Object v1 = map1.get(ob.property);
                Object v2 = map2.get(ob.property);
                
                if(ob.direction.toUpperCase() == 'ASC'){
                    if(m_sorter.compare(v1,v2,ob.classType) > 0){
                        fieldMapList[j] = map1;
                        fieldMapList[j-1] = map2;
                    }
                }else if(ob.direction.toUpperCase() == 'DESC'){
                	if(m_sorter.compare(v1,v2,ob.classType) < 0){
                        fieldMapList[j] = map1;
                        fieldMapList[j-1] = map2;
                    }
                }
            }
        }
        return fieldMapList;
    }
    
    private String selectAsJSON(){
        return '{"' + m_objectName + '":' + JSON.serialize(selectAndSort()) + '}';
    }
    
    private void initialize(){
        Map<String,Object> root = (Map<String,Object>)JSON.deserializeUntyped(m_jsonString);
        m_objectName = (new list<string>(root.keySet()))[0];
        m_fieldMapList = (List<Object>)root.get(m_objectName);
        m_sorter = new Sorter();
    }
    
    private static List<Object> deserialize(String jsonString, Type classType){
    	List<Object> objects = new List<Object>();
        JSONParser parser = JSON.createParser(jsonString);
        
        while(parser.nextToken() != null){
            if(parser.getCurrentToken() == JSONToken.START_ARRAY){
                while(parser.nextToken() != null){
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT){
                        Object obj = parser.readValueAs(classType);
                        objects.add(obj);
                    }
                }
            }
        }
        return objects;
    }
    
    private class Criterion{
        public String property;
        public Operator operator;
        public String value;
        public Criterion(String aProperty, Operator anOperator, String aValue){
        	property = aProperty;
            operator = anOperator;
            value = aValue;
        }
    }
    
    private class OrderBy{
        public String property;
        public String direction;
        public Type classType;
        public OrderBy(String aProperty, Type aClassType){
            property = aProperty;
            direction = 'ASC';
            classType = aClassType;
        }
        public OrderBy(String aProperty, String aDirection, Type aClassType){
        	property = aProperty;
            direction = aDirection;
            classType = aClassType;
        }
    }
}