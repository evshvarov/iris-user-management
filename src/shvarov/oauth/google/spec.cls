Class shvarov.oauth.google.spec Extends %REST.Spec [ ProcedureBlock ]
{

Parameter HandleCorsRequest = 1;

Parameter CONTENTTYPE = "application/json";

XData OpenAPI [ MimeType = application/json ]
{
{
  "swagger":"2.0",
  "info":{
    "title":"Google OAuth Authentication API",
    "version":"1.0.0",
    "description":"Handles user authentication via Google OAuth 2.0"
  },
  "basePath":"/auth",
  "schemes":[
    "https"
  ],
  "paths":{
    "/frontend/callback":{
  "get": {
    "tags": ["auth"],
    "summary": "Frontend Google OAuth callback",
    "description": "Accepts authorization code and redirect_uri to exchange for tokens and return user profile.",
    "operationId": "FrontendAuthCallback",
    "produces": ["application/json"],
    "parameters": [
      {
        "name": "code",
        "in": "query",
        "required": true,
        "type": "string",
        "description": "Authorization code returned by Google"
      },
      {
        "name": "redirect_uri",
        "in": "query",
        "required": true,
        "type": "string",
        "description": "Must match redirect_uri used in the original Google OAuth request"
      }
    ],
    "responses": {
      "200": {
        "description": "Authentication successful. Tokens and user profile returned.",
        "schema": {
          "type": "object",
          "properties": {
            "access_token": { "type": "string" },
            "id_token": { "type": "string" },
            "refresh_token": { "type": "string" },
            "expires_in": { "type": "integer" },
            "token_type": { "type": "string" },
            "user": {
              "type": "object",
              "properties": {
                "id": { "type": "string" },
                "email": { "type": "string" },
                "verified_email": { "type": "boolean" },
                "name": { "type": "string" },
                "given_name": { "type": "string" },
                "family_name": { "type": "string" },
                "picture": { "type": "string" },
                "locale": { "type": "string" }
              }
            }
          }
        }
      },
      "400": {
        "description": "Invalid or missing code or redirect_uri"
      }
    }
  }
}
 ,   "/google/refresh":{
      "post":{
        "tags":[
          "auth"
        ],
        "summary":"Refresh token",
        "description":"Uses refresh token to get a new access token",
        "operationId":"RefreshAccessToken",
        "consumes":[
          "application/json"
        ],
        "produces":[
          "application/json"
        ],
        "parameters":[
          {
            "in":"body",
            "name":"refresh",
            "required":true,
            "schema":{
              "type":"object",
              "required":[
                "refresh_token"
              ],
              "properties":{
                "refresh_token":{
                  "type":"string"
                }
              }
            }
          }
        ],
        "responses":{
          "200":{
            "description":"New access token issued",
            "schema":{
              "type":"object",
              "properties":{
                "access_token":{
                  "type":"string"
                },
                "expires_in":{
                  "type":"integer"
                },
                "token_type":{
                  "type":"string"
                }
              }
            }
          },
          "400":{
            "description":"Invalid or expired refresh token"
          }
        }
      }
    },
    "/google/logout":{
      "post":{
        "tags":[
          "auth"
        ],
        "summary":"Logout user",
        "description":"Invalidates access token or clears session",
        "operationId":"LogoutUser",
        "consumes":[
          "application/json"
        ],
        "produces":[
          "application/json"
        ],
        "parameters":[
          {
            "in":"body",
            "name":"logout",
            "required":true,
            "schema":{
              "type":"object",
              "required":[
                "access_token"
              ],
              "properties":{
                "access_token":{
                  "type":"string"
                }
              }
            }
          }
        ],
        "responses":{
          "200":{
            "description":"User logged out successfully"
          },
          "401":{
            "description":"Invalid or missing access token"
          }
        }
      }
    },
    "/_spec":{
      "get":{
        "tags":[
          "meta"
        ],
        "summary":"Get OpenAPI Spec",
        "operationId":"GetSpec",
        "produces":[
          "application/json"
        ],
        "responses":{
          "200":{
            "description":"OpenAPI specification document"
          }
        }
      }
    }
  },
  "tags":[
    {
      "name":"auth",
      "description":"Google OAuth endpoints"
    },
    {
      "name":"meta",
      "description":"Spec metadata"
    }
  ]
}
}

}
