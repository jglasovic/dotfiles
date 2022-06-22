#!/bin/sh

# restoring default npm registry from backup files, dev-cli overwrites them
function npmrc-restore(){
  local npmrc_bak=~/.npmrc.bak
  local yarnrc_bak=~/.yarnrc.bak

  local npmrc=~/.npmrc
  local yarnrc=~/.yarnrc
  local yarnrcyml=~/.yarnrc.yml

  check-file-exists $npmrc && \
  { print-red "Removing .npmrc"; rm -rf $npmrc }
  print-red "Adding .npmrc with npm registry"
  cp $npmrc_bak $npmrc

  check-file-exists $yarnrc && \
  { print-red "Removing .yarnrc"; rm -rf $yarnrc }
  check-file-exists $yarnrcyml && \
  { print-red "Removing .yarnrc.yml"; rm -rf $yarnrcyml }

  print-red "Adding .yarnrc with yarnpkg registry"
  cp $yarnrc_bak $yarnrc
}
