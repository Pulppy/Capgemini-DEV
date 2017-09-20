public without sharing class AP12TargetAssignmentToLead {
/* 
------------------------------------------------------------
-- - Name          : AP12TargetAssignmentToLead 
-- - Author        : Binh Dang
-- - Description   : trigger handle class for execution on Lead (each time it is created/edited with a change in the OwnerId status)
-- - Ticket:	   : ML-173 --Target Assignment to Lead
-- Maintenance History: 
--
-- Date         Name     Version  Remarks 
-- -----------  -------  ------ -  -----------------------------
-- 29-May-2017  Binh Dang  1.0    Initial version
-- 19-Jun-2017	Genio W    1.1	  Bulkified the code and add new conditions for Target Assignments
------------------------------------------------------------
*/
	/**
	* function: insertTargetAssignment
	* Inserts target to newly created lead.
	* Parameters: List of leads, Map of User Id to Agent Code
	*/
	public static void insertTargetAssignment(List<Lead> existingLeads, Map<Id, String> userIdToAgentCode) {
		String year = String.valueOf(Date.today().year());
		Set<Id> parentRoleIds = new Set<Id>();
		Set<Id> parentOfParentRoleIds = new Set<Id>();
		Map<String, Partner_Role__c> agentCodeToPartnerRole = new Map<String, Partner_Role__c>();
		List<Partner_Role__c> partnerRoles = [SELECT Id, Level_Num__c, Agent_Code__c, Parent_Code__c, Parent_Role__c,
												Parent_Role__r.Id, Parent_Role__r.Level_Num__c, Parent_Role__r.Parent_Role__c,
												Parent_Role__r.Parent_Role__r.Id, Parent_Role__r.Parent_Role__r.Level_Num__c,
												(SELECT Id FROM Performance_Summaries__r
													WHERE Year__c = :year AND
													(RecordType.Name ='Performance & Target' OR RecordType.Name ='Performance & Target (Submitted)'))
												FROM Partner_Role__c
												WHERE Agent_Code__c IN :userIdToAgentCode.values()];

		// Identify all Parent Roles (for filling up ASM and RSM targets)
		for(Partner_Role__c pr: partnerRoles) {
			agentCodeToPartnerRole.put(pr.Agent_Code__c, pr);
			if(pr.Parent_Role__r != null) {
				parentRoleIds.add(pr.Parent_Role__c);
				if(pr.Parent_Role__r.Parent_Role__r != null) {
					parentOfParentRoleIds.add(pr.Parent_Role__r.Parent_Role__c);
				}
			}
		}
		// Add all parentRoleIds together to query it once
		parentRoleIds.addAll(parentOfParentRoleIds);

		// Query Parent Roles for ASM and RSM Targets
		Map<Id, Partner_Role__c> parentRoleMap = new Map<Id, Partner_Role__c>([SELECT Id, Level_Num__c, Parent_Code__c, Parent_Role__c,
												Parent_Role__r.Id, Parent_Role__r.Level_Num__c, Parent_Role__r.Parent_Role__c,
												Parent_Role__r.Parent_Role__r.Id, Parent_Role__r.Parent_Role__r.Level_Num__c,
												(SELECT Id FROM Performance_Summaries__r
													WHERE Year__c = :year AND
													(RecordType.Name ='Performance & Target' OR RecordType.Name ='Performance & Target (Submitted)'))
												FROM Partner_Role__c
												WHERE Id IN :parentRoleIds]);

		System.debug(partnerRoles);
		System.debug(year);
		System.debug(parentRoleIds);
		System.debug(parentOfParentRoleIds);
		System.debug(parentRoleMap);

		for(Lead l: existingLeads) {
			String agentCode = userIdToAgentCode.get(l.OwnerId);
			if(agentCode != null) {
				Partner_Role__c pr = agentCodeToPartnerRole.get(agentCode);
				if(pr != null) {
					if(pr.Level_Num__c == 2) {
						// For Level 2, Fill up RSM and leave others blank
						if(pr.Performance_Summaries__r.size() > 0) {
							l.Target_RSM_AM__c = pr.Performance_Summaries__r[0].Id;
						}
						l.Target__c = null;
						l.Target_ASM_UM__c = null;
					} else if(pr.Level_Num__c == 3) {
						// For level 3, Fill up ASM and RSM if possible and leave Target blank
						l.Target__c = null;
						if(pr.Performance_Summaries__r.size() > 0) {
							l.Target_ASM_UM__c = pr.Performance_Summaries__r[0].Id;
						}
						if(pr.Parent_Role__c != null && parentRoleMap.get(pr.Parent_Role__c).Performance_Summaries__r.size() > 0) {
							l.Target_RSM_AM__c = parentRoleMap.get(pr.Parent_Role__c).Performance_Summaries__r[0].Id;
						}
					} else if(pr.Level_Num__c == 4) {
						// For Level 4, Fill up Target, ASM, and RSM if possible
						if(pr.Performance_Summaries__r.size() > 0) {
							l.Target__c = pr.Performance_Summaries__r[0].Id;
						}
						if(pr.Parent_Role__c != null) {
							if(parentRoleMap.get(pr.Parent_Role__c).Performance_Summaries__r.size() > 0) {
								l.Target_ASM_UM__c = parentRoleMap.get(pr.Parent_Role__c).Performance_Summaries__r[0].Id;
							}
							if(pr.Parent_Role__r.Parent_Role__c != null && parentRoleMap.get(pr.Parent_Role__r.Parent_Role__c).Performance_Summaries__r.size() > 0) {
								l.Target_RSM_AM__c = parentRoleMap.get(pr.Parent_Role__r.Parent_Role__c).Performance_Summaries__r[0].Id;
							}
						}
					}

					System.debug(l);
				}
			}
		}
	}

	/**
	* function
	*
	*
	*/
	public static void updateTargetAssignment(Map<String,Lead> mapWithAgentCodetoLead)
	{
		system.debug('## Start AP12 AP12TargetAssignmentToLead');
				
		Set<String> agentCodes = new Set<String>();
		Set<String> leadYears = new Set<String>();
		Set<Id> parentRoleIds = new Set<Id>();
		Set<Id> parentOfParentRoleIds = new Set<Id>();
		Map<String, Partner_Role__c> agentCodeToPartnerRole = new Map<String, Partner_Role__c>();

		for(String key: mapWithAgentCodetoLead.keySet()) {
			agentCodes.add(key.substringAfterLast(';'));
			leadYears.add(String.valueOf(mapWithAgentCodetoLead.get(key).CreatedDate.year()));
		}

		List<Partner_Role__c> partnerRoles = [SELECT Id, Level_Num__c, Agent_Code__c, Parent_Code__c, Parent_Role__c,
												Parent_Role__r.Id, Parent_Role__r.Level_Num__c, Parent_Role__r.Parent_Role__c,
												Parent_Role__r.Parent_Role__r.Id, Parent_Role__r.Parent_Role__r.Level_Num__c,
												(SELECT Id FROM Performance_Summaries__r
													WHERE Year__c IN :leadYears AND
													(RecordType.Name ='Performance & Target' OR RecordType.Name ='Performance & Target (Submitted)'))
												FROM Partner_Role__c
												WHERE Agent_Code__c IN :agentCodes];

		for(Partner_Role__c pr: partnerRoles) {
			agentCodeToPartnerRole.put(pr.Agent_Code__c, pr);
			if(pr.Parent_Role__r != null) {
				parentRoleIds.add(pr.Parent_Role__c);
				if(pr.Parent_Role__r.Parent_Role__r != null) {
					parentOfParentRoleIds.add(pr.Parent_Role__r.Parent_Role__c);
				}
			}
		}
		// Add all parentRoleIds together to query it once
		parentRoleIds.addAll(parentOfParentRoleIds);

		System.debug(agentCodes);
		System.debug(leadYears);
		System.debug(parentRoleIds);
		System.debug(parentOfParentRoleIds);
		System.debug(agentCodeToPartnerRole);

		Map<Id, Partner_Role__c> parentRoleMap = new Map<Id, Partner_Role__c>([SELECT Id, Level_Num__c, Parent_Code__c, Parent_Role__c,
												Parent_Role__r.Id, Parent_Role__r.Level_Num__c, Parent_Role__r.Parent_Role__c,
												Parent_Role__r.Parent_Role__r.Id, Parent_Role__r.Parent_Role__r.Level_Num__c,
												(SELECT Id FROM Performance_Summaries__r
													WHERE Year__c = :leadYears AND
													(RecordType.Name ='Performance & Target' OR RecordType.Name ='Performance & Target (Submitted)'))
												FROM Partner_Role__c
												WHERE Id IN :parentRoleIds]);
	
		for(String key: mapWithAgentCodetoLead.keySet()) {
			Lead l = mapWithAgentCodetoLead.get(key);
			String agentCode = key.substringAfterLast(';');
			if(!String.valueOf(l.OwnerId).startsWith('005')) {
				// If Lead owner is not a User, Remove all assigned targets
				l.Target_RSM_AM__c = null;
				l.Target__c = null;
				l.Target_ASM_UM__c = null;
			} else if(agentCode != null) {
				// Only set targets if lead owner is a User

				Partner_Role__c pr = agentCodeToPartnerRole.get(agentCode);
				if(pr != null) {
					if(pr.Level_Num__c == 2) {
						if(pr.Performance_Summaries__r.size() > 0) {
							l.Target_RSM_AM__c = pr.Performance_Summaries__r[0].Id;
						} else {
							l.Target_RSM_AM__c = null;
						}
						l.Target__c = null;
						l.Target_ASM_UM__c = null;
					} else if(pr.Level_Num__c == 3) {
						l.Target__c = null;
						if(pr.Performance_Summaries__r.size() > 0) {
							l.Target_ASM_UM__c = pr.Performance_Summaries__r[0].Id;
						} else {
							l.Target_ASM_UM__c = null;
						}
						if(pr.Parent_Role__c != null && parentRoleMap.get(pr.Parent_Role__c).Performance_Summaries__r.size() > 0) {
							l.Target_RSM_AM__c = parentRoleMap.get(pr.Parent_Role__c).Performance_Summaries__r[0].Id;
						} else {
							l.Target_RSM_AM__c = null;
						}
					} else if(pr.Level_Num__c == 4) {
						if(pr.Performance_Summaries__r.size() > 0) {
							l.Target__c = pr.Performance_Summaries__r[0].Id;
						} else {
							l.Target__c = null;
						}
						if(pr.Parent_Role__c != null) {
							if(parentRoleMap.get(pr.Parent_Role__c).Performance_Summaries__r.size() > 0) {
								l.Target_ASM_UM__c = parentRoleMap.get(pr.Parent_Role__c).Performance_Summaries__r[0].Id;
							} else {
								l.Target_ASM_UM__c = null;
							}
							if(pr.Parent_Role__r.Parent_Role__c != null && parentRoleMap.get(pr.Parent_Role__r.Parent_Role__c).Performance_Summaries__r.size() > 0) {
								l.Target_RSM_AM__c = parentRoleMap.get(pr.Parent_Role__r.Parent_Role__c).Performance_Summaries__r[0].Id;
							} else {
								l.Target_RSM_AM__c = null;
							}
						}
					}

					System.debug(l);
				}
			}
		}
	}// end 
 
}//end of Class