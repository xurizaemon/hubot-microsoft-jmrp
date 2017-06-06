# Description:
#   Check Microsoft JMRP for our IPs.
#
# Configuration:
#   HUBOT_MICROSOFT_JMRP_KEY - your JMRP key
#   HUBOT_MICROSOFT_JMRP_INFO - a helpful docs URL to print after the report
#
# Commands:
#   hubot jmrp - Show JMRP status.

dns = require('dns')

key = process.env.HUBOT_MICROSOFT_JMRP_KEY
info = process.env.HUBOT_MICROSOFT_JMRP_INFO

module.exports = (robot) ->

  robot.respond /(how'?s )?(jmrp|hotmail)\??/i, (msg) ->
    url = "https://postmaster.live.com/snds/ipStatus.aspx?key=" + key
    msg.send "Checking Microsoft JMRP ..."
    msg.http(url)
      .get() (err, res, body) ->
        if res.statusCode == 400
          msg.send "Bad result - are you sure HUBOT_MICROSOFT_JMRP_KEY is set right?"
        else
          if !res.body
            msg.send "... no servers listed :)"
          else
            [rows...] = body.split("\n").filter(Boolean).map (line) -> line.split ","
            for row, i in rows
              if row[0] == row[1]
                dns.reverse row[0], (err, hostnames) ->
                  msg.send hostnames[0] + ' is ' + row[3]
              else
                msg.send row[0] + '-' + row[1] + ' is ' + row[3]
            if info?
              msg.send info
