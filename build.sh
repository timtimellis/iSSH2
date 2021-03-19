#!/bin/bash

composeFramework() {
	framework=$1
	headers=$2
	lib=$3
	sdk=$4
	bundle_id=$5

	framework_path=$sdk/$framework.framework

	mkdir -p $framework_path/Headers

	mv $headers $framework_path/Headers/
	mv $lib $framework_path/$framework

	cp Info.plist $framework_path/

	plutil -replace CFBundleName -string $framework $framework_path/Info.plist
	plutil -replace DTSDKName -string $sdk14.4 $framework_path/Info.plist
	plutil -replace DTPlatformName -string $sdk $framework_path/Info.plist
	plutil -replace CFBundleIdentifier -string $bundle_id $framework_path/Info.plist
	plutil -replace MinimumOSVersion -string 14.0 $framework_path/Info.plist

	if [[ $sdk == "iphoneos" ]]; then
		plutil -replace CFBundleSupportedPlatforms.0 -string iPhoneOS $framework_path/Info.plist
	else
		plutil -replace CFBundleSupportedPlatforms.0 -string iPhoneSimulator $framework_path/Info.plist
	fi

	plutil -remove CFBundleSupportedPlatforms.1 $framework_path/Info.plist

	generateModuleMap $framework $framework_path
}

generateModuleMap() {
	framework=$1
	framework_path=$2

	mkdir $framework_path/Modules
	module_map=$framework_path/Modules/module.modulemap

	headers=($(find $framework_path/Headers -name "*.h"))
	echo "framework module $framework {" > $module_map
	for header in "${headers[@]}"
	do
		echo "  header \"$(basename $header)\"" >> $module_map
	done

	echo "  export *" >> $module_map
  	# echo "  module * { export * }" >> $module_map
	echo "}" >> $module_map
}

rm -r *.xcframework

# iphoneos

./iSSH2.sh --platform=iphoneos --min-version=14.0 -a "arm64 arm64e" --no-clean

composeFramework "libssl" "openssl_iphoneos/include/openssl/*.h" \
	"openssl_iphoneos/lib/libssl.a" "iphoneos" "org.openssl.libssl"

composeFramework "libcrypto" "openssl_iphoneos/include/crypto/*.h" \
	"openssl_iphoneos/lib/libcrypto.a" "iphoneos" "org.openssl.libcrypto"

composeFramework "libssh2" "libssh2_iphoneos/include/*.h" \
	"libssh2_iphoneos/lib/libssh2.a" "iphoneos" "org.libssh2.libssh2"

# iphonesimulator

./iSSH2.sh --platform=iphoneos --min-version=14.0 -a "x86_64" --no-clean

composeFramework "libssl" "openssl_iphoneos/include/openssl/*.h" \
	"openssl_iphoneos/lib/libssl.a" "iphonesimulator" "org.openssl.libssl"

composeFramework "libcrypto" "openssl_iphoneos/include/crypto/*.h" \
	"openssl_iphoneos/lib/libcrypto.a" "iphonesimulator" "org.openssl.libcrypto"

composeFramework "libssh2" "libssh2_iphoneos/include/*.h" \
	"libssh2_iphoneos/lib/libssh2.a" "iphonesimulator" "org.libssh2.libssh2"

# xcframeworks

xcodebuild -create-xcframework \
	-framework iphoneos/libssl.framework \
	-framework iphonesimulator/libssl.framework \
	-output libssl.xcframework

xcodebuild -create-xcframework \
	-framework iphoneos/libcrypto.framework \
	-framework iphonesimulator/libcrypto.framework \
	-output libcrypto.xcframework

xcodebuild -create-xcframework \
	-framework iphoneos/libssh2.framework \
	-framework iphonesimulator/libssh2.framework \
	-output libssh2.xcframework

rm -r iphoneos iphonesimulator