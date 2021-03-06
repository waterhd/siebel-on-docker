{
  "Profile": {
    "ProfileName": "Gateway"
  },
  "SecurityConfigParams": {
    "DataSources": [
      {
        "Name": "SIEBELDB",
        "Type": "DB",
        "Host": env.DB_HOST,
        "Port": env.DB_PORT,
        "SqlStyle": "Oracle",
        "Endpoint": env.DB_SERVICE,
        "TableOwner": env.DB_TABLEOWNER,
        "HashUserPwd": "false",
        "HashAlgorithm": "SHA1",
        "CRC": "",
        "_prevType": ""
      }
    ],
    "SecAdptName": "DBSecAdpt",
    "SecAdptMode": "DB",
    "NSAdminRole": [
      "Siebel Administrator"
    ],
    "TestUserName": env.DB_USERNAME,
    "TestUserPwd": env.DB_PASSWORD,
    "DBSecurityAdapterDataSource": "SIEBELDB",
    "DBSecurityAdapterPropagateChange": false
  }
}
