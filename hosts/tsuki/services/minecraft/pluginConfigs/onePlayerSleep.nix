{ ... }:
{
  #time, in ticks, to delay the task of passing of night
  # weather clear is scheduled to run after 2x this amount
  sleepDelay = 60;
  
  #amount of server time to increment by, per server tick
  # lowering this will slow the night passing, increasing will speed it up
  increment = 150;
  
  #number of server ticks between increments, usually 20 ticks per second
  # lower makes a smoother transition but more processing
  # min - 1
  timeBetweenIncrements = 2;
  
  #sleep attempt cooldown, in ms, to prevent spam
  bedCooldown = 2000;
  
  #whether to fully kick a player from a bed on wakeup call
  kickFromBed = true;
  
  #whether to randomize the message for every player, instead of distributing 1 random message to all
  #   costs more performance to do multiple randomization
  randomPerPlayer = false;
  
  #whether to reset the TIME_SINCE_REST statistic for every player on sleep task
  resetPhantomStatistics = true;
  
  #whether to write players' sleep messages to console
  logMessages = true;
  
  #plugins like EssentialsX will typically setSleepingIgnored on /afk or /vanish
  # whether to send messages from/to sleepingIgnored players
  messageFromSleepingIgnored = false;
  messageToSleepingIgnored = true;
  
  #how many players online and awake before sleep messages are used
  minPlayers = 2;
  
  #DO NOT TOUCH VERSION NUMBER
  version = 2.1;
}
