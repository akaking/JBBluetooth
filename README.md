JBBluetooth
===========

JBBluetooth is a small and flexible tool to access bluetooth by CoreBluetooth framework. You can quickly customize one of your own Bluetooth applications just by setting "uuid.plist" file.

LIKE:

<?xml version="1.0" encoding="UTF-8"?> \n
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">	\n
<plist version="1.0">
<array>
	<dict>
		<key>characteristicList</key>
		<array>
			<dict>
				<key>characteristicUUIDString</key>
				<string>97F57081-8E49-444A-8B79-1E41760DC804</string>
				<key>needNotifyValue</key>
				<true/>
			</dict>
			<dict>
				<key>characteristicUUIDString</key>
				<string>97F57081-8E49-444A-8B79-1E41760DC806</string>
				<key>needNotifyValue</key>
				<false/>
			</dict>
		</array>
		<key>serviceUUIDString</key>
		<string>04CD7354-E2CF-43EB-ABC7-54AF3BB75453</string>
	</dict>
</array>
</plist>


serviceUUIDString:The service you will listen or advertise.
characteristicUUIDString:the characteristic contained in service.