Class shvarov.oauth.google.security Extends %RegisteredObject
{

ClassMethod SetupSecurity(db as %String="USER") As %Status
{
    Set tSC = $$$OK
    d ..IntroduceSQLRole()
    d ..AddRole()
    d ..AddCORS()
    d ..IntroduceRoleDBRead(db)
    set rolename="DB_"_db_"_Read"
    d ..AddRoleToUser(,rolename)
    Quit tSC
}

/// verifies a Google JWT token
/// use __getitem__ to refer to dict keys of the id_info, e.g. write info."__getitem__"("sub")
ClassMethod VerifyGoogleJWT(idtoken, clientid) [ Language = python ]
{
from google.oauth2 import id_token
from google.auth.transport import requests
import traceback
import iris

try:
    # Verify the integrity and decode the token
    id_info = id_token.verify_oauth2_token(idtoken, requests.Request(), clientid)

    # id_info is a dictionary with the token claims (e.g. sub, email, name, etc.)
    return id_info
except ValueError as e:
        # Invalid token
    errobj=iris.cls("%Exception.General")._New(str(e),"Google JWT Verification Failed")
    stack_trace_list = traceback.format_tb(e.__traceback__)
    if stack_trace_list:
        last_instruction_line = stack_trace_list[-1].strip()
        errobj.Location = last_instruction_line
    errobj.Log()
    print("Token verification failed:", e)
    return None
}

ClassMethod IntroduceSQLRole() As %Status
{
    &SQL(CREATE ROLE google_auth)
    If SQLCODE '= 0 {
        Quit $$$ERROR($$$GeneralError, "Error creating role: "_SQLCODE)
    }
    &SQL(GRANT SELECT,INSERT,UPDATE,DELETE on shvarov_travel.trips to travel)
    If SQLCODE '= 0 {
        Quit $$$ERROR($$$GeneralError, "Error granting privileges: "_SQLCODE)
    }
    Quit $$$OK
}

ClassMethod IntroduceRoleDBRead(db as %String="USER") As %Status
{
    set rolename="DB_"_db_"_Read"
    
    
    #; &SQL(CREATE ROLE DB_USER_Read)
    #; If SQLCODE '= 0 {
    #;     Quit $$$ERROR($$$GeneralError, "Error creating role: "_SQLCODE)
    #; }

    // Change to the %SYS namespace.
    new $NAMESPACE
    set $NAMESPACE="%SYS"
    Set sc = ##class(Security.Roles).Create(rolename,"Role for OAuth app","%DB_"_db_":R")
 
    //set properties("Resources")="%DB_USER:R"
 
    //Set sc = ##class(Security.Roles).Modify("DB_USER_Read",.properties)
    If $$$ISERR(sc) {
        Quit $$$ERROR($$$GeneralError, "Error modifying role: "_sc)
    }
    return sc
}

ClassMethod AddRoleToUser(user = "CSPSystem", role = "DB_USER_Read") As %Status
{
    // Change to the %SYS namespace.
    new $NAMESPACE
    set $NAMESPACE="%SYS"

    set status=##class(Security.Users).Get(user, .MyUserProps)
    set $p(MyUserProps("Roles"),",",*)=role
    set status=##class(Security.Users).Modify(user,.MyUserProps)

    // Announce success.
    if $$$ISOK(status) {
        write !, "Roles for the user "_user_" were successfully modified."
    }
    Quit status
}

ClassMethod AddRole(appname = "/auth", approle = "google_auth") As %Status
{
    // Change to the %SYS namespace.
    new $NAMESPACE
    set $NAMESPACE="%SYS"

    set status=##class(Security.Applications).Get(appname, .MyAppProps)
    set MyAppProps("MatchRoles")=MyAppProps("MatchRoles")_":"_approle

    set status=##class(Security.Applications).Modify(appname,.MyAppProps)

    // Announce success.
    if $$$ISOK(status) {
        write !, "Roles were successfully modified."
    }
    Quit status
}

ClassMethod AddCORS(appname = "/auth") As %Status
{
    // Change to the %SYS namespace.
    new $NAMESPACE
    set $NAMESPACE="%SYS"

    set status=##class(Security.Applications).Get(appname, .MyAppProps)
    set MyAppProps("CorsAllowlist")="*"
    set MyAppProps("CorsCredentialsAllowed")=1
    set MyAppProps("CorsHeadersList")="Content-Type,Authorization,X-Requested-With,Accept,Origin,Access-Control-Request-Method,Access-Control-Request-Headers"
    set status=##class(Security.Applications).Modify(appname,.MyAppProps)

    // Announce success.
    if $$$ISOK(status) {
        write !, "CORS methods were successfully added to."_appname
    }
    Quit status
}

}
