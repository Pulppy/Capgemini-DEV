public class PAD {
    
    private static PAD instance = null;
    public Map<String, Map<String, Boolean>> triggerStatus = null;

    public void reload() {
		triggerStatus.put(UserInfo.getUserId() + '', new Map<String, Boolean>());
        load();
    }
    
    private void load() {
        if (!triggerStatus.containsKey(UserInfo.getUserId() + '')) {
            triggerStatus.put(UserInfo.getUserId() + '', new Map<String, Boolean>());
        }
        String bypassApex = [SELECT ByPass_Trigger__c
                            FROM User 
                            WHERE Id = :UserInfo.getUserId() LIMIT 1].ByPass_Trigger__c;
        if (byPassApex != null) {
            List<String> triggerList = bypassApex.split(';');
            
            for (String triggerName : triggerList) {
                if (triggerName != null && triggerName != '') {
                    triggerStatus.get(UserInfo.getUserId() + '').put(triggerName, false);
                }
            }
        }
    }
   
                            
    public static PAD getInstance() {
        if (instance == null) { 
            instance = new PAD();
        	instance.triggerStatus = new Map<String, Map<String, Boolean>>();                
        }
        if (!instance.triggerStatus.containsKey(UserInfo.getUserId() + '')) {
            instance.load();
        }
        return instance;
    }
    
    public static void deactiveTrigger(String name) {
        getInstance().triggerStatus.get(UserInfo.getUserId() + '').put(name, false);
    }

    public static void activeTrigger(String name) {
        getInstance().triggerStatus.get(UserInfo.getUserId() + '').put(name, true);
    }

    
    public static boolean canRun(String name) {
        if (getInstance().triggerStatus.get(UserInfo.getUserId() + '').containsKey(name)) {
            System.debug('### HERE ###');
            return (getInstance().triggerStatus.get(UserInfo.getUserId() + '').get(name));
        }
        return true;
    }

}