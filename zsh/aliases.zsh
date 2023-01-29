# Aliases for ls shortcuts
alias ls='ls -h --time-style=long-iso --group-directories-first --color=always'
alias l='ls -lah'
alias la='ls -lAh'
alias ll='ls -l'
alias lla='ll -A'
alias lsa='ls -lah'

# If we have exa installed, use it instead of ls
haveexa=$(which exa)
if [ -x "$haveexa" ] ; then
  if [[ "$os_name" == "Mac" ]]; then
    alias ls='exa --time-style=long-iso --group-directories-first --color=auto --color-scale --git --icons --group'
  else
    alias ls='exa --time-style=long-iso --group-directories-first --color=auto --color-scale --git --group'
  fi
  alias lsa='ls -a'
  alias l='ls -l'
  alias la='l -a'
  alias ll='l'
  alias lla='ll -a'
fi

# Aliases to colorize with grc
grcbin=$(which grc)
if [ -x "$grcbin" ] ; then
  alias g++="${grcbin} --colour=auto g++"
  alias head="${grcbin} --colour=auto head"
  alias make="${grcbin} --colour=auto make"
  alias ld="${grcbin} --colour=auto ld"
  alias ping6="${grcbin} --colour=auto ping6"
  alias tail="${grcbin} --colour=auto tail"
  alias traceroute6="${grcbin} --colour=auto traceroute6"
  alias curl="${grcbin} --colour=auto curl"
  alias df="${grcbin} --colour=auto df"
  alias diff="${grcbin} --colour=auto diff"
  alias dig="${grcbin} --colour=auto dig"
  alias du="${grcbin} --colour=auto du"
  alias env="${grcbin} --colour=auto env"
  alias fdisk="${grcbin} --colour=auto fdisk"
  alias gcc="${grcbin} --colour=auto gcc"
  alias id="${grcbin} --colour=auto id"
  alias ifconfig="${grcbin} --colour=auto ifconfig"
  alias jobs="${grcbin} --colour=auto jobs"
  alias kubectl="${grcbin} --colour=auto kubectl"
  alias last="${grcbin} --colour=auto last"
  alias log="${grcbin} --colour=auto log"
  # alias ls="${grcbin} --colour=auto ls"
  alias lsof="${grcbin} --colour=auto lsof"
  alias mount="${grcbin} --colour=auto mount"
  alias netstat="${grcbin} --colour=auto netstat"
  alias nmap="${grcbin} --colour=auto nmap"
  alias ping="${grcbin} --colour=auto ping"
  alias ps="${grcbin} --colour=auto ps"
  alias showmount="${grcbin} --colour=auto showmount"
  alias stat="${grcbin} --colour=auto stat"
  alias sysctl="${grcbin} --colour=auto sysctl"
  alias tcpdump="${grcbin} --colour=auto tcpdump"
  alias traceroute="${grcbin} --colour=auto traceroute"
  alias ulimit="${grcbin} --colour=auto ulimit"
  alias uptime="${grcbin} --colour=auto uptime"
  alias whois="${grcbin} --colour=auto whois"
fi

# Aliases for git shortcuts
alias glog="git log"
alias glo1="glog --oneline"
alias glo1c='glo1 --pretty=format:"%C(yellow)%h%Creset %as | %Cgreen%G? %Cblue%<(20,trunc)%cl %Creset | %s %Cred%D%Creset"'
alias gsta="git status"
alias gsts="gsta -s"
alias gcmt="git commit"
alias gush="git push"
alias gull="git pull"


# Other Aliases
alias br="bluereset"