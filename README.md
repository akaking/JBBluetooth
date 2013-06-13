JBBluetooth
===========

JBBluetooth is a small and flexible tool to access bluetooth by CoreBluetooth framework. You can quickly customize one of your own Bluetooth applications just by setting "uuid.plist" file.

LIKE:

1.	<?xml version="1.0" encoding="UTF-8"?>
2.	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
3.	<plist version="1.0">
4.	<array>
5.		<dict>	//	one service
6.			<key>characteristicList</key>	//	characteristics in the service
7.			<array>
8.				<dict>
9.					<key>characteristicUUIDString</key>	//	characteristic	uuid
10.					<string>97F57081-8E49-444A-8B79-1E41760DC804</string>
11.					<key>needNotifyValue</key>		//	whether notify characteristic's value	
12.					<true/>
13.				</dict>
14.				<dict>
15.					<key>characteristicUUIDString</key>	//	characteristic	uuid
16.					<string>97F57081-8E49-444A-8B79-1E41760DC806</string>
17.					<key>needNotifyValue</key>		//	whether notify characteristic's value
18.					<false/>
19.				</dict>
20.			</array>
21.			<key>serviceUUIDString</key>	//	service	uuid
22.			<string>04CD7354-E2CF-43EB-ABC7-54AF3BB75453</string>
23.		</dict>
24.	</array>
25.	</plist>


serviceUUIDString:The service you will listen or advertise.
characteristicUUIDString:the characteristic contained in service.

There can be multiple services setted in uuid.plist.
