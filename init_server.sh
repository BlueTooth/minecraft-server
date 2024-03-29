#!/bin/sh
VERSION_FILE=version.txt

touch $VERSION_FILE
VERSION_INSTALLED=$(head -n 1 $VERSION_FILE)
echo installed minecraft-server-version $VERSION_INSTALLED

echo search minecraft-server-version...
VERSION=`wget -qO- https://launchermeta.mojang.com/mc/game/version_manifest.json | sed -n -e 's/.*release\": \"\([1-9.]*\).*/\1/p'`
echo found minecraft-server-version $VERSION

if [ "$VERSION" = "" ]
then
 echo version not available
elif [ "$VERSION" != "$VERSION_INSTALLED" ]
then
 echo newer version available...
 echo doing update $VERSION_INSTALLED to $VERSION

 echo search download url...
 MANIFEST_URL=`wget -qO- https://launchermeta.mojang.com/mc/game/version_manifest.json | sed -n -e 's/release\", \"url\": \"\([a-z:/.0-9-]*\).*/\1/p'`
 echo "mf url = $MANIFEST_URL" 
 JSON_URL=`echo $MANIFEST_URL | sed -n -e 's/.*\"\([a-z:/.0-9-]*\)/\1/p'`
 echo "j url = $JSON_URL"
 URL=`wget -qO- $JSON_URL | sed -n -e 's/.*\"\([a-z:/.0-9-]*server\.jar\).*/\1/p'`
 if [ "$URL" = "" ]
 then
  echo url not available
 else
  echo download minecraft-server-$VERSION.jar from $URL
  wget -q --output-document=minecraft_server.jar $URL
  echo saved in /data/minecraft_server.jar

  echo accept eula
  echo eula=true > eula.txt

  echo $VERSION > $VERSION_FILE
 fi
fi

echo start minecraft_server
java -Xmx4096M -Xms4096M -jar minecraft_server.jar
