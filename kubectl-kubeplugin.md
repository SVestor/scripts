## Installing kubectl plugins

A plugin is a standalone executable file, whose name begins with  `kubectl-`. To install a plugin, move its executable file to anywhere on your  `PATH`.

You can also discover and install kubectl plugins available in the open source using  [Krew](https://krew.dev/). Krew is a plugin manager maintained by the Kubernetes SIG CLI community.
To discover and install  `kubectl`  plugins from a community-curated  [plugin index](https://krew.sigs.k8s.io/plugins/)

## Discovering plugins
`kubectl`  provides a command  `kubectl plugin list`  that searches your  `PATH`  for valid plugin executables. Executing this command causes a traversal of all files in your  `PATH`. Any files that are executable, and begin with  `kubectl-`  will show up  _in the order in which they are present in your  `PATH`_  in this command's output. A warning will be included for any files beginning with  `kubectl-`  that are  _not_  executable. A warning will also be included for any valid plugin files that overlap each other's name.

## Writing kubectl plugins

You can write a plugin in any programming language or script that allows you to write command-line commands.

There is no plugin installation or pre-loading required. Plugin executables receive the inherited environment from the  `kubectl`  binary. A plugin determines which command path it wishes to implement based on its name. For example, a plugin named  `kubectl-foo`  provides a command  `kubectl foo`. You must install the plugin executable somewhere in your  `PATH`

## Example plugin kubectl-kubeplugin

    #!/bin/bash
    #Define command-line arguments
    
    RESOURCE_TYPE=$1 #defining a res type variable pod or node - the first input arg
    ns=$2            #defining a namespace variable - the second input arg
       
    #Retrieve resource usage statistics from Kubernetes
    
    kubectl top $RESOURCE_TYPE -n $ns | tail -n 2 | while read -r line
    
    do
    #Extract CPU and memory usage from the output
    
    NAME=$(echo ${line} | awk '{print $1}')
    CPU=$(echo ${line} | awk '{print $2, $3}')
    MEMORY=$(echo ${line} | awk '{print $4, $NF}')
    
    #Output the statistics to the console
    echo -e "\n Resource=$RESOURCE_TYPE\n Namespace=$ns\n Name=$NAME\n CPU=$CPU\n Memory=$MEMORY\n"
    done

## Using a plugin
To use a plugin, make the plugin executable:  

`chmod +x ./kubectl-kubeplugin`

and place it anywhere in your `PATH`:

 `mv ./kubectl-kubeplugin ~/.local/bin` or `sudo mv ./kubectl-kubeplugin /usr/local/bin` 
> After the above is done **kubectl** be able to find the plugin, and you can run it with
<br>

Let's test and run our **kubectl-kubeplugin** on which we have been working on :

do    `kubectl kubeplugin node kube-system` where *node* refers to the `resource type argument` and *kube-system* is responsible for the `namespace argument`
    
 ![kubectl-kubepligin](/img/kubectl-kubeplugin.png)  

    So, plugin is working, the job is done
    
You can find the *kubectl-kubeplugin* script itself in the [scripts](/scripts) directory in the root /
<br>
<br>

> **If you require more advanced documentation in relation to writing plugins for kubectl use the following link to [start](https://kubernetes.io/docs/tasks/extend-kubectl/kubectl-plugins/) with**
