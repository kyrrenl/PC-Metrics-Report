This project is a bash based program that runs a bunch of tools along with a script to grab pc info to see how well the PC handles the memory being used with the tools. 
The main program is "APMTool.sh". We made that script on CentOS and it basically calls the  6 APM files and takes information from each file while they are running. 
The script then takes that information after 15 minutes and makes an excel plot out of them so we could make graphs and visually see overtime if any tools had memory leaks or weren't coded properly.
The tools were made in C language which is pretty easy in term of users forgetting or mis allocating memory incorrectly. The purpose of this project was to run these tools and see if any of them were coded incorrectly to 
cause memory issues.