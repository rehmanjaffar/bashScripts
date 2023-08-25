
echo "                ***Welcome to Shell Scripting Program***"
echo " "
echo "What Is Your Name ?"
read name


echo "                ***Welcome !! $name ***"
echo "                Please Select the Following Options"
while true; do
echo "                Please Select the Following Option...."
echo "                press 1 to See Disk Usage Of Virtual Machine"
echo "                press 2 to See Running Processes"
echo "                press 3 to See Running/Occupied Ports"
echo "                press 0 to Exit"
echo "Enter your choice = " 
read choice
if [ "$choice" -eq 1 ]; then 
	df -h
elif [ "$choice" -eq 2 ]; then
	ps aux
elif [ "$choice" -eq 3 ]; then
	netstat -nltpn
elif [ "$choice" -eq 0 ]; then
	echo "Exiting from Shell Script"
	break
else
	echo "Invalid Choice"
fi

done

