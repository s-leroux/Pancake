#!/usr/bin/env coffee

fs          = require 'fs'
coffee      = require 'coffee-script'
helpers     = require './helpers'


tasks = {}
tasks_list = []

# The build targets
targets = []

build_list = []

helpers.extend global,
    target: (name, attr) ->
        tasks_list.push(name)
        tasks[name] = attr

helpers.extend global, (require './actions').actions

buildTree = ->
    while targets.length
        target = targets.shift()
        task = tasks[target]
        { disabled, depends } = task

        if not disabled
            task['disabled'] = true
            build_list.push target
            if depends
                targets = depends.concat targets

doActions = ->
    for target in build_list
        { action } = tasks[target]
        action() if action

main = ->
    if targets.length
        buildTree()
        doActions()
        # console.log build_list
    else # no target
        console.log('Pancake build system')
        for name in tasks_list
            console.log "\t#{name}\t\t#{tasks[name].desc}"

# First load the `Pancakefile`
pancakefile = './Pancakefile'

targets = process.argv[2..]

fs.readFile pancakefile, 'utf-8', (err, data) ->
    throw err if err
    coffee.run data
    main()

