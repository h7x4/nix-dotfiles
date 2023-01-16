{ ... }:
{
# BackupTimer = At what time should a Backup be created? The format is: 'hh-mm' e.g. '12-30'.
# DeleteOldBackups = Deletes old backups automatically after a specific time (in days, standard = 7 days)
# DeleteOldBackups - Type '0' at DeleteOldBackups to disable the deletion of old backups.
# BackupLimiter = Deletes old backups automatically if number of total backups is greater than this number (e.g. if you enter '5' - the oldest backup will be deleted if there are more than 5 backups, so you will always keep the latest 5 backups)
# BackupLimiter - Type '0' to disable this feature. If you don't type '0' the feature 'DeleteOldBackups' will be disabled and this feature ('BackupLimiter') will be enabled.
# KeepUniqueBackups - Type 'true' to disable the deletion of unique backups. The plugin will keep the newest backup of all backed up worlds or folders, no matter how old it is.
# Blacklist - A list of files/directories that will not be backed up.
# IMPORTANT FTP information: Set 'UploadBackup' to 'true' if you want to store your backups on a ftp server (sftp does not work at the moment - if you host your own server (e.g. vps/root server) you need to set up a ftp server on it).
# If you use ftp backups, you can set 'DeleteLocalBackup' to 'true' if you want the plugin to remove the created backup from your server once it has been uploaded to your ftp server.
# Contact me if you need help or have a question: https://server-backup.net/#support

  Blacklist = [
    "libraries"
    "plugins/ServerBackup/config.yml"
  ];

  AutomaticUpdates = true;
  DynamicBackup = false;
  AutomaticBackups = true;

  BackupTimer = {
    Days = [
      "MONDAY"
      "TUESDAY"
      "WEDNESDAY"
      "THURSDAY"
      "FRIDAY"
      "SATURDAY"
      "SUNDAY"
    ];
    Times = [
      "00-00"
    ];
  };

  BackupWorlds = [
    "world"
    "world_nether"
    "world_the_end"
  ];

  DeleteOldBackups = 14;
  BackupLimiter = 0;
  KeepUniqueBackups = false;
  UpdateAvailableMessage = true;
  BackupDestination = "Backups/";

  # Ftp = {
  #   UploadBackup = false;
  #   DeleteLocalBackup = false;
  #   Server = {
  #     IP = "127.0.0.1";
  #     Port = 21;
  #     User = "username";
  #     Password = "password";
  #     BackupDirectory = "Backups/";
  #   };
  # };

  SendLogMessages = false;
}
