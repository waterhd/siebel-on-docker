{
  "ServerConfigParams": {
    "Username": env.SADMIN_USERNAME,
    "Password": env.SADMIN_PASSWORD,
    "AnonLoginUserName": env.ANON_USERNAME,
    "AnonLoginPassword": env.ANON_PASSWORD,
    "EnableCompGroupsSIA": "eai",
    "SCBPort": (env.SCB_PORT // "2321"),
    "LocalSynchMgrPort": (env.SYNCH_MGR_PORT // "40400"),
    "ModifyServerEncrypt": false,
    "ModifyServerAuth": false,
    "ClusteringEnvironmentSetup": "NotClustered",
    "UseOracleConnector": "true"
  },
  "Profile": {
    "ProfileName": "eai"
  }
}
