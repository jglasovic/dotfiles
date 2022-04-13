#!/bin/sh

# restoring default npm registry from backup files, dev-cli overwrites them
function restore-npmrc(){
  local npmrc_copy=~/.npmrc_copy
  local yarnrc_copy=~/.yarnrc_copy

  local npmrc=~/.npmrc
  local yarnrc=~/.yarnrc
  local yarnrcyml=~/.yarnrc.yml

  check-file-exists $npmrc && \
  { print-red "Removing .npmrc"; rm -rf $npmrc }
  print-red "Adding .npmrc with npm registry"
  cp $npmrc_copy $npmrc

  check-file-exists $yarnrc && \
  { print-red "Removing .yarnrc"; rm -rf $yarnrc }
  check-file-exists $yarnrcyml && \
  { print-red "Removing .yarnrc.yml"; rm -rf $yarnrcyml }

  print-red "Adding .yarnrc with yarnpkg registry"
  cp $yarnrc_copy $yarnrc
}
