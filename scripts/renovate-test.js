#!/usr/bin/env node
const { readFileSync } = require('fs')
const renovate = require(__dirname + '/../renovate.json')
const regex = new RegExp(renovate.regexManagers[0].matchStrings)
const lines = readFileSync('cucumber.gemspec', 'utf-8').split("\n").map(line => 
	[line, (regex.exec(line) || { groups: "" }).groups]
)
console.log(lines)

