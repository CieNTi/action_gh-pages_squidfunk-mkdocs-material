#!/bin/sh
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DESCRIPTION
#   Override default entrypoint to allow full control from GitHub action
#
# MOTIVATION
#   The original entrypoint looks like "/sbin/tini -- mkdocs" and it expects
#   CMD to finish the base call. Because this, there is no way to change
#   the working directory, and GitHub does not yet allow to modify parameters
#   like to set a different workdir.
#   Apart of that, action may allow a "pre-entrypoint", but not locally.
#
# USAGE
#   This entrypoint will listen to some optional environment variables:
#     MKDOCS_WORKDIR: This will be the new working directory
#     MKDOCS_REQSTXT: If defined and found, pip will install these before docs
#
# AUTHORS
#   CieNTi <cienti@cienti.com>
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Be rude with errors
set -e;

# Enters a custom workdir (relative to "/docs" or absolute path)
if [ -n "${MKDOCS_WORKDIR}" ]; then
  cd "${MKDOCS_WORKDIR}";
fi;

# Install custom packages (relative to current workdir or absolute path)
if [ -n "${MKDOCS_REQSTXT}" ]; then
  if [ -f "${MKDOCS_REQSTXT}" ]; then
    echo "INFO: Installing packages from custom requirements file";
    pip install -r "${MKDOCS_REQSTXT}";
  else
    echo "ERROR: Custom requirements file is defined but not found";
    exit 1;
  fi;
fi;

# Mimic the original entrypoint
/sbin/tini -- mkdocs "${@}";
