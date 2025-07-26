Class shvarov.um.users Extends (%Persistent, %JSON.Adaptor)
{

/// User's unique identifier
Property UserId As %String [ Required ];

/// OAuth provider. Possible values: "google", "facebook", "github", etc.
Property OauthProvider As %String;

/// User's email address
Property Email As %String [ Required ];

Index EmailIndex On Email [ Unique ];

Index UserIdIndex On UserId [ Unique ];

/// Classmethod to obtain user by userId and email
ClassMethod GetUser(userId As %Integer, oauthProvider As %String, email As %String, ByRef user As shvarov.um.users) As %Status
{
    //set ^AUserId=userId
    if ..UserIdIndexExists(userId) {
        // User already exists, return success
        Set user = ..UserIdIndexOpen(userId)
        Return $$$OK
    }
    
    return ..CreateUser(userId, oauthProvider, email, .user)
}

/// Classmethod to create a new user
ClassMethod CreateUser(userId As %Integer, oauthProvider As %String, email As %String, ByRef user As shvarov.um.users) As %Status
{
    
    Set newUser = ..%New()
    Set newUser.UserId = userId
    Set newUser.OauthProvider = $G(oauthProvider,"not specified")
    Set newUser.Email = email
    Set sc = newUser.%Save()
    If $$$ISERR(sc) {
        Throw ##class(%Exception.General).%New("Error saving user: "_sc)
    }

    set user = newUser
    Return sc
}

Storage Default
{
<Data name="usersDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>UserId</Value>
</Value>
<Value name="3">
<Value>OauthProvider</Value>
</Value>
<Value name="4">
<Value>Email</Value>
</Value>
</Data>
<DataLocation>^shvarov.um.usersD</DataLocation>
<DefaultData>usersDefaultData</DefaultData>
<IdLocation>^shvarov.um.usersD</IdLocation>
<IndexLocation>^shvarov.um.usersI</IndexLocation>
<StreamLocation>^shvarov.um.usersS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
