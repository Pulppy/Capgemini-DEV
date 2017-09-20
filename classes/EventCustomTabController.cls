public class EventCustomTabController{
    public EventCustomTabController(){
    //String p = ApexPages.currentPage().getParameters().get('param');
    //if(p == null){
    //redirectToSomePage();

    }
    public PageReference redirectToSomePage(){
        // /one/one.app#/sObject/Event/home
        // dev-axamy-dev.cs5.force.com/one/one.app#/sObject/Event/home
        //PageReference result_page = Page.EventCustomTab;
        //result_page.getParameters().put('secret_param', 'secret_value');
        //PageReference result_page =  new PageReference('https://dev-axamy-dev.cs5.force.com/one/one.app#/sObject/Event/home');
        //UserInfo.getUiThemeDisplayed()
        //String theme= UserInfo.getUiThemeDisplayed();

        //Theme1�Obsolete Salesforce theme
        //Theme2�Salesforce Classic 2005 user interface theme
        //Theme3�Salesforce Classic 2010 user interface theme
        //Theme4d�Modern �Lightning Experience� Salesforce theme
        //Theme4t�Salesforce1 mobile Salesforce theme
        //00U/c?md0=2017&md1=4;'/home/home.jsp';
        String url;
        
        if(UserInfo.getUiThemeDisplayed().contains('Theme4'))
        {
            url = '/one/one.app#/sObject/Event/home';
        }else url = '/00U/c?md0';

        PageReference result_page =  new PageReference(url);
        result_page.setRedirect(true);
        return result_page;
    }
}