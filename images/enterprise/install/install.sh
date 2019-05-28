#!/bin/bash -aeu

# Create and change into temporary install directory
tmpdir=$(mktemp -d) && cd $tmpdir

# Remove install directory on exit
trap "rm -rf $tmpdir" EXIT

# Set variables
files=Base
languages=
repo=$1
version=$2
disk1='Linux/Server/Siebel_Enterprise_Server/Disk1'

shift 2

# Remaining command line arguments are languages
for lang in $(echo "${@,,}" | grep -Eo '[a-z]{3}'); do

  case $lang in
    'ara') name='Arabic';;
    'chs') name='Simplified Chinese';;
    'cht') name='Traditional Chinese';;
    'csy') name='Czech';;
    'dan') name='Danish';;
    'deu') name='German';;
    'enu') name='English';;
    'esn') name='Spanish';;
    'fin') name='Finnish';;
    'fra') name='French';;
    'heb') name='Hebrew';;
    'ita') name='Italian';;
    'jpn') name='Japanese';;
    'kor') name='Korean';;
    'nld') name='Dutch';;
    'plk') name='Polish';;
    'ptb') name='Brazilian Portuguese';;
    'ptg') name='Portuguese';;
    'rus') name='Russian';;
    'sve') name='Swedish';;
    'tha') name='Thai';;
    'trk') name='Turkish';;
    *) die "%s is not a supported language!" >&2; exit 1;;
  esac

  echo "Adding language $lang ($name)..."

  # Add language
  files+=",$lang"
  languages+="${languages:+, }$name"
done

# Create url pattern for curl
url="${repo}/SBA_${version}_{${files}}_Linux_Siebel_Enterprise_Server.jar"

echo "Downloading files using URL pattern: $url"

# Download files, unzip and remove
for jar in $(curl -fL#O "$url" --write-out '%{filename_effective}\n'); do
  if [[ -f $jar ]]; then
    echo "Unzipping $jar..."
    unzip -qn $jar
    rm -fv $jar
  fi
done

# Check for disk1 directory
[[ -d $disk1 ]] || die "Disk1 directory not found. Something went wrong with download process!"

# Change into Disk1 directory
cd "$disk1"

# Add execute permissions
chmod -Rc +x install

# Export variables
export $(grep '^SIEBEL_VERSION=' install/oraparam.ini)
export WITH_DBSRVR=${WITH_DBSRVR:-'false'}
export SELECTED_LANGS=${languages}
export DEBUG=1

# Keystore file location and password, for installation only
export KEYSTORE=${KEYSTORE:-'/tmp/keystore.jks'}
export KEYSTORE_PASSWORD=${KEYSTORE_PASSWORD:-'changeit'}

# Truststore file location and password, for installation only
export TRUSTSTORE=${KEYSTORE:-'/tmp/truststore.jks'}
export TRUSTSTORE_PASSWORD=${KEYSTORE_PASSWORD:-'changeit'}

# Create keystore from scratch, if it doesn't exist
[[ -f $KEYSTORE ]] || keytool \
  -genkeypair -keystore $KEYSTORE -alias siebel -dname "CN=siebel" \
  -keypass "$KEYSTORE_PASSWORD" -storepass "$KEYSTORE_PASSWORD"

# Copy keystore to truststore, if it doesn't exist
[[ -f $TRUSTSTORE ]] || cp $KEYSTORE $TRUSTSTORE

# Populate (and display) response file from template
file-from-template $HOME/install_rsp.tmpl $PWD/install.rsp

# Install Siebel
install/runInstaller -silent -waitforcompletion -responseFile $PWD/install.rsp -invPtrLoc $HOME/orainst.loc

# Wait for 30 seconds so Tomcat can finish deploying WAR file
echo 'Sleeping for 30 seconds...'; sleep 30

# Change to Oracle home
$CATALINA_HOME/bin/shutdown.sh || true
