#!/bin/bash

# Define variables from Foreman parameters
FOREMAN_HOST="<%= @host.foreman_host || 'foreman.example.com' %>"
ORG="<%= @host.organization.label || 'Default_Organization' %>"
ENVIRONMENT="<%= @host.environment || 'Library' %>"
CONTENT_VIEW="<%= @host.content_view.label || 'Default_Organization_View' %>"
ARCH="x86_64"

# Disable all existing repos
for repo in /etc/yum.repos.d/*.repo; do
    mv "$repo" "$repo.disabled" 2>/dev/null || true
done

# Create base repo for Content View
cat > /etc/yum.repos.d/satellite-cv.repo << EOF
[base]
name=Satellite Content View - Base
baseurl=https://${FOREMAN_HOST}/pulp/repos/${ORG}/${ENVIRONMENT}/${CONTENT_VIEW}/rhel-8-baseos-${ARCH}
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
sslverify=0

[appstream]
name=Satellite Content View - AppStream
baseurl=https://${FOREMAN_HOST}/pulp/repos/${ORG}/${ENVIRONMENT}/${CONTENT_VIEW}/rhel-8-appstream-${ARCH}
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
sslverify=0
EOF

# Install CA certificate (if needed)
cat > /etc/pki/ca-trust/source/anchors/satellite-ca.crt << 'CA_CERT'
<%= File.read('/var/lib/puppet/ssl/certs/ca.pem') rescue '#' * 64 %>
CA_CERT
update-ca-trust extract

# Clean and install packages
yum clean all
yum makecache

# Install packages
PACKAGES="vim-enhanced wget curl bash-completion"
yum install -y $PACKAGES
