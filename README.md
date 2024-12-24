# Batch Wi-Fi Brute Forcer
An active attack tool against Wi-Fi networks with internal CMD commands.

This program is created to be a proof of concept that it is possible
to write a working Wi-Fi attack tool with Batchfiles since there 
are countless examples on the internet that claims to be legit
hacking tools, working on CMD. While this tool does not claim
a 100% success ratio, it still works if the target Wi-Fi has
weak password. :)

## Usage

### Interface initialization
The program automatically detects your wireless interfaces when you execute the batch file.
If it finds only one, it will select it as default. If there are multiple interfaces,
the program will ask you to choose one. If none exist, it will stay "not_defined".

> You can later change the interface by typing `interface` on the main menu.
> This will bring the interface initialization screen back.

### Scan
When you type `scan` at the main menu, the program will enumerate all Wi-Fi networks
available from the selected wireless interface. You can choose one by typing the number
associated with an SSID.

> No Name could mean that the network is hidden. You cannot attack that network.

> Performing a scan disconnects the interface from the network that it has connected previously.

### Selecting a wordlist
A wordlist file is already provided in the repository. If you want to use a custom
wordlist, you have to specify the file you are going to use by typing `wordlist` on the 
main menu and then typing the absolute or relative path of the wordlist file.

### Attacking
Simply type `attack` and the program will show you a warning screen that this process is going
to delete the profile associated with the SSID if you have connected to it before.
It means you will lose the password you entered while connecting to that SSID before.
Save it before using the attack.

### Counter
When a connection is attempted with `netsh` to a network, it takes time to establish the connection. To check whether the connection is successful,
the program repeatedly queries the connection status of the selected interface. A counter value controls how many times this query will be done.
If not changed, the counter value is 10, and counts down after each query for each password combination. 

> If an authentication or association is detected, this value is increased by 5 to ensure a successful connection.

## Limitations
- This program has been tested unsuccessfully on Windows 7 and tested successfully on Windows 10 and 11. Since some commands may differ in terms of output between Windows versions, it is not expected to work on previous versions.

- ANSI escape sequences used in the terminal were added to the Windows Console in the Windows 10 version 1511, previous versions are not expected to run this program.

- There is a strict dependency on the command line utility `netsh`, meaning that it cannot understand "Unicode" characters. Only ASCII characters are supported for network names.

- The command line utilities cannot be forced to output English-only text, which means parsing particularly depends on English-based output from command line utilities. Any other system language is not expected to be compatible with this program.

- Speed is significantly slow due to its nature.

- Cannot attack hidden networks.

## Result file
If an attack is successful, the result is automatically written to `result.txt`.


## Help screen
```txt
Commands

 - help             : Displays this page
 - wordlist         : Provide a wordlist file     
 - scan             : Performs a WI-FI scan       
 - interface        : Open Interface Management   
 - attack           : Attacks selected WI-FI      
 - counter          : Sets the attack counter     
 - exit             : Close the program

 For more information, please refer to "README.md".

 More projects from TechnicalUserX:
 https://github.com/TechnicalUserX


Press any key to continue...
```
