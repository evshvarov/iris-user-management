/// Handles user authentication via Google OAuth 2.0<br/>
/// Business logic class defined by OpenAPI in dc.google.auth.spec<br/>
/// Updated Jun 27, 2025 11:35:22
Class shvarov.oauth.google.impl Extends %REST.Impl [ ProcedureBlock ]
{

/// If ExposeServerExceptions is true, then details of internal errors will be exposed.
Parameter ExposeServerExceptions = 1;

Parameter SessionGlobal = "^GoogleAuthSession";

ClassMethod StartUserSession(userid = 1, idtoken = "token", expires = 300) As %Status
{
    set gn=$name(@..#SessionGlobal)
    set @gn@(userid,$H,"idtoken")=idtoken 
    set @gn@(userid,$H,"expires")=expires
    Return $$$OK
}

ClassMethod GetUserSession(idtoken = "token") As %Integer
{
    set gn=$name(@..#SessionGlobal)
    set clientId = $SYSTEM.Util.GetEnviron("GOOGLE_CLIENT_ID")
    set userinfo=##class(shvarov.oauth.google.security).VerifyGoogleJWT(idtoken, clientId)
    if userinfo = "" {
        d ..%SetStatusCode(401)
        d ..%SetHeader("X-Error", "Invalid ID token")
        return 0
    }
    set userid = userinfo."__getitem__"("sub")
    #; if '$data(@gn@(userid)) {
    #;     return 0
    #; }
    return userid
}

ClassMethod SetupSessionTimer(idtoken, expires = 300) As %Status
{
    set gn=$name(^GoogleAuthSession)
    if '$data(@gn@(idtoken)) {
        return $$$ERROR()
    }
    set @gn@(idtoken,"expires")=expires
    set @gn@(idtoken,"date")=$H
    return $$$OK
}

/// Accepts authorization code and redirect_uri to exchange for tokens and return user profile.<br/>
/// The method arguments hold values for:<br/>
///     code, Authorization code returned by Google<br/>
///     redirect_uri, Must match redirect_uri used in the original Google OAuth request<br/>
/// WARNING: This method's signature has changed.
ClassMethod FrontendAuthCallback(code As %String, redirecturi As %String) As %DynamicObject
{
    //set ^Airistravels("code")=code
    set token = ..ExchangeCodeForToken(code,redirecturi)
    //set ^Token=token.%ToJSON()
    set aToken = token."access_token"
    set idToken = token."id_token"
    set user=..GetUserInfo(aToken)
    //set ^GoogleUser = user.id
    set sc=##class(shvarov.um.users).CreateUser(user.id, "google", user.email)
    do ..StartUserSession(user.id, idToken, token."expires_in")
    //set ^GoogleUser=user.%ToJSON()
    set resJSON = {}
    do resJSON.%Set("token", idToken)
    do resJSON.%Set("user", user)
    //d ..%SetStatusCode(200)
    return resJSON
}

/// Exchanges authorization code for access and ID tokens<br/>
/// The method arguments hold values for:<br/>
///     code<br/>
ClassMethod ExchangeCodeForToken(code As %String, redirectUri As %String) As %DynamicObject
{
    //set redirectUri = "https://trip-scribe-journal.lovable.app/auth/callback"
    set clientId = $SYSTEM.Util.GetEnviron("GOOGLE_CLIENT_ID")
    set clientSecret = $SYSTEM.Util.GetEnviron("GOOGLE_SECRET_KEY")
    set authUrl = "https://oauth2.googleapis.com/token"
    set payload = {
        "code": (code), 
        "client_id": (clientId),
        "client_secret": (clientSecret),
        "redirect_uri": (redirectUri),
        "grant_type": "authorization_code"
        }
    
    s req=##class(%Net.HttpRequest).%New()
    s req.Server="oauth2.googleapis.com"
    s req.Https=1
    s req.SSLConfiguration="ISC.FeatureTracker.SSL.Config"
    s req.ContentType="application/json"
    d req.EntityBody.Write(payload.%ToJSON())
    s sc=req.Post("/token")
    if sc'=1 {
        d ..%SetStatusCode(500)
        d ..%SetHeader("X-Error", "Failed to exchange code for token")
        return ""
    }
    return {}.%FromJSON(req.HttpResponse.Data)
}

ClassMethod GetUserInfo(token As %String) As %DynamicObject
{
    set req=##class(%Net.HttpRequest).%New()
    set req.Server="www.googleapis.com"
    set req.Https=1
    set req.SSLConfiguration="ISC.FeatureTracker.SSL.Config"
    set req.ContentType="application/json"
    do req.SetHeader("Authorization", "Bearer "_token)
    
    s sc=req.Get("/oauth2/v2/userinfo")
    if sc'=1 {
        d ..%SetStatusCode(500)
        d ..%SetHeader("X-Error", "Failed to get user info")
        return ""
    }
    
    return {}.%FromJSON(req.HttpResponse.Data)
}

/// Get OpenAPI Spec
ClassMethod GetSpec() As %DynamicObject
{
     set specname=$p(..%ClassName(1),".impl")
    Set spec = {}.%FromJSON(##class(%Dictionary.CompiledXData).%OpenId(specname_".spec||OpenAPI").Data)
	Set url = $Select(%request.Secure:"https",1:"http") _ "://"_$Get(%request.CgiEnvs("SERVER_NAME")) _ ":" _ $Get(%request.CgiEnvs("SERVER_PORT")) _ %request.Application
	Set spec.servers = [{"url" : (url)}]
	Quit spec
}

}
