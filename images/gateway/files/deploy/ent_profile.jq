{
   "EnterpriseConfigParams": {
      "ServerFileSystem": env.SIEBEL_FS,
      "UserName": env.SADMIN_USERNAME,
      "Password": env.SADMIN_PASSWORD,
      "DatabasePlatform": "Oracle",
      "DBConnectString": "SIEBELDB",
      "DBUsername": env.DB_USERNAME,
      "DBUserPasswd": env.DB_PASSWORD,
      "TableOwner": env.DB_TABLEOWNER,
      "SecAdptProfileName": "Gateway",
      "PrimaryLanguage": env.SIEBEL_LANGUAGE,
      "Encrypt": "SISNAPI"
   },
   "Profile": {
      "ProfileName": "EnterpriseProfile"
   }
}
