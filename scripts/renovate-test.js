#!/usr/bin/env node
const { readFileSync } = require('fs')
const renovate = require('renovate.json')
const regex = renovate.regexManagers.matchStrings
const lines = readFileSync('cucumber.gemspec', 'utf-8').split("\n").map(line => 
	[line, (regex.exec(line) || { groups: "" }).groups]
)
console.log(lines)

