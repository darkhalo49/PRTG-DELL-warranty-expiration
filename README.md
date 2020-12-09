# PRTG custom sensor for monitoring remaining days of Dell device warranty

More details may be found to my website https://redhalo.eu

## Download instruction
If you have git installed on your computer, you just need to run the following command:
```
git clone https://github.com/darkhalo49/PRTG-DELL-warranty-expiration.git
```

Otherwise you can use the following link to download the script via a zip file:
https://github.com/darkhalo49/PRTG-DELL-warranty-expiration/archive/main.zip

## Installation instruction
* Add your proxy url when your remote probe is behind a proxy

Edit the variable $proxy (line 50) with your proxy url and port in Dell_Expiration_Support.ps1

```
$proxy = 'XXXXXXXXXXXXXXXXXXXXXXXX'
```

* Get your API ID and secret from Dell Technet website

If you do not have it yet, got to techdirect.dell.com/portal/Login.aspx, register yourself and then request an API Key.
As soon as you have both strings, you must update the variable $dell_api_id (line 51) and $dell_api_secret (line 52) with the respective string in Dell_Expiration_Support.ps1

```
$dell_api_id = 'XXXXXXXXXXXXXXXXXXXXXXXX'
$dell_api_secret = 'XXXXXXXXXXXXXXXXXXXXXXXX'
```

* [OPTIONAL] Edit pre defined channel settings 

You can change few settings of the unique channel which will be created. 
1. The name (line 57)
```
$channel_name = 'Remaining Support Days'
```

2. The custom unit (line 58)
```
$custom_unit = 'Days'
```

3. The lower error limit (line 59)
```
$limit_min_error = '30'
```

4. The lower warning limit (line 60)
```
$limit_min_warning = '75'
```

5. The warning limit message (line 61)
```
$limit_warning_msg = 'Less than 75 days remaining !'
```

6. The error limit message (line 62)
```
$limit_error_msg = 'Less than 30 days remaining !'
```

* Copy Dell_Expiration_Support.ps1 into the custom sensor folder of your PRTG Remote Probe installation folder

For 32-bit systems
```
%programfiles%\PRTG Network Monitor\Custom Sensors\EXEXML
```

For 64-bit systems 
```
%programfiles(x86)%\PRTG Network Monitor\Custom Sensors\EXEXML
```

* Create a new sensor

Create a new EXE/Script Advanced sensor on your dell device.
Give a name, select Dell_Expiration_Support.ps1 in EXE/Script field and add the following parameter into the Parameters field:
```
-tag XXXXXXX
```
Where XXXXXXX is your DELL service tag


Then it shoud looks like here:

![alt text](https://github.com/darkhalo49/PRTG-DELL-warranty-expiration/blob/main/Images/Remaining_Support_Days_PRTG_DELL.jpg?raw=true)
