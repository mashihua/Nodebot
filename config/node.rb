
##
# Custom installation tasks for Ubantu.
#
# Author: Shihua Ma http://f2eskills.com/


namespace :nodebot do
  
  namespace :install do
    
    desc "Install server software"
    task :default do
      setup
      
      git
      node
      npm
      jake
      tree
      httperf
      set_time_to_utc
    end
    
    task :setup do
      sudo "rm -rf src"
      run  "mkdir -p src"
    end
    
    desc "Install curl"
    task :curl do
      sudo "apt-get install curl"
    end
    
    desc "Install git"
    task :git do
      cmd = [
        "cd src",
        "wget http://ftp.ntu.edu.tw/pub2/software/scm/git/git-1.7.2.2.tar.gz",
        "tar xfz git-1.5.3.5.tar.gz",
        "cd git-1.5.3.5",
        "make prefix=/usr/local all",
        "sudo make prefix=/usr/local install"
      ].join(" && ")
      run cmd
    end
    
    desc "install node.js"
    task :node do
      cmd = [
        "cd src",
        "wget http://nodejs.org/dist/node-v0.4.12.tar.gz",
        "tar xfz node-v0.4.12.tar.gz",
        "cd node-v0.4.12",
        "./configure --prefix=/usr/local",
        "make",
        "sudo make install",
        "echo 'export NODE_PATH=/usr/local:/usr/local/lib/node_modules' >> ~/.bash_profile"
      ].join(" && ")
      run cmd
    end

    desc "install npm"
    task :npm do
      curl
      sudo "curl http://npmjs.org/install.sh | sh"
    end

    desc "install jake"
    task :jake do
      sudo "npm install jake -g"
    end
        
    desc "Install command-line directory lister"
    task :tree do
      cmd = [
        "cd src",
        "wget ftp://mama.indstate.edu/linux/tree/tree-1.5.3.tgz",
        "tar xfz tree-1.5.3.tgz",
        "cd tree-1.5.3",
        "make",
        "sudo make install"
      ].join(' && ')
      run cmd
    end
    
    desc "Install monit"
    task :monit do
      sudo "apt-get install monit"
      #set variable for monit to start
      sudo 'echo "startup=1" >> /etc/default/monit'
    end
    
    desc "Install httperf"
    task :httperf do
      cmd = [
        "cd src",
        "wget ftp://ftp.hpl.hp.com/pub/httperf/httperf-0.9.0.tar.gz",
        "tar xfz httperf-0.9.0.tar.gz",
        "cd httperf-0.9.0",
        "./configure --prefix=/usr/local",
        "make",
        "sudo make install"
      ].join(' && ')
      run cmd
    end
    
    desc "Set time to UTC"
    task :set_time_to_utc do
      sudo "ln -nfs /usr/share/zoneinfo/UTC /etc/localtime"
    end
    
  end

  
  
  
end