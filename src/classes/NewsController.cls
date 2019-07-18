public class NewsController {
    public static News newsList {get;set;}
    public static HttpResponse response;
    public static Map<String, News_Endpoints__c> endpointMap {get;set;}
    public static String newsSource {get;set;}
    public static String sourceName {get;set;}
    
    static{
        endpointMap = News_Endpoints__c.getAll();
    }
    
    public static void onLoad(){
        newsSource = ApexPages.currentPage().getParameters().get('source');//'TimesOfIndia';
        system.debug('newsSource '+newsSource );
        //sourceName = 'The Times of India';
        getNews();
    }
    
    public static PageReference getNews(){
        News_Endpoints__c endptObj = endpointMap.get(newsSource);
        String endpoint = endptObj.Url__c;
        if(String.isNotBlank(endpoint)){
            makeCallout(endpoint);
            system.debug('sourceName--'+sourceName);
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No endpoint url found. Please add it to the custom settings'));
        }
        return null;
    }
    
    public static HttpResponse makeCallout(String endpoint){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            system.debug(response.getBody());
            newsList = (News) JSON.deserialize(response.getBody(), News.class);
            Source src = newsList.articles != null && newsList.articles.size() > 0 ? newsList.articles.get(0).source : null;
            system.debug('src--'+src);
            sourceName = src != null ? src.name : '';
        }else{
            system.debug(response.getBody());
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,String.valueOf(results.get('message')))); 
        }
        return response;
    }
    
    public class News {
        public List<Article> articles {get;set;}
    }
    
    public class Article {
        public String title {get;set;}
        public String url {get;set;}
        public Source source {get;set;}
    }
    
    public class Source {
        public String name {get;set;}
    }
}