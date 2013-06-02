vdf = require './vdf.coffee'

fs = require 'fs'
# process = require 'process'
_ = require 'underscore'

# TODO: figure out the node equivalent of `if __name__ == '__main__'`
if process.argv[0] == 'node' or 'coffee'
  process.argv.shift()
data = fs.readFileSync process.argv[1]


parsed = vdf._parse data.toString()
# console.log parsed[0]['Resource/HudLayout.res'].AchievementNotificationPanel
# console.log parsed#[0]

if process.argv.length > 2
  fs.writeFileSync process.argv[2], JSON.stringify(parsed[0])
else
  console.log parsed[0]
