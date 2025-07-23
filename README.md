test #5

# Simple start to finish of turning a python script into a container to run in kubernetes

Docker Hub: https://hub.docker.com/u/aschiebold

Here's a simple Python script to calculate 1+1 and print the result:
python

# Calculate 1+1
result = 1 + 1

# Print the result
print("1 + 1 =", result)

When you run this script, it will output:

1 + 1 = 2

This script:

    Performs the addition of 1+1 and stores it in the variable result
    Uses the print() function to display the calculation and its result

Here's a Dockerfile that will containerize the Python script to calculate 1+1:
dockerfile

# Use official Python runtime as base image
FROM python:3.9-slim

# Set working directory in container
WORKDIR /app

# Copy the Python script to container
COPY script.py .

# Run the script when container launches
CMD ["python", "script.py"]

To use this Dockerfile:

    Save the Python script from my previous response as script.py
    Save this Dockerfile as Dockerfile (no extension) in the same directory
    Build the Docker image:

bash

docker build -t calculator .

    Run the container:

bash

docker run calculator

This Dockerfile:

    Uses Python 3.9 slim version as the base image (lightweight Python environment)
    Sets the working directory to /app in the container
    Copies the script.py file into the container
    Sets the command to run the Python script when the container starts

When you run the container, it will execute the script and output "1 + 1 = 2" to the console, then exit.
Note: Make sure both files are in the same directory when building the Docker image.

Here's a step-by-step guide to push your Docker image to Docker Hub:
Prerequisites

    You have Docker installed and running
    You have a Docker Hub account (if not, create one at hub.docker.com)
    You've built the image locally using the previous Dockerfile

Steps to Push to Docker Hub

    Login to Docker Hub from your terminal

bash

docker login

    Enter your Docker Hub username and password when prompted
    If successful, you'll see "Login Succeeded"

    Tag your image
    Your image needs to be tagged with your Docker Hub username/repository format. Replace your-username with your actual Docker Hub username:

bash

docker tag calculator your-username/calculator:latest

    calculator is the local image name from our previous build
    your-username/calculator will be the repository name on Docker Hub
    :latest is the tag (you can use other tags like :v1.0 if you prefer)

    Push the image to Docker Hub

bash

docker push your-username/calculator:latest

    This uploads your image to your Docker Hub repository
    You'll see the upload progress for each layer

Full Example
Assuming your Docker Hub username is "johndoe" and you built the image as "calculator":
bash

# Login
docker login

# Tag the image
docker tag calculator johndoe/calculator:latest

# Push to Docker Hub
docker push johndoe/calculator:latest

Verification

    After pushing, visit hub.docker.com/u/your-username in your browser
    You should see your "calculator" repository
    The repository will be public by default (unless you have a paid plan for private repos)

Notes

    If the repository doesn't exist yet, Docker Hub will create it automatically when you push
    If you get a "denied: requested access to the resource is denied" error:
        Double-check your username
        Ensure you're logged in (try docker login again)
    To make the repository private, log into Docker Hub website and adjust the settings after pushing

Now anyone can pull and run your image with:
bash

docker pull your-username/calculator:latest
docker run your-username/calculator:latest

To run your Docker container in Kubernetes, you'll need to create a Kubernetes deployment and apply it to a cluster. Here's a step-by-step guide:
Prerequisites

    You have a Kubernetes cluster running (e.g., Minikube locally or a cloud provider like GKE, EKS, AKS)
    kubectl is installed and configured to communicate with your cluster
    You've pushed your image to Docker Hub (e.g., your-username/calculator:latest)

Steps to Run in Kubernetes

    Create a Kubernetes Deployment YAML file
    Create a file named calculator-deployment.yaml with this content (replace your-username with your Docker Hub username):

yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: calculator-deployment
  labels:
    app: calculator
spec:
  replicas: 1
  selector:
    matchLabels:
      app: calculator
  template:
    metadata:
      labels:
        app: calculator
    spec:
      containers:
      - name: calculator
        image: your-username/calculator:latest
        imagePullPolicy: IfNotPresent

This YAML:

    Defines a Deployment named calculator-deployment
    Runs 1 replica (pod)
    Uses your Docker Hub image
    Labels the app as "calculator" for identification

    Apply the Deployment to your cluster
    Run this command in the directory containing your YAML file:

bash

kubectl apply -f calculator-deployment.yaml

    This creates the deployment in your Kubernetes cluster

    Verify the Deployment
    Check that the deployment is running:

bash

kubectl get deployments

You should see something like:

NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
calculator-deployment 1/1     1            1           10s

Check the pods:
bash

kubectl get pods

You should see a pod with a name like calculator-deployment-xyz123-abcde

    View the Output
    Since this is a simple script that runs once and exits, the pod will complete and enter a "Completed" state. To see the output:

bash

kubectl logs <pod-name>

Replace <pod-name> with the actual pod name from kubectl get pods. You should see:

1 + 1 = 2

Notes

    Job vs Deployment: Since your container runs once and exits, a Kubernetes Job might be more appropriate than a Deployment. Here's an alternative calculator-job.yaml:

yaml

apiVersion: batch/v1
kind: Job
metadata:
  name: calculator-job
spec:
  template:
    spec:
      containers:
      - name: calculator
        image: your-username/calculator:latest
      restartPolicy: Never

Apply it with:
bash

kubectl apply -f calculator-job.yaml

    Local Testing with Minikube:
        Start Minikube: minikube start
        Apply the deployment/job
        When done, clean up with kubectl delete -f calculator-deployment.yaml and minikube stop
    Cleanup:
        Delete the deployment: kubectl delete deployment calculator-deployment
        Delete the job: kubectl delete job calculator-job
    Troubleshooting:
        If the pod fails, use kubectl describe pod <pod-name> to see details
        Ensure your cluster can pull from Docker Hub (public images don't need credentials)

This will run your simple calculator container in Kubernetes! For a more persistent application, you'd typically add a Service and possibly an Ingress, but for this one-time calculation, a Job or simple Deployment is sufficient.
