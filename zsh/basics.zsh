# setup os_name with operating system
case "$(uname -s)" in
    Linux*)  os_name=Linux;;
    Darwin*) os_name=Mac;;
    CYGWIN*) os_name=Cygwin;;
    MINGW*)  os_name=MinGw;;
    *)       os_name="$(uname -s)"
esac

# set as_root if we're root
if [ "$EUID" -ne 0 ]; then
  as_root=1
fi