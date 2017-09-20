global class MAPReportingBatch implements Database.Batchable<sObject>, Database.Stateful{

	private Integer year;
	private Integer lastYear;
	private Integer month;
	private final List<String> monthNames = new List<String>{'', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};

	global MAPReportingBatch(Integer year, Integer month) {
		this.year = year;
		this.month = month;
		this.lastYear = year - 1;
	}

	// Aggregate from KPI Audit Trail to Agent KPI
	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug([SELECT Count() FROM KPI_Audit_Trail__c WHERE CALENDAR_YEAR(Data_Extract_Date__c) = :this.year AND CALENDAR_MONTH(Data_Extract_Date__c) = :this.month]);

		return Database.getQueryLocator('SELECT Id, Policy__r.Producing_Agent__c, Premium_Type__c,' +
			'Basic_Rider__c, Transaction_Type__c, FY_Premium__c, Issuance_Date__c, Policy__c, FYP__c ' +
			'FROM KPI_Audit_Trail__c ' +
			'WHERE CALENDAR_MONTH(Data_Extract_Date__c) = :month ' +
			'AND CALENDAR_YEAR(Data_Extract_Date__c) = :year');
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		String strYear 			= String.valueOf(year);										// Current year in String
		String currentMonth 	= monthNames[this.month];									// Current Month that the batch is processing
		String pviFieldName 	= 'PVI_' + currentMonth + '__c';							// Field to be retrieved and edited for PVI
		String pviFieldNameLY	= 'PVI_Last_' + currentMonth + '__c';						// Field to be retrieved and edited for last year's PVI
		String nocFieldName 	= 'No_of_Policies_' + currentMonth + '__c';					// Field to be retrieved and edited for NoC
		String nocFieldNameLY	= 'No_of_Policies_Last_' + currentMonth + '__c';			// Field to be retrieved and edited for last year's NOC
		String fypFieldName		= 'FYP_' + currentMonth + '__c';							// Field to be retrieved and edited for FYP
		String fypFieldnameLY	= 'FYP_Last_' + currentMonth + '__c';						// Field to be retrieved and edtied for last year's FYP

		Map<Id, KPI_Audit_Trail__c> kpiAuditTrails = new Map<Id, KPI_Audit_Trail__c>();		// Map to sort scope of KPI Audit Trails
		Set<Id> policyIds 		= new Set<Id>();											// IDs of Policies referenced by KPI Audit Trails
		Set<Id> partnerRoleIds  = new Set<Id>();											// IDs of Partner Roles referenced by KPI Audit Trails

		for(sObject obj: scope) {
			KPI_Audit_Trail__c kpiAuditTrail = (KPI_Audit_Trail__c) obj;
			kpiAuditTrails.put(kpiAuditTrail.Id, kpiAuditTrail);

			policyIds.add(kpiAuditTrail.Policy__c);
			partnerRoleIds.add(kpiAuditTrail.Policy__r.Producing_Agent__c);
		}

		// Get a list of policies from the list of KPI Audit Trails
		Map<Id, Policy__c> producingAgentPolicies = new Map<Id, Policy__c>([SELECT Id, Producing_Agent__c, Total_KPI_PVI__c FROM Policy__c WHERE Id IN :policyIds]);
		// Get a list of Partner Roles from the list of Policies
		// Map<Id, Partner_Role__c> partnerRoles = new Map<Id, Partner_Role__c>([SELECT Id FROM Partner_Role__c WHERE ]);
		// Get a list of Agent_KPI__c from the list of Partner Roles
		Map<Id, Agent_KPI__c> partnerRoleToAgentKPIs = new Map<Id, Agent_KPI__c>();
		List<sObject> existingAgentKPIs = Database.query('SELECT Agent_Code__c, Target_of_The_Year__c, Year__c, External_Key__c,' +
			' MTD_PVI_Growth__c, YTD_PVI__c, Previous_Year_YTD_PVI__c, YTD_PVI_Growth__c, ' +
			pviFieldName + ',' + pviFieldNameLY + ',' + nocFieldName + ',' + nocFieldNameLY + ',' + fypFieldName + ',' + fypFieldnameLY +
			' FROM Agent_KPI__c WHERE Agent_Code__c IN :partnerRoleIds AND (Target_of_The_Year__r.Year__c = :strYear OR Year__c = :strYear)');
		if(existingAgentKPIs.size() > 0) {
			for(sObject obj: existingAgentKPIs) {
				Agent_KPI__c agentKPI = (Agent_KPI__c) obj;
				partnerRoleToAgentKPIs.put(agentKPI.Agent_Code__c, agentKPI);
			}
		}
		// Get a list of Targets based on Partner Roles
		Map<Id, Target__c> partnerRoleToTargets = new Map<Id, Target__c>();
		for(Target__c t : [SELECT Partner_Role__c FROM Target__c WHERE Partner_Role__c IN :partnerRoleIds]) {
			partnerRoleToTargets.put(t.Partner_Role__c, t);
		}

		System.debug(producingAgentPolicies);
		System.debug(partnerRoleToAgentKPIs);
		System.debug(kpiAuditTrails);
		System.debug(policyIds);

		Map<Id, Policy__c> aggregatedPolicies		= new Map<Id, Policy__c>();		// Maps policies that have been aggregated to be updated at the end of the batch
		Map<Id, Double> partnerRoleToGrossPVI 		= new Map<Id, Double>();		// Maps partner role IDs to Gross PVI (Gross PVI for each agent)
		Map<Id, Double> partnerRoleToGrossPVI_LY 	= new Map<Id, Double>();		// Maps partner role IDs to Last Year's Gross PVI (Last Year's Gross PVI for each agent)
		Map<Id, Double> partnerRoleToCoolOffPVI 	= new Map<Id, Double>();		// Maps partner role IDs to Cool Off PVI (Cool Off PVI for each agent)
		Map<Id, Integer> partnerRoleToGrossNOC		= new Map<Id, Integer>();		// Maps partner role IDs to Gross NOC (Gross NOC for each agent)
		Map<Id, Integer> partnerRoleToGrossNOC_LY	= new Map<Id, Integer>();		// Maps partner role IDs to Last Year's Gross NOC (Last Year's Gross NOC for each agent)
		Map<Id, Integer> partnerRoleToCoolOffNOC	= new Map<Id, Integer>();		// Maps partner role IDs to Cool Off NOC (Cool Off NOC for each agent)
		Map<Id, Double> partnerRoleToFYP			= new Map<Id, Double>();		// Maps partner role IDs to FYP (FYP for each agent)
		Map<Id, Double> partnerRoleToFYP_LY			= new Map<Id, Double>();		// Maps partner role IDs to Last Year's FYP (Last Year's FYP for each agent)

		// Aggregate KPI Audit Trails for PVI and NOC to Agent_KPI__c and Policy__c
		for(KPI_Audit_Trail__c at: kpiAuditTrails.values()) {
			Id agentId = at.Policy__r.Producing_Agent__c;
			Agent_KPI__c agentKPI = partnerRoleToAgentKPIs.get(agentId);
			if(agentKPI == null) {
				agentKPI = new Agent_KPI__c(
					Agent_Code__c = agentId,
					Target_of_The_Year__c = partnerRoleToTargets.get(agentId) == null ? null : partnerRoleToTargets.get(agentId).Id,
					Year__c =  strYear
				);
				partnerRoleToAgentKPIs.put(agentId, agentKPI);
			}

			// Aggregate PVI based on formula for Gross PVI and Cool Off PVI
			if(at.Transaction_Type__c == 'P' && at.Issuance_Date__c.month() == this.month ) {
				if(at.Issuance_Date__c.year() == this.year) {
					Double grossPVI = partnerRoleToGrossPVI.get(agentId);
					if(grossPVI == null) {
						grossPVI = 0;
					}
					partnerRoleToGrossPVI.put(agentId, grossPVI + at.FY_Premium__c);

					// Aggregate PVI to Policy__c
					aggregatePVIToPolicy(producingAgentPolicies.get(at.Policy__c), at.FY_Premium__c);
					aggregatedPolicies.put(at.Policy__c, producingAgentPolicies.get(at.Policy__c));
				} else if(at.Issuance_Date__c.year() == this.lastYear) {
					Double grossPVI = partnerRoleToGrossPVI_LY.get(agentId);
					if(grossPVI == null) {
						grossPVI = 0;
					}
					partnerRoleToGrossPVI_LY.put(agentId, grossPVI + at.FY_Premium__c);
				}
			} else if(at.Transaction_Type__c == 'C') {
				Double coolOffPVI = partnerRoleToCoolOffPVI.get(agentId);
				if(coolOffPVI == null) {
					coolOffPVI = 0;
				}
				partnerRoleToCoolOffPVI.put(agentId, coolOffPVI + at.FY_Premium__c);

				// Aggregate PVI to Policy__c
				aggregatePVIToPolicy(producingAgentPolicies.get(at.Policy__c), at.FY_Premium__c);
				aggregatedPolicies.put(at.Policy__c, producingAgentPolicies.get(at.Policy__c));
			}

			// Aggregate NOC based on formula for Gross NOC and Cool Off NOC
			if(at.Transaction_Type__c == 'P' && at.Premium_Type__c == 'B' && at.Premium_Type__c == '' && at.Basic_Rider__c == 1 &&
				at.Issuance_Date__c.month() == this.month) {

				if(at.Issuance_Date__c.year() == this.year) {
					Integer grossNOC = partnerRoleToGrossNOC.get(agentId);
					if(grossNOC == null) {
						grossNOC = 0;
					}
					partnerRoleToGrossNOC.put(agentId, grossNOC + 1);
				} else if(at.Issuance_Date__c.year() == this.lastYear) {
					Integer grossNOC = partnerRoleToGrossNOC_LY.get(agentId);
					if(grossNOC == null) {
						grossNOC = 0;
					}
					partnerRoleToGrossNOC_LY.put(agentId, grossNOC + 1);
				}
			} else if(at.Transaction_Type__c == 'C' && at.Premium_Type__c == 'B' && at.Premium_Type__c == '' && at.Basic_Rider__c == 1) {
				Integer coolOffNOC = partnerRoleToCoolOffNOC.get(agentId);
				if(coolOffNOC == null) {
					coolOffNOC = 0;
				}
				partnerRoleToCoolOffNOC.put(agentId, coolOffNOC + 1);
			}

			// Aggregate FYP
			if(at.Issuance_Date__c.year() == this.year) {
				Double fyp = partnerRoleToFYP.get(agentId);
				if(fyp == null) {
					fyp = 0;
				}
				partnerRoleToFYP.put(agentId, fyp + at.FYP__c);
			} else if(at.Issuance_Date__c.year() == this.lastYear) {
				Double fypLY = partnerRoleToFYP_LY.get(agentId);
				if(fypLY == null) {
					fypLY = 0;
				}
				partnerRoleToFYP_LY.put(agentId, fypLY + at.FYP__c);
			}
		}

		System.debug(partnerRoleToGrossPVI);
		System.debug(partnerRoleToCoolOffPVI);
		System.debug(aggregatedPolicies);
		System.debug(partnerRoleToFYP);
		System.debug(partnerRoleToFYP_LY);

		// Aggregate to Agent_KPI__c
		for(Id agentId: partnerRoleToAgentKPIs.keySet()) {
			Agent_KPI__c agentKPI 	= partnerRoleToAgentKPIs.get(agentId);

			// Aggregate PVI to Agent_KPI__c
			Double grossPVI 		= partnerRoleToGrossPVI.get(agentId) == null ? 0 : partnerRoleToGrossPVI.get(agentId);
			Double coolOffPVI 		= partnerRoleToCoolOffPVI.get(agentId) == null ? 0 : partnerRoleToCoolOffPVI.get(agentId);
			Double grossPVI_LY 		= partnerRoleToGrossPVI_LY.get(agentId) == null ? 0 : partnerRoleToGrossPVI_LY.get(agentId);

			// Aggregate PVI MTD
			agentKPI.put(pviFieldName, grossPVI + coolOffPVI);
			// Aggregate Last Year's PVI
			agentKPI.put(pviFieldNameLY, grossPVI_LY + coolOffPVI);

			// Aggregate NOC to Agent_KPI__c
			Double grossNOC 		= partnerRoleToGrossNOC.get(agentId) == null ? 0 : partnerRoleToGrossNOC.get(agentId);
			Double coolOffNOC 		= partnerRoleToCoolOffNOC.get(agentId) == null ? 0 : partnerRoleToCoolOffNOC.get(agentId);
			Double grossNOC_LY 		= partnerRoleToGrossNOC_LY.get(agentId) == null ? 0 : partnerRoleToGrossNOC_LY.get(agentId);

			// Aggregate NoC MTD
			agentKPI.put(nocFieldName, grossNOC + coolOffNOC);
			// Aggregate Last Year's NoC
			agentKPI.put(nocFieldNameLY, grossNOC_LY + coolOffNOC);

			// Aggregate FYP to Agent_KPI__c
			Double fyp 				= partnerRoleToFYP.get(agentId) == null ? 0 : partnerRoleToFYP.get(agentId);
			Double fypLY 			= partnerRoleToFYP_LY.get(agentId) == null ? 0 : partnerRoleToFYP_LY.get(agentId);

			// Aggregate FYP MTD
			agentKPI.put(fypFieldName, fyp);
			// Aggregate Last Year's FYP MTD
			agentKPI.put(fypFieldnameLY, fypLY);
		}

		System.debug(partnerRoleToAgentKPIs);
		upsert partnerRoleToAgentKPIs.values();

		if(aggregatedPolicies.size() > 0) {
			upsert aggregatedPolicies.values();
		}
	}

	global void aggregatePVIToPolicy(Policy__c policyToAggregate, Decimal amount) {
		if(policyToAggregate.Total_KPI_PVI__c == null) {
			policyToAggregate.Total_KPI_PVI__c = 0;
		}

		policyToAggregate.Total_KPI_PVI__c += amount;

		return;
	}

	global void finish(Database.BatchableContext BC) {

	}

}