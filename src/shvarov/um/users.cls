Class shvarov.um.users Extends (%Persistent, %JSON.Adaptor)
{

/// User's unique identifier
Property UserId As %Integer [ Required ];

/// OAuth provider. Possible values: "google", "facebook", "github", etc.
Property OauthProvider As %String;

/// User's email address
Property Email As %String [ Required ];

Index EmailIndex On Email [ Unique ];

Index UserIdIndex On UserId [ Unique ];

/// Classmethod to create a new user
ClassMethod CreateUser(userId As %Integer, oauthProvider As %String, email As %String, ByRef user As shvarov.um.users) As %Status
{
    if ..UserIdIndexExists(userId) {
        // User already exists, return success
        Set user = ..UserIdIndexOpen(userId)
        Return $$$OK
    }
    Set newUser = ..%New()
    Set newUser.UserId = userId
    Set newUser.OauthProvider = $G(oauthProvider,"not specified")
    Set newUser.Email = email
    Set sc = newUser.%Save()
    If $$$ISERR(sc) {
        Throw ##class(%Exception.General).Create("Error saving user: "_sc)
    }

    set user = newUser
    Return sc
}


}
