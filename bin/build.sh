#!/bin/bash

project_dir=$(cd $(dirname $0)/.. && pwd)
configuration=Release

cd $project_dir
xcodebuild -workspace SlackMood.xcworkspace -scheme SlackMood -configuration ${configuration} -derivedDataPath ${project_dir}/build clean build
