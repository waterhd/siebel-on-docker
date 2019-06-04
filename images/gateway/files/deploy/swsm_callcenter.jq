{
  "ConfigParam": {
    "defaults": {
      "DoCompression": true,
      "EnableFQDN": false,
      "AuthenticationProperties": {
        "SessionTimeout": 900,
        "SessionTimeoutWarning": 60,
        "GuestSessionTimeout": 300,
        "SessionTimeoutWLMethod": "HeartBeat",
        "SessionTimeoutWLCommand": "UpdatePrefMsg",
        "SessionTokenMaxAge": 2880,
        "SessionTokenTimeout": 900,
        "SingleSignOn": false,
        "AnonUserName": env.ANON_USERNAME,
        "AnonPassword": env.ANON_PASSWORD
      }
    },
    "RESTInBound": {
      "RESTAuthenticationProperties": {
        "AnonUserName": env.ANON_USERNAME,
        "AnonPassword": env.ANON_PASSWORD,
        "AuthenticationType": "Basic",
        "SessKeepAlive": 120,
        "ValidateCertificate": true
      },
      "LogProperties": {
        "LogLevel": "DEBUG"
      },
      "ObjectManager": "eaiobjmgr_enu",
      "Baseuri": (env.REST_BASE_URI // "https://localhost:8443/siebel/v1.0/"),
      "MaxConnections": 20,
      "MinConnections": 25,
      "RESTResourceParamList": []
    },
    "UI": {
      "LogProperties": {
        "LogLevel": "ERROR"
      }
    },
    "EAI": {
      "LogProperties": {
        "LogLevel": "ERROR"
      }
    },
    "DAV": {
      "LogProperties": {
        "LogLevel": "ERROR"
      }
    },
    "RESTOutBound": {
      "LogProperties": {
        "LogLevel": "ERROR"
      }
    },
    "SOAPOutBound": {
      "LogProperties": {
        "LogLevel": "ERROR"
      }
    },
    "Applications": [
      {
        "Name": "eai",
        "ObjectManager": "eaiobjmgr_enu",
        "Language": "enu",
        "StartCommand": "",
        "EnableExtServiceOnly": true,
        "UseAnonPool": false,
        "EAISOAPMaxRetry": 0,
        "EAISOAPNoSessInPref": false,
        "AvailableInSiebelMobile": false,
        "AuthenticationProperties": {
          "SessionTimeout": 900,
          "SessionTimeoutWarning": 60,
          "GuestSessionTimeout": 300,
          "SessionTimeoutWLMethod": "HeartBeat",
          "SessionTimeoutWLCommand": "UpdatePrefMsg",
          "SessionTokenMaxAge": 2880,
          "SessionTokenTimeout": 900,
          "SingleSignOn": false,
          "AnonUserName": "",
          "AnonPassword": ""
        }
      },
      {
        "Name": "callcenter",
        "ObjectManager": "sccobjmgr_enu",
        "Language": "enu",
        "StartCommand": "",
        "EnableExtServiceOnly": false,
        "AvailableInSiebelMobile": false,
        "AuthenticationProperties": {
          "SessionTimeout": 900,
          "SessionTimeoutWarning": 60,
          "GuestSessionTimeout": 300,
          "SessionTimeoutWLMethod": "HeartBeat",
          "SessionTimeoutWLCommand": "UpdatePrefMsg",
          "SessionTokenMaxAge": 2880,
          "SessionTokenTimeout": 900,
          "SingleSignOn": false,
          "AnonUserName": "",
          "AnonPassword": ""
        }
      }
    ],
    "RESTInBoundResource": [],
    "swe": {
      "Language": env.SIEBEL_LANGUAGE,
      "MaxQueryStringLength": -1,
      "SeedFile": "",
      "SessionMonitor": false,
      "AllowStats": true
    }
  },
  "Profile": {
    "ProfileName": "callcenter"
  }
}
