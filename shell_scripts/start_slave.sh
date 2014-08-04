<<COMMENT
  @Description : Starts the slave process for the first time in a remote production instances
      using SSH shell
  @param : hostname:String        -- $1
  @param : queue_name:String      -- $2
  @param : aws_instance_id:String -- $3
COMMENT



# mbd_git instance
if [ $1 = "ec2-54-242-224-242.compute-1.amazonaws.com" ]; then
  echo "[KRAKE_ENGINE — start_slave.sh ] : Resurrection mode. ID:krake_data"
  what=cannot
  
# krake_data instance
elif [ $1 = "ec2-204-236-207-28.compute-1.amazonaws.com" ]; then
  echo "[KRAKE_ENGINE — start_slave.sh ] : Resurrection mode. ID:mbd_git"
  what=cannot
  
# Adhoc spin up slaves
else
  echo "[KRAKE_ENGINE — start_slave.sh ] : Reincarnation mode"
  what=can
    
fi


# Boots the AWS instance
ssh prod@$1 -p 2202 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
" . ~/.nvm/nvm.sh && 
  nvm use v0.10.28 && 
  rm -rf ~/logs &&
  mkdir ~/logs &&
  cd /home/prod/krake_phantomjs/ && 
  git checkout -f &&
  git pull origin master &&
  npm install &&
  # forever stop -c phantomjs --load-images=no server.js &&
  forever start -l ~/logs/phantom -a -c phantomjs --load-images=no server.js &&
  cd /home/prod/krake_slave_server/ && 
  git checkout -f && 
  git pull origin master && 
  export NODE_ENV=production && 
  export CAN_SHUTDOWN=$what && 
  export 
  npm install &&  
  # forever stop -c coffee krake_slave_server.coffee && 
  forever start -l ~/logs/slave -a -c coffee krake_slave_server.coffee $2 $3
  "