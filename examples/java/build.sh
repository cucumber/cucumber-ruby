#!/bin/sh
cd `dirname "$0"`
javac src/cucumber/demo/Hello.java && jar cf src/cucumber_demo.jar -C src cucumber/demo/Hello.class