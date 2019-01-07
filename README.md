## Request Tracker: Linking Incident Reports to Appropriate Incidents
Automating the process of linking old and future Incident Reports(IR) to appropriate Incident in Request Tracker for Incident Response (RTIR) based on the analyst's incident condition criterion. Two scripts (old_ir_incident.pl and ir2incident_linking.pl) cooperatively help achieve the objective.

#### Prerequisites
- Request Tracker privileges to create RT scrips.
- Relevant Custom field (in this case CF Name is **Incident Condition**) should exist in 'Incidents' RT Queue. You can create one through RT GUI console.
-  Custom field, *Incident Condition* should have the following selection values:
   - sig.name+dst.ip
   - sig.name+src.ip

#### Usage 
1. Please input appropriate values to the variables under CONFIGURATION section of the codes
2. Analyst should select one of the above values (refer point 3 in Prerequisites) for *Incident Condition* field while creating an Incident from an Incident Report/s in RTIR. Rest is all automated.

#### Note
1. Two scripts(*old_ir_incident.pl* and *ir2incident_linking.pl*) are deployed as a *scrip* in RT GUI.
2. Refer below *scrips* details to implement in RT GUI.

- **Scrip 1:**
    ```
    Description: <Anything you wish>
    Condition: On Create
    Action: User Defined
    Template: Blank
    Applies to: Incidents
    Custom condition:   Leave Blank
    Custom action preparation code: copy the code from <old_ir_incident.pl> and paste it here
    Custom action commit code:  return 1;
    ```
- **Scrip 2:**  as a *Batch* Stage
    ```
    Description: <Anything you wish>
    Condition: On Create
    Action: User Defined
    Template: Blank
    Applies to: IDS Alerts
    Custom condition: Leave Blank
    Custom action preparation code: return 1;
    Custom action commit code:  Copy the code from <ir2incident_linking.pl> and paste it here
    ```
3. You can accomodate more custom conditions in **Incidet Condition** custom field as per your needs. 