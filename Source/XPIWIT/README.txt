The latest version of XPIWIT is required for the spot detection. You can obtain the latest version from https://bitbucket.org/jstegmaier/xpiwit/downloads/ .

Download the version for your operating system, extract the folder to disk and copy the contents of the "Bin/" folder to the XPIWIT folder of the SpotDetectionAndColocalizationGUI.
Make sure there are no spaces or special characters in the path name to XPIWIT. Furthermore, XPIWIT requires read/write/execute permissions in order to function properly. 

In case you observe permission denied errors, try changing the permissions to the extracted software folder, such that read/write/execute are enabled. 
This can be performed by navigating to the respective folder (called $DIR in the following command) using the Terminal application and by executing the following command
 “chmod 755 -R $DIR”. This should change the permissions to read+write+execute for the current user and to read+execute for all other users.