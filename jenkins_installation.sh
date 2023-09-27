echo "Installing Jenkins"
echo " "

while true; do
    echo "Please Select an Option:"
    echo "1. Install Standalone Jenkins Application"
    echo "2. Install Jenkins using Kubernetes (K8s) cluster"
    echo "3. Jenkins Authentication Password"
    echo "0. Exit"
    echo "Enter your choice: "
    read choice

    if [ "$choice" -eq 1 ]; then



        echo "Updating packages..."
        sudo yum upgrade

        echo "Installing Java..."
        sudo yum install java-11-openjdk-devel
        echo "Java Version:"
        java -version


        echo "Adding Jenkins repository..."
        sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

        sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key

        echo "Installing Jenkins..."
        sudo yum install jenkins

        echo "Starting Jenkins service..."
        sudo systemctl start jenkins
        sudo systemctl enable jenkins
        sudo systemctl status jenkins

    elif [ "$choice" -eq 2 ]; then
        echo "Install Jenkins using Kubernetes (K8s) cluster - Add your K8s commands here"
        # Clone the GitHub repository
        git clone https://github.com/Noumanniazy/kubernetes-jenkins
        cd kubernetes-jenkins



        # Create the 'jenkins' namespace
        kubectl create namespace jenkins



        # Apply the Kubernetes resources
        kubectl apply -f serviceAccount.yaml
        kubectl create -f volume.yaml
        kubectl apply -f deployment.yaml
        kubectl apply -f service.yaml



        # Optionally, you can print a message indicating completion
        echo "Jenkins setup completed but wait for few mins to get the pod running for password or it can be retrive later in admin_pass file. Patinece is virtue my friend !!"



        # Check if the pod name is empty (no pods found)
        if [ -z "$pod_name" ]; then
          echo "No Jenkins pods found in the 'jenkins' namespace."
        else
          echo $pod_name
        fi



        sleep 240
        #Print password on screen and write in file
        kubectl exec -it $pod_name cat /var/jenkins_home/secrets/initialAdminPassword -n jenkins > admin_pass
        cat admin_pass


 elif [ "$choice" -eq 3 ]; then
        echo "Jenkins Authentication  Password"
        sudo cat /var/lib/jenkins/secrets/initialAdminPassword
        sudo sh -c 'echo "Your Jenkins Administration Password is: $(cat /var/lib/jenkins/secrets/initialAdminPassword)" > admin_passJ'

    elif [ "$choice" -eq 0 ]; then
        echo "Exiting from Shell Script"
        break
    else
        echo "Invalid Choice"
    fi
done
