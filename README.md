## .net core 3 on Azure webapps with Azure Devops

## Creating the project

* Install the [dot net core 3 runtime](https://dotnet.microsoft.com/download/dotnet-core/3.0)
* Create a new project

```bash
mkdir dotnetdemo && cd dotnetdemo
dotnet new dotnetdemo
```

* Add a suitable [.gitignore](.gitignore)
* Create the github project and push the code to it
* Add a proper [Dockerfile](Dockerfile)

```bash
git init
git add -A
git commit -m "First commit"
git remote add origin <your github project repo>
git push origin master
```

## Local test

* Build and run the project

```bash
docker build -t <your docker hub repo>/<your docker image name> .
docker run -it -p 8080:5000 <your docker hub repo>/<your docker image name>
```

* Open a browser to `http://localhost:8080` to test it

## Azure devops configuration

* Visit [Azure Devops](https://azure.microsoft.com/services/devops/pipelines)
* Create a new project
* Select *github* as origin and choose your repository
* Choose *starter pipelines*
* Edit steps to install the latest *dot net core* tooling

```
trigger:
- master

pool:
  vmImage: 'ubuntu-latest'

variables:
  buildConfiguration: 'Release'

steps:
- task: DotNetCoreInstaller@0
  displayName: 'Install .net core 3.0 (preview)'
  inputs:
    version: '3.0.100-preview8-013656'
- script: dotnet publish -c release -o webapp
  displayName: 'dotnet build $(buildConfiguration)'
```

* Trigger the build to ensure everything is ok

## Docker build and push

* Select *project settings* (on the low left)
* Go to *service connections
* Add a *docker registry* connection to your docker hub repo
* Edit the pipeline and add the *build & push tasks*

```
- task: Docker@2
  inputs:
    containerRegistry: '<your docker hub connection name>'
    repository: '<your docker hub repository and image name>'
    command: 'buildAndPush'
    Dockerfile: '**/Dockerfile'
```

* Trigger the build and check the [docker hub](https://hub.docker.com) to see your new artifact

## Webapp creation

* Visit the [Azure portal](https://portal.azure.com) 
* Create a new *web app for Linux containers* 
* Select *nginx* template and check it is working

## Basic release pipeline

* Go back to your devops pipeline
* Select *project settings* and add a webapp connection
* Create a release pipeline, selecting *Azure app service deployment*
* Configure the artifact with the current project (use *default version: specified at the time of release*)
* Configure the first stage and name it *staging env*
* Select the previously created connection to the webapp
* Set your docker hub registry username, the name of the image as *repository* and leave empty the *startup command*
* Click on its bolt icon and activate the *continuous deployment trigger*
* Update the source code and open the webapp after the ci/cd pipeline has been completed

## Multi environment pipeline

* Add a new slot to the webapp and name it *staging* (the current one should be *production*)
* Check it in your browser
* Edit the *release pipeline* and activate that slot as its destination
* Add another stage and name it *DeployToProduction*
* Configure the stage the same way than before but for the *production* slot of the webapp
* Click on the user icon of the stage and enable *pre-deployment aproval* selecting your own user as the authorized one
* Touch the source code
* See  how the artificat is built
* Wait until the release pipeline requires your attention
* Check how the *staging* slot contains the new version, but the *production* still runs the previous one
* Click to approve the deployment
* Check how the *production* slot has been update

