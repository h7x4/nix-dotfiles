{ pkgs, ... }:
{
  services.openldap = {
    enable = true;
    # dataDir = "/data/var/openldap";
    urlList = [ "ldap:///" "ldapi:///" ]; # Add ldaps to this list to listen with SSL (requires configured certificates)
    # suffix = "dc=nixos,dc=org";
    # rootdn = "cn=admin,dc=nixos,dc=org";
    # rootpwFile = "/var/keys/ldap/rootpw";
    # See https://www.openldap.org/doc/admin24/slapdconfig.html
    # extraDatabaseConfig = ''
    #   access to dn.base="dc=nixos,dc=org" by * read
    #   # Add your own ACLs here…

    #   # Drop everything that wasn't handled by previous ACLs:
    #   access to * by * none

    #   index objectClass eq
    #   index uid eq
    #   index mail sub
    #   # Accelerates replication if you use it
    #   index entryCSN eq
    #   index entryUUID eq
    # '';

    settings = {
      attrs.olcLogLevel = [ "stats" ];
      children = {
        "cn=schema".includes = [
           "${pkgs.openldap}/etc/schema/core.ldif"
           "${pkgs.openldap}/etc/schema/cosine.ldif"
           "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
        ];
        "olcDatabase={-1}frontend" = {
          attrs = {
            objectClass = "olcDatabaseConfig";
            olcDatabase = "{-1}frontend";
            olcAccess = [ "{0}to * by dn.exact=uidNumber=0+gidNumber=0,cn=peercred,cn=external,cn=auth manage stop by * none stop" ];
          };
        };
        "olcDatabase={0}config" = {
          attrs = {
            objectClass = "olcDatabaseConfig";
            olcDatabase = "{0}config";
            olcAccess = [ "{0}to * by * none break" ];
          };
        };
        "olcDatabase={1}mdb" = {
          attrs = {
            objectClass = [ "olcDatabaseConfig" "olcMdbConfig" ];
            olcDatabase = "{1}mdb";
            olcDbDirectory = "/data/var/openldap/db";
            olcDbIndex = [
              "objectClass eq"
              "cn pres,eq"
              "uid pres,eq"
              "sn pres,eq,subany"
            ];
            olcSuffix = "dc=example,dc=com";
            olcAccess = [ "{0}to * by * read break" ];
          };
        };
      };
    };

    # Setting this causes OpenLDAP to drop the entire database on startup and write the contents of
    # of this LDIF string into the database. This ensures that only nix-managed content is found in the
    # database. Note that if a lot of entries are created in conjunction with a lot of indexes, this might hurt
    # startup performance.
    # Also, you can set `readonly on` in `extraDatabaseConfig` to ensure nobody writes data that will be
    # lost.
    # declarativeContents = "…";
  };
}
