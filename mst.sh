#/bin/bash
 
# MST -- The Meta-Scan Tool
# This tool combines a few simple functions that need to
#  be done at every client into a single program.
 
 
# Make sure required files are in the current directory
if [ -f './networks' ] && [ -f './services_list' ]
then
  echo ""
  echo "**************************"
  echo "MST -- The Meta-Scan Tool"
  echo "**************************"
  echo ""
  echo "You are currently in the \"`pwd`\" directory."
  echo "Is that the directory you're supposed to be in?"
  sleep 2
  echo ""
  echo "Starting scan in 10 seconds..."
  sleep 1
  echo ""
  for i in `seq 1 10` 
   do
      echo "$i ..."
      sleep 1
   done
else
  echo ""
  echo "Oops. Make sure you satisfy the following conditions:"
  echo ""
  echo "  1. You're in the proper client's directory (don't overwrite something you want)."
  echo "  2. You have a file in the current directory named: 'networks'"
  echo "  3. You have a file in the current directory named: 'services_list'"
  echo ""
  exit $error_nofile
fi
 
# Lay out the variables
num_args=$#
services=`cat ./services_list`
networks=./networks
error_nofile=66
 
# Check to make sure one (and only one) argument is given to scat
if [ $num_args -ne 0 ]
  then
    echo "Usage: mst" 
  exit
fi
 
 
# Call Nmap for host discovery and write the output to a file called "hosts"
echo ""
echo "-----------------------------"
echo "1. Scanning for live hosts..."
echo "-----------------------------"
nmap -sP -PS21,22,23,25,80,88,139,389,445,3389 -iL $networks > hosts_tmp
cat hosts_tmp | grep is | grep up > hosts
## Removed the comment out of the deletion of hosts_tmp file. This was originally added to aid in testing.
rm ./hosts_tmp
echo ""
echo "  Host discovery complete."
echo "  `wc -l hosts | awk '{print $1}'` hosts found."
 
# Sleep for two seconds
sleep 2
 
# Scan each network and make sessions for each in all Nmap formats
echo ""
echo "---------------------------"
echo "2. Performing Nmap scans..."
echo "---------------------------"
echo ""
sleep 1
for line in `cat $networks`
do
  echo "  Scanning $line ..."
  session=`echo $line | tr "/" "-"`
  nmap -vv -T4 -sV -O -PS21,22,23,25,80,88,139,389,445,3389 -pT:1-65535,U:53,135,137,138,139,161 -oA $session $line > /dev/null
done
echo ""
echo "  Nmap scans complete."
 
# Grep through the output to find the services available on each network
echo ""
echo "------------------------------------"
echo "3. Collecting service information..."
echo "------------------------------------"
for file in `ls | grep \.gnmap$`
do
  for service in $services
  do
    grep $service $file | cut -d" " -f2 >> `echo $file | sed  s/\.gnmap/""/`-SVC-$service
  done
done
 
# Consolidate the service information into single files
for service in $services
do
  cat *SVC-$service > SERVICE-$service
done
 
# Create a service summary file
for service in $services
do
  echo "There are `wc -l SERVICE-$service | awk '{print $1}'` $service servers." >> services_summary
done
 
 
# Create directory structure and organize results
echo ""
echo "----------------------------"
echo "4. Preparing your results..."
echo "----------------------------"
 
sleep 3
 
mkdir ./nmap 2> /dev/null
mkdir ./services 2> /dev/null
 
mv *.nmap ./nmap
mv *.xml ./nmap
mv *.gnmap ./nmap
mv *SVC* ./services
mv *SERVICE* ./services
mv ./services_summary ./services
 
# Farewell message
echo ""
echo "Process complete. Your content is ready."
