mv vsphere-plugin.zip vsphere-plugin-old.zip
# Download the plugin (replace URL with the actual download link)
curl -LOk https://10.122.0.1/wcp/plugin/linux-amd64/vsphere-plugin.zip
#curl -LOk https://<vcenter-server>/wcp/plugin/linux-amd64/vsphere-plugin.zip

git add -A
git commit -m "$(date +'%Y%m%d')"
git push


#BINDIR=/usr/local/bin
# Extract the plugin
#unzip vsphere-plugin.zip
# Add to PATH (adjust the path as needed)
#export PATH=$PATH:$BINDIR
# Verify the installation
#kubectl vsphere
